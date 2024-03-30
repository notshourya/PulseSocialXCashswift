import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pulse_social/screens/profile_screen.dart';
import 'package:pulse_social/utility/colors.dart';
import 'package:transparent_image/transparent_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;
  String lastSearch = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void performSearch(String query) {
    setState(() {
      lastSearch = query.trim();
      isShowUsers = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundcolor,
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.grey[300]),
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.transparent,
            prefixIcon: Icon(Icons.search, color: Colors.white70),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear, color: Colors.white70),
              onPressed: () => searchController.clear(),
            ),
          ),
          style: TextStyle(color: Colors.white),
            onSubmitted: performSearch,
        ),
      ),
      body: isShowUsers ? buildUserSearchResults() : buildPostsGrid(),
    );
  }

  Widget buildUserSearchResults() {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: lastSearch)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        var docs = (snapshot.data! as dynamic).docs;
        if (docs.isEmpty) {
          return Center(child: Text("No users found.", style: TextStyle(color: Colors.white)));
        }
        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (context, index) => const Divider(color: Color.fromARGB(14, 0, 0, 0)),
          itemBuilder: (context, index) {
            var user = docs[index].data();
            return InkWell(
                onTap: () =>  Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            uid: (snapshot.data! as dynamic).docs[index]['uid'],
                          ),
                        ),
                      ), 
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(user['photoUrl'] ?? 'https://t4.ftcdn.net/jpg/00/64/67/27/360_F_64672736_U5kpdGs9keUll8CRQ3p3YaEv2M6qkVY5.jpg'),
                ),
                title: Text(user['username'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: Text(user['bio'] ?? '', style: TextStyle(color: Colors.grey)),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildPostsGrid() {
    
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('posts').get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return MasonryGridView.count(
          crossAxisCount: 3,
          itemCount: (snapshot.data! as dynamic).docs.length,
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
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
        );
      },
    );
  }
}
