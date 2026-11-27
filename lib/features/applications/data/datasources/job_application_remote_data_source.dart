import '../../../../core/network/api_client.dart';
import '../../domain/entities/application_draft.dart';
import '../../domain/entities/application_page.dart';
import '../../domain/entities/job_application.dart';
import '../../domain/repositories/job_application_repository.dart';
import '../models/job_application_model.dart';

final class JobApplicationRemoteDataSource {
  const JobApplicationRemoteDataSource(this._apiClient);
  final ApiClient _apiClient;

  Future<ApplicationSummary> summary() async {
    final response = await _apiClient.get(
      'job-applications/summary',
    ) as Map<String, dynamic>;
    return ApplicationSummary(
      total: response['total'] as int,
      active: response['active'] as int,
      interviews: response['interviews'] as int,
      offers: response['offers'] as int,
      rejected: response['rejected'] as int,
    );
  }

  Future<ApplicationPage> list({
    String? search,
    ApplicationStatus? status,
    int page = 0,
  }) async {
    final query = <String, String>{'page': '$page', 'size': '100'};
    if (search != null && search.trim().isNotEmpty)
      query['search'] = search.trim();
    if (status != null) query['status'] = status.wireValue;
    final response = await _apiClient.get(
      'job-applications',
      query: query,
    ) as Map<String, dynamic>;
    final items = (response['items'] as List<dynamic>)
        .map(
          (item) => JobApplicationModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList(growable: false);
    return ApplicationPage(
      items: items,
      page: response['page'] as int,
      totalPages: response['totalPages'] as int,
      totalItems: response['totalItems'] as int,
    );
  }

  Future<JobApplication> create(ApplicationDraft draft) async {
    final response = await _apiClient.post(
      'job-applications',
      body: _draftJson(draft),
    ) as Map<String, dynamic>;
    return JobApplicationModel.fromJson(response);
  }

  Future<JobApplication> update(
    JobApplication current,
    ApplicationDraft draft,
  ) async {
    final response = await _apiClient.put(
      'job-applications/${current.id}',
      body: {'version': current.version, 'application': _draftJson(draft)},
    ) as Map<String, dynamic>;
    return JobApplicationModel.fromJson(response);
  }

  Future<void> delete(String id) => _apiClient.delete('job-applications/$id');

  Map<String, dynamic> _draftJson(ApplicationDraft draft) => {
    'dateApplied': draft.dateApplied == null
        ? null
        : '${draft.dateApplied!.year.toString().padLeft(4, '0')}-${draft.dateApplied!.month.toString().padLeft(2, '0')}-${draft.dateApplied!.day.toString().padLeft(2, '0')}',
    'position': draft.position,
    'company': draft.company,
    'location': draft.location,
    'experience': draft.experience,
    'portal': draft.portal,
    'jobLink': draft.jobLink,
    'status': draft.status.wireValue,
    'notes': draft.notes,
  };
}
