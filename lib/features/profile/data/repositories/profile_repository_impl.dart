import '../../domain/entities/career_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/career_profile_model.dart';

final class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._dataSource);
  final ProfileRemoteDataSource _dataSource;
  @override
  Future<CareerProfile> getProfile() => _dataSource.read();
  @override
  Future<void> saveProfile(CareerProfile profile) => _dataSource.write(
    CareerProfileModel(
      position: profile.position,
      company: profile.company,
      companyDetails: profile.companyDetails,
      currentCtc: profile.currentCtc,
      expectedCtc: profile.expectedCtc,
      experienceYears: profile.experienceYears,
      experienceStartDate: profile.experienceStartDate,
      experienceDetails: profile.experienceDetails,
      currentLocation: profile.currentLocation,
      expectedLocations: profile.expectedLocations,
    ),
  );
}
