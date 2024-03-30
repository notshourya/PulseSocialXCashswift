import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pulse_social/resources/auth_methods.dart';
import 'package:pulse_social/responsive/tablet_screen_layout_screen.dart';
import 'package:pulse_social/utility/global_variables.dart';
import 'package:pulse_social/responsive/mobile_screen_layout.dart';
import 'package:pulse_social/responsive/responsive_layout_screen.dart';
import 'package:pulse_social/responsive/webscreen_layout.dart';
import 'package:pulse_social/screens/login_screen.dart';
import 'package:pulse_social/utility/utils.dart';
import 'package:pulse_social/widgets/text_field_input.dart';
import 'package:image_picker/image_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;


  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }

  void selectImage() async {
  Uint8List? im = await pickImage(ImageSource.gallery);
  if (im != null) {
    setState(() {
      _image = im;
    });
  }
}

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().signUpUser(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
      bio: _bioController.text,
      file: _image!,
    );

    setState(() {
      _isLoading = false;
    });

    if (res != 'User Created') {
      showSnackbar(res, context);
    } 
    else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>   const ResponsiveLayout(
                  mobileLayout: MobileScreenLayout(),
                  webScreenLayout: WebScreenLayout(),
                  tabletLayout: TabletScreenLayout(),
                ),
        ),
      );
    }
  }

   void navigateToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Container(
         padding: MediaQuery.of(context).size.width > webScreenSize
              ? EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 3)
              : const EdgeInsets.symmetric(horizontal: 32),
        width: double.infinity,
        child: Column(
          
          crossAxisAlignment: CrossAxisAlignment.center,
          
          children: [
            Flexible(child: Container(), flex: 2),
           SvgPicture.asset('assets/Pulse_Social_logo.svg', color: Colors.white,height: 100,), 
            const SizedBox(height: 20),
             

            Stack(
              children: [
                _image != null
                    ? CircleAvatar(
                        radius: 65,
                        backgroundImage: MemoryImage(_image!),
                      )
                    : const CircleAvatar(
                        radius: 65,
                        backgroundImage: NetworkImage(
                            'https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg'),
                      ),
                Positioned(
                  bottom: -11,
                  left: 82,
                  child: IconButton(
                    onPressed: selectImage,
                    icon: const Icon(Icons.add_a_photo),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 65),

            TextFieldInput(
                textEditingController: _usernameController,
                hintText: ' Enter your username',
                textInputType: TextInputType.text),

            const SizedBox(height: 16),

            TextFieldInput(
              textEditingController: _bioController,
              hintText: ' Enter your bio',
              textInputType: TextInputType.text,
            ),

            const SizedBox(height: 40),

            TextFieldInput(
                textEditingController: _emailController,
                hintText: ' Enter your email',
                textInputType: TextInputType.emailAddress),

            const SizedBox(height: 16),

            TextFieldInput(
              textEditingController: _passwordController,
              isPass: true,
              hintText: ' Enter your password',
              textInputType: TextInputType.text,
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: signUpUser,
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(
                    color: Colors.white,
                  ))
                  : const Text(
                      'Sign up',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
            ),

            const SizedBox(height: 26),
            Flexible(child: Container(), flex: 2),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: const Text("Already have an account?"),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                ),
                GestureDetector(
                  onTap: navigateToLogin,
                  child: Container(
                    child: const Text(
                      " Log in.",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ));
  }
}
