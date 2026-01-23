import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/screens/tab/main_tab_screen.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/main_header_appbar.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/voice_reminder/voice_reminder_bloc.dart';
import '../../blocs/voice_reminder/voice_reminder_event.dart';
import '../../blocs/voice_reminder/voice_reminder_state.dart';
import '../../repositories/reminder/reminder_repository.dart';
import '../../services/openai_service.dart';

Widget _buildHeader(AppColors appColors) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Add Voice Reminder",
        style: TextStyle(
          fontWeight: FontWeight.w400,
          color: appColors.textPrimary,
          fontSize: 28,
        ),
      ),
      const SizedBox(height: 16),
      Text(
        "Just tell us what you need to remember",
        style: TextStyle(
          fontWeight: FontWeight.w400,
          color: appColors.textPrimary,
          fontSize: 16,
        ),
      ),
    ],
  );
}

class VoiceReminderScreen extends StatelessWidget {
  const VoiceReminderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VoiceReminderBloc(
        openAIService: OpenAIService(),
        reminderRepository: ReminderRepository(),
      ),
      child: const _VoiceReminderView(),
    );
  }
}

class _VoiceReminderView extends StatelessWidget {
  const _VoiceReminderView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Match current design
      body: AppGradientBackground(
        child: BlocConsumer<VoiceReminderBloc, VoiceReminderState>(
          listener: (context, state) {
            if (state is VoiceReminderSaved) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reminder Saved Successfully!')),
              );
              // Close or reset
              Navigator.of(context).pop();
            } else if (state is VoiceReminderError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is VoiceReminderLoaded) {
              return _ConfirmationView(state: state);
            } else if (state is VoiceReminderListening) {
              return _ListeningView(partialText: state.partialText);
            } else if (state is VoiceReminderProcessing) {
              return const Center(child: CircularProgressIndicator());
            }
            return const _InitialView();
          },
        ),
      ),
    );
  }
}

class _InitialView extends StatelessWidget {
  const _InitialView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Stack(
      children: [
        Positioned(
          top: 50.0,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MainHeaderAppBar(
                onClose: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainTabScreen(initialIndex: 0),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildHeader(appColors),
              const SizedBox(height: 20),
            ],
          ),
        ),

        Positioned(
          bottom: 140.0,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  context.read<VoiceReminderBloc>().add(StartListening());
                },
                child: Container(
                  width: 120,
                  height: 120,
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: appColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(Assets.micIcon, width: 60.0, height: 60.0),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Tap to add your voice',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: appColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: AppButton(
              text: "Convert",
              onPressed: () {
                context.read<VoiceReminderBloc>().add(StartListening());
              },
              backgroundColor: appColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ListeningView extends StatefulWidget {
  final String partialText;
  const _ListeningView({Key? key, required this.partialText}) : super(key: key);

  @override
  State<_ListeningView> createState() => _ListeningViewState();
}

class _ListeningViewState extends State<_ListeningView>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Stack(
      children: [
        Positioned(
          top: 60,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MainHeaderAppBar(
                onClose: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainTabScreen(initialIndex: 0),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildHeader(appColors),
              const SizedBox(height: 40),
              Text(
                widget.partialText.isEmpty
                    ? "Listening..."
                    : widget.partialText,
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.black54),
              ),
            ],
          ),
        ),

        Positioned(
          bottom: 140,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Rotating Border
                  RotationTransition(
                    turns: _rotationController,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            Colors.blue.withOpacity(0.0), // Transparent start
                            Colors.blue.withOpacity(0.5),
                            Colors.blue.shade600,
                            Colors.blue.withOpacity(
                              0.0,
                            ), // Transparent end/loop
                          ],
                          stops: const [0.0, 0.5, 0.75, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Pulsing Center Background
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50.withOpacity(0.5),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Central Blob/Icon Container
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      // Use a gradient to look like the "blob" in screenshot
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF8E2DE2),
                          Color(0xFF4A00E0),
                        ], // Purple to Blue
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.graphic_eq,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          left: 40,
          bottom: 180,
          child: FloatingActionButton(
            onPressed: () {},
            mini: true,
            backgroundColor: Colors.white,
            elevation: 2,
            child: const Icon(Icons.keyboard, color: Colors.black54),
          ),
        ),
        Positioned(
          right: 40,
          bottom: 180,
          child: FloatingActionButton(
            onPressed: () {
              context.read<VoiceReminderBloc>().add(StopListening());
            },
            mini: true,
            backgroundColor: Colors.red.shade50,
            elevation: 2,
            child: const Icon(Icons.close, color: Colors.red),
          ),
        ),

        Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: AppButton(
              text: "Convert",
              onPressed: () {
                context.read<VoiceReminderBloc>().add(
                  ProcessVoiceInput(widget.partialText),
                );
                // context.read<VoiceReminderBloc>().add(StopListening());
              },
              backgroundColor: appColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfirmationView extends StatelessWidget {
  final VoiceReminderLoaded state;
  const _ConfirmationView({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    // Get activeFamilyId from UserBloc
    final activeFamilyId = context.select<UserBloc, String?>((bloc) {
      final state = bloc.state;
      return (state is UserLoadedState) ? state.activeFamilyId : null;
    });

    return Scaffold(
      backgroundColor: appColors.bgColor,
      body: AppGradientBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MainHeaderAppBar(
                  onClose: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainTabScreen(initialIndex: 0),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _buildHeader(appColors),

                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32.0,
                        height: 32.0,

                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: appColors.primary,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Image.asset(
                          Assets.pillIcon,
                          width: 20.0,
                          height: 20.0,
                          color: appColors.bgColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.type,
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildLabel("Title"),
                _buildTextField(initialValue: state.title),

                const SizedBox(height: 16),
                _buildLabel("Date"),
                _buildTextField(
                  initialValue: DateFormat('MMM dd, yyyy').format(state.date),
                ),

                const SizedBox(height: 16),
                _buildLabel("Time"),
                _buildTextField(
                  initialValue: state.time,
                ), // Should use TimePicker ideally

                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<VoiceReminderBloc>().add(
                              ResetVoiceReminder(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Try Again",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 55,
                        child: AppButton(
                          text: "Confirm",
                          onPressed: () {
                            final familyId = activeFamilyId;
                            if (familyId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('User not logged in'),
                                ),
                              );
                              return;
                            }

                            context.read<VoiceReminderBloc>().add(
                              ConfirmReminder(
                                title: state.title,
                                date: state.date,
                                time: state.time,
                                activeFamilyId: familyId,
                                type: state.type,
                                medicineName: state.medicineName,
                                dose: state.dose,
                                duration: state.duration,
                              ),
                            );
                          },
                          backgroundColor: appColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
      ),
    );
  }

  Widget _buildTextField({required String initialValue}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50, // Slight grey for input
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        initialValue: initialValue,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
