import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'package:quran/presentation/auth/pages/signin.dart';
import 'package:quran/presentation/mode/pages/choose_quran_mode.dart';

import 'package:quran/data/models/auth/create_user.dart';
import 'package:quran/domain/usecases/auth/signup_user.dart';
import 'package:quran/service_locator.dart';

class SignupPage extends StatefulWidget {
const SignupPage({super.key});

@override
State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
final fullnameController = TextEditingController();
final emailController = TextEditingController();
final passwordController = TextEditingController();
final confirmPasswordController = TextEditingController();

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

bool isLoading = false;
bool obscurePassword = true;
bool obscureConfirmPassword = true;

@override
void dispose() {
fullnameController.dispose();
emailController.dispose();
passwordController.dispose();
confirmPasswordController.dispose();
super.dispose();
}

void goToChooseQuranMode() {
Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (context) => const ChooseQuranModePage(),
),
);
}

void showMessage(String message) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text(message)),
);
}

// Sign up with Email and Password
Future<void> signup() async {
final fullname = fullnameController.text.trim();
final email = emailController.text.trim();
final password = passwordController.text;
final confirmPassword = confirmPasswordController.text;

if (fullname.isEmpty ||
email.isEmpty ||
password.isEmpty ||
confirmPassword.isEmpty) {
showMessage('Please fill all fields');
return;
}

if (password.length < 6) {
showMessage('Password must be at least 6 characters');
return;
}

if (password != confirmPassword) {
showMessage('Passwords do not match');
return;
}

setState(() => isLoading = true);

try {
final result = await sl<SignupUser>()(
params: CreateUserReq(
fullname: fullname,
email: email,
password: password,
),
);

if (!mounted) return;

result.fold(
(error) {
showMessage(error.toString());
},
(message) {
goToChooseQuranMode();
},
);
} catch (e) {
if (!mounted) return;
showMessage('Sign up failed: $e');
} finally {
if (mounted) {
setState(() => isLoading = false);
}
}
}

// Sign in with Google.
// If an account is already signed in, link Google to that account.
Future<void> signUpWithGoogle() async {
setState(() => isLoading = true);

try {
final GoogleSignIn googleSignIn = GoogleSignIn.instance;

await googleSignIn.initialize();

final GoogleSignInAccount googleUser =
await googleSignIn.authenticate();

final GoogleSignInAuthentication googleAuth =
googleUser.authentication;

final credential = GoogleAuthProvider.credential(
idToken: googleAuth.idToken,
);

final currentUser = firebaseAuth.currentUser;
late final UserCredential userCredential;

if (currentUser != null) {
// Link Google to the currently signed-in account.
userCredential =
await currentUser.linkWithCredential(credential);
} else {
// No signed-in user: sign in with Google normally.
userCredential =
await firebaseAuth.signInWithCredential(credential);
}

final fullname = fullnameController.text.trim();

if (fullname.isNotEmpty &&
(userCredential.user?.displayName == null ||
userCredential.user!.displayName!.isEmpty)) {
await userCredential.user?.updateDisplayName(fullname);
}

if (!mounted) return;

goToChooseQuranMode();
} on FirebaseAuthException catch (e) {
if (!mounted) return;

String message;

switch (e.code) {
case 'credential-already-in-use':
message =
'This Google account is already linked to another account.';
break;
case 'provider-already-linked':
message = 'Google is already linked to this account.';
break;
case 'account-exists-with-different-credential':
message =
'An account already exists with this email. Sign in using its original method first.';
break;
case 'requires-recent-login':
message = 'Please sign in again and retry.';
break;
default:
message = 'Google authentication failed: '
'${e.message ?? e.code}';
}

showMessage(message);
} catch (e) {
if (!mounted) return;
showMessage('Google Sign Up failed: $e');
} finally {
if (mounted) {
setState(() => isLoading = false);
}
}
}

// Add Email and Password to the currently signed-in Google account.
Future<void> addPasswordToGoogleAccount() async {
final user = firebaseAuth.currentUser;

if (user == null || user.email == null) {
showMessage('Please sign in with Google first.');
return;
}

final alreadyLinked = user.providerData.any(
(provider) => provider.providerId == 'password',
);

if (alreadyLinked) {
showMessage('Email and password are already linked.');
return;
}

final password = passwordController.text;

if (password.length < 6) {
showMessage('Enter a password of at least 6 characters.');
return;
}

setState(() => isLoading = true);

try {
final credential = EmailAuthProvider.credential(
email: user.email!,
password: password,
);

await user.linkWithCredential(credential);

if (!mounted) return;

showMessage('Password linked successfully!');
} on FirebaseAuthException catch (e) {
if (!mounted) return;

String message;

switch (e.code) {
case 'provider-already-linked':
message = 'Email and password are already linked.';
break;
case 'email-already-in-use':
case 'credential-already-in-use':
message =
'This email/password credential is already used by another account.';
break;
case 'weak-password':
message = 'Please choose a stronger password.';
break;
case 'requires-recent-login':
message = 'Please sign in again and retry.';
break;
default:
message = 'Failed to link password: '
'${e.message ?? e.code}';
}

showMessage(message);
} catch (e) {
if (!mounted) return;
showMessage('Failed to link password: $e');
} finally {
if (mounted) {
setState(() => isLoading = false);
}
}
}

// Sign in with Facebook
Future<void> signUpWithFacebook() async {
setState(() => isLoading = true);

try {
final LoginResult result = await FacebookAuth.instance.login(
permissions: ['email', 'public_profile'],
);

if (result.status != LoginStatus.success ||
result.accessToken == null) {
if (!mounted) return;

showMessage(
result.message ?? 'Facebook Sign Up cancelled',
);
return;
}

final credential = FacebookAuthProvider.credential(
result.accessToken!.tokenString,
);

final currentUser = firebaseAuth.currentUser;
late final UserCredential userCredential;

if (currentUser != null) {
userCredential =
await currentUser.linkWithCredential(credential);
} else {
userCredential =
await firebaseAuth.signInWithCredential(credential);
}

final fullname = fullnameController.text.trim();

if (fullname.isNotEmpty &&
(userCredential.user?.displayName == null ||
userCredential.user!.displayName!.isEmpty)) {
await userCredential.user?.updateDisplayName(fullname);
}

if (!mounted) return;

goToChooseQuranMode();
} on FirebaseAuthException catch (e) {
if (!mounted) return;
showMessage(
'Facebook authentication failed: ${e.message ?? e.code}',
);
} catch (e) {
if (!mounted) return;
showMessage('Facebook Sign Up failed: $e');
} finally {
if (mounted) {
setState(() => isLoading = false);
}
}
}

@override
Widget build(BuildContext context) {
final textColor = Theme.of(context).textTheme.bodyLarge?.color;

return Scaffold(
appBar: AppBar(
title: const Text('Sign Up'),
actions: [
Icon(
Icons.menu_book,
color: Theme.of(context).brightness == Brightness.dark
? Colors.greenAccent
    : Colors.green,
),
const SizedBox(width: 16),
],
),
body: SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.symmetric(horizontal: 24),
child: Column(
children: [
const SizedBox(height: 30),
Text(
'Create Account',
style: TextStyle(
color: textColor,
fontSize: 28,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 10),
Text(
'Sign up to get started',
textAlign: TextAlign.center,
style: TextStyle(
color: textColor,
fontSize: 16,
),
),
const SizedBox(height: 35),

// Full name
TextField(
controller: fullnameController,
textCapitalization: TextCapitalization.words,
decoration: InputDecoration(
labelText: 'Full Name',
hintText: 'Enter your full name',
prefixIcon: const Icon(Icons.person_outline),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
),
),
),
const SizedBox(height: 20),

// Email
TextField(
controller: emailController,
keyboardType: TextInputType.emailAddress,
decoration: InputDecoration(
labelText: 'Email',
hintText: 'Enter your email',
prefixIcon: const Icon(Icons.email_outlined),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
),
),
),
const SizedBox(height: 20),

// Password
TextField(
controller: passwordController,
obscureText: obscurePassword,
decoration: InputDecoration(
labelText: 'Password',
hintText: 'Enter your password',
prefixIcon: const Icon(Icons.lock_outline),
suffixIcon: IconButton(
onPressed: () {
setState(() {
obscurePassword = !obscurePassword;
});
},
icon: Icon(
obscurePassword
? Icons.visibility_outlined
    : Icons.visibility_off_outlined,
),
),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
),
),
),
const SizedBox(height: 20),

// Confirm password
TextField(
controller: confirmPasswordController,
obscureText: obscureConfirmPassword,
decoration: InputDecoration(
labelText: 'Confirm Password',
hintText: 'Re-enter your password',
prefixIcon: const Icon(Icons.lock_outline),
suffixIcon: IconButton(
onPressed: () {
setState(() {
obscureConfirmPassword =
!obscureConfirmPassword;
});
},
icon: Icon(
obscureConfirmPassword
? Icons.visibility_outlined
    : Icons.visibility_off_outlined,
),
),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
),
),
),
const SizedBox(height: 25),

// Create account
SizedBox(
width: double.infinity,
height: 55,
child: ElevatedButton(
onPressed: isLoading ? null : signup,
child: isLoading
? const SizedBox(
width: 25,
height: 25,
child: CircularProgressIndicator(),
)
    : const Text('Create Account'),
),
),
const SizedBox(height: 25),

const Row(
children: [
Expanded(child: Divider()),
Padding(
padding: EdgeInsets.symmetric(horizontal: 15),
child: Text('OR'),
),
Expanded(child: Divider()),
],
),
const SizedBox(height: 25),

// Google
SizedBox(
width: double.infinity,
height: 55,
child: OutlinedButton.icon(
onPressed: isLoading ? null : signUpWithGoogle,
icon: const Icon(
Icons.g_mobiledata,
size: 30,
),
label: const Text('Continue with Google'),
),
),
const SizedBox(height: 15),

// Facebook
SizedBox(
width: double.infinity,
height: 55,
child: OutlinedButton.icon(
onPressed: isLoading ? null : signUpWithFacebook,
icon: const Icon(Icons.facebook),
label: const Text('Continue with Facebook'),
),
),
const SizedBox(height: 25),

Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Text(
'Already have an account?',
style: TextStyle(
color: Theme.of(context)
    .textTheme
    .bodyMedium
    ?.color,
),
),
TextButton(
onPressed: isLoading
? null
    : () {
Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (context) =>
const SigninPage(),
),
);
},
child: const Text(
'Sign In',
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
),
],
),
const SizedBox(height: 20),
],
),
),
),
);
}
}
