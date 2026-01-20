import 'package:remindus/models/guardian_model.dart';

abstract class BaseGuardianRepository {
  Future<void> addMember(
    String guardianEmail,
    String selectedAccessLevel,
    String guardianName,
    String relationship,
    String activeFamilyId,
  );

  Future<bool> updateGuardianData(
    String guardianId,
    GuardianModel updatedGuardianData,
    String activeFamilyId,
  );

  Future<bool> deleteGuardian(
  String guardianId,
  String activeFamilyId,
);

}
