import 'package:flutter/material.dart';

class AppTitle extends StatelessWidget {
  const AppTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          "BONGISA MINE ",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text("R", style: TextStyle(color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold)),
        Text("D", style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold)),
        Text("C", style: TextStyle(color: Colors.yellow, fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }
}