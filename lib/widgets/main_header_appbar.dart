import 'package:flutter/material.dart';
import 'package:remindus/generated/assets.dart';

class MainHeaderAppBar extends StatelessWidget {
  final VoidCallback? onClose;

  const MainHeaderAppBar({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(Assets.logoIcon, height: 28, width: 28),
        IconButton(
          icon: const Icon(Icons.close, size: 24.0),
          onPressed: onClose ?? () => Navigator.pop(context),
        ),
      ],
    );
  }
}
