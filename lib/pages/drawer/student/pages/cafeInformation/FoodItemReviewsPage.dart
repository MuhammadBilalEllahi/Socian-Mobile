import 'dart:developer';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:flutter/material.dart';

class FoodItemReviewsPage extends StatefulWidget {
  final String foodItemId;
  final String cafeId;
  const FoodItemReviewsPage({
    super.key,
    required this.foodItemId,
    required this.cafeId,
  });

  @override
  State<FoodItemReviewsPage> createState() => _FoodItemReviewsPageState();
}

class _FoodItemReviewsPageState extends State<FoodItemReviewsPage> {
  final _apiClient = ApiClient();
  Map<String, dynamic>? foodItem;
  List reviews = [];
  List filteredReviews = [];
  int? _selectedRating;
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  void _filterReviews() {
    setState(() {
      if (_selectedRating == null) {
        filteredReviews = reviews;
      } else {
        filteredReviews = reviews
            .where((review) => review['rating'] == _selectedRating)
            .toList();
      }
    });
  }

  Future<void> getAllReviews() async {
    try {
      final response = await _apiClient
          .get('/api/cafe/campus/cafe/fooditems/reviews/${widget.foodItemId}');
      setState(() {
        foodItem = response;
        reviews = response['ratings'] ?? [];
        filteredReviews = reviews;
      });
    } catch (e) {
      print('Error fetching reviews: $e');
    }
  }

  Future<void> submitRating() async {
    try {
      final response = await _apiClient.post(
        '/api/cafe/fooditem/rate',
        {
          'foodItemId': widget.foodItemId,
          'rating': _rating,
          'ratingMessage': _commentController.text,
          'cafeId': widget.cafeId
        },
      );

      if (response != null) {
        await getAllReviews();
        _commentController.clear();
        _rating = 0;
        setState(() {});
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error submitting rating: $e');
    }
  }

  void _showReviewBottomSheet() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? Colors.black : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Write a Review',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black.withOpacity(0.7),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ...List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            _rating = index + 1.0;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            index < _rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: Colors.amber,
                            size: 24,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Write your review...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white.withOpacity(0.2)
                          : Colors.black.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _rating > 0 ? submitRating : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? Colors.white.withOpacity(0.1) : Colors.black,
                    foregroundColor: isDark ? Colors.white : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Submit Review',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getAllReviews();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
          'Food Reviews',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showReviewBottomSheet,
        backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black,
        child: Icon(
          Icons.add_comment,
          color: isDark ? Colors.white : Colors.white,
        ),
      ),
      body: foodItem == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food Item Details Card
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white,
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
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              foodItem!['name'],
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              foodItem!['description'],
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 12),
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
                                    'Rs ${foodItem!['price'][0].toStringAsFixed(0)}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color:
                                          isDark ? Colors.white : Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
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
                                  child: Text(
                                    '${foodItem!['totalRatings']} Reviews',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Reviews List
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reviews',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.white,
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
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                  items: [
                                    DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text(
                                        'All ratings',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.9),
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
                                              '$rating stars',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: theme
                                                    .colorScheme.onSurface
                                                    .withOpacity(0.9),
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
                                    _filterReviews();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        filteredReviews.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    _selectedRating == null
                                        ? 'No reviews yet'
                                        : 'No ${_selectedRating} star reviews',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredReviews.length,
                                itemBuilder: (context, index) {
                                  final review = filteredReviews[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.05)
                                          : Colors.white,
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
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor: isDark
                                                        ? Colors.white
                                                            .withOpacity(0.1)
                                                        : Colors.black
                                                            .withOpacity(0.05),
                                                    child: Text(
                                                      review['userId']['name']
                                                              [0]
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                        color: isDark
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        review['userId']
                                                            ['name'],
                                                        style: theme.textTheme
                                                            .titleSmall
                                                            ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      Text(
                                                        '@${review['userId']['username']}',
                                                        style: theme
                                                            .textTheme.bodySmall
                                                            ?.copyWith(
                                                          color: theme
                                                              .colorScheme
                                                              .onSurface
                                                              .withOpacity(0.7),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                _formatDate(
                                                    review['createdAt']),
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: theme
                                                      .colorScheme.onSurface
                                                      .withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          if (review['rating'] > 0)
                                            Row(
                                              children: [
                                                Text(
                                                  review['rating'].toString(),
                                                  style: theme
                                                      .textTheme.bodyMedium
                                                      ?.copyWith(
                                                    color: theme
                                                        .colorScheme.onSurface
                                                        .withOpacity(0.9),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                if (review['rating'] == 5)
                                                  Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                    size: 16,
                                                  )
                                                else if (review['rating'] == 4)
                                                  Icon(
                                                    Icons.star,
                                                    color: Colors.amberAccent,
                                                    size: 16,
                                                  )
                                                else if (review['rating'] == 3)
                                                  Icon(
                                                    Icons.star,
                                                    color:
                                                        Colors.deepOrangeAccent,
                                                    size: 16,
                                                  )
                                                else if (review['rating'] == 2)
                                                  Icon(
                                                    Icons.star,
                                                    color: Colors.grey,
                                                    size: 16,
                                                  )
                                                else
                                                  Icon(
                                                    Icons.star,
                                                    color: Colors.redAccent,
                                                    size: 16,
                                                  )
                                              ],
                                            ),
                                          if (review['ratingMessage'] != null &&
                                              review['ratingMessage']
                                                  .isNotEmpty)
                                            Text(
                                              review['ratingMessage'],
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: theme
                                                    .colorScheme.onSurface
                                                    .withOpacity(0.9),
                                              ),
                                            ),
                                          const SizedBox(height: 12),
                                          // Row(
                                          //   children: [
                                          //     IconButton(
                                          //       icon: Icon(
                                          //         review['favourited']
                                          //             ? Icons.favorite
                                          //             : Icons.favorite_border,
                                          //         color: review['favourited']
                                          //             ? Colors.red
                                          //             : (isDark
                                          //                 ? Colors.white
                                          //                     .withOpacity(0.7)
                                          //                 : Colors.black
                                          //                     .withOpacity(
                                          //                         0.7)),
                                          //       ),
                                          //       onPressed: () {
                                          //         // TODO: Implement favorite functionality
                                          //       },
                                          //     ),
                                          //     Text(
                                          //       '${review['cafeVoteId']['votePlusCount']}',
                                          //       style: TextStyle(
                                          //         color: Colors.green,
                                          //         fontSize: 14,
                                          //       ),
                                          //     ),
                                          //     const SizedBox(width: 8),
                                          //     IconButton(
                                          //       icon: Icon(
                                          //         Icons.thumb_down_alt_outlined,
                                          //         color: isDark
                                          //             ? Colors.white
                                          //                 .withOpacity(0.7)
                                          //             : Colors.black
                                          //                 .withOpacity(0.7),
                                          //       ),
                                          //       onPressed: () {
                                          //         // TODO: Implement downvote functionality
                                          //       },
                                          //     ),
                                          //     Text(
                                          //       '${review['cafeVoteId']['voteMinusCount']}',
                                          //       style: const TextStyle(
                                          //         color: Colors.red,
                                          //         fontSize: 14,
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()}y ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()}mo ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }
}
