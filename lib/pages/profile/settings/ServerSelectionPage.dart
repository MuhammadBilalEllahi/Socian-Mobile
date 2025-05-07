import 'package:flutter/material.dart';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServerSelectionPage extends StatefulWidget {
  const ServerSelectionPage({super.key});

  @override
  State<ServerSelectionPage> createState() => _ServerSelectionPageState();
}

class _ServerSelectionPageState extends State<ServerSelectionPage> {
  final TextEditingController _newUrlController = TextEditingController();
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadCurrentUrlIndex();
  }

  Future<void> _loadCurrentUrlIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedIndex = prefs.getInt('current_url_index') ?? 0;
    });
  }

  Future<void> _selectUrl(int index) async {
    await ApiConstants.setUrlByIndex(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _addNewUrl() async {
    final newUrl = _newUrlController.text.trim();
    if (newUrl.isEmpty) return;

    // Find the next available index
    int newIndex = ApiConstants.urlMap.keys.reduce((a, b) => a > b ? a : b) + 1;

    setState(() {
      ApiConstants.urlMap[newIndex] = newUrl;
    });

    await _selectUrl(newIndex);
    _newUrlController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final surfaceColor =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final secondaryTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Server',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode
                      ? const Color(0xFF27272A)
                      : const Color(0xFFE4E4E7),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newUrlController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Enter new server URL',
                      hintStyle: TextStyle(color: secondaryTextColor),
                      filled: true,
                      fillColor: backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDarkMode
                              ? const Color(0xFF27272A)
                              : const Color(0xFFE4E4E7),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDarkMode
                              ? const Color(0xFF27272A)
                              : const Color(0xFFE4E4E7),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDarkMode
                              ? const Color(0xFF3F3F46)
                              : const Color(0xFFA1A1AA),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addNewUrl,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? const Color(0xFF27272A)
                        : const Color(0xFF18181B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: ApiConstants.urlMap.length,
              itemBuilder: (context, index) {
                final urlIndex = ApiConstants.urlMap.keys.elementAt(index);
                final url = ApiConstants.urlMap[urlIndex]!;
                final isSelected = urlIndex == _selectedIndex;

                return Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color.fromARGB(255, 139, 139, 233)
                        : null,
                    border: Border(
                      bottom: BorderSide(
                        color: isDarkMode
                            ? const Color(0xFF27272A)
                            : const Color(0xFFE4E4E7),
                        width: 1,
                      ),
                    ),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      url,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      'Index: $urlIndex',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                    trailing: isSelected
                        ? Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color.fromARGB(255, 9, 226, 64)
                                  : const Color.fromARGB(255, 8, 197, 8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: isDarkMode
                                  ? const Color.fromARGB(255, 252, 252, 252)
                                  : const Color.fromARGB(255, 24, 24, 24),
                            ),
                          )
                        : null,
                    onTap: () => _selectUrl(urlIndex),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _newUrlController.dispose();
    super.dispose();
  }
}
