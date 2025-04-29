import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/pages/drawer/student/StudentDrawer.dart';
import 'package:beyondtheclass/pages/home/widgets/components/post/CreatePost.dart';
import 'package:flutter/material.dart';
import 'package:beyondtheclass/pages/home/widgets/campus/CampusPosts.dart';
import 'package:beyondtheclass/pages/home/widgets/universities/AllUniversityPosts.dart';

class AllView extends StatefulWidget {
  const AllView({super.key});

  @override
  State<AllView> createState() => _AllViewState();
}

class _AllViewState extends State<AllView> with TickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    // TODO: implement initState
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
                    tabs: const [
                      Tab(
                        child: Text(
                          'Campus',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Tab(
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
          children: const [
            // Campus Tab
            CampusPosts(),

            AllUniversityPosts(),

            // Universities Tab
            // const LogoLoader(),
            // Center(
            //   child: Text(
            //     'Coming Soon',
            //     style: TextStyle(
            //       color: isDark ? Colors.white : Colors.black,
            //       fontSize: 16,
            //     ),
            //   ),
            // ),
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
