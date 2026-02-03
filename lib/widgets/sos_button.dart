import 'package:flutter/material.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/theme/app_colors.dart';

class SOSButton extends StatefulWidget {
  final VoidCallback onTriggered;

  const SOSButton({super.key, required this.onTriggered});

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isCompleted = true;
        });
        widget.onTriggered();
      }
    });
  }

  // මෙන්න මේ function එකෙන් තමයි නැවත මුල් තත්වයට පත් කරන්නේ
  void _resetButton() {
    setState(() {
      _isCompleted = false;
      _controller.reset(); // Progress indicator එක සහ controller එක reset කරයි
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return GestureDetector(
      onLongPressStart: (_) {
        if (!_isCompleted) _controller.forward();
      },
      onLongPressEnd: (_) {
        if (!_isCompleted) _controller.reverse();
      },
      child: AnimatedBuilder(
        // <--- මුළු Stack එකම මේක ඇතුළට දාන්න
        animation: _controller,
        builder: (context, child) {
          // මෙන්න මෙතනදී තමයි dynamic color එක තීරණය වෙන්නේ
          final Color buttonColor = (_controller.value > 0 && !_isCompleted)
              ? appColors.errorRed!.withOpacity(0.5) // Progress වෙන වෙලාවට
              : appColors.errorRed!; // සාමාන්‍ය වෙලාවට සහ completed වෙලාවට

          return Stack(
            alignment: Alignment.center,
            children: [
              // Circular Progress Border
              SizedBox(
                width: 145.0,
                height: 145.0,
                child: CircularProgressIndicator(
                  value: _controller.value,
                  strokeWidth: 8,
                  backgroundColor: Colors.red.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),

              // Main Red Circle
              Stack(
                children: [
                  Container(
                    width: 140.0,
                    height: 140.0,
                    decoration: BoxDecoration(
                      color: buttonColor, // මෙතනට උඩින් හදපු variable එක දෙන්න
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: _isCompleted
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: _resetButton,
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                                const Text(
                                  "911",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Image.asset(
                              Assets.healthAmbulanceIcon,
                              width: 60,
                              height: 60,
                              color: appColors.bgColor,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  if (_isCompleted) ...[
                    Positioned(
                      left: 30.0,
                      child: Container(
                        width: 140.0,
                        height: 140.0,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
