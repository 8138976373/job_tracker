import '../../domain/entities/career_profile.dart';

final class CareerProfileModel extends CareerProfile {
  const CareerProfileModel({
    super.position,
    super.company,
    super.companyDetails,
    super.currentCtc,
    super.expectedCtc,
    super.experienceYears,
    super.experienceStartDate,
    super.experienceDetails,
    super.currentLocation,
    super.expectedLocations,
  });

  factory CareerProfileModel.fromJson(Map<String, dynamic> json) =>
      CareerProfileModel(
        position: json['position'] as String? ?? '',
        company: json['company'] as String? ?? '',
        companyDetails: json['companyDetails'] as String? ?? '',
        currentCtc: json['currentCtc'] as String? ?? '',
        expectedCtc: json['expectedCtc'] as String? ?? '',
        experienceYears: json['experienceYears'] as String? ?? '',
        experienceStartDate: json['experienceStartDate'] == null
            ? null
            : DateTime.tryParse(json['experienceStartDate'] as String),
        experienceDetails: (json['experienceDetails'] as List<dynamic>? ?? [])
            .cast<String>(),
        currentLocation: json['currentLocation'] as String? ?? '',
        expectedLocations: (json['expectedLocations'] as List<dynamic>? ?? [])
            .cast<String>(),
      );

  Map<String, dynamic> toJson() => {
    'position': position,
    'company': company,
    'companyDetails': companyDetails,
    'currentCtc': currentCtc,
    'expectedCtc': expectedCtc,
    'experienceYears': experienceYears,
    'experienceStartDate': experienceStartDate?.toIso8601String(),
    'experienceDetails': experienceDetails,
    'currentLocation': currentLocation,
    'expectedLocations': expectedLocations,
  };
}
