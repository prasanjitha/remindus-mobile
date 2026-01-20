import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/models/guardian_model.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/main_header_appbar.dart';
import 'package:remindus/widgets/profile/guardian_tile.dart';

class AddGuardientSuccessScreen extends StatelessWidget {
  final GuardianModel ? guardianModel;
  const AddGuardientSuccessScreen({
    super.key,
    this.guardianModel,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final canEdit = context.select<UserBloc, bool>((bloc) {
      final state = bloc.state;
      return state is UserLoadedState ? state.isAdmin : false;
    });
    return Scaffold(
      backgroundColor: appColors.bgColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              Assets.bgColorMap,
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.6),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MainHeaderAppBar(),
                const SizedBox(height: 20.0),

                Text(
                  "Invitation Sent",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: appColors.textPrimary,
                    fontSize: 28.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  "${guardianModel?.name ?? 'Unknown'} will receive an email invitation",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: appColors.textSecondary,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 32),
                GuardianTile(
                  canEdit: canEdit,
                  guardianModel: GuardianModel(
                    name: guardianModel?.name,
                    relationship: guardianModel?.relationship,
                    accessLevel: guardianModel?.accessLevel,
                  ),
                  checkStatus: "Pending",
                  
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: AppButton(
              text: "Done",
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              backgroundColor: appColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
