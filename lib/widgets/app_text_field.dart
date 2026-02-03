import 'package:flutter/material.dart';

import 'package:remindus/theme/app_colors.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final Widget? suffixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String prefixIconPath;
  final bool? readOnly;
  final VoidCallback? onSuffixTap;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.isPassword = false,
    this.controller,
    this.validator,
    required this.prefixIconPath,
    this.suffixIcon,
    this.readOnly = false,
    this.onSuffixTap,
    this.onChanged,
    this.focusNode,
    this.keyboardType,
    this.onTap,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: context.appColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          readOnly: widget.readOnly!,
          controller: widget.controller,
          obscureText: _obscureText,
          validator: widget.validator,
          onChanged: widget.onChanged,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          onTap: widget.onTap,
          decoration: InputDecoration(
            hintText: widget.hintText,
            suffixIconConstraints: BoxConstraints(
              minWidth: 24.0,
              minHeight: 24.0,
            ),
            hintStyle: TextStyle(
              color: context.appColors.placeholder,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
            suffixIcon: widget.isPassword
                ? Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: context.appColors.placeholder,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  )
                : widget.suffixIcon != null
                ? GestureDetector(
                    onTap: widget.onSuffixTap,
                    child: widget.suffixIcon,
                  )
                : null,
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                widget.prefixIconPath,
                width: 20,
                height: 20,
                color: context.appColors.placeholder,
              ),
            ),
            filled: true,
            fillColor: context.appColors.bgColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: context.appColors.surfceSecondary,
                width: 1.2,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: context.appColors.primary,
                width: 1.5,
              ),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red, // error
                width: 1.2,
              ),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
