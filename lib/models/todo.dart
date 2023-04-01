class Todo {
  Todo({required this.title, required this.dateTime});

  Todo.fromJson(Map<String, dynamic> json) : 
  title = json['nome'], 
  dateTime = DateTime.parse(json['dateTime']);
  
  String title;
  DateTime dateTime;

  Map<String, dynamic> toJson (){
    return {
      'nome': title,
      'dateTime':dateTime.toIso8601String(),
    };
  }
}