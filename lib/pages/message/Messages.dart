import 'package:flutter/material.dart';
import 'widgets/MessageCard.dart';

class Messages extends StatefulWidget {
  const Messages({super.key});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    
    // Custom theme colors
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final muted = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final mutedForeground = isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent = isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: background,
                title: Text(
                  "Messages",
                  style: TextStyle(
                    color: foreground,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.video_call_outlined,
                      color: foreground,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: foreground,
                    ),
                    onPressed: () {},
                  ),
                ],
                pinned: true,
                floating: true,
                bottom: TabBar(
                  controller: _tabController,
                  labelColor: foreground,
                  unselectedLabelColor: mutedForeground,
                  indicatorColor: foreground,
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
                      color: accent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
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
                          background: background,
                          foreground: foreground,
                          muted: muted,
                        ),
                        for (var i = 0; i < 10; i++)
                          _buildStoryItem(
                            name: "User ${i + 1}",
                            hasUnseenStory: true,
                            background: background,
                            foreground: foreground,
                            muted: muted,
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
                        color: accent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: border),
                      ),
                      child: TextField(
                        style: TextStyle(color: foreground),
                        decoration: InputDecoration(
                          icon: Icon(Icons.search, color: mutedForeground),
                          hintText: 'Search messages...',
                          hintStyle: TextStyle(color: mutedForeground),
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
    );
  }

  Widget _buildStoryItem({
    required String name,
    bool isYourStory = false,
    bool hasUnseenStory = false,
    required Color background,
    required Color foreground,
    required Color muted,
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
                          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        )
                      : null,
                  color: !hasUnseenStory ? muted : null,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: background,
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
                      color: const Color(0xFF8B5CF6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: background,
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
              color: foreground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
