import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulse_social/resources/auth_methods.dart';
import 'package:pulse_social/resources/firestore_methods.dart';
import 'package:pulse_social/screens/login_screen.dart';
import 'package:pulse_social/utility/colors.dart';
import 'package:pulse_social/utility/utils.dart';
import 'package:pulse_social/widgets/follow_button.dart';
import 'package:transparent_image/transparent_image.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = false;
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    setState(() => isLoading = true);
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();

      setState(() {
        if (userSnap.exists) {
          userData = userSnap.data();
          postLen = postSnap.docs.length;
          followers = userData!['followers']?.length ?? 0;
          following = userData!['following']?.length ?? 0;
          isFollowing = userData!['followers']
                  ?.contains(FirebaseAuth.instance.currentUser!.uid) ??
              false;
        }
      });
    } catch (e) {
      showSnackbar(e.toString(), context);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> handleMenuAction(String value) async {
    switch (value) {
      case "edit_picture":
        final ImagePicker _picker = ImagePicker();
        
        final XFile? image =
            await _picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          
          uploadProfilePicture(image.path);
        }
        break;
      case "sign_out":
        await AuthMethods().signOut();
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()));
        break;
      default:
    }
  }

  Future<void> uploadProfilePicture(String imagePath) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child(firebaseUser.uid + '.jpg');
      await ref.putFile(File(imagePath));
      final newPhotoUrl = await ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .update({
        'photoUrl': newPhotoUrl,
      });
      setState(() {
        getData(); 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = userData ?? {};

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundcolor,
        title: Text("" ?? 'Loading...',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  CircleAvatar(
                    radius: 75,
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(user['photoUrl'] ?? 'https://t4.ftcdn.net/jpg/00/64/67/27/360_F_64672736_U5kpdGs9keUll8CRQ3p3YaEv2M6qkVY5.jpg'),
                  ),
                  SizedBox(height: 20),
                  Text(
                    user['username'] ?? 'Username',
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    user['bio'] ?? 'No bio available.',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildStatColumn(postLen, "posts"),
                      buildStatColumn(followers, "followers"),
                      buildStatColumn(following, "following"),
                    ],
                  ),
                  SizedBox(height: 20),
                  FirebaseAuth.instance.currentUser!.uid == widget.uid
                      ? PopupMenuButton<String>(
                          onSelected: handleMenuAction,
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: "edit_picture",
                              child: Text("Edit Profile Picture"),
                            ),
                            const PopupMenuItem<String>(
                              value: "sign_out",
                              child: Text("Sign Out",
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: mobileBackgroundcolor,
                              border: Border.all(color: Colors.grey.shade800),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              'Edit Profile',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      : FollowButton(
                          text: isFollowing ? 'Unfollow' : 'Follow',
                          backgroundColor:
                              isFollowing ? Colors.white : Colors.blue,
                          textColor: isFollowing ? Colors.black : Colors.white,
                          borderColor: isFollowing ? Colors.grey : Colors.blue,
                          function: () async {
                            if (isFollowing) {
                              await FireStoreMethods().followUser(
                                FirebaseAuth.instance.currentUser!.uid,
                                userData?['uid'],
                              );
                              setState(() {
                                isFollowing = false;
                                followers--;
                              });
                            } else {
                              await FireStoreMethods().followUser(
                                FirebaseAuth.instance.currentUser!.uid,
                                userData?['uid'],
                              );
                              setState(() {
                                isFollowing = true;
                                followers++;
                              });
                            }
                          },
                        ),
                  SizedBox(height: 20),
                  FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('posts')
                        .where('uid', isEqualTo: widget.uid)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: (snapshot.data! as dynamic).docs.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 2,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, index) {
                          var doc = (snapshot.data! as dynamic).docs[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(1.0),
                            child: FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image: doc['postUrl'],
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w400, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
