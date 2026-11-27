import 'package:flutter/foundation.dart';
import '../../domain/entities/career_profile.dart';
import '../../domain/usecases/profile_usecases.dart';

final class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({
    required GetCareerProfile getProfile,
    required SaveCareerProfile saveProfile,
  }) : _getProfile = getProfile,
       _saveProfile = saveProfile;
  final GetCareerProfile _getProfile;
  final SaveCareerProfile _saveProfile;
  CareerProfile profile = const CareerProfile();
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      profile = await _getProfile();
    } catch (_) {
      errorMessage = 'Could not load your profile. Please try again.';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> save(CareerProfile value) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _saveProfile(value);
      profile = value;
      return true;
    } catch (_) {
      errorMessage = 'Could not save your profile. Please try again.';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
