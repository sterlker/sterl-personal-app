import 'package:flutter/material.dart';
import '../pages/expense_page.dart';
import '../pages/settings_page.dart';

void selectedItem(BuildContext context, int index) {
  switch (index) {
    case 0:
      Navigator.pop(context);
    case 1:
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ExpensePage(),
      ));
    case 2:
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SettingsPage(),
      ));
      break;
  }
}