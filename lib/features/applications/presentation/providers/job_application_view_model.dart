import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/application_draft.dart';
import '../../domain/entities/application_page.dart';
import '../../domain/entities/job_application.dart';
import '../../domain/repositories/job_application_repository.dart';
import '../../domain/usecases/job_application_usecases.dart';

final class JobApplicationViewModel extends ChangeNotifier {
  JobApplicationViewModel({
    required GetJobApplications getApplications,
    required GetApplicationSummary getSummary,
    required SaveJobApplication saveApplication,
    required DeleteJobApplication deleteApplication,
  }) : _getApplications = getApplications,
       _getSummary = getSummary,
       _saveApplication = saveApplication,
       _deleteApplication = deleteApplication;

  final GetJobApplications _getApplications;
  final GetApplicationSummary _getSummary;
  final SaveJobApplication _saveApplication;
  final DeleteJobApplication _deleteApplication;
  final List<JobApplication> _items = [];
  Timer? _searchDebounce;
  String _search = '';
  ApplicationStatus? _statusFilter;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _reloadWhenIdle = false;
  int _generation = 0;
  int _page = 0;
  int _totalPages = 0;
  int _totalItems = 0;
  ApplicationSummary? _summary;

  List<JobApplication> get items => List.unmodifiable(_items);
  ApplicationSummary? get summary => _summary;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get hasMore => _page + 1 < _totalPages;
  int get totalItems => _totalItems;
  String get search => _search;
  ApplicationStatus? get statusFilter => _statusFilter;

  Future<void> load({bool reset = true}) async {
    if (_isLoading) {
      if (reset) _reloadWhenIdle = true;
      return;
    }
    if (reset) {
      _page = 0;
      _items.clear();
    }
    final generation = _generation;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _getApplications(
        search: _search,
        status: _statusFilter,
        page: _page,
      );
      final summaryResult = await _getSummary();
      if (generation != _generation) return;
      summaryResult.fold<void>(
        onSuccess: (value) => _summary = value,
        onFailure: (_) {},
      );
      result.fold<void>(
        onSuccess: (page) {
          _items.addAll(page.items);
          _page = page.page;
          _totalPages = page.totalPages;
          _totalItems = page.totalItems;
        },
        onFailure: (failure) => _errorMessage = failure.message,
      );
    } finally {
      if (generation == _generation) {
        _isLoading = false;
        notifyListeners();
        if (_reloadWhenIdle) {
          _reloadWhenIdle = false;
          unawaited(load());
        }
      }
    }
  }

  void setSearch(String value) {
    _search = value.trim();
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () => load());
  }

  Future<void> setStatusFilter(ApplicationStatus? status) async {
    if (_statusFilter == status) return;
    _statusFilter = status;
    await load();
  }

  Future<void> loadMore() async {
    if (!hasMore || _isLoading) return;
    _page++;
    await load(reset: false);
  }

  Future<bool> save(ApplicationDraft draft, {JobApplication? current}) async {
    final generation = _generation;
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    final result = current == null
        ? await _saveApplication.create(draft)
        : await _saveApplication.update(current, draft);
    if (generation != _generation) return false;
    final saved = result.fold<bool>(
      onSuccess: (_) => true,
      onFailure: (failure) {
        _errorMessage = failure.message;
        return false;
      },
    );
    _isSaving = false;
    if (saved)
      await load();
    else
      notifyListeners();
    return saved;
  }

  Future<bool> delete(String id) async {
    final generation = _generation;
    final result = await _deleteApplication(id);
    if (generation != _generation) return false;
    final deleted = result.fold<bool>(
      onSuccess: (_) => true,
      onFailure: (failure) {
        _errorMessage = failure.message;
        return false;
      },
    );
    if (deleted)
      await load();
    else
      notifyListeners();
    return deleted;
  }

  void reset() {
    _generation++;
    _searchDebounce?.cancel();
    _isLoading = false;
    _isSaving = false;
    _reloadWhenIdle = false;
    _items.clear();
    _search = '';
    _statusFilter = null;
    _errorMessage = null;
    _page = 0;
    _totalPages = 0;
    _totalItems = 0;
    _summary = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
