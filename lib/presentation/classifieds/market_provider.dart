import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/classifieds_models.dart';
import 'classifieds_provider.dart';

class MarketState {
  final String? category;
  final String sortOrder; // 'latest', 'low_price', 'high_price'
  final int currentPage;
  final int itemsPerPage;

  MarketState({
    this.category,
    this.sortOrder = 'latest',
    this.currentPage = 1,
    this.itemsPerPage = 10,
  });

  MarketState copyWith({
    String? category,
    String? sortOrder,
    int? currentPage,
  }) {
    return MarketState(
      category: category ?? this.category,
      sortOrder: sortOrder ?? this.sortOrder,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: this.itemsPerPage,
    );
  }

  MarketState clearCategory() {
    return MarketState(
      category: null,
      sortOrder: this.sortOrder,
      currentPage: this.currentPage,
      itemsPerPage: this.itemsPerPage,
    );
  }
}

class MarketNotifier extends StateNotifier<MarketState> {
  MarketNotifier() : super(MarketState());

  void setCategory(String? category) {
    if (category == null) {
      state = state.clearCategory();
    } else {
      state = state.copyWith(category: category, currentPage: 1);
    }
  }

  void setSortOrder(String order) {
    state = state.copyWith(sortOrder: order, currentPage: 1);
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }
}

final marketStateProvider = StateNotifierProvider<MarketNotifier, MarketState>((ref) {
  return MarketNotifier();
});

final filteredMarketItemsProvider = Provider<AsyncValue<Map<String, dynamic>>>((ref) {
  final itemsAsync = ref.watch(marketItemsProvider);
  final filterState = ref.watch(marketStateProvider);

  return itemsAsync.whenData((items) {
    List<MarketItem> filtered = List.from(items);

    // Apply Category Filter
    if (filterState.category != null && filterState.category!.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.categoryName.toLowerCase() == filterState.category!.toLowerCase();
      }).toList();
    }

    // Apply Sorting
    filtered.sort((a, b) {
      if (filterState.sortOrder == 'latest') {
        return b.createdAt.compareTo(a.createdAt);
      } else if (filterState.sortOrder == 'high_price' || filterState.sortOrder == 'low_price') {
        double getPriceVal(String priceStr) {
          final RegExp regExp = RegExp(r'\d+(\.\d+)?');
          final match = regExp.firstMatch(priceStr);
          if (match != null) {
            return double.tryParse(match.group(0) ?? '0') ?? 0;
          }
          return 0;
        }
        
        final valA = getPriceVal(a.price);
        final valB = getPriceVal(b.price);
        
        if (filterState.sortOrder == 'high_price') {
          return valB.compareTo(valA);
        } else {
          return valA.compareTo(valB);
        }
      }
      return 0;
    });

    final totalItems = filtered.length;
    final totalPages = (totalItems / filterState.itemsPerPage).ceil();
    
    int currentPage = filterState.currentPage;
    if (currentPage < 1) currentPage = 1;
    if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;

    final startIndex = (currentPage - 1) * filterState.itemsPerPage;
    var endIndex = startIndex + filterState.itemsPerPage;
    if (endIndex > totalItems) endIndex = totalItems;
    
    List<MarketItem> pagedItems = [];
    if (startIndex < totalItems) {
      pagedItems = filtered.sublist(startIndex, endIndex);
    }

    return {
      'items': pagedItems,
      'totalItems': totalItems,
      'totalPages': totalPages,
      'currentPage': currentPage,
    };
  });
});
