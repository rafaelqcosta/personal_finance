import 'package:flutter/material.dart';

class DSIconButton extends StatelessWidget {
  final Function()? onPressed;
  final IconData icon;
  const DSIconButton({super.key, this.onPressed, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      width: 45,
      child: Card(
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.grey[850]),
          splashRadius: 12,
          iconSize: 16,
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
