import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pulse_social/screens/addpost_screen.dart';
import 'package:pulse_social/screens/chat_screen.dart';
import 'package:pulse_social/screens/feed_screen.dart';
import 'package:pulse_social/screens/cashswift_screen.dart';
import 'package:pulse_social/screens/profile_screen.dart';
import 'package:pulse_social/screens/search_screen.dart';

const webScreenSize = 1500;
//const tabletScreenSize = 100;
const mobileScreenSize = 1000;

 List<Widget>homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
   WalletHomePage(),
  ChatScreen(),
  ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid,),
];
