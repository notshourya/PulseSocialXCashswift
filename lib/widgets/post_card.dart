import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pulse_social/model/user.dart';
import 'package:pulse_social/providers/user_provider.dart';
import 'package:pulse_social/screens/comment_screen.dart';
import 'package:pulse_social/screens/profile_screen.dart';
import 'package:pulse_social/utility/colors.dart';
import 'package:pulse_social/widgets/like_animation.dart';
import 'package:flutter/material.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> snap;

  const PostCard({super.key, required this.snap});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late List<String> likes = [];
  bool isLikeAnimating = false;
  bool isLiked = false;
  bool isBookmarked = false;
  int commentLen = 0;

  @override
  void initState() {
    super.initState();
    fetchLikes();
    fetchCommentLen();
  }

  void fetchLikes() async {
    try {
      DocumentSnapshot postSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .get();
      setState(() {
        likes = List<String>.from(
            (postSnapshot.data() as Map<String, dynamic>)['likes'] ?? []);
        isLiked = likes.contains(
            Provider.of<UserProvider>(context, listen: false).getUser!.uid);
      });
    } catch (error) {
      print("Error fetching likes: $error");
    }
  }

  void fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      setState(() {
        commentLen = snap.docs.length;
      });
    } catch (error) {
      print("Error fetching comment length: $error");
    }
  }

  void updateLikes(List<String> updatedLikes) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .update({'likes': updatedLikes});
    } catch (error) {
      print("Error updating likes: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser;
    String formattedDate =
        _formatTimestamp(widget.snap['datePublished'].toDate());

    return Container(
      
      margin: const EdgeInsets.fromLTRB(4, 2, 4, 2),
      //elevation: 1,
      //  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: mobileBackgroundcolor,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10)
                  .copyWith(right: 0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileScreen(uid: widget.snap['uid']),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(widget.snap['profImage']),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 4, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProfileScreen(uid: widget.snap['uid']),
                                ),
                              );
            
                            },
                            child: Text(
                              widget.snap['username'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: () {
                      final currentUserID =
                          Provider.of<UserProvider>(context, listen: false)
                              .getUser!
                              .uid;
                      final postOwnerID = widget.snap['uid'];
                      if (currentUserID == postOwnerID) {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shrinkWrap: true,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    Navigator.of(context).pop();

                                    await FirebaseFirestore.instance
                                        .collection('posts')
                                        .doc(widget.snap['postId'])
                                        .delete();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'You cannot delete others posts.',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Color.fromARGB(255, 42, 42, 42),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            GestureDetector(
              onDoubleTap: () async {
                setState(() {
                  isLiked = !isLiked;
                  isLikeAnimating = true;
                });
                if (isLiked) {
                  likes.add(user!.uid);
                } else {
                  likes.remove(user!.uid);
                }
                updateLikes(likes);
                await Future.delayed(Duration(milliseconds: 400));

                setState(() {
                  isLikeAnimating = false;
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white12,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(widget.snap['postUrl'],
                          fit: BoxFit.cover),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: isLiked && !isLikeAnimating
                        ? Duration(milliseconds: 200)
                        : Duration(milliseconds: 500),
                    opacity: isLiked && !isLikeAnimating ? 1.0 : 0.0,
                    child: LikeAnimation(
                      isAnimating: isLikeAnimating,
                      duration: const Duration(
                        milliseconds: 400,
                      ),
                      onEnd: () {
                        setState(() {
                          isLikeAnimating = false;
                        });
                      },
                      child: const Icon(
                        Icons.favorite,
                        color: Color.fromARGB(0, 255, 0, 0),
                        size: 140,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Row(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    LikeAnimation(
                      isAnimating: likes.contains(user?.uid),
                      smallLike: true,
                      child: IconButton(
                        icon: isLiked
                            ? Icon(
                                Icons.favorite,
                                color: Colors.red,
                              )
                            : Icon(
                                Icons.favorite_border,
                              ),
                        onPressed: () async {
                          if (!isLiked) {
                            likes.add(user!.uid);
                            updateLikes(likes);
                          } else {
                            likes.remove(user?.uid);
                            updateLikes(likes);
                          }
                          setState(() {
                            isLiked = !isLiked;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.comment,
                        color: Colors.white70,
                      ),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CommentsScreen(
                            snap: widget.snap,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Colors.white70,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                Spacer(),
                IconButton(
                  icon: isBookmarked
                      ? Icon(
                          Icons.bookmark,
                          color: Colors.white,
                        )
                      : Icon(
                          Icons.bookmark_border,
                          color: isBookmarked ? Colors.white : Colors.white70,
                        ),
                  onPressed: () {
                    setState(() {
                      isBookmarked = !isBookmarked;
                    });
                  },
                ),
              ],
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(fontWeight: FontWeight.w700),
                    child: Text(
                      '${likes.length} likes',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 8),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: primaryColor),
                        children: [
                          TextSpan(
                            text: widget.snap['username'] + ' ',
                            style: const TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: widget.snap['description'],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.only(top: 6),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.white),
                          children: [
                            TextSpan(
                              text: 'View all $commentLen comments',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 6),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.white),
                        children: [
                          TextSpan(
                            text: formattedDate, // Use the formatted date here
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.white12,
                    thickness: 1,
                    height: 20,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    String formattedDate = DateFormat('MMM d, yyyy •h:mm a').format(timestamp);
    return formattedDate;
  }
}
