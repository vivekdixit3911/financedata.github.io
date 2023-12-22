import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class sahres extends StatelessWidget {
  const sahres({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 205, 201, 201),
      body: ListView(
        children: [
          Column(children: [
            Row(
              children: [sqaures(), sqaures()],
            ),
            Row(
              children: [sqaures(), sqaures()],
            ),
            Row(
              children: [sqaures(), sqaures()],
            ),
            Row(
              children: [sqaures(), sqaures()],
            ),
            Row(
              children: [sqaures(), sqaures()],
            ),
            Row(
              children: [sqaures(), sqaures()],
            ),
          ]),
        ],
      ),
    );
  }
}

class sqaures extends StatelessWidget {
  const sqaures({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
            height: 200,
            width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.elliptical(20, 20)),
              color: Color.fromARGB(224, 255, 255, 255),
              border: Border.all(color: Color.fromARGB(255, 186, 182, 182)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.elliptical(12, 12)),
                      border:
                          Border.all(color: Color.fromARGB(255, 208, 207, 207)),
                    ),
                    child: Icon(
                      FontAwesomeIcons.apple,
                      size: 46,
                      color: Color.fromRGBO(179, 179, 179, 1.0),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "  Apple",
                    style: TextStyle(
                        color: const Color.fromARGB(255, 126, 124, 124),
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    "  ₹1206.2",
                    style: TextStyle(
                        color: const Color.fromARGB(255, 126, 124, 124),
                        fontWeight: FontWeight.w800),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "  ₹1206.2",
                    style: TextStyle(
                        color: Color.fromARGB(163, 7, 220, 128),
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
