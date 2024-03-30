import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pulse_social/providers/user_provider.dart';
import 'package:pulse_social/model/user.dart' as model;
import 'package:pulse_social/utility/colors.dart';
import 'package:pulse_social/utility/global_variables.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
    int _page = 0;
    late PageController pageController;

    @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

    void navigationtapped(int page){
      pageController.jumpToPage(page);
    }

void onPageChanged(int page){
  setState(() {
    _page = page;
  });
}
   double getIconSize(int index) {
    return _page == index ? 32.0 : 30.0; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: homeScreenItems ,
        physics: NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: onPageChanged,
        ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: mobileBackgroundcolor,
        
        
        items: [ 
          BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.home_rounded, color: _page == 0? primaryColor: secondaryColor, size: getIconSize(0)),
                ),
              label: '',
              backgroundColor: primaryColor),
              BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.search_outlined, color: _page == 1? primaryColor: secondaryColor, size: getIconSize(1)),
              ),
              label: '',
              backgroundColor: primaryColor),
              BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.wallet, color: _page == 2? primaryColor: secondaryColor,size: getIconSize(2)),
              ),
              label: '',
              backgroundColor: primaryColor),
              BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.mail, color: _page == 3? primaryColor: secondaryColor,size: getIconSize(3)),
              ),
              label: '',
              backgroundColor: primaryColor),
              BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.account_circle_sharp, color:_page == 4? primaryColor: secondaryColor,size: getIconSize(4)),
              ),
              label: '',
              backgroundColor: primaryColor),
             
        ],
        onTap: navigationtapped,
      ),
    );
  }
}
