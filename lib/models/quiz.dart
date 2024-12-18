import 'dart:convert';

enum Type {
  multiple,
  boolean,
}

enum Difficulty {
  easy,
  medium,
  hard,
}

class Query {
  final int? responseCode;
  final List<Question>? results;

  Query({
    this.responseCode,
    this.results,
  });

  static Query deserialize(dynamic json) {
    return Query.fromJson(json);
  }

  String toRawJson() => json.encode(toJson());

  factory Query.fromJson(Map<String, dynamic> json) => Query(
        responseCode: json["response_code"],
        results: json["results"] == null
            ? []
            : List<Question>.from(
                json["results"]!.map((x) => Question.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "response_code": responseCode,
        "results": results == null
            ? []
            : List<dynamic>.from(results!.map((x) => x.toJson())),
      };
}

class Question {
  final String? type;
  final String? difficulty;
  final String? category;
  final String? question;
  final String? correctAnswer;
  final List<String>? incorrectAnswers;

  Question({
    this.type,
    this.difficulty,
    this.category,
    this.question,
    this.correctAnswer,
    this.incorrectAnswers,
  });

  static Question deserialize(dynamic json) {
    return Question.fromJson(json);
  }

  String toRawJson() => json.encode(toJson());

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        type: json["type"],
        difficulty: json["difficulty"],
        category: json["category"],
        question: json["question"],
        correctAnswer: json["correct_answer"],
        incorrectAnswers: json["incorrect_answers"] == null
            ? []
            : List<String>.from(json["incorrect_answers"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "difficulty": difficulty,
        "category": category,
        "question": question,
        "correct_answer": correctAnswer,
        "incorrect_answers": incorrectAnswers == null
            ? []
            : List<dynamic>.from(incorrectAnswers!.map((x) => x)),
      };
}
