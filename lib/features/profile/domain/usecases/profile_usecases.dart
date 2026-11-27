import '../entities/career_profile.dart';
import '../repositories/profile_repository.dart';

final class GetCareerProfile {
  const GetCareerProfile(this._repository);
  final ProfileRepository _repository;
  Future<CareerProfile> call() => _repository.getProfile();
}

final class SaveCareerProfile {
  const SaveCareerProfile(this._repository);
  final ProfileRepository _repository;
  Future<void> call(CareerProfile profile) => _repository.saveProfile(profile);
}
