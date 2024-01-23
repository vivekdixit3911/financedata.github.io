import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class UserData {
  static final UserData _singleton = UserData._internal();

  factory UserData() {
    return _singleton;
  }

  UserData._internal();

  String userId = '';
  String email = '';
  String name = '';
  List<dynamic> numberOfShares = [];
  int todaysEarning = 0;
  int totalBalance = 0;

  Future<void> fetchUserData() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? currentUser = auth.currentUser;

    if (currentUser != null) {
      userId = currentUser.uid;
      final DocumentReference docRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

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

  Future<void> savePurchasedProductToFirestore(
      String productName, int price, int days, int initialTimerValue) async {
    String? userId = UserData().userId;

    if (userId != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'purchasedProducts': FieldValue.arrayUnion([
          {
            'name': productName,
            'price': price,
            'purchaseDateTime': DateTime.now(),
            'days': days,
            'timerValue': initialTimerValue, // Initial timer value in seconds
            'status': 'active', // Status can be 'active' or 'over'
          }
        ]),
        'numberOfShares': FieldValue.arrayUnion([productName]),
      }).then((_) {
        print("Product added to Firestore successfully!");
      }).catchError((error) {
        print("Error adding product to Firestore: $error");
      });
    }
  }
}

class ElegantBackgroundProductCard extends StatelessWidget {
  final String productName;
  final int totalPrice;
  final int price;
  final int dailyIncome;
  final int days;
  final VoidCallback onPressed;

  const ElegantBackgroundProductCard({
    required this.productName,
    required this.totalPrice,
    required this.price,
    required this.dailyIncome,
    required this.days,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Product details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      productName,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Total Price: ₹${totalPrice.toString()}",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Price: ₹${price.toString()}",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Daily Income: ₹${dailyIncome.toString()}",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Days: ${days.toString()}",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    // Display remaining time
                  ],
                ),
              ),
              // Money shower effect
              Positioned(
                top: -50,
                child: Image.asset(
                  'assets/tree.png', // Replace with your money image
                  width: 40,
                  height: 40,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductCardPage extends StatefulWidget {
  const ProductCardPage({Key? key}) : super(key: key);

  @override
  _ProductCardPageState createState() => _ProductCardPageState();
}

class _ProductCardPageState extends State<ProductCardPage> {
  int _timerValue = 0;
  late Timer _timer;

  void _startTimer(String productName, int days) {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      setState(() {
        if (_timerValue > 0) {
          _timerValue--;
          // Do not update the timer value in Firebase here
        } else {
          timer.cancel(); // Stop the timer when it reaches zero
          _setProductInactive(productName);
        }
      });
    });
  }

  Future<void> _setProductInactive(String productName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      try {
        // Fetch the current user data
        await UserData().fetchUserData();

        // Get the purchased products array
        List<dynamic> purchasedProducts =
            UserData().numberOfShares as List<dynamic>;

        // Find the purchased product by name
        var purchasedProduct = purchasedProducts.firstWhere(
          (product) => product['name'] == productName,
          orElse: () => null,
        );

        // If the product is found, mark it as 'over'
        if (purchasedProduct != null) {
          purchasedProduct['status'] = 'over';

          // Update the status in Firestore
          await userDoc.update({'purchasedProducts': purchasedProducts});
        }
      } catch (e) {
        print('Error setting product as inactive: $e');
      }
    }
  }

  String _formatDuration(int seconds) {
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = ((seconds % 86400) % 3600) ~/ 60;
    final secondsRemaining = ((seconds % 86400) % 3600) % 60;

    return '$days days $hours hours $minutes minutes $secondsRemaining seconds';
  }

  void _showCongratulationsDialog(BuildContext context, String productName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You have successfully purchased $productName.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(
      BuildContext context, String productName, int price, int days) async {
    // Show loading dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Processing...'),
          content: CircularProgressIndicator(),
          actions: <Widget>[],
        );
      },
    );

    try {
      // Fetch the current user data
      await UserData().fetchUserData();

      // Check if the user has enough balance
      if (UserData().totalBalance < price) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorDialog(context, 'Insufficient Balance');
        return;
      }

      // Close loading dialog
      Navigator.of(context).pop();

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Purchase'),
            content: Text('Do you want to buy $productName for ₹$price?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  // Deduct the price from the total balance
                  UserData().totalBalance -= price;

                  // Save purchased product to Firestore
                  await UserData().savePurchasedProductToFirestore(productName,
                      price, days, 2 * 60); // 2 minutes initial timer value

                  // Update totalBalance in Firestore
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(UserData().userId)
                      .update({'totalBalance': UserData().totalBalance});

                  // Start the timer for the purchased product
                  _startTimer(productName, days);

                  // Close the confirmation dialog
                  Navigator.of(context).pop();
                  _showCongratulationsDialog(context, productName);
                },
                child: Text('Yes'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorDialog(context, 'Error fetching user data: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE1F5FE),
      body: SingleChildScrollView(
        child: GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: List.generate(
            12,
            (index) {
              String productName = '';
              int price = 0;
              int totalPrice = 0;
              int dailyIncome = 0;
              int days = 0;

              // Assign values based on the provided product details
              switch (index) {
                case 0:
                  productName = "Product 1";
                  price = 225;
                  totalPrice = 225;
                  dailyIncome = 25;
                  days = 14;
                  break;
                case 1:
                  productName = "Product 2";
                  price = 35;
                  totalPrice = 520;
                  dailyIncome = 20;
                  days = 35;
                  break;
                case 2:
                  productName = "Product 3";
                  price = 60;
                  totalPrice = 1225;
                  dailyIncome = 30;
                  days = 60;
                  break;
                case 3:
                  productName = "Product 4";
                  price = 120;
                  totalPrice = 1980;
                  dailyIncome = 26;
                  days = 26;
                  break;
                case 4:
                  productName = "Product 5";
                  price = 190;
                  totalPrice = 3900;
                  dailyIncome = 28;
                  days = 28;
                  break;
                case 5:
                  productName = "Product 6";
                  price = 250;
                  totalPrice = 7200;
                  dailyIncome = 250;
                  days = 30;
                  break;
                case 6:
                  productName = "Product 7";
                  price = 350;
                  totalPrice = 11200;
                  dailyIncome = 39;
                  days = 39;
                  break;
                case 7:
                  productName = "Product 8";
                  price = 710;
                  totalPrice = 24500;
                  dailyIncome = 40;
                  days = 40;
                  break;
                case 8:
                  productName = "Product 9";
                  price = 920;
                  totalPrice = 32000;
                  dailyIncome = 40;
                  days = 35;
                  break;
                case 9:
                  productName = "Product 10";
                  price = 1600;
                  totalPrice = 40000;
                  dailyIncome = 30;
                  days = 38;
                  break;
                case 10:
                  productName = "Product 11";
                  price = 1600;
                  totalPrice = 45000;
                  dailyIncome = 30;
                  days = 5;
                  break;
                case 11:
                  productName = "Product 12";
                  price = 2200;
                  totalPrice = 50000;
                  dailyIncome = 28;
                  days = 6;
                  break;
              }

              return ElegantBackgroundProductCard(
                totalPrice: totalPrice,
                price: price,
                dailyIncome: dailyIncome,
                days: days,
                productName: productName,
                onPressed: () {
                  _showConfirmationDialog(context, productName, price, days);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
