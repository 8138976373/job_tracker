import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/application_draft.dart';
import '../../domain/entities/application_page.dart';
import '../../domain/entities/job_application.dart';
import '../../domain/repositories/job_application_repository.dart';
import '../datasources/job_application_remote_data_source.dart';

final class JobApplicationRepositoryImpl implements JobApplicationRepository {
  const JobApplicationRepositoryImpl(this._dataSource);
  final JobApplicationRemoteDataSource _dataSource;

  @override
  Future<Result<ApplicationSummary>> summary() => _run(_dataSource.summary);
  @override
  Future<Result<ApplicationPage>> list({
    String? search,
    ApplicationStatus? status,
    int page = 0,
  }) =>
      _run(() => _dataSource.list(search: search, status: status, page: page));
  @override
  Future<Result<JobApplication>> create(ApplicationDraft draft) =>
      _run(() => _dataSource.create(draft));
  @override
  Future<Result<JobApplication>> update(
    JobApplication current,
    ApplicationDraft draft,
  ) => _run(() => _dataSource.update(current, draft));
  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _dataSource.delete(id);
      return const Success<void>(null);
    } on ApiException catch (error) {
      return Failure(UnexpectedFailure(error.message));
    } on Exception {
      return const Failure(
        UnexpectedFailure(
          'Could not delete this application. Please try again.',
        ),
      );
    }
  }

  Future<Result<T>> _run<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on ApiException catch (error) {
      return Failure(UnexpectedFailure(error.message));
    } on TypeError {
      return const Failure(
        UnexpectedFailure('The server returned data in an unexpected format.'),
      );
    } on Exception {
      return const Failure(
        UnexpectedFailure('Could not complete the request. Please try again.'),
      );
    }
  }
}
