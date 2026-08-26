import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/job.dart';
import 'classifieds_provider.dart';

class FindJobsState {
  final String searchQuery;
  final String? jobType;
  final String sortOrder; // 'latest', 'high_salary', 'low_salary'
  final int currentPage;
  final int itemsPerPage;

  FindJobsState({
    this.searchQuery = '',
    this.jobType,
    this.sortOrder = 'latest',
    this.currentPage = 1,
    this.itemsPerPage = 10,
  });

  FindJobsState copyWith({
    String? searchQuery,
    String? jobType,
    String? sortOrder,
    int? currentPage,
  }) {
    return FindJobsState(
      searchQuery: searchQuery ?? this.searchQuery,
      jobType: jobType ?? this.jobType, // null means clear filter if we explicitly want to, but copyWith usually doesn't clear null.
      sortOrder: sortOrder ?? this.sortOrder,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: this.itemsPerPage,
    );
  }
  
  // Custom method to clear jobType
  FindJobsState clearJobType() {
    return FindJobsState(
      searchQuery: this.searchQuery,
      jobType: null,
      sortOrder: this.sortOrder,
      currentPage: this.currentPage,
      itemsPerPage: this.itemsPerPage,
    );
  }
}

class FindJobsNotifier extends StateNotifier<FindJobsState> {
  FindJobsNotifier() : super(FindJobsState());

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query, currentPage: 1);
  }

  void setJobType(String? type) {
    if (type == null) {
      state = state.clearJobType();
    } else {
      state = state.copyWith(jobType: type, currentPage: 1);
    }
  }

  void setSortOrder(String order) {
    state = state.copyWith(sortOrder: order, currentPage: 1);
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }
}

final findJobsStateProvider = StateNotifierProvider<FindJobsNotifier, FindJobsState>((ref) {
  return FindJobsNotifier();
});

// A provider that applies the filters, sorting, and pagination locally
final filteredJobsProvider = Provider<AsyncValue<Map<String, dynamic>>>((ref) {
  final jobsAsync = ref.watch(jobsProvider); // Get raw list from API
  final filterState = ref.watch(findJobsStateProvider);

  return jobsAsync.whenData((jobs) {
    List<Job> filtered = List.from(jobs);

    // Apply Search
    if (filterState.searchQuery.isNotEmpty) {
      final q = filterState.searchQuery.toLowerCase();
      filtered = filtered.where((job) {
        return job.title.toLowerCase().contains(q) ||
               job.company.toLowerCase().contains(q) ||
               job.description.toLowerCase().contains(q);
      }).toList();
    }

    // Apply Job Type Filter
    if (filterState.jobType != null && filterState.jobType!.isNotEmpty) {
      filtered = filtered.where((job) {
        // e.g., 'full_time' or 'part_time'
        final typeMatches = job.jobType.toLowerCase().contains(filterState.jobType!.toLowerCase().replaceAll(' ', '_')) ||
                            job.type.toLowerCase().contains(filterState.jobType!.toLowerCase().replaceAll(' ', '_'));
        return typeMatches;
      }).toList();
    }

    // Apply Sorting
    filtered.sort((a, b) {
      if (filterState.sortOrder == 'latest') {
        return b.createdAt.compareTo(a.createdAt);
      } else if (filterState.sortOrder == 'high_salary' || filterState.sortOrder == 'low_salary') {
        // Very basic salary string parsing for sorting
        double getSalaryVal(String sal) {
          final RegExp regExp = RegExp(r'\d+(\.\d+)?');
          final match = regExp.firstMatch(sal);
          if (match != null) {
            return double.tryParse(match.group(0) ?? '0') ?? 0;
          }
          return 0;
        }
        
        final valA = getSalaryVal(a.salary);
        final valB = getSalaryVal(b.salary);
        
        if (filterState.sortOrder == 'high_salary') {
          return valB.compareTo(valA);
        } else {
          return valA.compareTo(valB);
        }
      }
      return 0;
    });

    final totalItems = filtered.length;
    final totalPages = (totalItems / filterState.itemsPerPage).ceil();
    
    // Safety bounds for page
    int currentPage = filterState.currentPage;
    if (currentPage < 1) currentPage = 1;
    if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;

    // Apply Pagination
    final startIndex = (currentPage - 1) * filterState.itemsPerPage;
    var endIndex = startIndex + filterState.itemsPerPage;
    if (endIndex > totalItems) endIndex = totalItems;
    
    List<Job> pagedJobs = [];
    if (startIndex < totalItems) {
      pagedJobs = filtered.sublist(startIndex, endIndex);
    }

    return {
      'jobs': pagedJobs,
      'totalItems': totalItems,
      'totalPages': totalPages,
      'currentPage': currentPage,
    };
  });
});
