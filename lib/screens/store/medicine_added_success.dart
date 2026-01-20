import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';

import 'package:remindus/generated/assets.dart';
import 'package:remindus/models/medicine_store_model.dart';
import 'package:remindus/screens/tab/main_tab_screen.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/medicine_card.dart';

class MedicineAddedSuccessScreen extends StatelessWidget {
  final MedicineStoreModel medicine;
  const MedicineAddedSuccessScreen({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
         final canEdit = context.select<UserBloc, bool>((bloc) {
      final state = bloc.state;
      return state is UserLoadedState ? state.isAdmin : false;
    });
            
    final appColors = context.appColors;
    return Scaffold(
      backgroundColor: appColors.bgColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              Assets.bgColorMap,
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 50.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(Assets.logoIcon, width: 28.0, height: 28.0),

                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainTabScreen(),
                          ),
                        );
                      },
                      icon: Icon(Icons.close, size: 24.0),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Text(
                  'Added Successfully',
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.w400,
                    color: appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your medicine has been saved',
                  style: TextStyle(
                    fontSize: 16,
                    color: appColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 46.0),
                MedicineCard(
                  canEdit: canEdit,
                  isSuccess: true,
                  name: medicine.name ?? "Medicine Name",
                  detail: "Remaining: ${medicine.quantity ?? 0} Tablets",
                  status: MedicineStatus.wellStocked,
                  onEdit: () {
                    // Handle edit action
                  },
                  onDelete: () {
                    // Handle delete action
                  },
                ),
                const Spacer(),
                AppButton(
                  text: "Done",
                  backgroundColor: appColors.primary,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MainTabScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
