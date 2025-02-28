// ignore_for_file: file_names

import 'package:flutter/material.dart';

class WishlistDialog extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  WishlistDialog({required this.message, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              message,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
