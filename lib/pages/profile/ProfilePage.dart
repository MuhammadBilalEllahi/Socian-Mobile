import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/core/utils/constants.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedReviewFilter = 'All';

  // Sample repost data
  final List<Map<String, dynamic>> reposts = [
    {
      "originalPoster": "John Doe",
      "username": "@johndoe", 
      "content": "Just discovered an amazing study spot in the library! Perfect lighting and super quiet.",
      "date": "2024-01-15",
      "likes": 45,
      "comments": 12
    },
    {
      "originalPoster": "Jane Smith",
      "username": "@jsmith",
      "content": "Great turnout at today's CS Society meetup! Thanks everyone who came.",
      "date": "2024-01-14",
      "likes": 32,
      "comments": 8
    }
  ];

  // Sample posts data
  final List<Map<String, dynamic>> posts = [
    {
      "type": "society",
      "societyName": "Computer Science Society",
      "content": "Next week's hackathon is going to be amazing! Don't forget to register.",
      "date": "2024-01-16",
      "likes": 56,
      "comments": 23
    },
    {
      "type": "personal",
      "content": "Finally finished my thesis! Time to celebrate!",
      "date": "2024-01-15",
      "likes": 89,
      "comments": 34
    }
  ];

  // Sample societies data
  final List<Map<String, dynamic>> societies = [
    {
      "name": "Computer Science Society",
      "description": "A community for CS enthusiasts to learn, network and grow together. Regular hackathons, coding workshops and industry talks.",
      "members": 250,
      "activities": ["Hackathons", "Tech Talks", "Coding Workshops", "Industry Visits"],
      "benefits": ["Technical skill development", "Networking", "Project experience", "Industry exposure"]
    },
    {
      "name": "Entrepreneurship Club",
      "description": "Platform for aspiring entrepreneurs to develop business ideas, meet co-founders and learn from successful founders.",
      "members": 180,
      "activities": ["Startup Weekends", "Pitch Competitions", "Mentorship Sessions", "Networking Events"],
      "benefits": ["Business skills", "Leadership experience", "Startup exposure", "Mentorship"]
    },
    {
      "name": "Debate Society",
      "description": "Enhance your public speaking and critical thinking skills through competitive debating and discussions.",
      "members": 120,
      "activities": ["Inter-university Debates", "Public Speaking Workshops", "Mock Debates", "Speech Competitions"],
      "benefits": ["Communication skills", "Critical thinking", "Confidence building", "Competition experience"]
    },
    {
      "name": "Photography Club",
      "description": "Express creativity through photography. Learn techniques, participate in exhibitions and build your portfolio.",
      "members": 150,
      "activities": ["Photo Walks", "Equipment Workshops", "Exhibitions", "Competitions"],
      "benefits": ["Creative skills", "Technical knowledge", "Portfolio building", "Exhibition experience"]
    }
  ];

  // Sample jobs data
  final List<Map<String, dynamic>> jobs = [
    {
      "type": "Freelance",
      "title": "Mobile App Developer",
      "company": "Tech Startup",
      "description": "Looking for a Flutter developer to build a social media app",
      "budget": "\$2000-\$3000",
      "duration": "2 months",
      "skills": ["Flutter", "Firebase", "UI/UX"],
      "postedDate": "2024-01-15"
    },
    {
      "type": "Contract",
      "title": "Web Developer",
      "company": "Digital Agency",
      "description": "6-month contract for full-stack development",
      "salary": "\$5000/month",
      "location": "Remote",
      "skills": ["React", "Node.js", "MongoDB"],
      "postedDate": "2024-01-14"
    },
    {
      "type": "Task",
      "title": "Logo Design",
      "client": "Local Business",
      "description": "Need a modern logo for a cafe",
      "budget": "\$200",
      "deadline": "1 week",
      "skills": ["Graphic Design", "Illustrator"],
      "postedDate": "2024-01-16"
    }
  ];

  // Sample review data
  final List<Map<String, dynamic>> cafeReviews = [
    {
      "foodItem": "Chicken Sandwich",
      "cafeName": "Campus Cafe",
      "rating": 4.5,
      "review": "Amazing sandwich! Great value for money. The chicken was perfectly cooked.",
      "date": "2024-01-15",
      "foodItems": ["Lunch", "Sandwich", "Popular"]
    },
    {
      "foodItem": "Pancakes",
      "cafeName": "Campus Cafe",
      "rating": 4.0,
      "review": "Fluffy pancakes with great maple syrup. Perfect breakfast option.",
      "date": "2024-01-14",
      "foodItems": ["Breakfast", "Sweet", "Vegetarian"]
    },
    {
      "foodItem": "Margherita Pizza",
      "cafeName": "Campus Cafe",
      "rating": 4.8,
      "review": "Best pizza on campus, thin crust and fresh toppings. Highly recommended!",
      "date": "2024-01-13",
      "foodItems": ["Pizza", "Lunch", "Vegetarian"]
    },
    {
      "foodItem": "Classic Burger",
      "cafeName": "Campus Cafe",
      "rating": 4.2,
      "review": "Juicy burger with fresh ingredients. Quick service!",
      "date": "2024-01-12",
      "foodItems": ["Burger", "Lunch", "Popular"]
    }
  ];

  @override
  void initState() {
    _tabController = TabController(length: 6, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildRepostsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: reposts.length,
      itemBuilder: (context, index) {
        final repost = reposts[index];
        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.repeat, color: Colors.grey, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Reposted from ${repost["originalPoster"]}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  repost["username"],
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  repost["content"],
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      repost["date"],
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.red[400], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          repost["likes"].toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.comment, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          repost["comments"].toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post["type"] == "society")
                  Text(
                    post["societyName"],
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  post["content"],
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      post["date"],
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.red[400], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          post["likes"].toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.comment, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          post["comments"].toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocietyTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: societies.length,
      itemBuilder: (context, index) {
        final society = societies[index];
        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      society["name"],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${society["members"]} members',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  society["description"],
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Activities:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: (society["activities"] as List<String>).map((activity) => Chip(
                    label: Text(
                      activity,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.grey[800],
                    labelStyle: const TextStyle(color: Colors.white),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Benefits:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: (society["benefits"] as List<String>).map((benefit) => Chip(
                    label: Text(
                      benefit,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.green[900],
                    labelStyle: const TextStyle(color: Colors.white),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Handle join society
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: const Text('Join Society'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildJobsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: job["type"] == "Freelance" 
                      ? Colors.blue[900]
                      : job["type"] == "Contract" 
                        ? Colors.green[900]
                        : Colors.orange[900],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    job["type"],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  job["title"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  job["company"] ?? job["client"],
                  style: TextStyle(color: Colors.grey[400]),
                ),
                const SizedBox(height: 8),
                Text(
                  job["description"],
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                if (job["budget"] != null)
                  Row(
                    children: [
                      const Icon(Icons.attach_money, color: Colors.green, size: 16),
                      Text(
                        job["budget"],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                if (job["salary"] != null)
                  Row(
                    children: [
                      const Icon(Icons.payments, color: Colors.green, size: 16),
                      Text(
                        job["salary"],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: (job["skills"] as List<String>).map((skill) => Chip(
                    label: Text(
                      skill,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.grey[800],
                    labelStyle: const TextStyle(color: Colors.white),
                  )).toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Posted: ${job["postedDate"]}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    if (job["deadline"] != null)
                      Text(
                        "Deadline: ${job["deadline"]}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    if (job["duration"] != null)
                      Text(
                        "Duration: ${job["duration"]}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'All', label: Text('All')),
              ButtonSegment(value: 'Cafe', label: Text('Cafe')),
              ButtonSegment(value: 'Teacher', label: Text('Teacher')),
            ],
            selected: {_selectedReviewFilter},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _selectedReviewFilter = newSelection.first;
              });
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.grey[800]!;
                  }
                  return Colors.black;
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              if (_selectedReviewFilter == 'All' || _selectedReviewFilter == 'Cafe')
                Stack(
                  children: [
                    // Third card (bottom)
                    if (cafeReviews.length > 2)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: _buildCafeReviewCard(
                          foodItem: cafeReviews[2]["foodItem"],
                          cafeName: cafeReviews[2]["cafeName"],
                          rating: cafeReviews[2]["rating"],
                          review: cafeReviews[2]["review"],
                          date: cafeReviews[2]["date"],
                          foodItems: List<String>.from(cafeReviews[2]["foodItems"]),
                          moreReviews: cafeReviews.length > 3 ? cafeReviews.length - 3 : null,
                        ),
                      ),
                    // Second card (middle)
                    if (cafeReviews.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: _buildCafeReviewCard(
                          foodItem: cafeReviews[1]["foodItem"],
                          cafeName: cafeReviews[1]["cafeName"],
                          rating: cafeReviews[1]["rating"],
                          review: cafeReviews[1]["review"],
                          date: cafeReviews[1]["date"],
                          foodItems: List<String>.from(cafeReviews[1]["foodItems"]),
                        ),
                      ),
                    // First card (top)
                    if (cafeReviews.isNotEmpty)
                      _buildCafeReviewCard(
                        foodItem: cafeReviews[0]["foodItem"],
                        cafeName: cafeReviews[0]["cafeName"],
                        rating: cafeReviews[0]["rating"],
                        review: cafeReviews[0]["review"],
                        date: cafeReviews[0]["date"],
                        foodItems: List<String>.from(cafeReviews[0]["foodItems"]),
                      ),
                  ],
                ),
              if (_selectedReviewFilter == 'All' || _selectedReviewFilter == 'Teacher')
                _buildTeacherReviewCard(
                  teacherName: "Prof. Smith",
                  department: "Computer Science",
                  rating: 5.0,
                  review: "Excellent teaching methods and very helpful.",
                  date: "2024-01-10",
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCafeReviewCard({
    required String foodItem,
    required String cafeName,
    required double rating,
    required String review,
    required String date,
    required List<String> foodItems,
    int? moreReviews,
  }) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          foodItem,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          cafeName,
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        Text(
                          rating.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  review,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: foodItems.map((item) => Chip(
                    label: Text(
                      item,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.grey[800],
                    labelStyle: const TextStyle(color: Colors.white),
                  )).toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          if (moreReviews != null)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+$moreReviews more',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTeacherReviewCard({
    required String teacherName,
    required String department,
    required double rating,
    required String review,
    required String date,
  }) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacherName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      department,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    Text(
                      rating.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              date,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          // leading: IconButton(
          //   icon: const Icon(Icons.arrow_back, color: Colors.white),
          //   // onPressed: () => Navigator.pop(context),
          // ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.white),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            auth.user?['name'] ?? "Logged Out",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: auth.user?['profile']['picture'] != null
                                ? NetworkImage(auth.user?['profile']['picture'])
                                : const AssetImage("assets/images/profilepic2.jpg")
                                    as ImageProvider,
                          ),
                        ],
                      ),
                      Text(
                        "@${auth.user?['username'] ?? "Logged Out"}",
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            "Joined December 2023",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: "10 ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: "Following",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: "5 ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: "Followers",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.white,
                    tabs: const [
                      Tab(text: 'posts'),
                      Tab(text: 'reposts'),
                      Tab(text: 'reviews'),
                      Tab(text: 'replies'),
                      Tab(text: 'society'),
                      Tab(text: 'jobs'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildPostsTab(),
              _buildRepostsTab(),
              _buildReviewsTab(),
              const Center(child: Text('replies', style: TextStyle(color: Colors.white))),
              _buildSocietyTab(),
              _buildJobsTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

// import 'package:flutter/material.dart';

// import 'widgets/AboutMeProfile.dart';
// import 'widgets/CarouselProfilePage.dart';
// import 'widgets/ProfileDropDown.dart';
// import 'widgets/ProfileIdentity.dart';
// import 'widgets/StatsBoxProfile.dart';

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       body: Container(
//         // color: Colors.lightGreenAccent,
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(height: screenWidth/16,),

//               const ProfileDropDown(),

//               const ProfileIdentity(),
//               const SizedBox(height: 15,),
//               const Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   StatsBoxProfile(),
//                 ],
//               ),
          
//               const SizedBox(height: 15,),
          
//               // About Me
//               const SingleChildScrollView(
          
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                 children: [
//                   AboutMeProfile(),
//                   // AboutMeProfile(),
//                   // AboutMeProfile(),
//                 ],
//               )),
//               const Text("Highlights",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
//               const CarouselProfilePage(),
//               const SizedBox(height: 10,),
//               const Text("Posts",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),

//               const SizedBox(height: 150,),
//             ],

//           ),
//         ),
//       ),
//     );
//   }
// }










