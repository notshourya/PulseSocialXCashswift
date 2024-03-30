import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pulse_social/screens/addpost_screen.dart';
import 'package:pulse_social/screens/apollo_ai.dart';
import 'package:pulse_social/utility/colors.dart';
import 'package:pulse_social/widgets/post_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundcolor,
        title: SvgPicture.asset(
          'assets/Pulse_Social_logo.svg',
          color: Colors.white,
          height: 40, // Adjust the size according to your AppBar height
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.auto_awesome_sharp, color: Colors.white70),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ApolloAIApp()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.photo_library, color: Colors.grey[400], size: 60),
                  SizedBox(height: 16),
                  Text(
                    "No posts found",
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              return PostCard(snap: snapshot.data!.docs[index].data());
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddPostScreen()),
          );
        },
        backgroundColor: bluecolor,
        child: Icon(Icons.add, color: Colors.white, size: 25),
      ),
    );
  }
}
