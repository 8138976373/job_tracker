import '../../../../core/utils/result.dart';
import '../entities/application_draft.dart';
import '../entities/application_page.dart';
import '../entities/job_application.dart';

abstract interface class JobApplicationRepository {
  Future<Result<ApplicationSummary>> summary();
  Future<Result<ApplicationPage>> list({
    String? search,
    ApplicationStatus? status,
    int page = 0,
  });
  Future<Result<JobApplication>> create(ApplicationDraft draft);
  Future<Result<JobApplication>> update(
    JobApplication current,
    ApplicationDraft draft,
  );
  Future<Result<void>> delete(String id);
}
