import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class UserDataDisplay extends StatefulWidget {
  @override
  UserDataDisplayState createState() => UserDataDisplayState();
}

class UserDataDisplayState extends State<UserDataDisplay> {
  late Stream<Map<String, dynamic>> userStream;

  @override
  void initState() {
    super.initState();
    userStream = getUserDetails().asStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE1F5FE),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No user data found!'),
            );
          } else {
            final userDetails = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: buildCard(
                      title: 'Welcome, ${userDetails['name']}!',
                      content: [
                        'Email: ${userDetails['email']}',
                        'Name: ${userDetails['name']}',
                        'Total Balance: ₹${userDetails['totalBalance']}',
                      ],
                    ),
                  ),

                  Divider(), // Divider to separate sections
                  SizedBox(height: 16),

                  Center(
                    child: Text(
                      'Products Count: ${userDetails['purchasedProducts']?.length ?? 0}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),

                  SizedBox(height: 16),
                  Text(
                    'Purchased Products:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  if (userDetails['purchasedProducts'] != null)
                    Expanded(
                      child: ListView.builder(
                        itemCount: userDetails['purchasedProducts'].length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          final product =
                              userDetails['purchasedProducts'][index];
                          final backgroundColor = index % 2 == 0
                              ? Colors.blue.shade100
                              : Colors.blue.shade200;

                          return GestureDetector(
                            onTap: () =>
                                _showProductDetailsDialog(context, product),
                            child: Card(
                              color: backgroundColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Product ${index + 1} Name: ${product['name']}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(' Price: ${product['price']}'),
                                    Countdown(
                                      days: product['days'],
                                      builder: (BuildContext context,
                                          int remainingDays) {
                                        return Text(
                                            ' Days Remaining: $remainingDays');
                                      },
                                    ),
                                    Text(
                                        ' Status: ${product['status']}'), // Display status
                                    SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () =>
                                          _showProductDetailsDialog(
                                              context, product),
                                      child: Text('View Details'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    return '${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  Widget buildCard({required String title, required List<String> content}) {
    return GestureDetector(
      onTap: () => _showUserDetailsDialog(context, title, content),
      child: Card(
        color: Colors.orange.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              for (String item in content) Text(item),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showUserDetailsDialog(
      BuildContext context, String title, List<String> content) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                for (String item in content) Text(item),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showProductDetailsDialog(
      BuildContext context, dynamic product) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text('Name: ${product['name']}'),
                Text('Price: ${product['price']}'),
                Text('Days: ${product['days']}'),
                Text('Status: ${product['status']}'),
                Text(
                  'Purchase Date and Time: ${DateFormat.yMMMMd().add_jm().format(product['purchaseDateTime'].toDate())}',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<Map<String, dynamic>> getUserDetails() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return {};
  final docSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  if (docSnapshot.exists) {
    return docSnapshot.data()!;
  } else {
    return {};
  }
}

class Countdown extends StatefulWidget {
  final int days;
  final Widget Function(BuildContext context, int remainingDays) builder;

  Countdown({
    required this.days,
    required this.builder,
  });

  @override
  _CountdownState createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  late Timer _timer;
  late int _remainingDays;

  @override
  void initState() {
    super.initState();
    _remainingDays = widget.days;
    _timer = Timer.periodic(Duration(days: 1), _updateRemaining);
  }

  void _updateRemaining(Timer timer) {
    setState(() {
      if (_remainingDays > 0) {
        _remainingDays--;
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _remainingDays);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
