import '../../domain/entities/application_draft.dart';
import '../../domain/entities/job_application.dart';

final class JobApplicationModel extends JobApplication {
  const JobApplicationModel({
    required super.id,
    required super.dateApplied,
    required super.position,
    required super.company,
    required super.location,
    required super.experience,
    required super.portal,
    required super.jobLink,
    required super.status,
    required super.notes,
    required super.updatedAt,
    required super.version,
  });

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) =>
      JobApplicationModel(
        id: json['id'] as String,
        dateApplied: json['dateApplied'] == null
            ? null
            : DateTime.parse(json['dateApplied'] as String),
        position: json['position'] as String,
        company: json['company'] as String,
        location: json['location'] as String,
        experience: json['experience'] as String,
        portal: json['portal'] as String,
        jobLink: json['jobLink'] as String?,
        status: applicationStatusFromWire(json['status'] as String),
        notes: json['notes'] as String? ?? '',
        updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
        version: json['version'] as int,
      );

  Map<String, dynamic> toJson(ApplicationDraft draft) => {
    'dateApplied': draft.dateApplied == null
        ? null
        : _dateOnly(draft.dateApplied!),
    'position': draft.position,
    'company': draft.company,
    'location': draft.location,
    'experience': draft.experience,
    'portal': draft.portal,
    'jobLink': draft.jobLink,
    'status': draft.status.wireValue,
    'notes': draft.notes,
  };

  static String _dateOnly(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
