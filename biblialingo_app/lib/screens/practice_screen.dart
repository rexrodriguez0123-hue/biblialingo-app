import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../main.dart';

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
  dynamic _selectedOption; // String for cloze/selection, List<String> for scramble
  TextEditingController _textController = TextEditingController(); // For type-in/cloze
  bool _isCorrect = false;

  // Tracking for stats
  int _correctCount = 0;
  int _totalAttempted = 0;

  @override
  void initState() {
    super.initState();
    _fetchLessonData();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
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

    // Limit to 10 exercises per session for playability
    if (allExercises.length > 10) {
      allExercises.shuffle();
      allExercises = allExercises.sublist(0, 10);
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
    final answerData = currentExercise['answer_data'];
    
    bool correctGuess = false;

    switch (type) {
      case 'cloze':
        final correct = answerData['correct'] ?? '';
        correctGuess = answer.toString().toLowerCase().trim() == correct.toString().toLowerCase().trim();
        break;

      case 'selection':
        final correct = answerData['correct'] ?? '';
        correctGuess = answer.toString() == correct.toString();
        break;

      case 'type_in':
        final correct = answerData['correct'] ?? '';
        final acceptList = answerData['accept'] as List? ?? [];
        final userAnswer = (answer ?? _textController.text).toString().trim().toLowerCase();
        correctGuess = userAnswer == correct.toString().toLowerCase().trim()
            || acceptList.any((a) => a.toString().toLowerCase().trim() == userAnswer);
        break;

      case 'scramble':
        final correctOrder = List<String>.from(answerData['correct_order'] ?? []);
        final userList = answer is List ? List<String>.from(answer) : <String>[];
        correctGuess = userList.join(' ') == correctOrder.join(' ');
        break;

      case 'true_false':
        final correct = answerData['correct'];
        if (correct is bool) {
          correctGuess = answer == correct;
        } else {
          correctGuess = answer.toString() == correct.toString();
        }
        break;

      default:
        correctGuess = false;
    }

    _totalAttempted++;
    if (correctGuess) _correctCount++;

    setState(() {
      _answered = true;
      _isCorrect = correctGuess;
      _selectedOption = answer;
    });

    // Submit answer to backend
    _submitToBackend(currentExercise, correctGuess);

    // Show snackbar feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(correctGuess ? '¡Correcto! 🎉' : 'Incorrecto 😞. La respuesta era: ${answerData['correct']}'),
        backgroundColor: correctGuess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitToBackend(Map<String, dynamic> exercise, bool isCorrect) async {
    try {
      final api = context.read<ApiService>();
      final exerciseId = exercise['id'];
      if (exerciseId == null) return; // Offline fallback exercise

      final result = await api.submitAnswer(
        exerciseId: exerciseId,
        isCorrect: isCorrect,
      );

      // Update user stats
      if (mounted) {
        final userState = context.read<UserState>();
        userState.updateStats(
          hearts: result['hearts'],
          gems: result['gems'],
          streak: result['streak_days'],
          totalXp: result['total_xp'],
        );
      }
    } catch (e) {
      // Silently fail — offline mode or auth issue
      debugPrint('Failed to submit answer: $e');
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
    final percentage = _totalAttempted > 0
        ? (_correctCount / _totalAttempted * 100).round()
        : 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('¡Lección Completada! 🏆'),
        content: Text(
          '$_correctCount/$_totalAttempted respuestas correctas ($percentage%)\n\n'
          '${percentage >= 80 ? "¡Excelente trabajo!" : percentage >= 50 ? "¡Buen intento!" : "¡Sigue practicando!"}',
        ),
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
        title: LinearProgressIndicator(value: progress, minHeight: 10, borderRadius: BorderRadius.circular(5)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             const SizedBox(height: 20),
             Text(
               'Pregunta ${_currentIndex + 1} de ${_exercises.length}', 
               style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
               textAlign: TextAlign.center,
             ),
             const SizedBox(height: 10),
             _buildExerciseTypeLabel(type),
             const SizedBox(height: 20),
             
             // --- EXERCISE CONTENT ---
             Expanded(child: SingleChildScrollView(child: _buildExerciseContent(type, questionData, exercise))),
             
             const SizedBox(height: 10),

             // Check Button (for type_in and scramble)
             if (!_answered && (type == 'type_in' || type == 'scramble'))
               ElevatedButton(
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.green,
                   padding: const EdgeInsets.symmetric(vertical: 15)
                 ),
                 onPressed: () => _checkAnswer(type == 'type_in' ? _textController.text : _selectedOption),
                 child: const Text('Comprobar', style: TextStyle(fontSize: 18, color: Colors.white)),
               ),
               
             // Continue Button (after answering)
             if (_answered)
               ElevatedButton(
                 style: ElevatedButton.styleFrom(
                   backgroundColor: _isCorrect ? Colors.green : Colors.blue,
                   padding: const EdgeInsets.symmetric(vertical: 15),
                 ),
                 onPressed: _nextQuestion,
                 child: Text(
                   _currentIndex < _exercises.length - 1 ? 'Continuar' : 'Finalizar',
                   style: const TextStyle(fontSize: 18, color: Colors.white),
                 ),
               ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseTypeLabel(String type) {
    String label;
    IconData icon;
    switch (type) {
      case 'cloze':
        label = 'Completa el versículo';
        icon = Icons.edit_note;
        break;
      case 'selection':
        label = 'Selecciona la palabra correcta';
        icon = Icons.touch_app;
        break;
      case 'scramble':
        label = 'Ordena las palabras';
        icon = Icons.shuffle;
        break;
      case 'type_in':
        label = 'Escribe la palabra que falta';
        icon = Icons.keyboard;
        break;
      case 'true_false':
        label = '¿Verdadero o falso?';
        icon = Icons.check_circle_outline;
        break;
      default:
        label = 'Ejercicio';
        icon = Icons.quiz;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue)),
      ],
    );
  }

  Widget _buildExerciseContent(String type, Map<String, dynamic> questionData, Map<String, dynamic> exercise) {
    switch (type) {
      case 'cloze':
      case 'selection':
        return _buildSelectionExercise(questionData, exercise);
      case 'scramble':
        return _buildScrambleExercise(questionData, exercise);
      case 'type_in':
        return _buildTypeInExercise(questionData, exercise);
      case 'true_false':
        return _buildTrueFalseExercise(questionData, exercise);
      default:
        return const Text('Tipo de ejercicio no soportado.');
    }
  }

  Widget _buildSelectionExercise(Map<String, dynamic> questionData, Map<String, dynamic> exercise) {
    final text = questionData['text'] ?? '';
    final options = questionData['options'] as List? ?? [];
    final correct = exercise['answer_data']['correct'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        if (questionData['hint'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Pista: empieza con "${questionData['hint']}"', style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic), textAlign: TextAlign.center),
          ),
        const SizedBox(height: 30),
        ...options.map((option) {
          Color btnColor;
          if (_answered) {
            if (option == correct) {
              btnColor = Colors.green;
            } else if (_selectedOption == option) {
              btnColor = Colors.red;
            } else {
              btnColor = Colors.grey;
            }
          } else {
            btnColor = _selectedOption == option ? Colors.blue.shade900 : Colors.blue;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: btnColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: _answered ? null : () => _checkAnswer(option),
              child: Text(option.toString(), style: const TextStyle(fontSize: 16, color: Colors.white)),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildScrambleExercise(Map<String, dynamic> questionData, Map<String, dynamic> exercise) {
    final words = List<String>.from(questionData['words'] ?? []);
    final selected = _selectedOption as List<String>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Target area — selected words
        Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(minHeight: 80),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(12),
            color: Colors.blue.shade50,
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selected.asMap().entries.map((entry) {
              return Chip(
                label: Text(entry.value),
                onDeleted: _answered ? null : () {
                  setState(() {
                    final list = List<String>.from(selected);
                    list.removeAt(entry.key);
                    _selectedOption = list;
                  });
                },
              );
            }).toList(),
          ),
        ),
        const Divider(height: 30),
        // Source area — available words
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: words.asMap().entries.map((entry) {
            // Count how many times this word appears in selected at this index
            final usedCount = selected.where((w) => w == entry.value).length;
            final availableCount = words.where((w) => w == entry.value).length;
            final isUsedUp = usedCount >= availableCount;
            
            return ActionChip(
              label: Text(entry.value),
              backgroundColor: isUsedUp ? Colors.grey.shade300 : null,
              onPressed: _answered || isUsedUp ? null : () {
                setState(() {
                  final list = List<String>.from(selected);
                  list.add(entry.value);
                  _selectedOption = list;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTypeInExercise(Map<String, dynamic> questionData, Map<String, dynamic> exercise) {
    final context = questionData['context'] ?? '';
    final wordLength = questionData['word_length'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(context, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        if (wordLength > 0)
          Text('($wordLength letras)', style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        TextField(
           controller: _textController,
           enabled: !_answered,
           textAlign: TextAlign.center,
           style: const TextStyle(fontSize: 20),
           decoration: InputDecoration(
             border: const OutlineInputBorder(),
             hintText: 'Escribe la palabra...',
             suffixIcon: _answered
                 ? Icon(_isCorrect ? Icons.check_circle : Icons.cancel, color: _isCorrect ? Colors.green : Colors.red)
                 : null,
           ),
           onSubmitted: _answered ? null : (value) => _checkAnswer(value),
        ),
      ],
    );
  }

  Widget _buildTrueFalseExercise(Map<String, dynamic> questionData, Map<String, dynamic> exercise) {
    final statement = questionData['statement'] ?? '';
    final instruction = questionData['instruction'] ?? '¿Es correcta esta afirmación?';
    final correct = exercise['answer_data']['correct'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(instruction, style: TextStyle(fontSize: 14, color: Colors.grey[600]), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(statement, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('Verdadero', style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _answered
                      ? (correct == true ? Colors.green : (_selectedOption == true ? Colors.red : Colors.grey))
                      : Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _answered ? null : () => _checkAnswer(true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.close, color: Colors.white),
                label: const Text('Falso', style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _answered
                      ? (correct == false ? Colors.green : (_selectedOption == false ? Colors.red : Colors.grey))
                      : Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _answered ? null : () => _checkAnswer(false),
              ),
            ),
          ],
        ),
        if (_answered && exercise['answer_data']['explanation'] != null) ...[
          const SizedBox(height: 16),
          Text(
            exercise['answer_data']['explanation'],
            style: TextStyle(color: _isCorrect ? Colors.green.shade700 : Colors.red.shade700, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
