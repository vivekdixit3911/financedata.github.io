import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserData {
  static final UserData _singleton = UserData._internal();

  factory UserData() {
    return _singleton;
  }

  UserData._internal();

  String userId = '';
  String email = '';
  String name = '';
  List<dynamic> purchasedProducts = [];
  int todaysEarning = 0;
  int totalBalance = 0;

  Timer? updateTimer;
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
          purchasedProducts = userMap['purchasedProducts'] ?? [];
          todaysEarning = userMap['todaysEarning'] ?? 0;
          totalBalance = userMap['totalBalance'] ?? 0;

          // Display the fetched data
          print('Email: $email');
          print('Name: $name');
          print('Purchased Products: $purchasedProducts');
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

  Future<void> updateTodaysEarning() async {
    String? userId = UserData().userId;

    if (userId != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);

      try {
        // Fetch the current user data
        await fetchUserData();

        if (purchasedProducts != null && purchasedProducts.isNotEmpty) {
          // Get the active purchased products array
          List<dynamic> activeProducts = purchasedProducts
              .where((product) => isProductActive(product))
              .toList();

          // Calculate todaysEarning based on dailyIncome of active products
          int updatedTodaysEarning = 0;
          activeProducts.forEach((product) {
            updatedTodaysEarning += (product['dailyIncome'] as int?) ?? 0;
          });

          // Update todaysEarning in Firestore
          await userDoc.update({'todaysEarning': updatedTodaysEarning});
        } else {
          print('Error: purchasedProducts is null or empty.');
        }
      } catch (e) {
        print('Error updating todaysEarning: $e');
      }
    }
  }

  Future<void> savePurchasedProductToFirestore(
      String productName, int price, int days, int dailyIncome) async {
    String? userId = UserData().userId;

    if (userId != null) {
      // Check if the user has enough balance
      if (UserData().totalBalance < price) {
        throw Exception('Insufficient Balance');
      }

      try {
        // Deduct the price from totalBalance
        UserData().totalBalance -= price;

        // Calculate expiry date by adding days to the current date
        DateTime purchaseDateTime = DateTime.now();
        DateTime expiryDateTime = purchaseDateTime.add(Duration(days: days));

        // Save purchased product to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'purchasedProducts': FieldValue.arrayUnion([
            {
              'name': productName,
              'price': price,
              'purchaseDateTime': purchaseDateTime,
              'expiryDateTime': expiryDateTime,
              'days': days,
              'dailyIncome': dailyIncome,
              'status': 'active',
            }
          ]),
          'totalBalance':
              UserData().totalBalance, // Update totalBalance in Firestore
        });

        print("Product added to Firestore successfully!");
      } catch (error) {
        // If there's an error, add the deducted price back to totalBalance
        UserData().totalBalance += price;
        print("Error adding product to Firestore: $error");
        throw error;
      }
    }
  }

  bool isProductActive(Map<String, dynamic> product) {
    DateTime purchaseDateTime = product['purchaseDateTime'].toDate();
    int days = product['days'];
    DateTime expiryDateTime = purchaseDateTime.add(Duration(days: days));

    return DateTime.now().isBefore(expiryDateTime) &&
        product['status'] == 'active';
  }

  void schedulePeriodicUpdate() {
    const Duration updateInterval = Duration(seconds: 10);

    updateTimer = Timer.periodic(updateInterval, (timer) async {
      await updateTodaysEarning();
    });
  }

  // Cancel the periodic update timer
  void cancelUpdateTimer() {
    updateTimer?.cancel();
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
  bool isUpdateScheduled = false;

  @override
  void initState() {
    super.initState();
    UserData().schedulePeriodicUpdate();
  }

  @override
  void dispose() {
    super.dispose();
    UserData().cancelUpdateTimer(); // Cancel the timer to prevent memory leaks
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

  void _showConfirmationDialog(BuildContext context, String productName,
      int price, int days, int dailyIncome) async {
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
                  await UserData().savePurchasedProductToFirestore(
                      productName, price, days, dailyIncome);

                  // Update totalBalance in Firestore
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(UserData().userId)
                      .update({'totalBalance': UserData().totalBalance});

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
                  _showConfirmationDialog(
                      context, productName, price, days, dailyIncome);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
