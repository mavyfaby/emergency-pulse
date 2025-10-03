import 'package:flutter/material.dart';

class PulseMarker extends StatelessWidget {
  const PulseMarker({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image(
          image: const AssetImage("assets/marker.png"),
          height: 35,
          width: 40,
        ),
        Text(text, style: TextStyle(color: Colors.white)),
      ],
    );
  }
}
