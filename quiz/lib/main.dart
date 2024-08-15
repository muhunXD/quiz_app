import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: FutureBuilder(
        future: loadQuestions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(child: Text('Error loading questions')),
              );
            } else {
              final questions = snapshot.data as List<Question>;
              return QuizPage(questions: questions);
            }
          } else {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }

  Future<List<Question>> loadQuestions() async {
    final String content = await rootBundle.loadString('assets/Question.txt');

    // Print the content of the file to the terminal
    print('File content:\n$content');

    final List<Question> questions = parseQuestions(content);
    return questions;
  }

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

      // Reading question
      if (lines[lineIndex].contains(RegExp(r'\d+\.\s'))) {
        if (questionText.isNotEmpty && answers.isNotEmpty) {
          questions.add(
              Question(questionText: questionText, answers: Map.from(answers)));
          answers.clear();
        }
        questionText = lines[lineIndex].trim();
        lineIndex++;
      }

      // Reading answers
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
      questions.add(
          Question(questionText: questionText, answers: Map.from(answers)));
    }

    return questions;
  }
}

class QuizPage extends StatefulWidget {
  final List<Question> questions;

  QuizPage({required this.questions});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestionIndex = 0;
  int _score = 0;

  void _answerQuestion(bool isCorrect) {
    if (isCorrect) {
      setState(() {
        _score++;
      });
    }

    setState(() {
      _currentQuestionIndex++;
    });

    if (_currentQuestionIndex >= widget.questions.length) {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Quiz Completed!'),
        content:
            Text('Your score is $_score out of ${widget.questions.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetQuiz();
            },
            child: Text('Restart Quiz'),
          ),
        ],
      ),
    );
  }

  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
        backgroundColor: Colors.green,
      ),
      body: _currentQuestionIndex < widget.questions.length
          ? Quiz(
              question: widget.questions[_currentQuestionIndex],
              answerQuestion: _answerQuestion,
            )
          : Center(
              child: Text('คุณได้ $_score คะแนน'),
            ),
    );
  }
}

class Quiz extends StatelessWidget {
  final Question question;
  final Function(bool) answerQuestion;

  Quiz({required this.question, required this.answerQuestion});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.questionText,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ...question.answers.keys.map((answer) {
              return Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 10),
                child: ElevatedButton(
                  onPressed: () => answerQuestion(question.answers[answer]!),
                  child: Text(answer),
                  style: ElevatedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class Question {
  final String questionText;
  final Map<String, bool> answers;

  Question({required this.questionText, required this.answers});
}
