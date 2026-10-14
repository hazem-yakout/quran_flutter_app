import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'package:quran/presentation/auth/pages/signup.dart';
import 'package:quran/presentation/mode/pages/choose_quran_mode.dart';

class SigninPage extends StatefulWidget {
const SigninPage({super.key});

@override
State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
final emailController = TextEditingController();
final passwordController = TextEditingController();

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

bool isLoading = false;
bool obscurePassword = true;

@override
void dispose() {
emailController.dispose();
passwordController.dispose();
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

// Email and Password Sign In
Future<void> signin() async {
final email = emailController.text.trim();
final password = passwordController.text;

if (email.isEmpty || password.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Please fill all fields'),
),
);
return;
}

setState(() => isLoading = true);

try {
await firebaseAuth.signInWithEmailAndPassword(
email: email,
password: password,
);

if (!mounted) return;
goToChooseQuranMode();
} on FirebaseAuthException catch (e) {
if (!mounted) return;

String message;

switch (e.code) {
case 'invalid-credential':
case 'wrong-password':
case 'user-not-found':
message = 'Email or password is incorrect.';
break;
case 'invalid-email':
message = 'Please enter a valid email address.';
break;
case 'user-disabled':
message = 'This account has been disabled.';
break;
case 'too-many-requests':
message = 'Too many attempts. Please try again later.';
break;
case 'network-request-failed':
message = 'Check your internet connection.';
break;
case 'operation-not-allowed':
message = 'Email/Password sign-in is not enabled in Firebase.';
break;
default:
message = e.message ?? 'Sign in failed: ${e.code}';
}

debugPrint('Sign In Error: ${e.code}');
debugPrint('Sign In Message: ${e.message}');

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text(message)),
);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Sign in failed: $e')),
);
} finally {
if (mounted) {
setState(() => isLoading = false);
}
}
}

// Google Sign In
Future<void> signInWithGoogle() async {
setState(() => isLoading = true);

try {
final googleSignIn = GoogleSignIn.instance;

await googleSignIn.initialize();

final googleUser = await googleSignIn.authenticate();
final googleAuth = googleUser.authentication;

final credential = GoogleAuthProvider.credential(
idToken: googleAuth.idToken,
);

await firebaseAuth.signInWithCredential(credential);

if (!mounted) return;
goToChooseQuranMode();
} on FirebaseAuthException catch (e) {
if (!mounted) return;

debugPrint('Google Firebase Error: ${e.code}');

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
'Google Sign In failed: ${e.message ?? e.code}',
),
),
);
} catch (e) {
if (!mounted) return;

debugPrint('Google Sign In Error: $e');

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Google Sign In failed: $e')),
);
} finally {
if (mounted) {
setState(() => isLoading = false);
}
}
}

// Facebook Sign In
Future<void> signInWithFacebook() async {
setState(() => isLoading = true);

try {
final result = await FacebookAuth.instance.login(
permissions: ['email', 'public_profile'],
);

if (result.status != LoginStatus.success ||
result.accessToken == null) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
result.message ?? 'Facebook Sign In cancelled',
),
),
);
return;
}

final credential = FacebookAuthProvider.credential(
result.accessToken!.tokenString,
);

await firebaseAuth.signInWithCredential(credential);

if (!mounted) return;
goToChooseQuranMode();
} on FirebaseAuthException catch (e) {
if (!mounted) return;

debugPrint('Facebook Firebase Error: ${e.code}');

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
'Facebook Sign In failed: ${e.message ?? e.code}',
),
),
);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Facebook Sign In failed: $e')),
);
} finally {
if (mounted) {
setState(() => isLoading = false);
}
}
}

// Forgot Password
Future<void> forgotPassword() async {
final email = emailController.text.trim();

if (email.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Enter your email first'),
),
);
return;
}

try {
await firebaseAuth.sendPasswordResetEmail(email: email);

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'If an eligible account exists, a reset email will be sent.',
),
),
);
} on FirebaseAuthException catch (e) {
if (!mounted) return;

debugPrint('Password Reset Error: ${e.code}');

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
e.message ?? 'Unable to send password reset email',
),
),
);
}
}

// Add a password to the currently signed-in Google account
Future<void> setPasswordForGoogleAccount() async {
final user = firebaseAuth.currentUser;

if (user == null || user.email == null) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Please sign in with Google first'),
),
);
return;
}

final hasPassword = user.providerData.any(
(provider) => provider.providerId == 'password',
);

if (hasPassword) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('This account already has a password'),
),
);
return;
}

final newPasswordController = TextEditingController();
final confirmPasswordController = TextEditingController();

final passwords = await showDialog<List<String>>(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: const Text('Create a password'),
content: Column(
mainAxisSize: MainAxisSize.min,
children: [
TextField(
controller: newPasswordController,
obscureText: true,
decoration: const InputDecoration(
labelText: 'New password',
),
),
const SizedBox(height: 12),
TextField(
controller: confirmPasswordController,
obscureText: true,
decoration: const InputDecoration(
labelText: 'Confirm password',
),
),
],
),
actions: [
TextButton(
onPressed: () => Navigator.pop(dialogContext),
child: const Text('Cancel'),
),
ElevatedButton(
onPressed: () {
final password = newPasswordController.text;

if (password.length < 6 ||
password != confirmPasswordController.text) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Passwords must match and be at least 6 characters',
),
),
);
return;
}

Navigator.pop(dialogContext, [password]);
},
child: const Text('Save password'),
),
],
);
},
);

final password =
passwords == null ? null : passwords.first;

newPasswordController.dispose();
confirmPasswordController.dispose();

if (password == null || !mounted) return;

setState(() => isLoading = true);

try {
// Refresh the current user before linking credentials.
await user.reload();

final currentUser = firebaseAuth.currentUser;

if (currentUser == null || currentUser.email == null) {
throw FirebaseAuthException(
code: 'user-not-found',
message: 'Please sign in again.',
);
}

final credential = EmailAuthProvider.credential(
email: currentUser.email!,
password: password,
);

await currentUser.linkWithCredential(credential);

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Password added successfully! You can now sign in with email and password.',
),
),
);
} on FirebaseAuthException catch (e) {
if (!mounted) return;

debugPrint('Link Password Error: ${e.code}');
debugPrint('Link Password Message: ${e.message}');

String message;

if (e.code == 'credential-already-in-use' ||
e.code == 'email-already-in-use') {
message =
'This email is already linked to another account. The accounts must be handled separately.';
} else if (e.code == 'provider-already-linked') {
message = 'This account already has a password provider.';
} else {
message = e.message ?? 'Could not add password: ${e.code}';
}

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text(message)),
);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Could not add password: $e')),
);
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
title: const Text('Sign In'),
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
'Welcome Back',
style: TextStyle(
color: textColor,
fontSize: 28,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 10),

Text(
'Sign in to continue',
textAlign: TextAlign.center,
style: TextStyle(
color: textColor,
fontSize: 16,
),
),

const SizedBox(height: 35),

TextField(
controller: emailController,
keyboardType: TextInputType.emailAddress,
enabled: !isLoading,
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

TextField(
controller: passwordController,
obscureText: obscurePassword,
enabled: !isLoading,
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

const SizedBox(height: 10),

Align(
alignment: Alignment.centerRight,
child: TextButton(
onPressed: isLoading ? null : forgotPassword,
child: const Text('Forgot Password?'),
),
),

const SizedBox(height: 15),

SizedBox(
width: double.infinity,
height: 55,
child: ElevatedButton(
onPressed: isLoading ? null : signin,
child: isLoading
? const SizedBox(
width: 25,
height: 25,
child: CircularProgressIndicator(
strokeWidth: 2,
),
)
    : const Text('Sign In'),
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

SizedBox(
width: double.infinity,
height: 55,
child: OutlinedButton.icon(
onPressed: isLoading ? null : signInWithGoogle,
icon: const Icon(
Icons.g_mobiledata,
size: 30,
),
label: const Text('Continue with Google'),
),
),

const SizedBox(height: 8),

TextButton(
onPressed:
isLoading ? null : setPasswordForGoogleAccount,
child: const Text(
'Create a password for my Google account',
textAlign: TextAlign.center,
),
),

const SizedBox(height: 8),

SizedBox(
width: double.infinity,
height: 55,
child: OutlinedButton.icon(
onPressed: isLoading ? null : signInWithFacebook,
icon: const Icon(Icons.facebook),
label: const Text('Continue with Facebook'),
),
),

const SizedBox(height: 25),

Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Text(
"Don't have an account?",
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
const SignupPage(),
),
);
},
child: const Text(
'Sign Up',
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