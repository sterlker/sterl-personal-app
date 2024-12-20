import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loginlogoutbasic/database/expense_database.dart';
import 'package:loginlogoutbasic/pages/expense_page.dart';
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
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
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
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildHeader(),
              _buildItems(
                icon: Icons.home_rounded,
                title: 'Home',
                onTap: () => selectedItem(context, 0),
              ),
              _buildItems(
                icon: Icons.monetization_on_outlined,
                title: 'Expense',
                onTap: () => selectedItem(context, 1),
              ),
              _buildItems(
                icon: Icons.logout,
                title: 'Logout',
                onTap: signUserOut,
              )
            ],
          ),
        ),
        body: const Row(
          children: [
            Text(
              'Welcome',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      );
    });
  }

  _buildHeader() {
    return const DrawerHeader(
      decoration: BoxDecoration(color: Color(0xff1D1E22)),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage('assets/icon/icon.jpg'),
            radius: 40,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Sterl',
            style: TextStyle(color: Colors.white, fontSize: 15),
          )
        ],
      ),
    );
  }

  _buildItems(
      {required IconData icon,
      required String title,
      required GestureTapCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
      minLeadingWidth: 5,
    );
  }
}
