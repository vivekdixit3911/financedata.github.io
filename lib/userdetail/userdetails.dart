import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance/payment/payment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserData {
  static final UserData _singleton = UserData._internal();

  factory UserData() {
    return _singleton;
  }

  UserData._internal();

  static String email = '';
  static String name = '';
  static List<dynamic> numberOfShares = [];
  static int todaysEarning = 0;
  static int totalBalance = 0;

  static Future<void> fetchUserData() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? currentUser = auth.currentUser;

    if (currentUser != null) {
      final String uid = currentUser.uid;
      final DocumentReference docRef =
          FirebaseFirestore.instance.collection('users').doc(uid);

      try {
        final DocumentSnapshot userDocSnapshot = await docRef.get();

        if (userDocSnapshot.exists) {
          final userMap = userDocSnapshot.data() as Map<String, dynamic>;

          email = userMap['email'] ?? '';
          name = userMap['name'] ?? '';
          numberOfShares = userMap['numberOfShares'] ?? [];
          todaysEarning = userMap['todaysEarning'] ?? 0;
          totalBalance = userMap['totalBalance'] ?? 0;

          // Display the fetched data
          print('Email: $email');
          print('Name: $name');
          print('Number of Shares: $numberOfShares');
          print('Today\'s Earning: $todaysEarning');
          print('Total Balance: $totalBalance');
        } else {
          print('User document not found!');
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  static void updateUserData() async {
    await fetchUserData();
  }
}

class UserDetails extends StatefulWidget {
  static String id = 'user_details';
  const UserDetails({Key? key}) : super(key: key);

  @override
  State<UserDetails> createState() => UserDetailsState();
}

class UserDetailsState extends State<UserDetails> {
  TextEditingController amountController = TextEditingController();

  Future<void> _addBalance(num amount) async {
    if (amount < 1 || amount > 100000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter an amount between 1 and 100000."),
        ),
      );
      return;
    }

    setState(() {});

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Screen(
          enteredNumber: amount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter amount (less than 100000)',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                num amount = int.tryParse(amountController.text) ?? 0;
                await _addBalance(amount);
              },
              child: Text("Add Balance"),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
