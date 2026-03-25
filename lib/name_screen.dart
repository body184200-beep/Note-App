import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'note_screen.dart';

class LockScreen extends StatefulWidget {
  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final controller = TextEditingController();

  void saveName() async {
    if (controller.text.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", controller.text);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => NotesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 60),
          CircleAvatar(
            radius: 80,
            backgroundColor: Colors.indigo,
            child: Icon(Icons.person, size: 70, color: Colors.white),
          ),
          SizedBox(height: 30),
          Padding(
            padding: EdgeInsets.all(20),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text("Enter Your Name",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15),
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: "Your name...",
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: saveName,
                      child: Text("START"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}