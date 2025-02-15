import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/pages/home/widgets/CampusPosts.dart';
import 'package:beyondtheclass/pages/drawer/pages/pastPaper/DepartmentPage.dart';
import 'package:beyondtheclass/pages/drawer/pages/teachersReviews/TeachersPage.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:beyondtheclass/providers/page_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyDrawer extends ConsumerStatefulWidget {
  const MyDrawer({super.key});

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends ConsumerState<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    String name = auth.user?['name'] ?? "";
    String username = auth.user?['username'] ?? "";

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Container(
          decoration: BoxDecoration(
            gradient: Theme.of(context).brightness == Brightness.dark
                // for dark mode
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.black12, Colors.black38],
                  )
                // for light mode
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color.fromARGB(255, 12, 12, 12),
                      const Color.fromARGB(255, 32, 32, 32)
                          .withValues(alpha: 0.1)
                    ],
                  ),
            border: Border.all(
              color:
                  const Color.fromARGB(255, 22, 22, 22).withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 31, 31, 31)
                    .withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(3, 3),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(-3, -3),
              ),
            ],
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 20),
            // Close Drawer Button
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 40, 15, 0),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_sharp,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),
            const Divider(thickness: 0.5,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 5, 8, 15),
                  child: GestureDetector(
                    onTap: () => ref.read(pageIndexProvider.notifier).state =
                        BottomNavBarRoute.profile,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color.fromARGB(160, 10, 10, 10),
                          child: Icon(
                            Icons.person,
                            size: 25,
                            color: Color.fromARGB(239, 238, 238, 238),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name ?? 'user',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(227, 244, 244, 244),
                                ),
                              ),
                              Text(
                                '@$username' ?? '@username',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(243, 227, 227, 227),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white54,
                    size: 22,
                  ),
                  onPressed: () {
                    ref.watch(authProvider.notifier).logout();
                    Navigator.pushNamedAndRemoveUntil(
                        context, AppRoutes.authScreen, (route) => false);
                  },
                ),
              ],
            ),
            const Divider(),

            // Drawer Options
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.home_filled,color: Color.fromARGB(223, 178, 178, 178),),
                    title: const Text("Home",
                        style: TextStyle(color: Color.fromARGB(223, 255, 255, 255), fontSize: 14)),
                    onTap: () {
                      () => ref.read(pageIndexProvider.notifier).state =
                        BottomNavBarRoute.home;
                    },
                  ),
                  ListTile(
                    // leading: Icon(Icons.person, color: Colors.white,color: Color.fromARGB(223, 178, 178, 178),),
                    leading: const Icon(Icons.workspaces_outline,color: Color.fromARGB(223, 178, 178, 178),),
                    title: const Text("All Unis",
                        style: TextStyle(color: Color.fromARGB(223, 255, 255, 255), fontSize: 14)),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    // leading: Icon(Icons.person, color: Colors.white,color: Color.fromARGB(223, 178, 178, 178),),
                    leading: const Icon(Icons.home_work_outlined,color: Color.fromARGB(223, 178, 178, 178),),
                    title: const Text("Inter Campuses",
                        style: TextStyle(color: Color.fromARGB(223, 255, 255, 255), fontSize: 14)),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    // leading: Icon(Icons.notifications, color: Colors.white,color: Color.fromARGB(223, 178, 178, 178),),
                    leading: const Icon(Icons.emoji_people,color: Color.fromARGB(223, 178, 178, 178),),
                    title: const Text("Alumni",
                        style: TextStyle(color: Color.fromARGB(223, 255, 255, 255), fontSize: 14)),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    // leading: Icon(Icons.notifications, color: Colors.white,color: Color.fromARGB(223, 178, 178, 178),),
                    leading: const Icon(Icons.rate_review_rounded,color: Color.fromARGB(223, 178, 178, 178),),
                    title: const Text("Teacher's Reviews",
                        style: TextStyle(color: Color.fromARGB(223, 255, 255, 255), fontSize: 14)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TeachersPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.home_filled,color: Color.fromARGB(223, 178, 178, 178),),
                    title: const Text("Cafe Information Services",
                        style: TextStyle(color: Color.fromARGB(223, 255, 255, 255), fontSize: 14)),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.insert_drive_file_outlined,color: Color.fromARGB(223, 178, 178, 178),),
                    title: GestureDetector(
                        child: const Text("Past Papers",
                            style: TextStyle(
                                color: Color.fromARGB(223, 255, 255, 255), fontSize: 14))),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DepartmentPage()),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Divider(),

            //     Padding(
            //       padding: const EdgeInsets.only(bottom: 60.0),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Padding(
            //           padding: const EdgeInsets.fromLTRB(8, 1, 8, 15),
            //           child: GestureDetector(
            //             onTap: () => ref.read(pageIndexProvider.notifier).state =
            //                 BottomNavBarRoute.profile,
            //             child: Row(
            //               crossAxisAlignment: CrossAxisAlignment.center,
            //               mainAxisAlignment: MainAxisAlignment.start,
            //               children: [
            //                 const CircleAvatar(
            //                   radius: 20,
            //                   backgroundColor: Color.fromARGB(160, 10, 10, 10),
            //                   child: Icon(
            //                     Icons.person,
            //                     size: 25,
            //                     color: Color.fromARGB(239, 238, 238, 238),
            //                   ),
            //                 ),
            //                 const SizedBox(height: 10),
            //                 Padding(
            //                   padding: const EdgeInsets.only(left: 10),
            //                   child: Column(
            //                     mainAxisAlignment: MainAxisAlignment.center,
            //                     crossAxisAlignment: CrossAxisAlignment.start,
            //                     children: [
            //                       Text(
            //                         name ?? 'user',
            //                         style: const TextStyle(
            //                           fontSize: 11,
            //                           fontWeight: FontWeight.bold,
            //                           color: Color.fromARGB(227, 244, 244, 244),
            //                         ),
            //                       ),
            //                       Text(
            //                         '@$username' ?? '@username',
            //                         style: const TextStyle(
            //                           fontSize: 10,
            //                           fontWeight: FontWeight.bold,
            //                           color: Color.fromARGB(243, 227, 227, 227),
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                 )
            //               ],
            //             ),
            //           ),
            //         ),
            //         IconButton(
            //           icon: const Icon(
            //             Icons.logout,
            //             color: Colors.white54,
            //             size: 22,
            //           ),
            //           onPressed: () {
            //             ref.watch(authProvider.notifier).logout();
            //                 Navigator.pushNamedAndRemoveUntil(context, AppRoutes.authScreen, (route) => false);
            //           },
            //         ),
            //       ],
            //     )
            //   ),]
            // ),
          ])),
    );
  }
}
