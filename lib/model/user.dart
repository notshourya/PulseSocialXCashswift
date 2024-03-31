import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final String bio;
  final List followers;
  final List following;
  final double accountBalance; // Added for payments integration
  final String upiId; // Added for payments integration

  const User({
    required this.username,
    required this.uid,
    required this.photoUrl,
    required this.email,
    required this.bio,
    required this.followers,
    required this.following,
    this.accountBalance = 0.0, // Default balance
    required this.upiId,
  });

  static User fromSnap(DocumentSnapshot snap) {
  if (!snap.exists) {
    throw Exception("User does not exist");
  }
  
  var snapshot = snap.data() as Map<String, dynamic>? ?? {}; // Provides an empty map as a fallback

  return User(
    username: snapshot["username"] ?? "", // Provide default values to avoid null
    uid: snapshot["uid"] ?? "",
    email: snapshot["email"] ?? "",
    photoUrl: snapshot["photoUrl"] ?? "",
    bio: snapshot["bio"] ?? "",
    followers: snapshot["followers"] ?? [],
    following: snapshot["following"] ?? [],
    accountBalance: snapshot["accountBalance"]?.toDouble() ?? 0.0, // Safely convert to double
    upiId: snapshot["upiId"] ?? "${snapshot["username"] ?? ""}@cashswift", // Handle null username
  );
}

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "photoUrl": photoUrl,
        "bio": bio,
        "followers": followers,
        "following": following,
        "accountBalance": accountBalance,
        "upiId": upiId,
      };
}
