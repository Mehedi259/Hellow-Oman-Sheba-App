import re

with open('lib/presentation/classifieds/classifieds_screen.dart', 'r') as f:
    content = f.read()

# Make sure we add imports
if "import 'job_seekers_provider.dart';" not in content:
    content = content.replace("import 'classifieds_provider.dart';", "import 'classifieds_provider.dart';\nimport 'job_seekers_provider.dart';\nimport 'widgets/job_seeker_card.dart';")

new_jobs_view = """
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
"""

start_str = "class JobsView extends ConsumerStatefulWidget {"
end_str = "class PropertiesView extends ConsumerWidget {"

start_idx = content.find(start_str)
end_idx = content.find(end_str)

if start_idx != -1 and end_idx != -1:
    new_content = content[:start_idx] + new_jobs_view + content[end_idx:]
    with open('lib/presentation/classifieds/classifieds_screen.dart', 'w') as f:
        f.write(new_content)
    print("Successfully replaced JobsView")
else:
    print("Could not find bounds of JobsView")
