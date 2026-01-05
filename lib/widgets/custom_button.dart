import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;
  final bool? isLoading;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isOutlined = false,
    this.isLoading=false
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : (backgroundColor ?? Theme.of(context).colorScheme.primary),
          foregroundColor: textColor ?? (isOutlined ? Theme.of(context).colorScheme.primary : Colors.white),
          elevation: 0 ,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isOutlined ? BorderSide(color: Theme.of(context).colorScheme.primary) : BorderSide.none,
          ),
        ),
        child: (isLoading == true) ? CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            textColor ?? (isOutlined ? Theme.of(context).colorScheme.primary : Colors.white),
          ),
        ) : Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: textColor ?? (isOutlined ? Theme.of(context).colorScheme.primary : Colors.white),
          ),
        ),
      ),
    );
  }
}