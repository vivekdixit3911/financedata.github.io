import 'package:finance/bottombarinitalpage/bottombarpage.dart';
import 'package:finance/firebase_options.dart';
import 'package:finance/pages/loginscreen.dart';
import 'package:finance/pages/registerscreen.dart';
import 'package:finance/pages/welcomescreen.dart';
import 'package:finance/payment/payment.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 178, 193, 203),
      ),
      initialRoute: registerpage.id,
      routes: {
        welcomeScreen.id: (context) => const welcomeScreen(),
        bottombar.id: (context) => const bottombar(),
        registerpage.id: (context) => const registerpage(),
        loginscreen.id: (context) => const loginscreen(),
        HomePage.id: (context) => HomePage(),
      },
    );
  }
}
