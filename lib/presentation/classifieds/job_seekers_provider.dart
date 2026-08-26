import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/job_seeker.dart';
import 'classifieds_provider.dart';

class JobSeekersState {
  final List<JobSeeker> items;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final String sortOrder;
  final String searchQuery;

  JobSeekersState({
    this.items = const [],
    this.isLoading = true,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.sortOrder = '-created_at',
    this.searchQuery = '',
  });

  JobSeekersState copyWith({
    List<JobSeeker>? items,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    String? sortOrder,
    String? searchQuery,
  }) {
    return JobSeekersState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Can be null
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      sortOrder: sortOrder ?? this.sortOrder,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class JobSeekersNotifier extends StateNotifier<JobSeekersState> {
  final Ref ref;

  JobSeekersNotifier(this.ref) : super(JobSeekersState()) {
    fetchJobSeekers();
  }

  Future<void> fetchJobSeekers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(classifiedsRepositoryProvider);
      final response = await repository.getJobSeekers(
        search: state.searchQuery,
        sort: state.sortOrder,
        page: state.currentPage,
      );

      state = state.copyWith(
        items: response['items'] as List<JobSeeker>,
        totalItems: response['total'] as int,
        totalPages: response['totalPages'] as int,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setPage(int page) {
    if (page > 0 && page <= state.totalPages) {
      state = state.copyWith(currentPage: page);
      fetchJobSeekers();
    }
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query, currentPage: 1);
    fetchJobSeekers();
  }

  void setSortOrder(String sort) {
    state = state.copyWith(sortOrder: sort, currentPage: 1);
    fetchJobSeekers();
  }
}

final jobSeekersStateProvider = StateNotifierProvider<JobSeekersNotifier, JobSeekersState>((ref) {
  return JobSeekersNotifier(ref);
});
