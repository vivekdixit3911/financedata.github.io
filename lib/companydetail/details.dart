import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance/allshares/allshares.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Transaction {
  String name;
  double amount;
  DateTime date;

  Transaction({
    required this.name,
    required this.amount,
    required this.date,
  });
}

class UserDataDisplay extends StatefulWidget {
  static String id = "UserDataDisplay";
  @override
  _UserDataDisplayState createState() => _UserDataDisplayState();
}

class _UserDataDisplayState extends State<UserDataDisplay> {
  Map<String, dynamic>? userData;
  List<Transaction> purchasedShares = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchPurchasedShares();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userSnapshot.exists) {
        setState(() {
          userData = userSnapshot.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _fetchPurchasedShares() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      QuerySnapshot transactionsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('purchasedProducts')
          .get();

      List<Transaction> transactions = [];

      transactionsSnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Print the entire data for debugging
        print('Raw Data: $data');

        // Convert date string to DateTime
        DateTime purchaseDateTime =
            (data['purchaseDateTime'] as Timestamp).toDate();

        transactions.add(Transaction(
          name: data['name'],
          amount: data['price'].toDouble(),
          date: purchaseDateTime,
        ));
      });

      setState(() {
        purchasedShares = transactions;
      });
    } catch (e) {
      print('Error fetching purchased shares: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListView(
        children: [
          Center(
            child: userData != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome "${userData?['name'] ?? "N/A"}", have a great earning',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  )
                : Text("Error in getting user data. Try again later."),
          ),
          Center(
            child: Text(
              "Build For a Growing India.📈",
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  backgroundColor: Color.fromARGB(
                      255, 3, 252, 119), // Text Color (Foreground color)
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProductCardPage()),
                  );
                },
                child: Text(
                  "Get Started",
                  style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                ),
              ),
            ),
          ),
          Center(
            child: CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              onDateChanged: (value) => Null,
            ),
          ),

          // Display purchased shares below the calendar
          if (purchasedShares.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Shares!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Purchased Shares:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  for (int i = 0; i < purchasedShares.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${i + 1}. ${purchasedShares[i].name}',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Price: ${purchasedShares[i].amount}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Date: ${purchasedShares[i].date}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'You have not purchased any shares yet!',
                style: TextStyle(fontSize: 18),
              ),
            ),
        ],
      ),
    );
  }
}
