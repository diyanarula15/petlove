import 'package:flutter/material.dart';
import 'package:petlove/utils/authentication.dart';
import 'package:petlove/widgets/google_sign_in_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 7, 21, 32),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Row(),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Image.asset(
                        'assets/petcare_image.PNG',
                        height: 200,
                        fit: BoxFit.fill,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'PetCare',
                      style: TextStyle(
                        color: Color.fromARGB(255, 4, 50, 88),
                        fontSize: 40,
                      ),
                    ),
                    const Text(
                      'Authentication',
                      style: TextStyle(
                        color: Color.fromARGB(255, 66, 152, 173),
                        fontSize: 40,
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder(
                future: Authentication.initializeFirebase(context: context),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Error initializing Firebase');
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    return const GoogleSignInButton();
                  }
                  return const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromARGB(255, 65, 231, 14),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
