import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QuizPage(),
    );
  }
}

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final List<Question> _questions = [
    Question(
        questionText:
            'การรวมเลขของระบบ 2’s complement 2 + 7 ควรได้เลขฐานสอง จำนวน 5 บิตเป็นเท่าไร',
        answers: {
          'ก. 00110': false,
          'ข. 01001': false,
          'ค. 10000': true,
          'ง. 00111': false,
        }),
    Question(
        questionText: 'Canonical sum ของ AB + AbarB ควรอ่านว่าอย่างไร',
        answers: {
          'ก. A and B or A bar and B': true,
          'ข. A or B and A bar or B': false,
          'ค. A and B or A and B': false,
          'ง. ถูกทุกข้อ': false,
        }),
    Question(
        questionText:
            'จากเลขฐานสอง 101011 เมื่อแปลงเป็นเลขฐานสิบแล้ว ค่าที่ได้ตรงกับข้อใด',
        answers: {
          'ก. 30₁₀': false,
          'ข. 43₁₀': false,
          'ค. 45₁₀': true,
          'ง. 47₁₀': false,
        }),
    Question(
        questionText:
            'Maurice Karnaugh คือผู้คิดหลักการลดรูปสมการบูลีนด้วยวิธีอะไร',
        answers: {
          'ก. Karnaugh Map': true,
          'ข. Karna Map': false,
          'ค. Karnung Map': false,
          'ง. Kaning Map': false,
        }),
    Question(
        questionText:
            'จงแปลงกลับ 10’s compliment ของเลขฐานสองดังต่อไปนี้ -01110 (-14)',
        answers: {
          'ก. 951': false,
          'ข. 231': false,
          'ค. 064': true,
          'ง. 085': false,
        }),
    Question(
        questionText:
            'จงแปลงกลับ 2 compliment ของเลขฐาน10ดังต่อไปนี้ 16(10000)',
        answers: {
          'ก. 00010': false,
          'ข. 00001': true,
          'ค. 101111': false,
          'ง. 10001': false,
        }),
  ];

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

    if (_currentQuestionIndex >= _questions.length) {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Quiz Completed!'),
        content: Text('Your score is $_score out of ${_questions.length}'),
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
        backgroundColor: Colors.green, // Change this to any color you like
      ),
      body: _currentQuestionIndex < _questions.length
          ? Quiz(
              question: _questions[_currentQuestionIndex],
              answerQuestion: _answerQuestion,
            )
          : Center(
              child: Text('You did it! Your score is $_score'),
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
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.questionText,
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.left,
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
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
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
