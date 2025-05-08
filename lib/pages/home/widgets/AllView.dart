import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/pages/drawer/student/StudentDrawer.dart';
import 'package:beyondtheclass/pages/home/widgets/components/post/CreatePost.dart';
import 'package:flutter/material.dart';
import 'package:beyondtheclass/pages/home/widgets/campus/CampusPosts.dart';
import 'package:beyondtheclass/pages/home/widgets/universities/AllUniversityPosts.dart';
import 'package:beyondtheclass/pages/home/widgets/intracampus/IntraCampus.dart';

class AllView extends StatefulWidget {
  const AllView({super.key});

  @override
  State<AllView> createState() => _AllViewState();
}

class _AllViewState extends State<AllView> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isCampusView = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      drawer: const StudentDrawer(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: isDark ? Colors.black : Colors.white,
              elevation: 0,
              toolbarHeight: 60.0,
              centerTitle: false,
              title: Text(
                AppConstants.appName,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              automaticallyImplyLeading: false,
              pinned: true,
              leading: GestureDetector(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: Icon(
                  Icons.menu_outlined,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: isDark ? Colors.white : Colors.black,
                    unselectedLabelColor:
                        isDark ? Colors.grey[400] : Colors.grey[600],
                    indicatorColor: isDark ? Colors.white : Colors.black,
                    indicatorWeight: 3,
                    tabs: [
                      Tab(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isCampusView = !_isCampusView;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isCampusView ? 'Campus' : 'IntraCampus',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                _isCampusView
                                    ? Icons.arrow_drop_down
                                    : Icons.arrow_drop_up,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Tab(
                        child: Text(
                          'Universities',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Campus/IntraCampus Tab
            _isCampusView ? const CampusPosts() : const IntraCampus(),
            const AllUniversityPosts(),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreatePost(),
              ),
            );
          },
          backgroundColor: isDark ? Colors.white : Colors.black,
          child: Icon(
            Icons.add,
            color: isDark ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
