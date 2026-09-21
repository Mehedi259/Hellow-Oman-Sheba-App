import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/classifieds_models.dart';
import '../../data/repositories/classifieds_repository.dart';
import '../classifieds/classifieds_provider.dart';
import '../categories/service_list_screen.dart' show ServiceDetailScreen;

// ─────────────────────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────────────────────
const List<Map<String, dynamic>> specialServiceCategories = [
  {'value': 'Cleaning',          'labelBn': 'ক্লিনিং',          'icon': Icons.cleaning_services_rounded,     'color': 0xFF0EA5E9, 'gradient': [0xFF0EA5E9, 0xFF0369A1]},
  {'value': 'Plumbing',          'labelBn': 'প্লাম্বিং',         'icon': Icons.plumbing_rounded,              'color': 0xFF14B8A6, 'gradient': [0xFF14B8A6, 0xFF0F766E]},
  {'value': 'Electrical',        'labelBn': 'ইলেকট্রিশিয়ান',    'icon': Icons.electrical_services_rounded,   'color': 0xFFF59E0B, 'gradient': [0xFFF59E0B, 0xFFB45309]},
  {'value': 'AC Repair',         'labelBn': 'এসি সার্ভিস',       'icon': Icons.ac_unit_rounded,               'color': 0xFF3B82F6, 'gradient': [0xFF3B82F6, 0xFF1D4ED8]},
  {'value': 'Carpentry',         'labelBn': 'কার্পেন্টার',       'icon': Icons.carpenter_rounded,             'color': 0xFF8B5CF6, 'gradient': [0xFF8B5CF6, 0xFF6D28D9]},
  {'value': 'Painting',          'labelBn': 'রঙ মিস্ত্রি',       'icon': Icons.format_paint_rounded,          'color': 0xFFEC4899, 'gradient': [0xFFEC4899, 0xFFBE185D]},
  {'value': 'Appliance Repair',  'labelBn': 'ফ্রিজ সার্ভিস',     'icon': Icons.kitchen_rounded,               'color': 0xFF10B981, 'gradient': [0xFF10B981, 0xFF065F46]},
  {'value': 'Sweeper',           'labelBn': 'সুইপার',            'icon': Icons.delete_sweep_rounded,          'color': 0xFF64748B, 'gradient': [0xFF64748B, 0xFF334155]},
  {'value': 'Mason',             'labelBn': 'রাজমিস্ত্রি',       'icon': Icons.construction_rounded,          'color': 0xFFF97316, 'gradient': [0xFFF97316, 0xFFC2410C]},
  {'value': 'Mobile Technician', 'labelBn': 'মোবাইল মিস্ত্রি',   'icon': Icons.phone_android_rounded,         'color': 0xFF6366F1, 'gradient': [0xFF6366F1, 0xFF4338CA]},
  {'value': 'Pest Control',      'labelBn': 'পেস্ট কন্ট্রোল',    'icon': Icons.pest_control_rounded,          'color': 0xFFEF4444, 'gradient': [0xFFEF4444, 0xFFB91C1C]},
  {'value': 'Other',             'labelBn': 'অন্যান্য',          'icon': Icons.miscellaneous_services_rounded,'color': 0xFF94A3B8, 'gradient': [0xFF94A3B8, 0xFF64748B]},
];

// ─────────────────────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────────────────────
final specialServicesProvider = FutureProvider.autoDispose<List<Service>>((ref) async {
  final repo = ref.watch(classifiedsRepositoryProvider);
  final allServices = await repo.getServices();
  final specialTypes = specialServiceCategories.map((c) => (c['value'] as String).toLowerCase()).toSet();
  final filtered = allServices.where((s) =>
    specialTypes.contains(s.category.toLowerCase()) ||
    specialTypes.contains(s.serviceType.toLowerCase())).toList();
  return filtered.isNotEmpty ? filtered : allServices;
});

class _FilterState {
  final bool verifiedOnly;
  final String? category;
  final String query;
  const _FilterState({this.verifiedOnly = false, this.category, this.query = ''});
  _FilterState copyWith({bool? verifiedOnly, String? category, bool clearCat = false, String? query}) =>
    _FilterState(
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      category: clearCat ? null : (category ?? this.category),
      query: query ?? this.query,
    );
}

class _FilterNotifier extends StateNotifier<_FilterState> {
  _FilterNotifier() : super(const _FilterState());
  void setVerified(bool v) => state = state.copyWith(verifiedOnly: v);
  void setCategory(String? c) => state = c == null ? state.copyWith(clearCat: true) : state.copyWith(category: c);
  void setQuery(String q) => state = state.copyWith(query: q);
}

final _filterProvider = StateNotifierProvider.autoDispose<_FilterNotifier, _FilterState>(
  (_) => _FilterNotifier(),
);

// ─────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────
Map<String, dynamic> _catData(String cat) {
  return specialServiceCategories.firstWhere(
    (c) => (c['value'] as String).toLowerCase() == cat.toLowerCase(),
    orElse: () => {'labelBn': cat, 'color': 0xFF64748B, 'gradient': [0xFF64748B, 0xFF334155], 'icon': Icons.miscellaneous_services_rounded},
  );
}

// ─────────────────────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────────────────────
class SpecialServicesScreen extends ConsumerStatefulWidget {
  const SpecialServicesScreen({super.key});

  @override
  ConsumerState<SpecialServicesScreen> createState() => _SpecialServicesScreenState();
}

class _SpecialServicesScreenState extends ConsumerState<SpecialServicesScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late final AnimationController _fabAnim;
  late final Animation<double> _fabScale;

  @override
  void initState() {
    super.initState();
    _fabAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fabScale = CurvedAnimation(parent: _fabAnim, curve: Curves.elasticOut);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fabAnim.forward();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _fabAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(_filterProvider);
    final async  = ref.watch(specialServicesProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [_appBar(filter)],
        body: _body(filter, async),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: ScaleTransition(
          scale: _fabScale,
          child: GestureDetector(
            onTap: () => _showCategorySheet(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF1E40AF).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: const Text('সেবা দিন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
            ),
          ),
        ),
      ),
    );
  }

  // ── APP BAR ──────────────────────────────────────────────
  SliverAppBar _appBar(_FilterState filter) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      floating: false,
      backgroundColor: const Color(0xFF1E40AF),
      automaticallyImplyLeading: false,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: _headerBg(),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(102),
        child: _bottomBar(filter),
      ),
    );
  }

  Widget _headerBg() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF60A5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // decorative circles
          Positioned(top: -50, right: -50, child: _circle(180, 0x0DFFFFFF)),
          Positioned(bottom: -30, left: -40, child: _circle(130, 0x08FFFFFF)),
          Positioned(top: 40, right: 80, child: _circle(50, 0x0AFFFFFF)),
          Positioned(bottom: 80, right: 20, child: _circle(25, 0x10FFFFFF)),
          // content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'বিশেষ সেবাসমূহ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w900,
                      color: Colors.white, letterSpacing: -0.8, height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(_FilterState filter) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // filter tabs
        Container(
          color: Colors.white,
          child: Row(
            children: [
              _tab('সব সেবা', Icons.apps_rounded, !filter.verifiedOnly,
                  () => ref.read(_filterProvider.notifier).setVerified(false)),
              _tab('যাচাইকৃত', Icons.verified_rounded, filter.verifiedOnly,
                  () => ref.read(_filterProvider.notifier).setVerified(true)),
            ],
          ),
        ),
        // horizontal category chips
        Container(
          height: 52,
          color: const Color(0xFFF8FAFC),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            itemCount: specialServiceCategories.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) {
                return _chip('সব', Icons.grid_view_rounded, 0xFF1E40AF, filter.category == null,
                    () => ref.read(_filterProvider.notifier).setCategory(null));
              }
              final c = specialServiceCategories[i - 1];
              return _chip(c['labelBn'] as String, c['icon'] as IconData, c['color'] as int,
                  filter.category == c['value'],
                  () => ref.read(_filterProvider.notifier).setCategory(c['value'] as String));
            },
          ),
        ),
      ],
    );
  }

  Widget _tab(String label, IconData icon, bool selected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 50,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? const Color(0xFF1E40AF) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15,
                color: selected ? const Color(0xFF1E40AF) : const Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Text(label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  color: selected ? const Color(0xFF1E40AF) : const Color(0xFF94A3B8),
                )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, IconData icon, int color, bool selected, VoidCallback onTap) {
    final c = Color(color);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? c : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: selected ? c : const Color(0xFFE2E8F0), width: 1.5),
          boxShadow: selected ? [BoxShadow(color: c.withOpacity(0.28), blurRadius: 8, offset: const Offset(0, 3))] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: selected ? Colors.white : c),
            const SizedBox(width: 5),
            Text(label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                color: selected ? Colors.white : const Color(0xFF475569))),
          ],
        ),
      ),
    );
  }

  // ── BODY ─────────────────────────────────────────────────
  Widget _body(_FilterState filter, AsyncValue<List<Service>> async) {
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF1E40AF))),
      error: (e, _) => _errorState(),
      data: (all) {
        var items = all;
        if (filter.verifiedOnly)  items = items.where((s) => s.verified).toList();
        if (filter.category != null) {
          final cat = filter.category!.toLowerCase();
          items = items.where((s) =>
            s.category.toLowerCase() == cat || s.serviceType.toLowerCase() == cat).toList();
        }
        if (filter.query.isNotEmpty) {
          final q = filter.query.toLowerCase();
          items = items.where((s) =>
            s.title.toLowerCase().contains(q) || s.description.toLowerCase().contains(q)).toList();
        }
        if (items.isEmpty) return _emptyState();
        return _serviceList(items);
      },
    );
  }

  Widget _serviceList(List<Service> items) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E40AF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.handyman_rounded, size: 15, color: Color(0xFF1E40AF)),
                ),
                const SizedBox(width: 8),
                const Text('বিশেষ সেবার ক্যাটাগরি',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E40AF).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${items.length}টি সেবা',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF1E40AF), fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 150),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _premiumCard(ctx, items[i]),
              childCount: items.length,
            ),
          ),
        ),
      ],
    );
  }

  // ── PREMIUM SERVICE CARD ──────────────────────────────────
  Widget _premiumCard(BuildContext context, Service item) {
    final cd = _catData(item.category.isNotEmpty ? item.category : item.serviceType);
    final gColors = (cd['gradient'] as List<dynamic>).map((v) => Color(v as int)).toList();
    final catColor = Color(cd['color'] as int);
    final catIcon  = cd['icon'] as IconData;

    return GestureDetector(
      onTap: () => Navigator.push(context, _slideRoute(ServiceDetailScreen(service: item))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 20, offset: const Offset(0, 6)),
            BoxShadow(color: catColor.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 3)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            children: [
              // colored top stripe
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gColors),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // image / icon
                    Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gColors.map((c) => c.withOpacity(0.12)).toList(),
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: catColor.withOpacity(0.15), width: 1.5),
                          ),
                          child: item.primaryImage.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: CachedNetworkImage(
                                    imageUrl: item.primaryImage,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Icon(catIcon, size: 32, color: catColor),
                                    errorWidget: (_, __, ___) => Icon(catIcon, size: 32, color: catColor),
                                  ),
                                )
                              : Center(child: Icon(catIcon, size: 36, color: catColor)),
                        ),
                        // views badge
                        if (item.views > 0)
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 4)],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.remove_red_eye_rounded, size: 9, color: Color(0xFF94A3B8)),
                                  const SizedBox(width: 2),
                                  Text('${item.views}', style: const TextStyle(fontSize: 8, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    // content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // title + verified
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    height: 1.25,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (item.verified) ...[
                                const SizedBox(width: 6),
                                Tooltip(
                                  message: 'যাচাইকৃত সেবা',
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFDCFCE7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF16A34A)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 7),
                          // category pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: gColors.map((c) => c.withOpacity(0.14)).toList()),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: catColor.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(catIcon, size: 11, color: catColor),
                                const SizedBox(width: 4),
                                Text(cd['labelBn'] as String,
                                  style: TextStyle(fontSize: 11, color: catColor, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // description
                          if (item.description.isNotEmpty)
                            Text(
                              item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.45),
                            ),
                          const SizedBox(height: 10),
                          // location + rating row
                          Row(
                            children: [
                              if (item.location.isNotEmpty) ...[
                                const Icon(Icons.location_on_rounded, size: 12, color: Color(0xFF94A3B8)),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(item.location,
                                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                ),
                              ] else
                                const Spacer(),
                              if (item.rating > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF9C3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star_rounded, size: 12, color: Color(0xFFF59E0B)),
                                      const SizedBox(width: 3),
                                      Text(item.rating.toStringAsFixed(1),
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF92400E))),
                                      Text(' (${item.reviewCount})',
                                        style: const TextStyle(fontSize: 10, color: Color(0xFFCA8A04))),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // bottom action bar
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.04),
                  border: Border(top: BorderSide(color: catColor.withOpacity(0.08))),
                ),
                child: Row(
                  children: [
                    // phone button
                    Expanded(
                      child: _actionBtn(
                        icon: Icons.call_rounded,
                        label: 'কল করুন',
                        bg: catColor,
                        fg: Colors.white,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 10),
                    // detail button
                    Expanded(
                      child: _actionBtn(
                        icon: Icons.open_in_new_rounded,
                        label: 'বিস্তারিত',
                        bg: Colors.white,
                        fg: catColor,
                        border: catColor,
                        onTap: () => Navigator.push(
                          context, _slideRoute(ServiceDetailScreen(service: item))),
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
  }

  Widget _actionBtn({required IconData icon, required String label,
      required Color bg, required Color fg, Color? border, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: border != null ? Border.all(color: border.withOpacity(0.35), width: 1.5) : null,
          boxShadow: bg != Colors.white
              ? [BoxShadow(color: bg.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3))]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: fg),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: fg)),
          ],
        ),
      ),
    );
  }

  // ── EMPTY STATE ───────────────────────────────────────────
  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFF1E40AF).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: const Icon(Icons.handyman_rounded, size: 46, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text('কোনো সেবা পাওয়া যায়নি',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
            const SizedBox(height: 8),
            Text('এই ক্যাটাগরিতে এখনো কোনো সেবা যোগ করা হয়নি',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.5)),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _showCategorySheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: const Color(0xFF1E40AF).withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 5))],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_circle_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('সেবা দিন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 60, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 16),
          const Text('সেবা লোড করতে সমস্যা হয়েছে',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(specialServicesProvider),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('আবার চেষ্টা করুন'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E40AF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────────────────
  Widget _circle(double size, int color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: Color(color)),
  );

  PageRoute _slideRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) =>
      SlideTransition(position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(
        CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)), child: child),
    transitionDuration: const Duration(milliseconds: 320),
  );

  void _showCategorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategorySheet(
        onSelected: (cat) {
          Navigator.pop(context);
          Navigator.push(context, _slideRoute(_AddServiceScreen(
            category: cat,
            onSuccess: () => ref.invalidate(specialServicesProvider),
          )));
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CATEGORY PICKER SHEET
// ─────────────────────────────────────────────────────────────
class _CategorySheet extends StatelessWidget {
  final void Function(Map<String, dynamic>) onSelected;
  const _CategorySheet({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // handle
              Container(margin: const EdgeInsets.only(top: 14), width: 40, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 22),
              // header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.handyman_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('সেবার ধরন বেছে নিন',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                        SizedBox(height: 2),
                        Text('আপনি কোন সেবা দিতে চান?',
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 12),
              // grid
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.88,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: specialServiceCategories.length,
                  itemBuilder: (_, i) {
                    final cat  = specialServiceCategories[i];
                    final g    = (cat['gradient'] as List).map((v) => Color(v as int)).toList();
                    final icon = cat['icon'] as IconData;
                    return GestureDetector(
                      onTap: () => onSelected(cat),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 54, height: 54,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: g),
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: g.first.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: Icon(icon, size: 26, color: Colors.white),
                            ),
                            const SizedBox(height: 9),
                            Text(cat['labelBn'] as String,
                              textAlign: TextAlign.center,
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ADD SERVICE FORM SCREEN
// ─────────────────────────────────────────────────────────────
class _AddServiceScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> category;
  final VoidCallback onSuccess;
  const _AddServiceScreen({required this.category, required this.onSuccess});

  @override
  ConsumerState<_AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends ConsumerState<_AddServiceScreen> {
  final _form  = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc  = TextEditingController();
  final _price = TextEditingController();
  final _area  = TextEditingController();
  final _phone = TextEditingController();
  final _name  = TextEditingController();

  String _city = 'Muscat';
  List<File> _images = [];
  bool _loading = false;
  final _picker = ImagePicker();

  static const _cities = ['Muscat','Salalah','Sohar','Nizwa','Sur','Ibri','Barka','Rustaq'];

  @override
  void dispose() {
    for (final c in [_title, _desc, _price, _area, _phone, _name]) c.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) setState(() => _images = picked.map((e) => File(e.path)).take(4).toList());
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final repo = ref.read(classifiedsRepositoryProvider);
      await repo.createService({
        'title': _title.text.trim(),
        'description': _desc.text.trim(),
        'category': widget.category['value'],
        'city': _city,
        'area': _area.text.trim(),
        'contact_name': _name.text.trim(),
        'contact_phone': _phone.text.trim(),
        'contact_info': _phone.text.trim(),
        'price': _price.text.isEmpty ? 0 : double.tryParse(_price.text) ?? 0,
      }, images: _images.isNotEmpty ? _images : null);
      if (mounted) {
        widget.onSuccess();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [Icon(Icons.check_circle_rounded, color: Colors.white), SizedBox(width: 8), Text('সেবা সফলভাবে প্রকাশিত হয়েছে!')]),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('সমস্যা হয়েছে: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final g     = (widget.category['gradient'] as List).map((v) => Color(v as int)).toList();
    final color = Color(widget.category['color'] as int);
    final icon  = widget.category['icon'] as IconData;
    final label = widget.category['labelBn'] as String;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: g.first,
            foregroundColor: Colors.white,
            title: Text('$label সেবা যোগ করুন',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: LinearGradient(colors: g)),
                child: Stack(
                  children: [
                    Positioned(top: -20, right: -20, child: Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)))),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                              child: Icon(icon, color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 12),
                            Text(label,
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Form
          SliverToBoxAdapter(
            child: Form(
              key: _form,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _section('মূল তথ্য'),
                    _field(_title, 'সেবার শিরোনাম', Icons.title_rounded, color,
                      hint: 'যেমন: দক্ষ AC মেরামত সার্ভিস',
                      validator: (v) => (v ?? '').isEmpty ? 'শিরোনাম দিন' : null),
                    const SizedBox(height: 12),
                    _field(_desc, 'সেবার বিবরণ', Icons.description_rounded, color,
                      hint: 'আপনার অভিজ্ঞতা ও সেবা সম্পর্কে লিখুন',
                      maxLines: 3,
                      validator: (v) => (v ?? '').isEmpty ? 'বিবরণ দিন' : null),
                    const SizedBox(height: 12),
                    _field(_price, 'মূল্য (OMR)', Icons.payments_rounded, color,
                      hint: '0.000', keyboardType: TextInputType.number),
                    const SizedBox(height: 20),
                    _section('অবস্থান'),
                    _dropdownField(color),
                    const SizedBox(height: 12),
                    _field(_area, 'এলাকা', Icons.map_rounded, color,
                      hint: 'যেমন: Al Seeb, Ruwi'),
                    const SizedBox(height: 20),
                    _section('যোগাযোগ'),
                    _field(_name, 'আপনার নাম', Icons.person_rounded, color,
                      hint: 'পুরো নাম',
                      validator: (v) => (v ?? '').isEmpty ? 'নাম দিন' : null),
                    const SizedBox(height: 12),
                    _field(_phone, 'ফোন নম্বর', Icons.phone_rounded, color,
                      hint: '+968 9999 9999',
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v ?? '').isEmpty ? 'ফোন নম্বর দিন' : null),
                    const SizedBox(height: 20),
                    _section('ছবি যোগ করুন'),
                    _imagesPicker(color),
                    const SizedBox(height: 28),
                    // Submit
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: g),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: g.first.withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 5))],
                        ),
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _loading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.rocket_launch_rounded, size: 20, color: Colors.white),
                                  SizedBox(width: 10),
                                  Text('সেবা প্রকাশ করুন',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                                ],
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(title,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.8)),
  );

  Widget _field(
    TextEditingController ctrl, String label, IconData icon, Color color, {
    String hint = '',
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: color, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13.5),
          labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
        ),
      ),
    );
  }

  Widget _dropdownField(Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: DropdownButtonFormField<String>(
        value: _city,
        decoration: InputDecoration(
          labelText: 'শহর',
          prefixIcon: Icon(Icons.location_city_rounded, color: color, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
        ),
        items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (v) => setState(() => _city = v!),
      ),
    );
  }

  Widget _imagesPicker(Color color) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.add_photo_alternate_rounded, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ছবি সিলেক্ট করুন', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
                    const Text('সর্বোচ্চ ৪টি ছবি', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_images.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              itemBuilder: (_, i) => Container(
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.25), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(_images[i], width: 80, height: 80, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
