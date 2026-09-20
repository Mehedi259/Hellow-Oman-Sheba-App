import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../classifieds/classifieds_provider.dart';
import '../../classifieds/widgets/job_card.dart';
import '../../community/community_provider.dart';
import '../../../data/repositories/news_repository.dart';
import 'home_job_seeker_card.dart';
import '../../../data/models/job.dart';
import '../../../data/models/job_seeker.dart';
import '../../../data/models/classifieds_models.dart';
import '../../../data/models/post.dart';
import 'section_header.dart';
import 'animated_see_more_button.dart';
import 'properties_widget.dart';
import 'vehicles_widget.dart';
import 'market_widget.dart';
import 'community_widget.dart';
import 'latest_news_widget.dart';

class HomeTabSectionWidget extends ConsumerStatefulWidget {
  const HomeTabSectionWidget({super.key});

  @override
  ConsumerState<HomeTabSectionWidget> createState() => _HomeTabSectionWidgetState();
}

class _HomeTabSectionWidgetState extends ConsumerState<HomeTabSectionWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _tabs = [
    {'label': 'চাকরি খুঁজুন', 'icon': Icons.work_outline_rounded, 'color': const Color(0xFF0056D2)},
    {'label': 'কর্মী খুঁজুন', 'icon': Icons.person_search_outlined, 'color': const Color(0xFF10B981)},
    {'label': 'বাসা ভাড়া', 'icon': Icons.home_outlined, 'color': const Color(0xFF8B5CF6)},
    {'label': 'মার্কেট', 'icon': Icons.storefront_outlined, 'color': const Color(0xFFEF4444)},
    {'label': 'সংবাদ', 'icon': Icons.newspaper_outlined, 'color': const Color(0xFF06B6D4)},
    {'label': 'প্রশ্নোত্তর', 'icon': Icons.forum_outlined, 'color': const Color(0xFFF59E0B)},
    {'label': 'গাড়ি', 'icon': Icons.directions_car_outlined, 'color': const Color(0xFF64748B)},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(() { if (mounted) setState(() {}); });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _toBengaliNumber(int n) {
    const e = ['0','1','2','3','4','5','6','7','8','9'];
    const b = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
    String s = n.toString();
    for (int i = 0; i < e.length; i++) s = s.replaceAll(e[i], b[i]);
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(jobsProvider);
    final workersAsync = ref.watch(homeJobSeekersProvider);
    final propertiesAsync = ref.watch(propertiesProvider);
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final marketAsync = ref.watch(marketItemsProvider);
    final newsAsync = ref.watch(allNewsProvider);
    final postsAsync = ref.watch(postsProvider);

    // Build counts
    final counts = [
      jobsAsync.valueOrNull?.length ?? 0,
      workersAsync.valueOrNull?.length ?? 0,
      propertiesAsync.valueOrNull?.length ?? 0,
      marketAsync.valueOrNull?.length ?? 0,
      newsAsync.valueOrNull?.length ?? 0,
      postsAsync.valueOrNull?.length ?? 0,
      vehiclesAsync.valueOrNull?.length ?? 0,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  const Text(
                    'আজকের জনপ্রিয়',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Horizontal scrollable tabs with count badges
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final isSelected = _tabController.index == index;
              final color = _tabs[index]['color'] as Color;
              final count = counts[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => _tabController.animateTo(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? color : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isSelected ? color : Colors.grey.shade200, width: 1.5),
                      boxShadow: isSelected
                          ? [BoxShadow(color: color.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 4))]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_tabs[index]['icon'] as IconData, size: 16, color: isSelected ? Colors.white : color),
                        const SizedBox(width: 6),
                        Text(
                          _tabs[index]['label'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                          ),
                        ),
                        if (count > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white.withOpacity(0.25) : color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _toBengaliNumber(count),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : color,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 8),

        // Tab content — only render the active tab
        if (_tabController.index == 0)
          _TabContent(
            asyncValue: jobsAsync,
            onSeeAll: () => context.push('/classifieds?tab=jobs'),
            buildContent: (jobs) => _JobsContent(jobs: jobs as List<Job>),
          )
        else if (_tabController.index == 1)
          _TabContent(
            asyncValue: workersAsync,
            onSeeAll: () => context.push('/classifieds?tab=workers'),
            buildContent: (workers) => _WorkersContent(workers: workers as List<JobSeeker>),
          )
        else if (_tabController.index == 2)
          _TabContent(
            asyncValue: propertiesAsync,
            onSeeAll: () => context.push('/classifieds?tab=properties'),
            buildContent: (props) => PropertiesWidget(properties: props as List<Property>),
          )
        else if (_tabController.index == 3)
          _TabContent(
            asyncValue: marketAsync,
            onSeeAll: () => context.push('/classifieds?tab=market'),
            buildContent: (items) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: MarketWidget(items: items as List<MarketItem>),
            ),
          )
        else if (_tabController.index == 4)
          newsAsync.when(
            data: (news) => LatestNewsWidget(articles: news),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox.shrink(),
          )
        else if (_tabController.index == 5)
          postsAsync.when(
            data: (posts) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CommunityWidget(posts: posts as List<Post>),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox.shrink(),
          )
        else
          _TabContent(
            asyncValue: vehiclesAsync,
            onSeeAll: () => context.push('/classifieds?tab=vehicles'),
            buildContent: (vehicles) => VehiclesWidget(vehicles: vehicles as List<Vehicle>),
          ),
      ],
    );
  }
}

class _TabContent extends StatelessWidget {
  final AsyncValue asyncValue;
  final VoidCallback onSeeAll;
  final Widget Function(dynamic) buildContent;

  const _TabContent({
    required this.asyncValue,
    required this.onSeeAll,
    required this.buildContent,
  });

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      data: (data) {
        if (data == null || (data is List && data.isEmpty)) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: Text('কোনো তথ্য পাওয়া যায়নি', style: TextStyle(color: Colors.grey))),
          );
        }
        return buildContent(data);
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}

class _JobsContent extends StatefulWidget {
  final List<Job> jobs;
  const _JobsContent({required this.jobs});

  @override
  State<_JobsContent> createState() => _JobsContentState();
}

class _JobsContentState extends State<_JobsContent> {
  bool _expanded = false;

  String _toBengaliNumber(int n) {
    const e = ['0','1','2','3','4','5','6','7','8','9'];
    const b = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
    String s = n.toString();
    for (int i = 0; i < e.length; i++) s = s.replaceAll(e[i], b[i]);
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final count = _expanded ? widget.jobs.length : widget.jobs.length.clamp(0, 6);
    return Column(
      children: [
        SectionHeader(
          title: 'চাকরি খুঁজুন',
          badgeText: '${_toBengaliNumber(widget.jobs.length)} টি',
          subtitle: 'আপনার স্বপ্নের চাকরি খুঁজুন',
          icon: Icons.work_outline_rounded,
          color: const Color(0xFF0056D2),
          onSeeAllPressed: () => context.push('/classifieds?tab=jobs'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.95,
            ),
            itemCount: count,
            itemBuilder: (context, i) => JobCardWidget(job: widget.jobs[i]),
          ),
        ),
        if (widget.jobs.length > 6 && !_expanded)
          AnimatedSeeMoreButton(onPressed: () => setState(() => _expanded = true)),
      ],
    );
  }
}

class _WorkersContent extends StatefulWidget {
  final List<JobSeeker> workers;
  const _WorkersContent({required this.workers});

  @override
  State<_WorkersContent> createState() => _WorkersContentState();
}

class _WorkersContentState extends State<_WorkersContent> {
  bool _expanded = false;

  String _toBengaliNumber(int n) {
    const e = ['0','1','2','3','4','5','6','7','8','9'];
    const b = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
    String s = n.toString();
    for (int i = 0; i < e.length; i++) s = s.replaceAll(e[i], b[i]);
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final count = _expanded ? widget.workers.length : widget.workers.length.clamp(0, 6);
    return Column(
      children: [
        SectionHeader(
          title: 'কর্মী খুঁজুন',
          badgeText: '${_toBengaliNumber(widget.workers.length)} টি',
          subtitle: 'দক্ষ কর্মী খুঁজে নিন',
          icon: Icons.person_search_outlined,
          color: const Color(0xFF10B981),
          onSeeAllPressed: () => context.push('/classifieds?tab=workers'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.95,
            ),
            itemCount: count,
            itemBuilder: (context, i) => HomeJobSeekerCardWidget(jobSeeker: widget.workers[i]),
          ),
        ),
        if (widget.workers.length > 6 && !_expanded)
          AnimatedSeeMoreButton(onPressed: () => setState(() => _expanded = true)),
      ],
    );
  }
}
