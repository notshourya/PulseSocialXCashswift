import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pulse_social/providers/user_provider.dart';
import 'package:pulse_social/utility/global_variables.dart';

class ResponsiveLayout extends StatefulWidget {
  final Widget webScreenLayout;
  final Widget mobileLayout;
  final Widget tabletLayout;
  const ResponsiveLayout({super.key, required this.webScreenLayout,required this.tabletLayout, required this.mobileLayout});

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {

    @override
  void initState() {
    super.initState();
    addData();
  }

  addData() async {
    UserProvider _userProvider = Provider.of(context, listen: false);
    await _userProvider.refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints){
        if(constraints.maxWidth > webScreenSize){
          return widget.webScreenLayout;
       
        }else{
          return widget.mobileLayout;
        }
      }
    );

}
}