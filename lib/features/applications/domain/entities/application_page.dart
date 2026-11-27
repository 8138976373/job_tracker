import 'job_application.dart';

final class ApplicationPage {
  const ApplicationPage({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalItems,
  });
  final List<JobApplication> items;
  final int page;
  final int totalPages;
  final int totalItems;
}

final class ApplicationSummary {
  const ApplicationSummary({
    required this.total,
    required this.active,
    required this.interviews,
    required this.offers,
    required this.rejected,
  });
  final int total;
  final int active;
  final int interviews;
  final int offers;
  final int rejected;
}
