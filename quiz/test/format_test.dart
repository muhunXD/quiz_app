import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/question_parser.dart'; // Import the file containing parseQuestions

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const String formatTestFileName =
      'assets/Working.txt'; // Define the test file name here

  group('Question Format Tests', () {
    test('Text file should not be empty', () async {
      final content = await rootBundle.loadString(formatTestFileName);
      expect(content.trim().isNotEmpty, isTrue,
          reason: 'The text file should not be empty.');
    });

    test('Text file should have questions with exactly 4 choices', () async {
      final content = await rootBundle.loadString(formatTestFileName);
      final questions = parseQuestions(content);

      for (var question in questions) {
        if (question.answers.isNotEmpty) {
          final choicesCount = question.answers.length;
          expect(choicesCount, 4,
              reason:
                  'Each question must have exactly 4 choices. Found $choicesCount for "${question.questionText}".');
        }
      }
    });

    test('Choices should end with "true" or "false"', () async {
      final content = await rootBundle.loadString(formatTestFileName);
      final questions = parseQuestions(content);

      for (var question in questions) {
        if (question.answers.isNotEmpty) {
          for (var answer in question.answers.keys) {
            final parts = answer.split(' ');
            final lastPart = parts.last;
            expect(
              lastPart == 'true' || lastPart == 'false',
              isTrue,
              reason:
                  'Each choice must end with either "true" or "false". Found "$lastPart" in choice "$answer".',
            );
          }
        }
      }
    });

    test('Choices should have "true" or "false" in the correct position',
        () async {
      final content = await rootBundle.loadString(formatTestFileName);
      final questions = parseQuestions(content);

      for (var question in questions) {
        if (question.answers.isNotEmpty) {
          for (var answer in question.answers.keys) {
            final parts = answer.split(' ');
            final lastPart = parts.last;
            final isCorrect = question.answers[answer];
            if (isCorrect != null) {
              expect(
                lastPart == 'true' && isCorrect ||
                    lastPart == 'false' && !isCorrect,
                isTrue,
                reason:
                    'The correctness flag ("true" or "false") should match the actual correctness of the choice. Found "$lastPart" for choice "$answer".',
              );
            }
          }
        }
      }
    });

    test('Should handle missing question identifier', () async {
      final content = await rootBundle.loadString(formatTestFileName);
      final questions = parseQuestions(content);

      expect(
        questions.any((q) => !q.questionText.contains(RegExp(r'\d+\.\s'))),
        isFalse,
        reason: 'Each question must have a question identifier (e.g., "1. ").',
      );
    });

    test('Should handle missing question separator', () async {
      final content = await rootBundle.loadString(formatTestFileName);
      final questions = parseQuestions(content);

      // Test if there are any questions where answers are missing or not separated correctly
      expect(
        questions.any((q) => q.answers.isEmpty),
        isFalse,
        reason: 'Each question must have at least one answer.',
      );
    });

    test('Should handle empty lines and incorrect formatting', () async {
      final content = await rootBundle.loadString(formatTestFileName);
      final lines = content.split('\n');
      final hasEmptyLines = lines.any((line) => line.trim().isEmpty);
      final hasIncorrectFormatting = !lines.every((line) =>
          line.trim().isEmpty ||
          line.contains(RegExp(r'\d+\.\s')) ||
          line.split(' ').length >= 2);

      expect(
        hasEmptyLines || hasIncorrectFormatting,
        isFalse,
        reason:
            'Text file should not contain empty lines or incorrect formatting.',
      );
    });
  });
}
