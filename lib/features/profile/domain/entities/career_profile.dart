/// Career preferences and work history kept private to this device.
class CareerProfile {
  const CareerProfile({
    this.position = '',
    this.company = '',
    this.companyDetails = '',
    this.currentCtc = '',
    this.expectedCtc = '',
    this.experienceYears = '',
    this.experienceStartDate,
    this.experienceDetails = const [],
    this.currentLocation = '',
    this.expectedLocations = const [],
  });

  final String position;
  final String company;
  final String companyDetails;
  final String currentCtc;
  final String expectedCtc;
  final String experienceYears;
  final DateTime? experienceStartDate;
  final List<String> experienceDetails;
  final String currentLocation;
  final List<String> expectedLocations;

  CareerProfile copyWith({
    String? position,
    String? company,
    String? companyDetails,
    String? currentCtc,
    String? expectedCtc,
    String? experienceYears,
    DateTime? experienceStartDate,
    List<String>? experienceDetails,
    String? currentLocation,
    List<String>? expectedLocations,
  }) => CareerProfile(
    position: position ?? this.position,
    company: company ?? this.company,
    companyDetails: companyDetails ?? this.companyDetails,
    currentCtc: currentCtc ?? this.currentCtc,
    expectedCtc: expectedCtc ?? this.expectedCtc,
    experienceYears: experienceYears ?? this.experienceYears,
    experienceStartDate: experienceStartDate ?? this.experienceStartDate,
    experienceDetails: experienceDetails ?? this.experienceDetails,
    currentLocation: currentLocation ?? this.currentLocation,
    expectedLocations: expectedLocations ?? this.expectedLocations,
  );
}
