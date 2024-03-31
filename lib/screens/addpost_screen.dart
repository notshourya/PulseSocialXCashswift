import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulse_social/providers/user_provider.dart';
import 'package:pulse_social/resources/firestore_methods.dart';
import 'package:pulse_social/utility/colors.dart';
import 'package:provider/provider.dart';
import 'package:pulse_social/utility/utils.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();

  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Create a Post', style: TextStyle(color: Colors.white)),
          children: <Widget>[
            SimpleDialogOption(
              child: Row(
                children: [
                  Icon(Icons.photo_camera, color: Colors.white),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Take a photo'),
                  ),
                ],
              ),
              onPressed: () async {
                Navigator.pop(context);
                Uint8List file = await pickImage(ImageSource.camera);
                setState(() {
                  _file = file;
                });
              },
            ),
            SimpleDialogOption(
              child: Row(
                children: [
                  Icon(Icons.image, color: Colors.white),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Choose from Gallery'),
                  ),
                ],
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List file = await pickImage(ImageSource.gallery);
                setState(() {
                  _file = file;
                });
              },
            ),
            SimpleDialogOption(
              child: Row(
                children: [
                  Icon(Icons.cancel, color: Colors.redAccent),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Cancel"),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void postImage(String uid, String username, String profImage) async {
    if (_file == null) return;
    setState(() {
      isLoading = true;
    });
    try {
      String res = await FireStoreMethods().uploadPost(
        _descriptionController.text,
        _file!,
        uid,
        username,
        profImage,
      );
      if (res == "success") {
        setState(() => isLoading = false);
        clearImage();
        showSnackbar("Posted!", context);
      } else {
        setState(() => isLoading = false);
        showSnackbar(res, context);
      }
    } catch (err) {
      setState(() => isLoading = false);
      showSnackbar(err.toString(), context);
    }
  }

  void clearImage() => setState(() => _file = null);

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider?>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: mobileBackgroundcolor,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue,))
          : _file == null ? buildSelectionScreen() : buildPostForm(userProvider),
      floatingActionButton: _file != null ? FloatingActionButton(
        onPressed: () => postImage(
          userProvider?.getUser?.uid ?? '',
          userProvider?.getUser?.username ?? '',
          userProvider?.getUser?.photoUrl ?? '',
        ),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.send),
      ) : null,
    );
  }

  Widget buildSelectionScreen() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.photo_library, color: Colors.blue, size: 120),
        SizedBox(height: 20),
        Text(
          'Create a New Post',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 10),
        Text(
          'Share a photo with your followers',
          style: TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        ElevatedButton.icon(
          icon: Icon(Icons.ios_share, color: Colors.white),
          label: Text('Select Image', style: TextStyle(color: Colors.white)),
          onPressed: () => _selectImage(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          ),
        ),
      ],
    ),
  );

  Widget buildPostForm(UserProvider? userProvider) => SingleChildScrollView(
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(userProvider?.getUser?.photoUrl ?? ''),
                radius: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: "Write a caption...",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  maxLines: 8,
                  keyboardType: TextInputType.multiline,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 8),
              Container(
                height: 100.0,
                width: 100.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                  //  fit: BoxFit.cover,
                    image: MemoryImage(_file!),
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

