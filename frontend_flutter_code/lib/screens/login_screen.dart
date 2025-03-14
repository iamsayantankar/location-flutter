import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sd_project/components/components.dart';
import 'package:sd_project/constants.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:http/http.dart' as http;

import '../utils/helper/shared_preferences_helper.dart';
import '../utils/helper/url_helper.dart';
import '../utils/services/global.dart';
import 'entry_screen.dart';
import 'home_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static String id = 'login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final brightness =
      MediaQuery.of(GlobalVariable.navState.currentContext!).platformBrightness;
  // final _auth = FirebaseAuth.instance;
  late String _email;
  late String _password;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          GlobalVariable.navState.currentContext!,
          MaterialPageRoute(builder: (context) => const EntryScreen()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LoadingOverlay(
          isLoading: _saving,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const TopScreenImage(screenImageName: 'welcome.png'),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                         ScreenTitle(title: 'Login',
                          style: TextStyle(
                            color: brightness == Brightness.dark
                                ? const Color(0xFFC5C5C5)
                                : Color(0xFF343434),
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        CustomTextField(
                          textField: TextField(
                              onChanged: (value) {
                                _email = value;
                              },
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                              decoration: kTextInputDecoration.copyWith(
                                  hintText: 'Email')),
                        ),
                        CustomTextField(
                          textField: TextField(
                            obscureText: true,
                            onChanged: (value) {
                              _password = value;
                            },
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                            decoration: kTextInputDecoration.copyWith(
                                hintText: 'Password'),
                          ),
                        ),
                        CustomBottomScreen(
                          textButton: 'Login',
                          heroTag: 'login_btn',
                          question: 'Forgot password?',
                          buttonPressed: () async {
                             // Todo: code for login entry

                              final response = await http.post(
                                Uri.parse(UrlHelper.logInUrl),
                                body: {
                                  'email': _email,
                                  'password': _password,
                                },
                              );

                              final data = json.decode(response.body);
                              print(data);

                              if (data["code"] == 1) {
                                await SharedPreferencesHelper.saveString('user_email', _email); // Save a string value

                                Navigator.pushReplacement(
                                  GlobalVariable.navState.currentContext!,
                                  MaterialPageRoute(builder: (context) =>  HomeScreen()),
                                );
                              } else {
                                signUpAlert(
                                  context: context,
                                  onPressed: () {
                                    setState(() {
                                      _saving = false;
                                    });
                                    Navigator.popAndPushNamed(
                                        context, LoginScreen.id);
                                  },
                                  title: 'WRONG PASSWORD OR EMAIL',
                                  desc:
                                  'Confirm your email and password and try again',
                                  btnText: 'Try Now',
                                ).show();
                              }



                          },
                          questionPressed: () {
                            signUpAlert(
                              onPressed: () async {
                                // await FirebaseAuth.instance
                                //     .sendPasswordResetEmail(email: _email);
                              },
                              title: 'RESET YOUR PASSWORD',
                              desc:
                                  'Click on the button to reset your password',
                              btnText: 'Reset Now',
                              context: context,
                            ).show();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
