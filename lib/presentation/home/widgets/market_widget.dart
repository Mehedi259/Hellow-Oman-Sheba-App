import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/classifieds_models.dart';
import '../../classifieds/widgets/market_card.dart';

import 'section_header.dart';
import 'animated_see_more_button.dart';

class MarketWidget extends StatefulWidget {
  final List<MarketItem> items;

  const MarketWidget({super.key, required this.items});

  @override
  State<MarketWidget> createState() => _MarketWidgetState();
}

class _MarketWidgetState extends State<MarketWidget> {
  bool isExpanded = false;

  String _toBengaliNumber(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bengali = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    String numStr = number.toString();
    for (int i = 0; i < english.length; i++) {
      numStr = numStr.replaceAll(english[i], bengali[i]);
    }
    return numStr;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox();

    final displayCount = isExpanded ? widget.items.length : (widget.items.length > 6 ? 6 : widget.items.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'মার্কেট',
          badgeText: '${_toBengaliNumber(widget.items.length)} টি',
          subtitle: 'কিনুন, বিক্রি করুন সহজেই',
          icon: Icons.storefront_outlined,
          color: const Color(0xFF0056D2), // Logo Blue
          onSeeAllPressed: () {
            context.push('/classifieds');
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.85,
            ),
            itemCount: displayCount,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return MarketCardWidget(item: item);
            },
          ),
        ),
        if (widget.items.length > 6 && !isExpanded)
          AnimatedSeeMoreButton(
            onPressed: () {
              setState(() {
                isExpanded = true;
              });
            },
          ),
      ],
    );
  }
}
