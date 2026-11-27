import '../entities/career_profile.dart';

abstract interface class ProfileRepository {
  Future<CareerProfile> getProfile();
  Future<void> saveProfile(CareerProfile profile);
}
