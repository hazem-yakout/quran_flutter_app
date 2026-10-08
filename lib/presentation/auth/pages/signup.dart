import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'package:quran/presentation/auth/pages/signin.dart';
import 'package:quran/presentation/choose_reciter/pages/choose_reciter.dart';

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

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final FirebaseAuth firebaseAuth =
      FirebaseAuth.instance;

  @override
  void dispose() {
    fullnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  // =========================
  // GO TO CHOOSE RECITER
  // =========================

  void goToChooseReciter() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const ChooseReciterPage(),
      ),
    );
  }

  // =========================
  // EMAIL / PASSWORD SIGN UP
  // =========================

  Future<void> signup() async {
    if (fullnameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all fields',
          ),
        ),
      );

      return;
    }

    if (passwordController.text !=
        confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Passwords do not match',
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await sl<SignupUser>()(
        params: CreateUserReq(
          fullname:
          fullnameController.text.trim(),
          email:
          emailController.text.trim(),
          password:
          passwordController.text,
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
              content: Text(
                error.toString(),
              ),
            ),
          );
        },
            (message) {
          goToChooseReciter();
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  // =========================
  // GOOGLE SIGN UP
  // =========================

  Future<void> signUpWithGoogle() async {
    setState(() {
      isLoading = true;
    });

    try {
      final GoogleSignIn googleSignIn =
          GoogleSignIn.instance;

      await googleSignIn.initialize();

      final GoogleSignInAccount googleUser =
      await googleSignIn.authenticate();

      final GoogleSignInAuthentication
      googleAuth =
          googleUser.authentication;

      final credential =
      GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await firebaseAuth
          .signInWithCredential(
        credential,
      );

      if (userCredential.user != null &&
          fullnameController.text
              .trim()
              .isNotEmpty) {
        await userCredential.user!
            .updateDisplayName(
          fullnameController.text.trim(),
        );
      }

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      goToChooseReciter();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Google Sign Up failed: $e',
          ),
        ),
      );
    }
  }

  // =========================
  // FACEBOOK SIGN UP
  // =========================

  Future<void> signUpWithFacebook() async {
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
        loginTracking:
        LoginTracking.enabled,
      );

      if (result.status !=
          LoginStatus.success ||
          result.accessToken == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message ??
                  'Facebook Sign Up cancelled',
            ),
          ),
        );

        return;
      }

      final credential =
      FacebookAuthProvider.credential(
        result.accessToken!.tokenString,
      );

      final userCredential =
      await firebaseAuth
          .signInWithCredential(
        credential,
      );

      if (userCredential.user != null &&
          fullnameController.text
              .trim()
              .isNotEmpty) {
        await userCredential.user!
            .updateDisplayName(
          fullnameController.text.trim(),
        );
      }

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      goToChooseReciter();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Facebook Sign Up failed: $e',
          ),
        ),
      );
    }
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context)
        .textTheme
        .bodyLarge
        ?.color;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign Up',
        ),

        actions: [
          Icon(
            Icons.menu_book,
            color:
            Theme.of(context).brightness ==
                Brightness.dark
                ? Colors.greenAccent
                : Colors.green,
          ),

          const SizedBox(
            width: 16,
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 24,
          ),

          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),

              Text(
                'Create Account',

                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                'Create your account to continue',

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                ),
              ),

              const SizedBox(
                height: 35,
              ),

              // =========================
              // FULL NAME
              // =========================

              TextField(
                controller:
                fullnameController,

                keyboardType:
                TextInputType.name,

                decoration:
                InputDecoration(
                  labelText: 'Full Name',
                  hintText:
                  'Enter your full name',

                  prefixIcon:
                  const Icon(
                    Icons.person_outline,
                  ),

                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // =========================
              // EMAIL
              // =========================

              TextField(
                controller:
                emailController,

                keyboardType:
                TextInputType.emailAddress,

                decoration:
                InputDecoration(
                  labelText: 'Email',
                  hintText:
                  'Enter your email',

                  prefixIcon:
                  const Icon(
                    Icons.email_outlined,
                  ),

                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // =========================
              // PASSWORD
              // =========================

              TextField(
                controller:
                passwordController,

                obscureText:
                obscurePassword,

                decoration:
                InputDecoration(
                  labelText: 'Password',
                  hintText:
                  'Create a password',

                  prefixIcon:
                  const Icon(
                    Icons.lock_outline,
                  ),

                  suffixIcon:
                  IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword =
                        !obscurePassword;
                      });
                    },

                    icon: Icon(
                      obscurePassword
                          ? Icons
                          .visibility_outlined
                          : Icons
                          .visibility_off_outlined,
                    ),
                  ),

                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // =========================
              // CONFIRM PASSWORD
              // =========================

              TextField(
                controller:
                confirmPasswordController,

                obscureText:
                obscureConfirmPassword,

                decoration:
                InputDecoration(
                  labelText:
                  'Confirm Password',

                  hintText:
                  'Confirm your password',

                  prefixIcon:
                  const Icon(
                    Icons.lock_outline,
                  ),

                  suffixIcon:
                  IconButton(
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword =
                        !obscureConfirmPassword;
                      });
                    },

                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons
                          .visibility_outlined
                          : Icons
                          .visibility_off_outlined,
                    ),
                  ),

                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              // =========================
              // CREATE ACCOUNT
              // =========================

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed:
                  isLoading
                      ? null
                      : signup,

                  child: isLoading
                      ? const SizedBox(
                    width: 25,
                    height: 25,

                    child:
                    CircularProgressIndicator(),
                  )
                      : const Text(
                    'Create Account',
                  ),
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              // =========================
              // OR
              // =========================

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

                    child: Text(
                      'OR',
                    ),
                  ),

                  Expanded(
                    child: Divider(),
                  ),
                ],
              ),

              const SizedBox(
                height: 25,
              ),

              // =========================
              // GOOGLE
              // =========================

              SizedBox(
                width: double.infinity,
                height: 55,

                child:
                OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : signUpWithGoogle,

                  icon: const Icon(
                    Icons.g_mobiledata,
                    size: 30,
                  ),

                  label: const Text(
                    'Sign up with Google',
                  ),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              // =========================
              // FACEBOOK
              // =========================

              SizedBox(
                width: double.infinity,
                height: 55,

                child:
                OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : signUpWithFacebook,

                  icon: const Icon(
                    Icons.facebook,
                  ),

                  label: const Text(
                    'Sign up with Facebook',
                  ),
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              // =========================
              // SIGN IN
              // =========================

              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,

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
                    onPressed: () {
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
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}