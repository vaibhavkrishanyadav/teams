import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:teams/provider/user_provider.dart';
import 'package:teams/screens/callscreens/pickup_screen.dart';
import 'package:teams/utils/firebase_methods.dart';
import 'package:teams/utils/utils.dart';

import 'chat_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {

  PageController pageController;
  int _page = 0;
  final FirebaseMethods firebaseMethods = FirebaseMethods();
  UserProvider userProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshUser();

      firebaseMethods.setUserState(
        userId: userProvider.getUser.uid,
        userState: UserState.Online,
      );
    });

    WidgetsBinding.instance.addObserver(this);

    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    String currentUserId =
    (userProvider != null && userProvider.getUser != null)
        ? userProvider.getUser.uid
        : "";

    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        currentUserId != null
            ? firebaseMethods.setUserState(
            userId: currentUserId, userState: UserState.Online)
            : print("resume state");
        break;
      case AppLifecycleState.inactive:
        currentUserId != null
            ? firebaseMethods.setUserState(
            userId: currentUserId, userState: UserState.Offline)
            : print("inactive state");
        break;
      case AppLifecycleState.paused:
        currentUserId != null
            ? firebaseMethods.setUserState(
            userId: currentUserId, userState: UserState.Waiting)
            : print("paused state");
        break;
      case AppLifecycleState.detached:
        currentUserId != null
            ? firebaseMethods.setUserState(
            userId: currentUserId, userState: UserState.Offline)
            : print("detached state");
        break;
    }
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: Colors.black,
        body: PageView(
          children: <Widget>[
            Container(
              child: ChatListScreen(),
            ),
            Center(child: Text("Group", style: TextStyle(color: Colors.white),)),
            Center(child: Text("Call Logs", style: TextStyle(color: Colors.white),)),
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
          //physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: Container(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: CupertinoTabBar(
              backgroundColor: Colors.black,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat,
                      color: (_page == 0)
                          ? Colors.lightBlue
                          : Colors.grey),
                  title: Text(
                    "Chats",
                    style: TextStyle(
                        fontSize: 15,
                        color: (_page == 0)
                            ? Colors.lightBlue
                            : Colors.grey),
                  ),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.group,
                      color: (_page == 1)
                          ? Colors.lightBlue
                          : Colors.grey),
                  title: Text(
                    "Group",
                    style: TextStyle(
                        fontSize: 15,
                        color: (_page == 1)
                            ? Colors.lightBlue
                            : Colors.grey),
                  ),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.call,
                      color: (_page == 2)
                          ? Colors.lightBlue
                          : Colors.grey),
                  title: Text(
                    "Calls",
                    style: TextStyle(
                        fontSize: 15,
                        color: (_page == 2)
                            ? Colors.lightBlue
                            : Colors.grey),
                  ),
                ),
              ],
              onTap: navigationTapped,
              currentIndex: _page,
            ),
          ),
        ),
        // bottomNavigationBar: BottomNavigationBar(
        //   items: const <BottomNavigationBarItem>[
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.chat),
        //       label: 'Chats',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.group),
        //       label: 'Group',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.call),
        //       label: 'Calls',
        //     ),
        //   ],
        //   currentIndex: _page,
        //   selectedItemColor: Colors.amber[800],
        //   onTap: navigationTapped,
        // ),
      ),
    );
  }
}
