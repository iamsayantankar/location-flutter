import 'package:flutter/material.dart';
import '../utils/services/global.dart';
import 'package:sd_project/components/components.dart';
import 'package:sd_project/screens/login_screen.dart';
import 'package:sd_project/screens/signup_screen.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({Key? key}) : super(key: key);

  @override
  _EntryScreenState createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  // Get the current theme brightness (dark or light mode)
  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      brightness == Brightness.dark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Display top screen image
              const TopScreenImage(screenImageName: 'home.jpg'),
              Expanded(
                child: Padding(
                  padding:
                  const EdgeInsets.only(right: 15.0, left: 15, bottom: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Welcome title
                      ScreenTitle(
                        title: 'Hello',
                        style: TextStyle(
                          color: brightness == Brightness.dark
                              ? const Color(0xFFC5C5C5)
                              : const Color(0xFF343434),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Subtitle message
                      Text(
                        'Welcome to SD, where you manage your map',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: brightness == Brightness.dark
                              ? const Color(0xFF757575)
                              : Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Login button
                      Hero(
                        tag: 'login_btn',
                        child: CustomButton(
                          buttonText: 'Login',
                          onPressed: () {
                            Navigator.pushReplacement(
                              GlobalVariable.navState.currentContext!,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Signup button
                      Hero(
                        tag: 'signup_btn',
                        child: CustomButton(
                          buttonText: 'Sign Up',
                          isOutlined: true,
                          onPressed: () {
                            Navigator.pushReplacement(
                              GlobalVariable.navState.currentContext!,
                              MaterialPageRoute(
                                  builder: (context) => const SignUpScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 25),
                      // Social sign-up section
                      const Text(
                        'Sign up using',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Facebook sign-up button
                          IconButton(
                            onPressed: () {},
                            icon: CircleAvatar(
                              radius: 25,
                              child: Image.asset(
                                  'assets/images/icons/facebook.png'),
                            ),
                          ),
                          // Google sign-up button
                          IconButton(
                            onPressed: () {},
                            icon: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.transparent,
                              child:
                              Image.asset('assets/images/icons/google.png'),
                            ),
                          ),
                          // LinkedIn sign-up button
                          IconButton(
                            onPressed: () {},
                            icon: CircleAvatar(
                              radius: 25,
                              child: Image.asset(
                                  'assets/images/icons/linkedin.png'),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
