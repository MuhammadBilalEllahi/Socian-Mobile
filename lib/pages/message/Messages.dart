import 'package:flutter/material.dart';
import 'widgets/MessageCard.dart';

class Messages extends StatefulWidget {
  const Messages({super.key});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> with SingleTickerProviderStateMixin {
  bool isDarkMode = true; // Toggle for theme
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  ThemeData get _theme => isDarkMode ? _darkTheme : _lightTheme;

  final _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.teal,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark().copyWith(
      secondary: Colors.tealAccent,
      surface: const Color(0xFF1E1E1E),
    ),
  );

  final _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.teal,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light().copyWith(
      secondary: Colors.teal,
      surface: Colors.grey[100],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _theme,
      child: Scaffold(
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  title: Text(
                    "Messages",
                    style: TextStyle(
                      color: _theme.colorScheme.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: _theme.colorScheme.onSurface,
                      ),
                      onPressed: () => setState(() => isDarkMode = !isDarkMode),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.video_call_outlined,
                        color: _theme.colorScheme.onSurface,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: _theme.colorScheme.onSurface,
                      ),
                      onPressed: () {},
                    ),
                  ],
                  pinned: true,
                  floating: true,
                  bottom: TabBar(
                    controller: _tabController,
                    labelColor: _theme.colorScheme.onSurface,
                    unselectedLabelColor: _theme.colorScheme.onSurface.withOpacity(0.5),
                    tabs: const [
                      Tab(text: 'Normal'),
                      Tab(text: 'Society'),
                      Tab(text: 'Job'),
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                // Normal Tab
                ListView(
                  children: [
                    // Stories Section
                    Container(
                      height: 130,
                      decoration: BoxDecoration(
                        color: _theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: isDarkMode ? [] : [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.all(8),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        children: [
                          _buildStoryItem(
                            isYourStory: true,
                            name: "Your Story",
                            hasUnseenStory: false,
                          ),
                          for (var i = 0; i < 10; i++)
                            _buildStoryItem(
                              name: "User ${i + 1}",
                              hasUnseenStory: true,
                            ),
                        ],
                      ),
                    ),

                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: _theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: _theme.colorScheme.onSurface.withOpacity(0.1),
                          ),
                        ),
                        child: TextField(
                          style: TextStyle(color: _theme.colorScheme.onSurface),
                          decoration: InputDecoration(
                            icon: Icon(Icons.search, color: _theme.colorScheme.onSurface.withOpacity(0.7)),
                            hintText: 'Search messages...',
                            hintStyle: TextStyle(color: _theme.colorScheme.onSurface.withOpacity(0.5)),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),

                    // Message List
                    for (var i = 0; i < 15; i++)
                      MessageCard(
                        picture: 'assets/images/anime.png',
                        name: 'User ${i + 1}',
                        message: 'Hey there! How are you doing today?',
                        time: '${(i + 1)}:45 PM',
                        isOnline: i % 2 == 0,
                      ),
                  ],
                ),

                // Society Tab
                ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return MessageCard(
                      picture: 'assets/images/anime.png',
                      name: 'Society Group ${index + 1}',
                      message: 'Latest society updates and discussions',
                      time: '${(index + 1)}:00 PM',
                      isOnline: true,
                    );
                  },
                ),

                // Job Tab
                ListView.builder(
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    return MessageCard(
                      picture: 'assets/images/anime.png',
                      name: 'Job Recruiter ${index + 1}',
                      message: 'We have a new job opportunity for you',
                      time: '${(index + 1)}:15 PM',
                      isOnline: true,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryItem({
    required String name,
    bool isYourStory = false,
    bool hasUnseenStory = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 75,
                height: 75,
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: hasUnseenStory
                      ? const LinearGradient(
                          colors: [Colors.purple, Colors.black, Colors.pink],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        )
                      : null,
                  color: !hasUnseenStory ? _theme.colorScheme.onSurface.withOpacity(0.2) : null,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _theme.scaffoldBackgroundColor,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/anime.png'),
                  ),
                ),
              ),
              if (isYourStory)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _theme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              color: _theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
