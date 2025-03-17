import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonStyle? buttonStyle;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.buttonStyle,
  });

  @override
  Widget build(BuildContext context)
  {
    return ElevatedButton(
      onPressed: onPressed,
      style: buttonStyle??
          ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            side: BorderSide(color: Colors.green.withValues(alpha: 127), width: 2),
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
      child: Text(
        text,
        style: TextStyle(fontSize: 20, fontFamily: 'Orbitron', color: Colors.green),
      ),
    );
  }
}