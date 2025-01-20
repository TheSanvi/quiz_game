class Question {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswerIndex: json['correctAnswerIndex'],
    );
  }
}

class Quiz {
  final List<Question> questions;

  Quiz({required this.questions});

  factory Quiz.fromJson(Map<String, dynamic> json) {
    var questionsList = json['questions'] as List;
    List<Question> questions = questionsList.map((q) => Question.fromJson(q)).toList();
    return Quiz(questions: questions);
  }
}

