import 'package:flutter/material.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/main_header_appbar.dart';

class HealthCheckupScreen extends StatelessWidget {
  const HealthCheckupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MainHeaderAppBar(
                onClose: () {
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 20),

              Text(
                "Health Checkup",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: appColors.textPrimary,
                  fontSize: 28.0,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                "Track your vital health information",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: appColors.textSecondary,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 40.0),

              _buildDeviceCard(context),
              const SizedBox(height: 24),
              const Text(
                'Vital Signs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildVitalGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.favorite, color: Colors.pink),
        const SizedBox(width: 8),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Health Checkup',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Track your vital health information',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        const Icon(Icons.close, color: Colors.grey),
      ],
    );
  }

  Widget _buildDeviceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 76.0,
                height: 76.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.appColors.primary.withOpacity(0.1),
                ),
                child: ClipOval(child: Image.asset(Assets.appleWatchIcon)),
              ),

              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Apple Watch',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Syncing:',
                          style: TextStyle(
                            color: context.appColors.placeholder,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Heart rate, blood pressure...',
                            style: TextStyle(
                              color: context.appColors.textSecondary,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Last sync: 2 min ago',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                'Connected',
                style: TextStyle(
                  color: Color(0xFF4A7C59),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {},
              child: const Text('Manage Connection'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        VitalCard(
          icon: Icons.favorite_border,
          title: 'Heart Rate',
          value: '72 bpm • Normal',
        ),
        VitalCard(
          icon: Icons.show_chart,
          title: 'Blood Pressure',
          value: '120/80 mmHg',
        ),
        VitalCard(icon: Icons.bloodtype, title: 'Blood Type', value: 'A+'),
        VitalCard(
          icon: Icons.warning_amber_rounded,
          title: 'Allergies',
          value: 'Penicillin, Peanuts',
        ),
      ],
    );
  }
}

class VitalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const VitalCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}
