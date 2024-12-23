import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../controller/selected_item.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
            icon: Icons.settings,
            title: 'Settings',
            onTap: () => selectedItem(context, 2),
          ),
          _buildItems(
            icon: Icons.logout,
            title: 'Logout',
            onTap: signUserOut,
          )
        ],
      ),
    );
  }

  _buildHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
      child: const Column(
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
