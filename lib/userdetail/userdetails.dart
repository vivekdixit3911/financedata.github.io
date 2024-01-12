import 'package:finance/qr/qr.dart';
import 'package:flutter/material.dart';

class UserDetails extends StatefulWidget {
  static String id = 'UserDetails';

  const UserDetails({Key? key}) : super(key: key);

  @override
  State<UserDetails> createState() => UserDetailsState();
}

class UserDetailsState extends State<UserDetails> {
  double totalBalance = 1000.0; // Replace with actual data
  double todaysEarning = 50.0; // Replace with actual data

  TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 8.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      '\$$totalBalance',
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
                      '\$$todaysEarning',
                      style: TextStyle(fontSize: 24.0),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _showDialog('Add Balance');
              },
              child: Text('Add Balance'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Colors.amber,
              ),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                _showDialog('Withdraw');
              },
              child: Text('Withdraw'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Colors.deepOrange,
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _navigateToQrgenPage(double.parse(amountController.text));
              },
              child: Text('Share App'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
              ),
            ),
          ],
        ),
      ),
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
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _navigateToQrgenPage(double.parse(amountController.text));
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToQrgenPage(double enteredAmount) {
    Navigator.pushNamed(
      context,
      Qrgen.id,
      arguments: {'enteredAmount': enteredAmount},
    );
  }
}
