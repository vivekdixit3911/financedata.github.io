import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrawPaymentPage extends StatefulWidget {
  static String id = "WithdrawPaymentPage";

  // Add a field to store the received amount
  final double amount;

  WithdrawPaymentPage({required this.amount});

  @override
  _WithdrawPaymentPageState createState() => _WithdrawPaymentPageState();
}

class _WithdrawPaymentPageState extends State<WithdrawPaymentPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _confirmAccountNumberController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorText = '';
  String _buttonText = 'Save Details';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Withdraw Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the received amount in a non-editable section
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade300,
              ),
              child: Text(
                'Withdrawal Amount: \$${widget.amount}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            // Bank Name TextField
            _buildRoundedTextField(
              controller: _bankNameController,
              labelText: 'Bank Name',
            ),
            SizedBox(height: 16),
            // IFSC Code TextField
            _buildRoundedTextField(
              controller: _ifscCodeController,
              labelText: 'IFSC Code',
              maxLength: 12,
            ),
            SizedBox(height: 16),
            // Account Number TextField
            _buildRoundedTextField(
              controller: _accountNumberController,
              labelText: 'Account Number',
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            // Confirm Account Number TextField
            _buildRoundedTextField(
              controller: _confirmAccountNumberController,
              labelText: 'Confirm Account Number',
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            // Current Password TextField
            _buildRoundedTextField(
              controller: _passwordController,
              labelText: 'Current Password',
              obscureText: true,
            ),
            SizedBox(height: 16),
            // Error Text
            Text(
              _errorText,
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 16),
            // Save Details Button
            Center(
              child: ElevatedButton(
                onPressed: () => _saveDetails(),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  primary: Colors.green,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _buttonText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.save),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build rounded text field
  Widget _buildRoundedTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Function to handle saving details
  void _saveDetails() async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: _passwordController.text,
        );

        await currentUser.reauthenticateWithCredential(credential);

        if (_accountNumberController.text ==
            _confirmAccountNumberController.text) {
          // Create a timestamp
          Timestamp timestamp = Timestamp.now();

          // Create a variable to store transaction details
          Map<String, dynamic> transactionDetails = {
            'bankName': _bankNameController.text,
            'ifscCode': _ifscCodeController.text,
            'accountNumber': _accountNumberController.text,
            'upiId': currentUser.email,
            'amount': widget.amount,
            'timestamp': timestamp,
          };

          // Update the 'transactionsDetails' array field in the user's document
          await _firestore.collection('users').doc(currentUser.uid).update({
            'transactionsDetails': FieldValue.arrayUnion([transactionDetails]),
          });

          // Calculate GST deduction (18%)
          double gstDeduction = (widget.amount * 0.18).toDouble();
          double originalAmount = widget.amount;
          double deductedAmount = originalAmount - gstDeduction;

          // Update button text to indicate success
          setState(() {
            _buttonText = 'Success';
          });

          // Show GST deduction information
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Withdrawal Details'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        'Original Amount: \$${originalAmount.toStringAsFixed(2)}'),
                    Text(
                        'GST Deduction (18%): \$${gstDeduction.toStringAsFixed(2)}'),
                    Text(
                        'Deducted Amount: \$${deductedAmount.toStringAsFixed(2)}'),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );

          // Navigate to the success page or perform any other actions
          // You might want to use a delay before popping the page to show the "Success" message
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pop(context);
          });
        } else {
          setState(() {
            _errorText = 'Account numbers do not match.';
          });
        }
      } else {
        // Handle the case where the user is not logged in
        print('User not logged in');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _errorText = 'Invalid password or an error occurred.';
      });
    }
  }
}
