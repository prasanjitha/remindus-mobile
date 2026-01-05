import 'package:flutter/material.dart';

class ZoomedImage extends StatelessWidget {
  final String imagePath;
  final double scale;
  final Alignment alignment;

  const ZoomedImage({
    super.key,
    required this.imagePath,
    this.scale = 1.0,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Transform.scale(
        scale: scale,
        alignment: alignment,
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}