import '../../../../core/network/api_client.dart';
import '../models/career_profile_model.dart';

final class ProfileRemoteDataSource {
  const ProfileRemoteDataSource(this._apiClient);
  final ApiClient _apiClient;

  Future<CareerProfileModel> read() async => CareerProfileModel.fromJson(
    Map<String, dynamic>.from(await _apiClient.get('profile') as Map),
  );

  Future<void> write(CareerProfileModel profile) =>
      _apiClient.put('profile', body: profile.toJson());
}
