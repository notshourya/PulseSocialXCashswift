import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pulse_social/responsive/mobile_screen_layout.dart';
import 'package:pulse_social/screens/feed_screen.dart';
import 'package:pulse_social/utility/colors.dart';
import 'package:pulse_social/utility/global_variables.dart'; // Ensure this path is correct

void main() {
  runApp(ApolloAIApp());
}

class ApolloAIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ApolloAIScreen(),
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
    );
  }
}

class ApolloAIScreen extends StatefulWidget {
  @override
  _ApolloAIScreenState createState() => _ApolloAIScreenState();
}

class _ApolloAIScreenState extends State<ApolloAIScreen> {
  void _simulateAIResponse() async {
    await Future.delayed(Duration(seconds: 1));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Apollo Response", style: TextStyle(fontWeight: FontWeight.bold),),
          content: Text("Working on implementing Chatgpt's API in it."),
          actions: <Widget>[
            ElevatedButton(
              child: Text("Close", style: TextStyle(color: Colors.deepPurple),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundcolor,
        title: Text("Apollo AI", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SpinKitRipple(color: Colors.white, size: 150.0),
            SizedBox(height: 50),
            TypewriterAnimatedTextKit(
              text: ["Hello, I'm Apollo. How can I assist you today?"],
              textStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
              speed: Duration(milliseconds: 50),
            ),
            SizedBox(height: 50),
            TextButton.icon(
              icon: Icon(Icons.question_answer, color: Colors.deepPurple),
              label: Text("Ask Apollo", style: TextStyle(color: Colors.deepPurpleAccent),),
              onPressed: () => _simulateAIResponse(),
              style: ElevatedButton.styleFrom(

              ),
            ),
          ],
        ),
      ),
    );
  }
}
