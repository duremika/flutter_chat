import 'dart:async';

import 'package:chat/chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:chat/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_screen.dart';


void main() async {
  String? email;
  await runZonedGuarded(() async{
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    SharedPreferences pref = await SharedPreferences.getInstance();
    email = pref.getString('email');
  }, (e, state) => print(e));


  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: email != null ? MainScreen() : LoginPage(),
  ));
}
