import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ⬇️ If your pubspec `name:` is different, change this import accordingly.
import 'package:simple_quiz_creator_attempt/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Create a quiz, then attempt it and see result',
      (WidgetTester tester) async {
    // Launch app
    await tester.pumpWidget(const SimpleQuizApp());
    await tester.pumpAndSettle();

    // Role selector visible
    expect(find.text('Who are you?'), findsOneWidget);

    // Go to Creator
    await tester.tap(find.widgetWithText(FilledButton, "I'm a Creator"));
    await tester.pumpAndSettle();

    // Creator dashboard
    expect(find.text('Creator Dashboard'), findsOneWidget);
    expect(find.textContaining('No quizzes yet'), findsOneWidget);

    // Tap "New Quiz" (FAB)
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Quiz Editor
    expect(find.text('Quiz Editor'), findsOneWidget);
    expect(find.text('Quiz title'), findsOneWidget);

    // Enter title
    await tester.enterText(find.byType(TextField).first, 'Math Basics');
    await tester.pump();

    // Add Question
    await tester.tap(find.widgetWithText(FilledButton, 'Add Question'));
    await tester.pumpAndSettle();

    // Question dialog
    expect(find.text('Add Question'), findsOneWidget);
    await tester.enterText(
        find.widgetWithText(TextField, 'Question'), '2 + 2 = ?');
    await tester.enterText(find.widgetWithText(TextField, 'Option A'), '3');
    await tester.enterText(find.widgetWithText(TextField, 'Option B'), '4'); // correct
    await tester.enterText(find.widgetWithText(TextField, 'Option C'), '5');
    await tester.enterText(find.widgetWithText(TextField, 'Option D'), '6');

    // Save question
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    // Ensure question appears in editor list
    expect(find.textContaining('2 + 2 = ?'), findsOneWidget);

    // Save quiz (AppBar save icon)
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    // Back on Creator dashboard with new quiz
    expect(find.text('Math Basics'), findsOneWidget);

    // Go back to Role Selector
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Pick Participant
    await tester.tap(find.widgetWithText(FilledButton, "I'm a Participant"));
    await tester.pumpAndSettle();

    // Attempter dashboard: see quiz
    expect(find.text('Available Quizzes'), findsOneWidget);
    expect(find.text('Math Basics'), findsOneWidget);

    // Open the quiz
    await tester.tap(find.text('Math Basics'));
    await tester.pumpAndSettle();

    // Question page
    expect(find.textContaining('Q1/1'), findsOneWidget);
    expect(find.text('2 + 2 = ?'), findsOneWidget);

    // Choose option B (correct)
    // Option tiles are ListTiles inside InkWell; easiest is tap by visible text.
    await tester.tap(find.text('4'));
    await tester.pumpAndSettle();

    // Finish (only one question)
    await tester.tap(find.widgetWithText(FilledButton, 'Finish'));
    await tester.pumpAndSettle();

    // Result page
    expect(find.text('Result'), findsOneWidget);
    expect(find.textContaining('Score:'), findsOneWidget);
    expect(find.textContaining('1 / 1'), findsOneWidget);
  });
}
