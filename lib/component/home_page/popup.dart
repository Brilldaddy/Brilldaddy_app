import 'package:flutter/material.dart';

class Popup extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onClose;

  const Popup({required this.imageUrl, required this.onClose, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Image.network(imageUrl),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onClose,
                child: const Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
