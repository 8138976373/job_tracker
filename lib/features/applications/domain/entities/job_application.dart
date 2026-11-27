enum ApplicationStatus {
  saved,
  applied,
  assessment,
  interview,
  offer,
  rejected,
  withdrawn,
}

extension ApplicationStatusLabel on ApplicationStatus {
  String get label => switch (this) {
    ApplicationStatus.saved => 'Saved',
    ApplicationStatus.applied => 'Applied',
    ApplicationStatus.assessment => 'Assessment',
    ApplicationStatus.interview => 'Interview',
    ApplicationStatus.offer => 'Offer',
    ApplicationStatus.rejected => 'Rejected',
    ApplicationStatus.withdrawn => 'Withdrawn',
  };
  String get wireValue => name.toUpperCase();
  static ApplicationStatus fromWire(String value) => ApplicationStatus.values
      .firstWhere((status) => status.wireValue == value);
}

class JobApplication {
  const JobApplication({
    required this.id,
    required this.dateApplied,
    required this.position,
    required this.company,
    required this.location,
    required this.experience,
    required this.portal,
    required this.jobLink,
    required this.status,
    required this.notes,
    required this.updatedAt,
    required this.version,
  });
  final String id;
  final DateTime? dateApplied;
  final String position;
  final String company;
  final String location;
  final String experience;
  final String portal;
  final String? jobLink;
  final ApplicationStatus status;
  final String notes;
  final DateTime updatedAt;
  final int version;
}

ApplicationStatus applicationStatusFromWire(String value) =>
    ApplicationStatus.values.firstWhere((status) => status.wireValue == value);
