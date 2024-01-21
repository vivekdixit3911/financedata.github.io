import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:upi_payment_qrcode_generator/upi_payment_qrcode_generator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Qrgen extends StatefulWidget {
  static String id = "qrgen";

  @override
  QrgenState createState() => QrgenState();
}

class QrgenState extends State<Qrgen> {
  final DatabaseService _databaseService = DatabaseService();
  late UPIDetails upiDetails;
  int countdown = 10;
  late Timer timer;
  TextEditingController transactionIdController = TextEditingController();
  bool isVerifying = false;

  @override
  void initState() {
    super.initState();
    _databaseService.initializeDatabase();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final double? enteredAmount = args?['enteredAmount'];

    upiDetails = UPIDetails(
      upiID: "9129999362",
      payeeName: "vivek kr. dixit",
      amount: enteredAmount ?? 0,
      transactionNote: " $enteredAmount is fetchig balance ",
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('UPI Payment QRCode Generator'),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 190, 208, 223),
                const Color.fromARGB(255, 206, 164, 213)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "UPI Payment QRCode with Amount",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    UPIPaymentQRCode(
                      upiDetails: upiDetails,
                      size: 220,
                      upiQRErrorCorrectLevel: UPIQRErrorCorrectLevel.low,
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        handleMakePayment();
                      },
                      child: Text("Input UTR number"),
                    ),
                    if (isVerifying)
                      Column(
                        children: [
                          SizedBox(height: 20),
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text(
                            "Transaction being verified. Please wait for $countdown seconds.",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    if (!isVerifying && countdown == 0)
                      Column(
                        children: [
                          SizedBox(height: 20),
                          Text(
                            "Enter the 12-digit transaction ID:",
                            style: TextStyle(color: Colors.green),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: transactionIdController,
                            keyboardType: TextInputType.number,
                            maxLength: 12,
                            decoration: InputDecoration(
                              labelText: "Transaction ID",
                              hintText: "Enter 12-digit ID",
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              verifyPayment(transactionIdController.text);
                            },
                            child: Text("Verify Payment"),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown == 0) {
        timer.cancel();
        showTransactionIdField();
      } else {
        setState(() {
          countdown--;
        });
      }
    });
  }

  void handleMakePayment() {
    setState(() {
      isVerifying = true;
    });
    startTimer();
  }

  void showTransactionIdField() {
    setState(() {
      isVerifying = false;
    });
  }

  void verifyPayment(String enteredTransactionId) {
    _databaseService.getTransactionDetails(enteredTransactionId).then(
      (transactionDetails) {
        if (transactionDetails != null) {
          showTransactionDetailsPopup(transactionDetails);
        } else {
          showTransactionNotFoundError();
        }
      },
    ).catchError((error) {
      print("Error: $error");
      showTransactionNotFoundError();
    });
  }

  void showTransactionDetailsPopup(Map<String, dynamic> transactionDetails) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Transaction Details"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amount: \$${transactionDetails['amount'].toStringAsFixed(2)}',
              ),
              SizedBox(height: 8),
              Text(
                'Date: ${transactionDetails['date'] != null ? DateFormat('dd MMM yyyy').format(transactionDetails['date'].toDate()) : 'N/A'}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void showTransactionNotFoundError() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Transaction Not Found"),
          content: Text("No transaction found with the entered ID."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference _transactionsCollection;

  Future<void> initializeDatabase() async {
    await _firestore.settings;
    _transactionsCollection = _firestore.collection('transactions');
  }

  Future<Map<String, dynamic>?> getTransactionDetails(
    String enteredTransactionId,
  ) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _transactionsCollection.doc('all_transactions').get();

      if (documentSnapshot.exists) {
        // Ensure 'data' is a Map before accessing
        if (documentSnapshot.data() is Map) {
          Map<String, dynamic>? data =
              documentSnapshot.data() as Map<String, dynamic>?;

          // Safely check for 'transactions' using the conditional member access operator
          if (data?.containsKey('transactions') == true &&
              data?['transactions'] is List) {
            List<Map<String, dynamic>> transactions =
                List<Map<String, dynamic>>.from(data!['transactions']);

            Map<String, dynamic>? transactionDetails = transactions.firstWhere(
              (transaction) =>
                  transaction['transactionNumber'] == enteredTransactionId,
            );

            return transactionDetails;
          } else {
            throw Exception(
                'Invalid data structure: "transactions" field is missing or not a List');
          }
        } else {
          throw Exception('Invalid data structure: "data" is not a Map');
        }
      } else {
        return null;
      }
    } catch (error) {
      // Handle error gracefully (e.g., log error, display user-friendly message)
      rethrow; // Re-throw to allow handling in calling code
    }
  }
}
