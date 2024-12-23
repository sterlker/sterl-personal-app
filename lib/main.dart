import 'package:flutter/material.dart';
import 'package:loginlogoutbasic/database/expense_database.dart';
import 'package:loginlogoutbasic/pages/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:loginlogoutbasic/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'database/note_database.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize local database
  await ExpenseDatabase.initialize();
  await NoteDatabase.initialize();

  // Initialize firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ExpenseDatabase(),
        ),
        ChangeNotifierProvider(
          create: (context) => NoteDatabase(),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        )
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
