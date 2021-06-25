import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  PageController pageController;
  int _page = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController();
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView(
        children: <Widget>[
          Container(
            child: ChatScreen(),
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
    );
  }
}
