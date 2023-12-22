import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';

class glass extends StatelessWidget {
  final Text;
  final height;
  final width;
  const glass(this.Text, this.height, this.width,
      {required MaterialColor bordercolor});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      height: height,
      width: width,
      gradient: LinearGradient(
        colors: [
          Color.fromARGB(255, 192, 150, 150).withOpacity(0.40),
          Color.fromARGB(255, 240, 236, 13).withOpacity(0.10),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.60),
          Colors.white.withOpacity(0.10),
          Color.fromARGB(255, 238, 0, 0).withOpacity(0.05),
          Color.fromARGB(255, 255, 0, 0).withOpacity(0.60),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.39, 0.40, 1.0],
      ),
      blur: 20,
      borderRadius: BorderRadius.circular(24.0),
      borderWidth: 1.0,
      elevation: 3.0,
      isFrostedGlass: true,
      shadowColor: Colors.purple.withOpacity(0.20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            child: Icon(Icons.money, color: Colors.deepPurple),
            backgroundColor: Colors.white70,
          ),
          Container(child: Center(child: Text)),
        ],
      ),
    );
  }
}
