class Note {
  String text;
  String date;
  bool done;

  Note({required this.text, required this.date, this.done = false});

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      text: json['text'],
      date: json['date'],
      done: json['done'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'date': date,
      'done': done,
    };
  }
}