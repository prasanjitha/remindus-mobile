import 'package:flutter/material.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/models/guardian_model.dart';
import 'package:remindus/screens/profile/add_guardian_screen.dart';
import 'package:remindus/theme/app_colors.dart';

class GuardianTile extends StatelessWidget {
  final GuardianModel guardianModel;
  final String? checkStatus;
  final bool canEdit;

  const GuardianTile({
    super.key,
    required this.guardianModel,
    this.checkStatus,
    required this.canEdit,
  });

  @override
  Widget build(BuildContext context) {
    final appColor = context.appColors;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: appColor.bgColor,
      elevation: 0,
      child: ListTile(
        leading: CircleAvatar(
          radius: 26.0,
          backgroundColor: appColor.primary,
          child: Text(
            guardianModel.name!.isNotEmpty
                ? guardianModel.name![0].toUpperCase()
                : '',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: appColor.bgColor,
              fontSize: 28.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        title: Text(
          guardianModel.name ?? '',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: appColor.textPrimary,
            fontSize: 18.0,
          ),
        ),
        subtitle: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          runSpacing: 2,
          children: [
            Text(
              guardianModel.relationship ?? '',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: appColor.textPrimary,
                fontSize: 14.0,
              ),
            ),
          
            Text(
              " . ",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: appColor.textPrimary,
                fontSize: 16.0,
              ),
            ),
            Text(
              guardianModel.accessLevel ?? '',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: appColor.textPrimary,
                fontSize: 14.0,
              ),
            ),
            if (checkStatus!.isNotEmpty) ...[
              Text(
                " . ",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: appColor.textPrimary,
                  fontSize: 16.0,
                ),
              ),
              Text(
                checkStatus!,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: checkStatus!.toLowerCase() == 'pending'
                      ? Colors.orange
                      : appColor.textPrimary,
                  fontSize: 14.0,
                ),
              ),
            ],
          ],
        ),
        trailing: canEdit==true? GestureDetector(
          onTap: () {
                 Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  AddGuardianScreen(
                  guardianModel: guardianModel,
                  isEditFlow: true,

                ),
                ),
              );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(Assets.settings02Icon, width: 20.0, height: 20.0),
              const SizedBox(width: 10.0),
              Image.asset(Assets.arrowUpIcon, width: 20.0, height: 20.0),
            ],
          ),
        ):null,
        onTap: () {},
      ),
    );
  }
}
