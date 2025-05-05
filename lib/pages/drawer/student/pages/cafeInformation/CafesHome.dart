import 'dart:developer';

import 'package:beyondtheclass/pages/drawer/student/pages/cafeInformation/FoodItemReviewsPage.dart';
import 'package:beyondtheclass/pages/drawer/student/pages/cafeInformation/Modals.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:flutter/material.dart';

class CafesHome extends StatefulWidget {
  const CafesHome({super.key});

  @override
  State<CafesHome> createState() => _CafesHomeState();
}

class _CafesHomeState extends State<CafesHome> {
  final _apiClient = ApiClient();
  List<Cafe> _cafes = [];
  List<FoodItem> _foodItems = [];
  List<FoodItem> _filteredFoodItems = [];
  String? _selectedCafeId;
  final TextEditingController _searchController = TextEditingController();
  int? _selectedRating;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFoodItems(String query) {
    setState(() {
      _filteredFoodItems = _foodItems.where((item) {
        final nameLower = item.name.toLowerCase();
        final descriptionLower = item.description.toLowerCase();
        final searchLower = query.toLowerCase();
        final matchesSearch = nameLower.contains(searchLower) ||
            descriptionLower.contains(searchLower);
        final matchesRating = _selectedRating == null ||
            (item.totalRatings ?? 0) >= _selectedRating!;
        return matchesSearch && matchesRating;
      }).toList();
    });
  }

  Future<void> _fetchCafes() async {
    final response = await _apiClient.get('/api/cafe/campus/cafe/all');

    final cafes =
        (response as List).map((json) => Cafe.fromJson(json)).toList();

    setState(() {
      _cafes = cafes;
    });

    // Fetch food items for the first cafe by default
    if (cafes.isNotEmpty) {
      _fetchFoodItems(cafes[0].id);
    }
  }

  Future<void> _fetchFoodItems(String cafeId) async {
    final response =
        await _apiClient.get('/api/cafe/campus/cafe/$cafeId/fooditems');

    final List<dynamic> foodItemsJson = response['fooditems']['foodItems'];
    final List<FoodItem> foodItems =
        foodItemsJson.map((json) => FoodItem.fromJson(json)).toList();

    setState(() {
      _foodItems = foodItems;
      _filteredFoodItems = foodItems;
      _selectedCafeId = cafeId;
      _searchController.clear();
      _selectedRating = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchCafes();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Cafes',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _cafes.length,
              itemBuilder: (context, index) {
                final cafe = _cafes[index];
                final isSelected = cafe.id == _selectedCafeId;

                return GestureDetector(
                  onTap: () => _fetchFoodItems(cafe.id),
                  child: CafeCard(
                    cafe: cafe,
                    isSelected: isSelected,
                    isDark: isDark,
                  ),
                );
              },
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 18),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: _selectedRating,
                isDense: true,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: isDark
                      ? Colors.white.withOpacity(0.7)
                      : Colors.black.withOpacity(0.7),
                ),
                hint: Text(
                  'Filter by rating',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(
                      'All ratings',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.9),
                      ),
                    ),
                  ),
                  ...List.generate(5, (index) {
                    final rating = index + 1;
                    return DropdownMenuItem<int?>(
                      value: rating,
                      child: Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$rating+ stars',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRating = value;
                  });
                  _filterFoodItems(_searchController.text);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color:
                        isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterFoodItems,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search food items...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDark
                            ? Colors.white.withOpacity(0.7)
                            : Colors.black.withOpacity(0.7),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _filteredFoodItems.isEmpty
                ? Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? 'No food items available'
                          : 'No items found',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredFoodItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredFoodItems[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: FoodItemCard(
                          item: item,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FoodItemReviewsPage(
                                  foodItemId: item.id,
                                  cafeId: _selectedCafeId!,
                                ),
                              ),
                            );
                          },
                          cafeId: _selectedCafeId!,
                          isDark: isDark,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class CafeCard extends StatelessWidget {
  final Cafe cafe;
  final bool isSelected;
  final bool isDark;

  const CafeCard({
    super.key,
    required this.cafe,
    this.isSelected = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? Colors.white.withOpacity(0.1) : Colors.black)
            : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Center(
              child: Text(
                cafe.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.white)
                      : (isDark ? Colors.white : Colors.black),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FoodItemCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onTap;
  final String cafeId;
  final bool isDark;

  const FoodItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.cafeId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.food_bank,
                        size: 32,
                        color: isDark
                            ? Colors.white.withOpacity(0.7)
                            : Colors.black.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.totalRatings ?? 0}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Rs ${item.price.isNotEmpty ? item.price.first.toStringAsFixed(0) : 'N/A'}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark ? Colors.white : Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (item.bestSelling) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    size: 16,
                                    color: isDark
                                        ? Colors.white.withOpacity(0.7)
                                        : Colors.black.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Best Seller',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                  ),
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
        ),
      ),
    );
  }
}
