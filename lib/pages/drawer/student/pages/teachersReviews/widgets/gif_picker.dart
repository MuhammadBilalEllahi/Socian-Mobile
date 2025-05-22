import 'package:flutter/material.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GifPicker extends StatefulWidget {
  final bool isDark;
  final Function(String) onGifSelected;

  const GifPicker({
    super.key,
    required this.isDark,
    required this.onGifSelected,
  });

  @override
  State<GifPicker> createState() => _GifPickerState();
}

class _GifPickerState extends State<GifPicker> {
  final TextEditingController _searchController = TextEditingController();
  final ExternalApiClient _apiClient = ExternalApiClient();
  List<Map<String, dynamic>> _gifs = [];
  bool _isLoading = false;
  String? _currentQuery;

  @override
  void initState() {
    super.initState();
    _loadTrendingGifs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTrendingGifs() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _gifs = [];
    });

    try {
      final response = await _apiClient.get(
        'https://api.giphy.com/v1/gifs/trending',
        queryParameters: {
          'api_key': dotenv.env['GIPHY_API_KEY'] ?? "", // Replace with your actual Giphy API key
          'limit': 20,
        },
      );

      setState(() {
        _gifs = List<Map<String, dynamic>>.from(response['data']);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load GIFs: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _searchGifs(String query) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _gifs = [];
      _currentQuery = query;
    });

    try {
      final response = await _apiClient.get(
        'https://api.giphy.com/v1/gifs/search',
        queryParameters: {
          'api_key': dotenv.env['GIPHY_API_KEY'] ?? "",
          'q': query,
          'limit': 20,
        },
      );

      setState(() {
        _gifs = List<Map<String, dynamic>>.from(response['data']);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to search GIFs: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search GIFs...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: widget.isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: widget.isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: widget.isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.2),
                ),
              ),
              filled: true,
              fillColor: widget.isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
            ),
            onChanged: (value) {
              if (value.trim().isEmpty) {
                _loadTrendingGifs();
              } else {
                _searchGifs(value.trim());
              }
            },
          ),
        ),
        Expanded(
          child: _isLoading && _gifs.isEmpty
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _gifs.length,
                  itemBuilder: (context, index) {
                    final gif = _gifs[index];
                    final originalUrl = gif['images']['original']['url'] as String;
                    final previewUrl = gif['images']['preview_gif']['url'] as String;

                    return InkWell(
                      onTap: () {
                        widget.onGifSelected(originalUrl);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          previewUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: widget.isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.05),
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    widget.isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
} 