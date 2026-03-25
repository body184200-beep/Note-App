import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.indigo,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: LockScreen(),
    );
  }
}

/* ================= NAME SCREEN ================= */

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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text("Enter Your Name",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
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

/* ================= NOTES SCREEN ================= */

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List notes = [];
  List filteredNotes = [];
  TextEditingController controller = TextEditingController();
  TextEditingController searchController = TextEditingController();
  int? editingIndex;

  String userName = "";

  @override
  void initState() {
    super.initState();
    loadNotes();
    loadName();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 18) return "Good Afternoon";
    return "Good Evening";
  }

  Future<void> loadName() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString("name") ?? "";
    setState(() {});
  }

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('notes');
    if (data != null) {
      notes = jsonDecode(data);
      filteredNotes = notes;
      setState(() {});
    }
  }

  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes', jsonEncode(notes));
  }

  void addOrEditNote() {
    if (controller.text.isEmpty) return;

    final newNote = {
      "text": controller.text,
      "date": DateFormat('yyyy-MM-dd – HH:mm').format(DateTime.now()),
      "done": false,
    };

    setState(() {
      if (editingIndex == null) {
        notes.add(newNote);
      } else {
        notes[editingIndex!] = newNote;
        editingIndex = null;
      }
      controller.clear();
      filteredNotes = notes;
    });

    saveNotes();
  }

  void deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
      filteredNotes = notes;
    });
    saveNotes();
  }

  void toggleDone(int index) {
    setState(() {
      filteredNotes[index]["done"] =
      !(filteredNotes[index]["done"] ?? false);
    });
    saveNotes();
  }

  void startEdit(int index) {
    controller.text = notes[index]["text"];
    editingIndex = index;
  }

  void searchNote(String value) {
    setState(() {
      filteredNotes = notes
          .where((note) =>
          note["text"].toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text("${getGreeting()} $userName 👋"),
        centerTitle: true,
      ),

      body: Stack(
        children: [
          /// WATERMARK
          Center(
            child: Transform.rotate(
              angle: -0.5,
              child: Opacity(
                opacity: 0.05,
                child: Text(
                  userName.isEmpty ? "NOTES" : userName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          /// UI
          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(12),
                child: TextField(
                  controller: searchController,
                  onChanged: searchNote,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search...",
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Write a note...",
                          hintStyle: TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[900],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: addOrEditNote,
                      child: Icon(Icons.check),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),

              Expanded(
                child: ListView.builder(
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];
                    final isDone = note["done"] ?? false;

                    return Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Card(
                        color: Colors.grey[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: isDone,
                            onChanged: (_) => toggleDone(index),
                            activeColor: Colors.indigo,
                          ),
                          title: Text(
                            note["text"],
                            style: TextStyle(
                              color: isDone
                                  ? Colors.grey
                                  : Colors.white,
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          subtitle: Text(
                            note["date"],
                            style: TextStyle(color: Colors.grey),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit,
                                    color: Colors.indigo),
                                onPressed: () => startEdit(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () => deleteNote(index),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}