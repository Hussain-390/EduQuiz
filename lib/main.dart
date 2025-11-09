import 'package:flutter/material.dart';

void main() => runApp(const SimpleQuizApp());

/* ========= Models ========= */

class Question {
  String text;
  List<String> options; // exactly 4 options for simplicity
  int answerIndex;
  Question({required this.text, required this.options, required this.answerIndex});
}

class Quiz {
  String id;
  String title;
  List<Question> questions;
  Quiz({required this.id, required this.title, required this.questions});
}

class AttemptResult {
  String quizId;
  int score;
  int total;
  List<bool> perQuestionCorrect;
  DateTime when;
  AttemptResult({
    required this.quizId,
    required this.score,
    required this.total,
    required this.perQuestionCorrect,
    required this.when,
  });
}

/* ========= In-memory App State (no packages, no persistence) ========= */

class AppState {
  final List<Quiz> quizzes = [];
  final List<AttemptResult> results = [];

  List<AttemptResult> resultsFor(String quizId) =>
      results.where((r) => r.quizId == quizId).toList();

  double avgPct(String quizId) {
    final rs = resultsFor(quizId);
    if (rs.isEmpty) return 0;
    final sum = rs.fold<double>(0, (a, b) => a + (b.score / b.total));
    return (sum / rs.length) * 100;
  }

  int bestScore(String quizId) {
    final rs = resultsFor(quizId);
    if (rs.isEmpty) return 0;
    return rs.map((r) => r.score).reduce((a, b) => a > b ? a : b);
  }

  List<double> perQuestionAccuracy(String quizId, int questionCount) {
    final rs = resultsFor(quizId);
    if (rs.isEmpty) return List.filled(questionCount, 0);
    final correctCounts = List<int>.filled(questionCount, 0);
    for (final r in rs) {
      for (var i = 0; i < r.perQuestionCorrect.length; i++) {
        if (r.perQuestionCorrect[i]) correctCounts[i]++;
      }
    }
    return correctCounts.map((c) => (c / rs.length) * 100).toList();
  }
}

/* ========= App Shell ========= */

class SimpleQuizApp extends StatefulWidget {
  const SimpleQuizApp({super.key});
  @override
  State<SimpleQuizApp> createState() => _SimpleQuizAppState();
}

class _SimpleQuizAppState extends State<SimpleQuizApp> {
  final AppState state = AppState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Quiz',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: RoleSelector(state: state),
    );
  }
}

/* ========= Role Selector ========= */

class RoleSelector extends StatelessWidget {
  final AppState state;
  const RoleSelector({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Quiz')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Who are you?', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('I\'m a Creator'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreatorHome(state: state)),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('I\'m a Participant'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AttempterHome(state: state)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ========= Creator Side ========= */

class CreatorHome extends StatefulWidget {
  final AppState state;
  const CreatorHome({super.key, required this.state});

  @override
  State<CreatorHome> createState() => _CreatorHomeState();
}

class _CreatorHomeState extends State<CreatorHome> {
  void _addQuiz() async {
    final quiz = await Navigator.push<Quiz>(
      context,
      MaterialPageRoute(
        builder: (_) => QuizEditor(
          quiz: Quiz(id: DateTime.now().millisecondsSinceEpoch.toString(), title: '', questions: []),
        ),
      ),
    );
    if (quiz != null) {
      setState(() => widget.state.quizzes.add(quiz));
    }
  }

  void _editQuiz(Quiz q) async {
    final idx = widget.state.quizzes.indexOf(q);
    final updated = await Navigator.push<Quiz>(
      context,
      MaterialPageRoute(builder: (_) => QuizEditor(quiz: Quiz(id: q.id, title: q.title, questions: q.questions.map((e) => Question(text: e.text, options: List<String>.from(e.options), answerIndex: e.answerIndex)).toList()))),
    );
    if (updated != null) {
      setState(() => widget.state.quizzes[idx] = updated);
    }
  }

  void _deleteQuiz(Quiz q) {
    setState(() {
      widget.state.quizzes.remove(q);
      widget.state.results.removeWhere((r) => r.quizId == q.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizzes = widget.state.quizzes;
    return Scaffold(
      appBar: AppBar(title: const Text('Creator Dashboard')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addQuiz,
        icon: const Icon(Icons.add),
        label: const Text('New Quiz'),
      ),
      body: quizzes.isEmpty
          ? const Center(child: Text('No quizzes yet. Tap "New Quiz".'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: quizzes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final qz = quizzes[i];
                final attempts = widget.state.resultsFor(qz.id).length;
                final avg = widget.state.avgPct(qz.id).toStringAsFixed(0);
                return Card(
                  child: ListTile(
                    title: Text(qz.title.isEmpty ? '(Untitled Quiz)' : qz.title),
                    subtitle: Text('${qz.questions.length} questions • $attempts attempts • Avg $avg%'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'edit') _editQuiz(qz);
                        if (v == 'delete') _deleteQuiz(qz);
                        if (v == 'analytics') {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => AnalyticsPage(state: widget.state, quiz: qz)));
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'analytics', child: Text('Analytics')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class QuizEditor extends StatefulWidget {
  final Quiz quiz;
  const QuizEditor({super.key, required this.quiz});
  @override
  State<QuizEditor> createState() => _QuizEditorState();
}

class _QuizEditorState extends State<QuizEditor> {
  late TextEditingController _title;
  late List<Question> _questions;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.quiz.title);
    _questions = widget.quiz.questions.map((q) => Question(text: q.text, options: List<String>.from(q.options), answerIndex: q.answerIndex)).toList();
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _addOrEditQuestion({Question? existing, int? index}) async {
    final res = await showDialog<Question>(
      context: context,
      builder: (_) => _QuestionDialog(existing: existing),
    );
    if (res != null) {
      setState(() {
        if (index == null) {
          _questions.add(res);
        } else {
          _questions[index] = res;
        }
      });
    }
  }

  void _save() {
    Navigator.pop(
      context,
      Quiz(id: widget.quiz.id, title: _title.text.trim(), questions: _questions),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Editor'),
        actions: [IconButton(onPressed: _questions.isEmpty ? null : _save, icon: const Icon(Icons.save))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Quiz title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _questions.isEmpty
                  ? const Center(child: Text('No questions yet. Add one.'))
                  : ListView.separated(
                      itemCount: _questions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final q = _questions[i];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(child: Text('${i + 1}')),
                            title: Text(q.text),
                            subtitle: Text(List.generate(4, (k) => '${String.fromCharCode(65 + k)}. ${q.options[k]}').join('  •  ')),
                            trailing: Text('Ans: ${String.fromCharCode(65 + q.answerIndex)}'),
                            onTap: () => _addOrEditQuestion(existing: q, index: i),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => _addOrEditQuestion(),
              icon: const Icon(Icons.add),
              label: const Text('Add Question'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionDialog extends StatefulWidget {
  final Question? existing;
  const _QuestionDialog({this.existing});
  @override
  State<_QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<_QuestionDialog> {
  late TextEditingController t;
  late List<TextEditingController> o;
  int ans = 0;

  @override
  void initState() {
    super.initState();
    t = TextEditingController(text: widget.existing?.text ?? '');
    final defaults = widget.existing?.options ?? List.filled(4, '');
    o = List.generate(4, (i) => TextEditingController(text: defaults[i]));
    ans = widget.existing?.answerIndex ?? 0;
  }

  @override
  void dispose() {
    t.dispose();
    for (final c in o) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add Question' : 'Edit Question'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Question'), controller: t),
            const SizedBox(height: 8),
            for (var i = 0; i < 4; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: TextField(
                  controller: o[i],
                  decoration: InputDecoration(labelText: 'Option ${String.fromCharCode(65 + i)}'),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Correct: '),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: ans,
                  items: List.generate(4, (i) => DropdownMenuItem(value: i, child: Text(String.fromCharCode(65 + i)))),
                  onChanged: (v) => setState(() => ans = v ?? 0),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final text = t.text.trim();
            final opts = o.map((e) => e.text.trim()).toList();
            if (text.isEmpty || opts.any((e) => e.isEmpty)) return;
            Navigator.pop(context, Question(text: text, options: opts, answerIndex: ans));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/* ========= Attempter Side ========= */

class AttempterHome extends StatelessWidget {
  final AppState state;
  const AttempterHome({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final quizzes = state.quizzes;
    return Scaffold(
      appBar: AppBar(title: const Text('Available Quizzes')),
      body: quizzes.isEmpty
          ? const Center(child: Text('No quizzes yet. Ask a creator to add one.'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: quizzes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final qz = quizzes[i];
                return Card(
                  child: ListTile(
                    title: Text(qz.title.isEmpty ? '(Untitled Quiz)' : qz.title),
                    subtitle: Text('${qz.questions.length} questions'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TakeQuizPage(state: state, quiz: qz))),
                  ),
                );
              },
            ),
    );
  }
}

class TakeQuizPage extends StatefulWidget {
  final AppState state;
  final Quiz quiz;
  const TakeQuizPage({super.key, required this.state, required this.quiz});

  @override
  State<TakeQuizPage> createState() => _TakeQuizPageState();
}

class _TakeQuizPageState extends State<TakeQuizPage> {
  int idx = 0;
  int? selected;
  int score = 0;
  final List<bool> perCorrect = [];

  void _select(int i) {
    if (selected != null) return;
    setState(() => selected = i);
    final ok = i == widget.quiz.questions[idx].answerIndex;
    perCorrect.add(ok);
    if (ok) score++;
  }

  void _next() {
    if (selected == null) return;
    if (idx < widget.quiz.questions.length - 1) {
      setState(() { idx++; selected = null; });
    } else {
      final res = AttemptResult(
        quizId: widget.quiz.id,
        score: score,
        total: widget.quiz.questions.length,
        perQuestionCorrect: perCorrect,
        when: DateTime.now(),
      );
      widget.state.results.add(res);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ResultPage(score: score, total: widget.quiz.questions.length)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.quiz.questions[idx];
    return Scaffold(
      appBar: AppBar(title: Text('${widget.quiz.title} • Q${idx + 1}/${widget.quiz.questions.length}')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(q.text, style: Theme.of(context).textTheme.titleLarge))),
            const SizedBox(height: 12),
            for (var i = 0; i < 4; i++)
              _OptionTile(
                label: String.fromCharCode(65 + i),
                text: q.options[i],
                state: selected == null
                    ? _OptState.idle
                    : (i == q.answerIndex ? _OptState.correct : (selected == i ? _OptState.wrong : _OptState.dim)),
                onTap: () => _select(i),
              ),
            const Spacer(),
            FilledButton(onPressed: selected == null ? null : _next, child: Text(idx == widget.quiz.questions.length - 1 ? 'Finish' : 'Next')),
          ],
        ),
      ),
    );
  }
}

enum _OptState { idle, correct, wrong, dim }

class _OptionTile extends StatelessWidget {
  final String label;
  final String text;
  final _OptState state;
  final VoidCallback onTap;
  const _OptionTile({required this.label, required this.text, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color border;
    switch (state) {
      case _OptState.correct: border = Colors.green; break;
      case _OptState.wrong: border = Colors.red; break;
      case _OptState.dim: border = Theme.of(context).disabledColor; break;
      default: border = Theme.of(context).dividerColor;
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: state == _OptState.idle ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 2)),
          child: ListTile(leading: CircleAvatar(child: Text(label)), title: Text(text)),
        ),
      ),
    );
  }
}

/* ========= Result & Analytics ========= */

class ResultPage extends StatelessWidget {
  final int score;
  final int total;
  const ResultPage({super.key, required this.score, required this.total});
  @override
  Widget build(BuildContext context) {
    final pct = ((score / total) * 100).toStringAsFixed(0);
    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.emoji_events, size: 96, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text('Score: $score / $total ($pct%)', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), icon: const Icon(Icons.home), label: const Text('Home'))
        ]),
      ),
    );
  }
}

class AnalyticsPage extends StatelessWidget {
  final AppState state;
  final Quiz quiz;
  const AnalyticsPage({super.key, required this.state, required this.quiz});

  @override
  Widget build(BuildContext context) {
    final attempts = state.resultsFor(quiz.id);
    final avg = state.avgPct(quiz.id).toStringAsFixed(0);
    final best = state.bestScore(quiz.id);
    final perQ = state.perQuestionAccuracy(quiz.id, quiz.questions.length);

    return Scaffold(
      appBar: AppBar(title: Text('Analytics • ${quiz.title}')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: attempts.isEmpty
            ? const Center(child: Text('No attempts yet.'))
            : ListView(
                children: [
                  _Stat(title: 'Attempts', value: attempts.length.toString()),
                  _Stat(title: 'Average', value: '$avg%'),
                  _Stat(title: 'Best Score', value: '$best / ${quiz.questions.length}'),
                  const SizedBox(height: 12),
                  Text('Per-question accuracy', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  for (var i = 0; i < quiz.questions.length; i++) ...[
                    Text('Q${i + 1}: ${quiz.questions[i].text}'),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(value: (perQ[i] / 100).clamp(0, 1), minHeight: 10),
                    const SizedBox(height: 4),
                    Text('${perQ[i].toStringAsFixed(0)}% correct'),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 12),
                  Text('Recent attempts', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  for (final r in attempts.reversed.take(10))
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: Text('${((r.score / r.total) * 100).toStringAsFixed(0)}%  •  ${r.score}/${r.total}'),
                      subtitle: Text(r.when.toString()),
                    ),
                ],
              ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String title;
  final String value;
  const _Stat({required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(title: Text(title), trailing: Text(value, style: Theme.of(context).textTheme.titleLarge)));
  }
}
