import 'package:flutter/material.dart';
import 'package:quran/presentation/auth/pages/signin.dart';
import 'package:quran/presentation/auth/pages/signup.dart';

class SigninOrSignup extends StatelessWidget {
  const SigninOrSignup({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),

              Text(
                'Welcome',
                style: TextStyle(
                  color: textColor,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Sign in or create a new account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const SigninPage(),
                      ),
                    );
                  },
                  child: const Text('Sign In'),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const SignupPage(),
                      ),
                    );
                  },
                  child: const Text('Register'),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}