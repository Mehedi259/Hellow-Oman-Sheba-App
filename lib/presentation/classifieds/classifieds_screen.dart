import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'classifieds_provider.dart';
import 'job_seekers_provider.dart';
import 'widgets/job_seeker_card.dart';
import 'classifieds_detail_screens.dart';
import '../../data/models/job.dart';
import '../../data/models/classifieds_models.dart';
import 'find_jobs_provider.dart';
import 'market_provider.dart';
import 'widgets/job_list_card.dart';
import 'widgets/market_card.dart';

class ClassifiedsScreen extends StatelessWidget {
  final String? initialTab;
  const ClassifiedsScreen({super.key, this.initialTab});

  int _getInitialIndex() {
    switch (initialTab) {
      case 'market':
        return 0;
      case 'jobs':
        return 1;
      case 'properties':
        return 2;
      case 'vehicles':
        return 3;
      case 'services':
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: _getInitialIndex(),
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E293B),
          elevation: 0,
          title: const Text(
            'ক্লাসিফায়েড',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: Color(0xFF1E293B),
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            labelColor: const Color(0xFF2563EB),
            unselectedLabelColor: const Color(0xFF94A3B8),
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            indicatorColor: const Color(0xFF2563EB),
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'মার্কেট'),
              Tab(text: 'চাকরি'),
              Tab(text: 'প্রপার্টি'),
              Tab(text: 'গাড়ি'),
              Tab(text: 'সেবা'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MarketView(),
            JobsView(),
            PropertiesView(),
            VehiclesView(),
            ServicesView(),
          ],
        ),
      ),
    );
  }
}


class JobsView extends ConsumerStatefulWidget {
  const JobsView({super.key});

  @override
  ConsumerState<JobsView> createState() => _JobsViewState();
}

class _JobsViewState extends ConsumerState<JobsView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isFindingWorkers = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmit(String value) {
    if (_isFindingWorkers) {
      ref.read(jobSeekersStateProvider.notifier).updateSearch(value);
    } else {
      ref.read(findJobsStateProvider.notifier).updateSearch(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        if (_isFindingWorkers) {
          ref.read(jobSeekersStateProvider.notifier).fetchJobSeekers();
        } else {
          ref.invalidate(jobsProvider);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Search Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF9333EA)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _isFindingWorkers = false),
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: !_isFindingWorkers ? Colors.white : Colors.transparent,
                                width: 4,
                              ),
                            ),
                          ),
                          child: Text(
                            'চাকরি খুঁজুন',
                            style: TextStyle(
                              color: !_isFindingWorkers ? Colors.white : Colors.blue.shade200,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => setState(() => _isFindingWorkers = true),
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _isFindingWorkers ? Colors.white : Colors.transparent,
                                width: 4,
                              ),
                            ),
                          ),
                          child: Text(
                            'কর্মী খুঁজুন',
                            style: TextStyle(
                              color: _isFindingWorkers ? Colors.white : Colors.blue.shade200,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'পেশা বা দক্ষতা দিয়ে খুঁজুন...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () => _onSearchSubmit(_searchController.text),
                          ),
                        ),
                      ),
                      onSubmitted: _onSearchSubmit,
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isFindingWorkers ? _buildWorkersContent(context) : _buildJobsContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobsContent(BuildContext context) {
    final jobsAsync = ref.watch(filteredJobsProvider);
    final filterState = ref.watch(findJobsStateProvider);

    return jobsAsync.when(
      data: (data) {
        final List<Job> jobs = data['jobs'] ?? [];
        final int totalItems = data['totalItems'] ?? 0;
        final int totalPages = data['totalPages'] ?? 0;
        final int currentPage = data['currentPage'] ?? 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.filter_alt_outlined, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'ফিল্টার',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'চাকরির ধরন',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip('FULL_TIME', 'ফুল টাইম', filterState),
                      _buildFilterChip('PART_TIME', 'পার্ট টাইম', filterState),
                      _buildFilterChip('CONTRACT', 'কন্ট্রাক্ট', filterState),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Results Header & Sorting
            Text(
              '${totalItems}টি চাকরি পাওয়া গেছে',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSortButton('সর্বশেষ', 'latest', filterState),
                  const SizedBox(width: 8),
                  _buildSortButton('উচ্চ বেতন', 'high_salary', filterState),
                  const SizedBox(width: 8),
                  _buildSortButton('নিম্ন বেতন', 'low_salary', filterState),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Job List
            if (jobs.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'কোনো চাকরি পাওয়া যায়নি',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                  return JobListCardWidget(job: jobs[index]);
                },
              ),
            
            // Pagination
            if (totalPages > 1)
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPaginationButton(
                      'পূর্ববর্তী',
                      enabled: currentPage > 1,
                      onPressed: () {
                        ref.read(findJobsStateProvider.notifier).setPage(currentPage - 1);
                      },
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$currentPage',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildPaginationButton(
                      'পরবর্তী',
                      enabled: currentPage < totalPages,
                      onPressed: () {
                        ref.read(findJobsStateProvider.notifier).setPage(currentPage + 1);
                      },
                    ),
                  ],
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: Color(0xFF2563EB)))),
      error: (e, _) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Text('Error: $e'))),
    );
  }

  Widget _buildWorkersContent(BuildContext context) {
    final workersState = ref.watch(jobSeekersStateProvider);

    if (workersState.isLoading) {
      return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: Color(0xFF2563EB))));
    }
    if (workersState.error != null) {
      return Center(child: Padding(padding: const EdgeInsets.all(32), child: Text('Error: ${workersState.error}')));
    }

    final workers = workersState.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'আপনি কি চাকরি খুঁজছেন?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'আপনার সিভি এবং দক্ষতা দিয়ে প্রোফাইল তৈরি করুন, এমপ্লয়াররা আপনাকে খুঁজে নেবে।',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: Go to create profile screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('প্রোফাইল তৈরি করুন', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Results Header & Sorting
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${workersState.totalItems} জন কর্মী পাওয়া গেছে',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildWorkerSortButton('সর্বশেষ', '-created_at', workersState.sortOrder),
              const SizedBox(width: 8),
              _buildWorkerSortButton('বেশি অভিজ্ঞতা', '-years_of_experience', workersState.sortOrder),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Workers List
        if (workers.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  const Text('👨‍💼', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  const Text(
                    'কোনো কর্মী পাওয়া যায়নি',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'আপনার খোঁজার মানদণ্ড পরিবর্তন করে আবার চেষ্টা করুন।',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: workers.length,
            itemBuilder: (context, index) {
              return JobSeekerCardWidget(jobSeeker: workers[index]);
            },
          ),
        
        // Pagination
        if (workersState.totalPages > 1)
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPaginationButton(
                  'পূর্ববর্তী',
                  enabled: workersState.currentPage > 1,
                  onPressed: () {
                    ref.read(jobSeekersStateProvider.notifier).setPage(workersState.currentPage - 1);
                  },
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${workersState.currentPage}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                _buildPaginationButton(
                  'পরবর্তী',
                  enabled: workersState.currentPage < workersState.totalPages,
                  onPressed: () {
                    ref.read(jobSeekersStateProvider.notifier).setPage(workersState.currentPage + 1);
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label, FindJobsState state) {
    final isSelected = state.jobType == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        ref.read(findJobsStateProvider.notifier).setJobType(selected ? value : null);
      },
      backgroundColor: Colors.white,
      selectedColor: Colors.blue.shade50,
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF2563EB) : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildSortButton(String label, String value, FindJobsState state) {
    final isSelected = state.sortOrder == value;
    return InkWell(
      onTap: () {
        ref.read(findJobsStateProvider.notifier).setSortOrder(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildWorkerSortButton(String label, String value, String currentSort) {
    final isSelected = currentSort == value;
    return InkWell(
      onTap: () {
        ref.read(jobSeekersStateProvider.notifier).setSortOrder(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationButton(String label, {required bool enabled, required VoidCallback onPressed}) {
    return InkWell(
      onTap: enabled ? onPressed : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: enabled ? Colors.black87 : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
class PropertiesView extends ConsumerWidget {
  const PropertiesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(propertiesProvider);
    return state.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_work_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('কোনো প্রপার্টি পাওয়া যায়নি', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PropertyDetailScreen(property: item)),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(Icons.apartment_rounded, color: Colors.green.shade600, size: 36),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item.location,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.type,
                                    style: TextStyle(fontSize: 11, color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '\$${item.price}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class VehiclesView extends ConsumerWidget {
  const VehiclesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vehiclesProvider);
    return state.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('কোনো গাড়ি পাওয়া যায়নি', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VehicleDetailScreen(vehicle: item)),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(Icons.directions_car_filled_rounded, color: Colors.purple.shade500, size: 36),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.make} ${item.model} (${item.year})',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${item.price}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class ServicesView extends ConsumerWidget {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(servicesProvider);
    return state.when(
      data: (items) {
        if (items.isEmpty) return const Center(child: Text('No services found.'));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              elevation: 2,
              shadowColor: Colors.grey.shade100,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ServiceDetailScreen(service: item)),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.handyman_outlined, color: Colors.teal.shade600, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.category,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.phone_outlined, size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 8),
                              Text(
                                item.contactInfo,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class MarketView extends ConsumerWidget {
  const MarketView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketAsync = ref.watch(filteredMarketItemsProvider);
    final filterState = ref.watch(marketStateProvider);

    return marketAsync.when(
      data: (data) {
        final List<MarketItem> items = data['items'] ?? [];
        final int totalItems = data['totalItems'] ?? 0;
        final int totalPages = data['totalPages'] ?? 0;
        final int currentPage = data['currentPage'] ?? 1;

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(marketItemsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Search Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F9D58), Color(0xFF0F9D58)], // Solid green to match screenshot
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'মার্কেট',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'কিনুন, বিক্রি করুন এবং বিনিময় করুন',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextButton.icon(
                                onPressed: () {
                                  // TODO: Search functionality
                                },
                                icon: const Icon(Icons.search, color: Colors.grey),
                                label: const Text(
                                  'পণ্য খুঁজুন...',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                style: TextButton.styleFrom(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextButton.icon(
                                onPressed: () {
                                  // TODO: Post ad functionality
                                },
                                icon: const Icon(Icons.add, color: Color(0xFF0F9D58)),
                                label: const Text(
                                  'বিজ্ঞাপন দিন',
                                  style: TextStyle(color: Color(0xFF0F9D58)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 2. Categories Grid
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildCategoryItem('Electronics', 'ইলেকট্রনিক্স', Icons.phone_android, '2', filterState, ref),
                      _buildCategoryItem('Computer', 'কম্পিউটার', Icons.laptop, '0', filterState, ref),
                      _buildCategoryItem('Furniture', 'ফার্নিচার', Icons.home, '1', filterState, ref),
                      _buildCategoryItem('Clothing', 'পোশাক', Icons.checkroom, '1', filterState, ref),
                      _buildCategoryItem('Baby', 'শিশু সামগ্রী', Icons.child_care, '0', filterState, ref),
                      _buildCategoryItem('Machinery', 'যন্ত্রপাতি', Icons.build, '0', filterState, ref),
                      _buildCategoryItem('Books', 'বই', Icons.menu_book, '0', filterState, ref),
                      _buildCategoryItem('Others', 'অন্যান্য', Icons.favorite_border, '2', filterState, ref),
                    ],
                  ),
                ),
                
                const Divider(thickness: 1, color: Color(0xFFEEEEEE)),

                // 3. Latest Ads Section
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'সর্বশেষ বিজ্ঞাপন',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'মোট $totalItems টি বিজ্ঞাপন পাওয়া গেছে',
                        style: const TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildSortButton('সর্বশেষ', 'latest', filterState, ref),
                            const SizedBox(width: 8),
                            _buildSortButton('কম দাম', 'low_price', filterState, ref),
                            const SizedBox(width: 8),
                            _buildSortButton('বেশি দাম', 'high_price', filterState, ref),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 4. Ads List
                      if (items.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(Icons.store, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  'কোনো আইটেম পাওয়া যায়নি',
                                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.58,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return MarketCardWidget(item: items[index]);
                          },
                        ),
                      
                      // 5. Pagination
                      if (totalPages > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0, bottom: 32.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildPaginationButton(
                                'পূর্ববর্তী',
                                enabled: currentPage > 1,
                                onPressed: () {
                                  ref.read(marketStateProvider.notifier).setPage(currentPage - 1);
                                },
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '$currentPage',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildPaginationButton(
                                'পরবর্তী',
                                enabled: currentPage < totalPages,
                                onPressed: () {
                                  ref.read(marketStateProvider.notifier).setPage(currentPage + 1);
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF0F9D58))),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildCategoryItem(String id, String title, IconData icon, String count, MarketState state, WidgetRef ref) {
    final isSelected = state.category == id;
    return InkWell(
      onTap: () {
        if (isSelected) {
          ref.read(marketStateProvider.notifier).setCategory(null);
        } else {
          ref.read(marketStateProvider.notifier).setCategory(id);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon, 
            size: 32, 
            color: isSelected ? const Color(0xFF0F9D58) : const Color(0xFF2563EB)
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.bold,
              color: isSelected ? const Color(0xFF0F9D58) : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton(String label, String value, MarketState state, WidgetRef ref) {
    final isSelected = state.sortOrder == value;
    return InkWell(
      onTap: () {
        ref.read(marketStateProvider.notifier).setSortOrder(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationButton(String label, {required bool enabled, required VoidCallback onPressed}) {
    return InkWell(
      onTap: enabled ? onPressed : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: enabled ? Colors.black87 : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}

