import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:quran/domain/usecases/auth/signin_user.dart';
import 'package:quran/presentation/auth/pages/signup.dart';
import 'package:quran/presentation/root/pages/root.dart';
import 'package:quran/service_locator.dart';


class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // =========================
  // GO TO ROOT
  // =========================

  void goToRoot() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Root(),
      ),
    );
  }

  // =========================
  // EMAIL / PASSWORD SIGN IN
  // =========================

  Future<void> signin() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await sl<SigninUser>()(
        params: SigninParams(
          email: emailController.text.trim(),
          password: passwordController.text,
        ),
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      result.fold(
            (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
            ),
          );
        },
            (message) {
          goToRoot();
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  // =========================
  // GOOGLE SIGN IN
  // =========================

  Future<void> signInWithGoogle() async {
    setState(() {
      isLoading = true;
    });

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

      await firebaseAuth.signInWithCredential(
        credential,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      goToRoot();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Google Sign In failed: $e',
          ),
        ),
      );
    }
  }

  // =========================
  // FACEBOOK SIGN IN
  // =========================

  Future<void> signInWithFacebook() async {
    setState(() {
      isLoading = true;
    });

    try {
      final LoginResult result =
      await FacebookAuth.instance.login(
        permissions: [
          'email',
          'public_profile',
        ],
        loginTracking: LoginTracking.enabled,
      );

      if (result.status != LoginStatus.success ||
          result.accessToken == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message ??
                  'Facebook Sign In cancelled',
            ),
          ),
        );

        return;
      }

      final credential =
      FacebookAuthProvider.credential(
        result.accessToken!.tokenString,
      );

      await firebaseAuth.signInWithCredential(
        credential,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      goToRoot();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Facebook Sign In failed: $e',
          ),
        ),
      );
    }
  }

  // =========================
  // FORGOT PASSWORD
  // =========================

  Future<void> forgotPassword() async {
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter your email first',
          ),
        ),
      );
      return;
    }

    try {
      await firebaseAuth.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset email sent',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Something went wrong',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        actions: [
          Icon(
            Icons.menu_book,
            color:
            Theme.of(context).brightness == Brightness.dark
                ? Colors.greenAccent
                : Colors.green,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
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

              // EMAIL
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // PASSWORD
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword =
                        !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // FORGOT PASSWORD
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: forgotPassword,
                  child: const Text(
                    'Forgot Password?',
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // SIGN IN
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed:
                  isLoading ? null : signin,
                  child: isLoading
                      ? const SizedBox(
                    width: 25,
                    height: 25,
                    child:
                    CircularProgressIndicator(),
                  )
                      : const Text(
                    'Sign In',
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // OR
              const Row(
                children: [
                  Expanded(
                    child: Divider(),
                  ),
                  Padding(
                    padding:
                    EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    child: Text('OR'),
                  ),
                  Expanded(
                    child: Divider(),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // GOOGLE
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : signInWithGoogle,
                  icon: const Icon(
                    Icons.g_mobiledata,
                    size: 30,
                  ),
                  label: const Text(
                    'Continue with Google',
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // FACEBOOK
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : signInWithFacebook,
                  icon: const Icon(
                    Icons.facebook,
                  ),
                  label: const Text(
                    'Continue with Facebook',
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // SIGN UP
              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
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
                    onPressed: () {
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
                        fontWeight:
                        FontWeight.bold,
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