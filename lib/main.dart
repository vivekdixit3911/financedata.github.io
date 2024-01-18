import 'package:finance/bottombarinitalpage/bottombarpage.dart';
import 'package:finance/firebase_options.dart';
import 'package:finance/pages/loginscreen.dart';
import 'package:finance/pages/registerscreen.dart';
import 'package:finance/pages/welcomescreen.dart';
import 'package:finance/qr/qr.dart';
import 'package:finance/refreal/startrefreal.dart';
import 'package:finance/userdetail/userdetails.dart';
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
      initialRoute: welcomeScreen.id,
      routes: {
        welcomeScreen.id: (context) => const welcomeScreen(),
        bottombar.id: (context) => const bottombar(),
        registerpage.id: (context) => const registerpage(),
        loginscreen.id: (context) => const loginscreen(),
        ReferralPageStart.id: (context) =>  ReferralPageStart(),
        Qrgen.id: (context) => Qrgen(),
        UserDetails.id: (context) => const UserDetails(),
      },
    );
  }
}
