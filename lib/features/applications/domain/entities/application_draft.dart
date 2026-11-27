import 'job_application.dart';

final class ApplicationDraft {
  const ApplicationDraft({
    required this.dateApplied,
    required this.position,
    required this.company,
    required this.location,
    required this.experience,
    required this.portal,
    required this.jobLink,
    required this.status,
    required this.notes,
  });
  final DateTime? dateApplied;
  final String position;
  final String company;
  final String location;
  final String experience;
  final String portal;
  final String? jobLink;
  final ApplicationStatus status;
  final String notes;
}
