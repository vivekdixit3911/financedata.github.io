import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance/payment/payment.dart';
import 'package:flutter/material.dart';
import '../qr/qr.dart';
import '../withdrawl/withdraw.dart';

class UserDetails extends StatefulWidget {
  static String id = 'UserDetails';

  const UserDetails({Key? key}) : super(key: key);

  @override
  State<UserDetails> createState() => UserDetailsState();
}

class UserDetailsState extends State<UserDetails> {
  late double todaysEarning;
  late double totalBalance;
  late TextEditingController amountController;
  late Future<void> fetchData;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController();
    fetchData = _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Show loading indicator while fetching data
        setState(() {
          todaysEarning = 0.0;
          totalBalance = 0.0;
        });

        // Fetch user data from Firestore
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        // Update UI with fetched data
        setState(() {
          todaysEarning = userSnapshot['todaysEarning'] ?? 0.0;
          totalBalance = userSnapshot['totalBalance'] ?? 0.0;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Your Finance',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              FutureBuilder<void>(
                future: fetchData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error loading data');
                  } else {
                    return _buildCard();
                  }
                },
              ),
              SizedBox(height: 16.0),
              _buildStyledButton(
                onPressed: () {
                  _showAddBalanceDialog();
                },
                label: 'Add Balance',
                color: Colors.teal,
              ),
              SizedBox(height: 8.0),
              _buildStyledButton(
                onPressed: () {
                  _showDialog('Withdraw');
                },
                label: 'Withdraw',
                color: Colors.deepOrange,
              ),
              SizedBox(height: 16.0),
              _buildStyledButton(
                onPressed: () {
                  _navigateToQrgenPage(double.parse(amountController.text));
                },
                label: 'Share App',
                color: Colors.blue,
              ),
              SizedBox(height: 16.0),
              _buildStyledButton(
                onPressed: () {
                  _navigateToAllTransactions();
                },
                label: 'View All Transactions',
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyledButton({
    required VoidCallback onPressed,
    required String label,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(16.0),
          primary: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Card(
      elevation: 8.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Total Balance',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              '₹$totalBalance',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Today\'s Earning',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              '₹$todaysEarning',
              style: TextStyle(fontSize: 24.0),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBalanceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Balance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Enter Amount'),
              ),
              SizedBox(height: 16.0),
              _buildStyledButton(
                onPressed: () {
                  double enteredAmount = double.parse(amountController.text);

                  // Validate if entered amount is greater than or equal to 300
                  if (enteredAmount >= 300) {
                    Navigator.pop(context);
                    _navigateToQrgenPage(enteredAmount);
                  } else {
                    // Show error message for amount less than 300
                    _showErrorDialog(
                        'Please enter an amount greater than or equal to 300.');
                  }
                },
                label: 'QR Payment',
                color: Colors.amber,
              ),
              SizedBox(height: 8.0),
              _buildStyledButton(
                onPressed: () {
                  Navigator.pop(context);
                  double enteredAmount = double.parse(amountController.text);

                  // Validate if entered amount is greater than or equal to 300
                  if (enteredAmount >= 300) {
                    _navigateToUPIAppsPage(enteredAmount);
                  } else {
                    // Show error message for amount less than 300
                    _showErrorDialog(
                        'Please enter an amount greater than or equal to 300.');
                  }
                },
                label: 'UPI Apps',
                color: Colors.blue,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDialog(String action) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(action),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Enter Amount'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            _buildStyledButton(
              onPressed: () {
                double enteredAmount = double.parse(amountController.text);

                // Validate if entered amount is less than total balance
                if (enteredAmount <= totalBalance) {
                  // Validate if entered amount is greater than or equal to 200
                  if (enteredAmount >= 200) {
                    Navigator.pop(context);
                    _navigateToWithdrawPaymentPage(enteredAmount);
                  } else {
                    // Show error message for amount less than 200
                    _showErrorDialog(
                        'Please enter an amount greater than or equal to 200.');
                  }
                } else {
                  // Show error message for amount greater than total balance
                  _showErrorDialog(
                      'Insufficient balance. Please enter a valid amount.');
                }
              },
              label: 'Submit',
              color: Colors.deepOrange,
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToWithdrawPaymentPage(double enteredAmount) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WithdrawPaymentPage(amount: enteredAmount),
      ),
    );
  }

  void _navigateToQrgenPage(double enteredAmount) {
    Navigator.pushNamed(
      context,
      Qrgen.id,
      arguments: {'enteredAmount': enteredAmount},
    );
  }

  void _navigateToUPIAppsPage(double enteredAmount) {
    bool isMobileApp = MediaQuery.of(context).size.shortestSide < 600;

    if (isMobileApp) {
      Navigator.pushNamed(
        context,
        Screen.id,
        arguments: {'enteredAmount'},
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('UPI Apps'),
            content: Text('This option is available only on mobile apps.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }

    print('Navigating to UPI Apps with amount: $enteredAmount');
  }

  void _navigateToAllTransactions() {
    print('Navigating to All Transactions Page');
  }
}
