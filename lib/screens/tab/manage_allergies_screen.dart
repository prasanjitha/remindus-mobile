import 'package:flutter/material.dart';
import 'package:remindus/screens/tab/allergy_summary_screen.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/manage_allergies_screen.dart';

class ManageAllergiesScreen extends StatefulWidget {
  const ManageAllergiesScreen({super.key});

  @override
  State<ManageAllergiesScreen> createState() => _ManageAllergiesScreenState();
}

class _ManageAllergiesScreenState extends State<ManageAllergiesScreen> {
  // Data Structure to hold all selections
  final Map<String, List<String>> _sections = {
    "Meds": [
      "Ketoprofen",
      "Etodolac",
      "Valdecoxib",
      "Erythromycins",
      "Doxycycline",
      "Azithromycin",
    ],
    "Food": [
      "Shellfish",
      "Finned fish",
      "Soy",
      "Lentils",
      "Chickpeas",
      "Lupins",
    ],
    "Insect": ["Stinging Insects", "Biting Insects", "Pests", "Nuts", "Dairy"],
    "External": ["Dogs", "Rabbits", "Birds", "Horses", "Ragweed"],
  };

  // Set to track user selections
  final Map<String, Set<String>> _selectedAllergies = {
    "Meds": {},
    "Food": {},
    "Insect": {},
    "External": {},
  };

  String _activeTab = "Meds";

  void _toggleSelection(String section, String item) {
    setState(() {
      if (_selectedAllergies[section]!.contains(item)) {
        _selectedAllergies[section]!.remove(item);
      } else {
        _selectedAllergies[section]!.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ManageAllergiesHeader(
                        title: "Manage Allergies",
                        subtitle: "Keep track of what you're allergic to",
                        onBackTap: () => Navigator.of(context).pop(),
                        onCloseTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: 20.0),
                      _buildTabSwitcher(appColors),
                      const SizedBox(height: 20.0),
                      _buildAllergyList(appColors),
                    ],
                  ),
                ),
              ),

              // 2. Pinned Bottom Button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: AppButton(
                  text: 'Save',
                  onPressed: () {
                    // Logic to show summary or navigate

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AllergySummaryScreen(
                          selectedData: _selectedAllergies,
                        ),
                      ),
                    );
                  },
                  backgroundColor: appColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSwitcher(dynamic appColors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _sections.keys.map((tab) {
        bool isActive = _activeTab == tab;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _activeTab = tab),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isActive
                    ? appColors.primaryLightBlue
                    : appColors.bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  tab,
                  style: TextStyle(
                    color: appColors.textPrimary,
                    fontSize: 16.0,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAllergyList(dynamic appColors) {
    List<String> items = _sections[_activeTab]!;
    return Column(
      children: items.map((item) {
        bool isSelected = _selectedAllergies[_activeTab]!.contains(item);
        return GestureDetector(
          onTap: () => _toggleSelection(_activeTab, item),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: appColors.bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: isSelected
                      ? appColors.primary
                      : appColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  item,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: appColors.textPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
