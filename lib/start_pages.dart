import 'package:chat/firebase_helper.dart';
import 'package:chat/register_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';

class StartPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final String _pageName;
  final String _buttonText;
  final String _bottomText;

  final Service service = Service();

  final auth = FirebaseAuth.instance;

  StartPage.loginPage({Key? key})
      : _pageName = 'Login Page',
        _buttonText = 'SIGN IN',
        _bottomText = "I don't have any account",
        super(key: key);

  StartPage.registerPage({Key? key})
      : _pageName = 'Register Page',
        _buttonText = 'SIGN UP',
        _bottomText = 'Already have account?',
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                _pageName,
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter your Email',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(60)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(60)),
                  ),
                ),
              ),
              if (_pageName == 'Register Page')
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: TextField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      hintText: 'Confirm your password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(60)),
                    ),
                  ),
                ),
              ElevatedButton(
                onPressed: (_pageName == 'Register Page')
                    ? () async {
                        SharedPreferences pref =
                            await SharedPreferences.getInstance();
                        if (emailController.text.isNotEmpty &&
                            passwordController.text.isNotEmpty &&
                            confirmPasswordController.text.isNotEmpty &&
                            passwordController.text ==
                                confirmPasswordController.text) {

                          await FirebaseFirestore.instance
                              .collection('Users')
                              .doc()
                              .set(
                            {
                              'email': emailController.text,
                            },
                          );
                          service.createUser(context, emailController.text,
                              passwordController.text);
                          pref.setString('email', emailController.text);
                        } else {
                          service.errorBox(context, 'Fields must not empty');
                        }
                      }
                    : () async {
                        SharedPreferences pref =
                            await SharedPreferences.getInstance();
                        if (emailController.text.isNotEmpty &&
                            passwordController.text.isNotEmpty) {
                          service.loginUser(context, emailController.text,
                              passwordController.text);
                          pref.setString('email', emailController.text);
                        } else {
                          service.errorBox(context, 'Fields must not empty');
                        }
                      },
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 80)),
                child: Text(_buttonText),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => (_pageName == 'Register Page')
                            ? LoginPage()
                            : RegisterPage(),
                      ),
                    );
                  },
                  child: Text(_bottomText)),
            ],
          ),
        ),
      ),
    );
  }
}
