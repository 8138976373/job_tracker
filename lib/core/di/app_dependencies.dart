import '../../features/applications/data/datasources/job_application_remote_data_source.dart';
import '../../features/applications/data/repositories/job_application_repository_impl.dart';
import '../../features/applications/domain/repositories/job_application_repository.dart';
import '../../features/applications/domain/usecases/job_application_usecases.dart';
import '../../features/applications/presentation/providers/job_application_view_model.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/authenticate.dart';
import '../../features/auth/presentation/providers/auth_view_model.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/profile_usecases.dart';
import '../../features/profile/presentation/providers/profile_view_model.dart';
import '../network/api_client.dart';
import '../network/secure_token_store.dart';
import '../network/token_store.dart';
import 'service_locator.dart';

/// Composition root. Concrete network/storage adapters are wired to domain ports here.
final class AppDependencies {
  AppDependencies._(this.locator);
  final ServiceLocator locator;

  static AppDependencies create() {
    final locator = ServiceLocator();
    locator.registerSingleton<TokenStore>(SecureTokenStore());
    locator.registerSingleton<ApiClient>(
      ApiClient(tokenStore: locator.get<TokenStore>()),
    );

    locator.registerSingleton<AuthRemoteDataSource>(
      AuthRemoteDataSource(
        apiClient: locator.get<ApiClient>(),
        tokenStore: locator.get<TokenStore>(),
      ),
    );
    locator.registerSingleton<AuthRepository>(
      AuthRepositoryImpl(locator.get<AuthRemoteDataSource>()),
    );
    locator.registerSingleton<Authenticate>(
      Authenticate(locator.get<AuthRepository>()),
    );
    locator.registerSingleton<AuthViewModel>(
      AuthViewModel(locator.get<Authenticate>(), locator.get<AuthRepository>()),
    );

    locator.registerSingleton<JobApplicationRemoteDataSource>(
      JobApplicationRemoteDataSource(locator.get<ApiClient>()),
    );
    locator.registerSingleton<JobApplicationRepository>(
      JobApplicationRepositoryImpl(
        locator.get<JobApplicationRemoteDataSource>(),
      ),
    );
    locator.registerSingleton<GetJobApplications>(
      GetJobApplications(locator.get<JobApplicationRepository>()),
    );
    locator.registerSingleton<GetApplicationSummary>(
      GetApplicationSummary(locator.get<JobApplicationRepository>()),
    );
    locator.registerSingleton<SaveJobApplication>(
      SaveJobApplication(locator.get<JobApplicationRepository>()),
    );
    locator.registerSingleton<DeleteJobApplication>(
      DeleteJobApplication(locator.get<JobApplicationRepository>()),
    );
    locator.registerSingleton<JobApplicationViewModel>(
      JobApplicationViewModel(
        getApplications: locator.get<GetJobApplications>(),
        getSummary: locator.get<GetApplicationSummary>(),
        saveApplication: locator.get<SaveJobApplication>(),
        deleteApplication: locator.get<DeleteJobApplication>(),
      ),
    );
    locator.registerSingleton<ProfileRemoteDataSource>(
      ProfileRemoteDataSource(locator.get<ApiClient>()),
    );
    locator.registerSingleton<ProfileRepository>(
      ProfileRepositoryImpl(locator.get<ProfileRemoteDataSource>()),
    );
    locator.registerSingleton<GetCareerProfile>(
      GetCareerProfile(locator.get<ProfileRepository>()),
    );
    locator.registerSingleton<SaveCareerProfile>(
      SaveCareerProfile(locator.get<ProfileRepository>()),
    );
    locator.registerSingleton<ProfileViewModel>(
      ProfileViewModel(
        getProfile: locator.get<GetCareerProfile>(),
        saveProfile: locator.get<SaveCareerProfile>(),
      ),
    );
    return AppDependencies._(locator);
  }
}
