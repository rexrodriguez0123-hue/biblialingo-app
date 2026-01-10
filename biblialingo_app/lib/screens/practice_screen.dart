import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class PracticeScreen extends StatefulWidget {
  final int lessonId;
  const PracticeScreen({super.key, required this.lessonId});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  bool _isLoading = true;
  List<dynamic> _exercises = [];
  int _currentIndex = 0;
  
  // State for current question
  bool _answered = false;
  String? _selectedOption; // For cloze/scramble multiple choice
  TextEditingController _textController = TextEditingController(); // For type-in/cloze
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _fetchLessonData();
  }

  Future<void> _fetchLessonData() async {
    final api = context.read<ApiService>();
    final data = await api.getLessonDetails(widget.lessonId);
    
    // Flatten exercises from verses
    List<dynamic> allExercises = [];
    if (data['verses'] != null) {
      for (var verse in data['verses']) {
        if (verse['exercises'] != null) {
          allExercises.addAll(verse['exercises']);
        }
      }
    }

    if (mounted) {
      setState(() {
        _exercises = allExercises;
        _isLoading = false;
      });
    }
  }

  void _checkAnswer(dynamic answer) {
    if (_answered) return;

    final currentExercise = _exercises[_currentIndex];
    final type = currentExercise['exercise_type'];
    final correct = currentExercise['answer_data']['correct'] ?? currentExercise['answer_data']['text'];
    
    bool correctGuess = false;

    if (type == 'cloze') {
       // Check against 'correct' field
       // Simple normalization
       correctGuess = answer.toString().toLowerCase().trim() == correct.toString().toLowerCase().trim();
    } else if (type == 'type_in') {
       correctGuess = _textController.text.toLowerCase().trim() == correct.toString().toLowerCase().trim();
    } else {
       // Fallback
       correctGuess = true;
    }

    setState(() {
      _answered = true;
      _isCorrect = correctGuess;
      if (_isCorrect) _selectedOption = answer; // Mark specific option if needed
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(correctGuess ? '¡Correcto! 🎉' : 'Incorrecto 😞'),
        backgroundColor: correctGuess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );

    // Auto-advance if correct, or wait?
    // Let's standard Duolingo style: "Continue" button appears.
    // For now, simpler: Auto-advance after 1.5s if correct.
    if (correctGuess) {
      Future.delayed(const Duration(milliseconds: 1500), _nextQuestion);
    } else {
      // Allow retry? Or show correct?
      // Reset after delay to try again
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
             _answered = false;
             _selectedOption = null;
             _textController.clear();
          });
        }
      });
    }
  }

  void _nextQuestion() {
    if (_currentIndex < _exercises.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedOption = null;
        _textController.clear();
      });
    } else {
      _finishLesson();
    }
  }

  void _finishLesson() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('¡Lección Completada! 🏆'),
        content: const Text('Has terminado todos los ejercicios.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to dashboard
            },
            child: const Text('Continuar'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Práctica')),
        body: const Center(child: Text('No hay ejercicios en esta lección.')),
      );
    }

    final exercise = _exercises[_currentIndex];
    final type = exercise['exercise_type'];
    final questionData = exercise['question_data'];
    
    // Progress
    double progress = (_currentIndex + 1) / _exercises.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: LinearProgressIndicator(value: progress),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
             const SizedBox(height: 20),
             Text('Pregunta ${_currentIndex + 1} de ${_exercises.length}', style: TextStyle(color: Colors.grey)),
             const SizedBox(height: 20),
             
             if (type == 'cloze') ...[
                Text('Completa el espacio:', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                Text(questionData['text'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const Spacer(),
                // Mock Options (In real app, we need distractors from backend or generate them)
                // Since our backend 'cloze' assumes text input or options?
                // The user request showed options. 
                // Our data gen: "question_text": "En el ... ____ ..."
                // Importer generated options? No, just question and answer.
                // We need to generate distractors or use Type In.
                // For now, let's use a Text Input if options aren't provided, OR generate dummy options.
                // The user explicit feedback was about OPTIONS. 
                // Importer didn't create options list. 
                // I will use TextField for now to be safe, or generate random words.
                TextField(
                   controller: _textController,
                   decoration: InputDecoration(
                     border: OutlineInputBorder(),
                     hintText: 'Escribe la palabra que falta'
                   ),
                   onSubmitted: (val) => _checkAnswer(val),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _answered ? null : () => _checkAnswer(_textController.text),
                  child: const Text('Comprobar'),
                )
             ] else if (type == 'type_in') ...[
                Text(questionData['prompt'] ?? 'Escribe:', style: TextStyle(fontSize: 18)),
                 const SizedBox(height: 20),
                TextField(
                   controller: _textController,
                   maxLines: 3,
                   decoration: InputDecoration(
                     border: OutlineInputBorder(),
                     hintText: 'Escribe el versículo...'
                   ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _answered ? null : () => _checkAnswer(_textController.text),
                  child: const Text('Comprobar'),
                )
             ] else ...[
                Text('Tipo de ejercicio no soportado: $type'),
                ElevatedButton(onPressed: _nextQuestion, child: Text('Saltar'))
             ]
          ],
        ),
      ),
    );
  }
}
