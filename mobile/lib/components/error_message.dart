import 'package:flutter/material.dart';

class ErrorMessageText extends StatelessWidget {
  final String text;

  const ErrorMessageText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Theme.of(context).colorScheme.error,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
    );
  }
}
