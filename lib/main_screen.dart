import 'package:chat/chat_screen.dart';
import 'package:chat/firebase_helper.dart';
import 'package:chat/register_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';



class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Service service = Service();
  late String? email;

  getEmailAsync() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    email = (pref.containsKey('email')) ? pref.getString('email') : '+';
  }


  @override
  void initState() {
    getEmailAsync();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Users').snapshots(),
      builder: (context, snapshot) => (!snapshot.hasData)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: snapshot.data!.docs.length,
              shrinkWrap: true,
              primary: true,
              physics: ScrollPhysics(),
              itemBuilder: (context, item) {
                QueryDocumentSnapshot _data = snapshot.data!.docs[item];
                return TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatScreen(_data['email'])),
                    );
                  },
                  child: Text(_data['email']),
                );
              },
            ),
    );
  }
}
