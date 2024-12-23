import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loginlogoutbasic/components/my_drawer.dart';
import 'package:loginlogoutbasic/database/expense_database.dart';
import 'package:provider/provider.dart';

import '../controller/selected_item.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(builder: (context, value, child) {
      // return UI
      return Scaffold(
        appBar: AppBar(
          title: Text('Main Page'),
          centerTitle: true,
          /*
            actions: [
              IconButton(
                onPressed: signUserOut,
                icon: Icon(Icons.logout),
              )
            ],
             */
        ),
        drawer: MyDrawer(),
        body: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          ],
        ),
      );
    });
  }
}
