import 'package:chat/main_screen.dart';
import 'package:intl/intl.dart';
import 'package:chat/firebase_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

User? loginUser;
late String collections;
late String interlocutor;

class ChatScreen extends StatefulWidget {
  ChatScreen(_interlocutor) {
    interlocutor = _interlocutor;
  }

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Service service = Service();

  final auth = FirebaseAuth.instance;
  final storeMessage = FirebaseFirestore.instance;

  TextEditingController messageTextController = TextEditingController();

  _ChatScreenState();

  getCurrentUser() {
    final user = auth.currentUser;
    if (user != null) {
      loginUser = user;
    }
  }

  getCollection() {
    collections = (interlocutor.compareTo(loginUser!.email!) > 0)
        ? interlocutor + loginUser!.email!
        : loginUser!.email! + interlocutor;
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getCollection();
    createFBCollection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(),
              ),
            );
          },
        ),
        actions: [
          IconButton(
              onPressed: () async {
                service.signOut(context);
                SharedPreferences pref = await SharedPreferences.getInstance();
                pref.remove('email');
              },
              icon: Icon(Icons.logout))
        ],
        title: Text(loginUser!.email.toString() +
            ' -> ' +
            interlocutor +
            ' / ' +
            collections),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                physics: ScrollPhysics(),
                child: Messages(),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.blueGrey),
                      ),
                    ),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Enter Message...",
                      ),
                      controller: messageTextController,
                      minLines: 1,
                      maxLines: 5,
                      maxLength: 200,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (messageTextController.text.isNotEmpty) {
                      storeMessage.collection('Messages/$collections').doc().set(
                        {
                          'message': messageTextController.text.trim(),
                          'user': loginUser!.email,
                          'time': DateTime.now()
                        },
                      );
                      messageTextController.clear();
                    }
                  },
                  icon: const Icon(
                    Icons.send,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void createFBCollection() {
    FirebaseFirestore.instance.
  }
}

class Messages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Messages/$collections')
          .orderBy('time')
          .snapshots(),
      builder: (context, snapshot) => (!snapshot.hasData)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Text(snapshot.data!.toString())
          // : ListView.builder(
          //     itemCount: snapshot.data!.docs.length,
          //     shrinkWrap: true,
          //     primary: true,
          //     physics: ScrollPhysics(),
          //     itemBuilder: (context, item) {
          //       QueryDocumentSnapshot _data = snapshot.data!.docs[item];
          //       print(_data.toString() + ' ' + item.toString());
          //       return Container(
          //         child: Column(
          //           crossAxisAlignment: (_data['user'] == loginUser!.email)
          //               ? CrossAxisAlignment.end
          //               : CrossAxisAlignment.start,
          //           children: [
          //             Text(_data['message']),
          //             Text(
          //               DateFormat("d MMM h:mm:ss")
          //                   .format((_data['time'] as Timestamp).toDate()),
          //               style: TextStyle(fontSize: 11, color: Colors.grey),
          //             ),
          //           ],
          //         ),
          //         decoration: BoxDecoration(
          //           color: (_data['user'] == loginUser!.email)
          //               ? Colors.blue.withOpacity(0.2)
          //               : Colors.lime.withOpacity(0.4),
          //           borderRadius: BorderRadius.circular(15),
          //         ),
          //         padding: EdgeInsets.all(10),
          //         margin: (_data['user'] == loginUser!.email)
          //             ? EdgeInsets.only(
          //                 top: 10,
          //                 bottom: 10,
          //                 right: 10,
          //                 left: 50,
          //               )
          //             : EdgeInsets.only(
          //                 top: 10,
          //                 bottom: 10,
          //                 left: 10,
          //                 right: 50,
          //               ),
          //       );
          //     },
          //   ),
    );
  }
}
