// question_parser.dart
import 'package:flutter/material.dart';

List<Question> parseQuestions(String content) {
  final List<Question> questions = [];
  final lines = content.split('\n');
  Map<String, bool> answers = {};
  String questionText = '';
  int lineIndex = 0;

  while (lineIndex < lines.length) {
    if (lines[lineIndex].trim().isEmpty) {
      lineIndex++;
      continue;
    }

    if (lines[lineIndex].contains(RegExp(r'\d+\.\s'))) {
      if (questionText.isNotEmpty && answers.isNotEmpty) {
        questions.add(
            Question(questionText: questionText, answers: Map.from(answers)));
        answers.clear();
      }
      questionText = lines[lineIndex].trim();
      lineIndex++;
    }

    while (lineIndex < lines.length &&
        !lines[lineIndex].contains(RegExp(r'\d+\.\s'))) {
      final parts = lines[lineIndex].split(' ');
      if (parts.length >= 2) {
        final answerText = parts.sublist(0, parts.length - 1).join(' ');
        final isCorrect = parts.last == 'true';
        answers[answerText] = isCorrect;
      }
      lineIndex++;
    }
  }

  if (questionText.isNotEmpty && answers.isNotEmpty) {
    questions
        .add(Question(questionText: questionText, answers: Map.from(answers)));
  }

  return questions;
}

class Question {
  final String questionText;
  final Map<String, bool> answers;

  Question({required this.questionText, required this.answers});
}
