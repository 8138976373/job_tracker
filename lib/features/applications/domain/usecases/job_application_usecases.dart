import '../../../../core/utils/result.dart';
import '../entities/application_draft.dart';
import '../entities/application_page.dart';
import '../entities/job_application.dart';
import '../repositories/job_application_repository.dart';

final class GetApplicationSummary {
  const GetApplicationSummary(this._repository);
  final JobApplicationRepository _repository;
  Future<Result<ApplicationSummary>> call() => _repository.summary();
}

final class GetJobApplications {
  const GetJobApplications(this._repository);
  final JobApplicationRepository _repository;
  Future<Result<ApplicationPage>> call({
    String? search,
    ApplicationStatus? status,
    int page = 0,
  }) => _repository.list(search: search, status: status, page: page);
}

final class SaveJobApplication {
  const SaveJobApplication(this._repository);
  final JobApplicationRepository _repository;
  Future<Result<JobApplication>> create(ApplicationDraft draft) =>
      _repository.create(draft);
  Future<Result<JobApplication>> update(
    JobApplication current,
    ApplicationDraft draft,
  ) => _repository.update(current, draft);
}

final class DeleteJobApplication {
  const DeleteJobApplication(this._repository);
  final JobApplicationRepository _repository;
  Future<Result<void>> call(String id) => _repository.delete(id);
}
