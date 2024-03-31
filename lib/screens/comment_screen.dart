import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pulse_social/model/user.dart';
import 'package:pulse_social/providers/user_provider.dart';
import 'package:pulse_social/resources/firestore_methods.dart';
import 'package:pulse_social/utility/colors.dart';
import 'package:pulse_social/widgets/comment_card.dart';
import 'package:provider/provider.dart';

class CommentsScreen extends StatefulWidget {
  final Map<String, dynamic> snap;

  const CommentsScreen({super.key, required this.snap});

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _postComment(User user) async {
    setState(() {
      _isPosting = true;
    });
    await FireStoreMethods().postComment(
      widget.snap['postId'],
      _commentController.text.trim(),
      user.uid,
      user.username,
      user.photoUrl,
    );
    setState(() {
      _commentController.text = "";
      _isPosting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundcolor,
        title: Text(
          'Comments',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
      
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.snap['postId'])
                  .collection('comments')
                  .orderBy('datePublished', descending: true)
                  .snapshots(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) => CommentCard(
                    snap: snapshot.data!.docs[index].data(),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: EdgeInsets.only(left: 16, right: 8, bottom: 8, top: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user!.photoUrl),
                    radius: 24,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(25),
                        
                      ),
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Comment as ${user.username}',
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isPosting ? null : () => _postComment(user),
                    child: Text(
                      'Post',
                      style: TextStyle(
                        color: _commentController.text.trim().isEmpty
                            ? Colors.grey
                            : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
