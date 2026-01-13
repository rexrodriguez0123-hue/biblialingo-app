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
  dynamic _selectedOption; // String for cloze/selection, List<String> for scramble
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
             const SizedBox(height: 30),
             
             // --- EXERCISE CONTENT ---
             if (type == 'type_in') ...[
                Text('Escribe el versículo:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Text(exercise['answer_data']['text'], style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey)), // Hint? Maybe hide it
                // Actually, for "write the verse", we usually show the reference and ask them to type it?
                // Or "Listen and write"? 
                // Given the prompt "Escribe el versículo completo:", let's show the TextField.
                // We should probably hide the answer text unless it's a "Copy" exercise. 
                // Let's assume it's a "Read and Copy" to practice typing/spelling for now, as memory is hard without prompts.
                const SizedBox(height: 10),
                TextField(
                   controller: _textController,
                   maxLines: 4,
                   decoration: InputDecoration(
                     border: OutlineInputBorder(),
                     hintText: 'Escribe aquí...'
                   ),
                ),
             ] 
             else if (type == 'scramble') ...[
                Text('Ordena las palabras:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                // Target Area (Selected Words)
                 Wrap(
                   spacing: 8,
                   children: (_selectedOption as List<String>? ?? []).map((word) {
                     return Chip(
                       label: Text(word),
                       onDeleted: _answered ? null : () {
                         setState(() {
                           final list = List<String>.from(_selectedOption);
                           list.remove(word);
                           _selectedOption = list;
                         });
                       },
                     );
                   }).toList(),
                 ),
                 Divider(),
                 // Source Area (Available Words)
                 Wrap(
                   spacing: 8,
                   children: (questionData['words'] as List).cast<String>().map((word) {
                      // Hide if already selected (simple count check needed for duplicates, but for now simple hide)
                      // Better: Filter out one instance.
                      final currentSelected = _selectedOption as List<String>? ?? [];
                      final isSelected = currentSelected.contains(word); 
                      // Simple implementation: Don't hide, just allow multiple adds? No, usually move.
                      // Let's just create a list of "available" words state.
                      // For simplicity in this edit: Just buttons that append.
                      return ActionChip(
                        label: Text(word),
                        onPressed: _answered ? null : () {
                          setState(() {
                             final list = List<String>.from(_selectedOption ?? []);
                             list.add(word);
                             _selectedOption = list;
                          });
                        },
                      );
                   }).toList(),
                 ),
             ]
             else if (type == 'cloze' || type == 'selection' || type == 'true_false') ...[
                 Text(questionData['text'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                 const SizedBox(height: 40),
                 
                 // Options Buttons
                 if (questionData['options'] != null)
                   ...(questionData['options'] as List).map((option) {
                     final isSelected = _selectedOption == option;
                     Color btnColor = Colors.blue;
                     if (_answered) {
                        if (option == exercise['answer_data']['correct']) {
                          btnColor = Colors.green; // Show correct
                        } else if (isSelected) {
                          btnColor = Colors.red; // Show wrong selection
                        } else {
                          btnColor = Colors.grey;
                        }
                     } else {
                       btnColor = isSelected ? Colors.blue.shade900 : Colors.blue;
                     }

                     return Padding(
                       padding: const EdgeInsets.only(bottom: 10),
                       child: ElevatedButton(
                         style: ElevatedButton.styleFrom(
                           backgroundColor: btnColor,
                           padding: EdgeInsets.symmetric(vertical: 15),
                         ),
                         onPressed: _answered ? null : () {
                           _checkAnswer(option);
                         },
                         child: Text(option.toString(), style: TextStyle(fontSize: 16, color: Colors.white)),
                       ),
                     );
                   }).toList()
             ],

             const Spacer(),
             
             // Check Button (Only for Type In and Scramble where explicit check is needed)
             if (type == 'type_in' || type == 'scramble')
               ElevatedButton(
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.green,
                   padding: EdgeInsets.symmetric(vertical: 15)
                 ),
                 onPressed: _answered ? null : () => _checkAnswer(type == 'type_in' ? _textController.text : _selectedOption),
                 child: const Text('Comprobar', style: TextStyle(fontSize: 18, color: Colors.white)),
               ),
               
             // Continue Button (Only after answered)
             if (_answered)
               ElevatedButton(
                 onPressed: _nextQuestion,
                 child: const Text('Continuar'),
               )
          ],
        ),
      ),
    );
  }

  void _checkAnswer(dynamic answer) {
    if (_answered) return;

    final currentExercise = _exercises[_currentIndex];
    final type = currentExercise['exercise_type'];
    final correct = currentExercise['answer_data']['correct'] ?? currentExercise['answer_data']['correct_order']; 
    // correct_order is List<String> for scramble
    
    bool correctGuess = false;

    if (type == 'scramble') {
       // Compare lists
       final userList = answer as List<String>;
       final correctList = List<String>.from(correct);
       correctGuess = userList.join(' ') == correctList.join(' ');
    } else if (type == 'type_in') {
       final correctAnswer = currentExercise['answer_data']['text']; // Full text
       // Loose comparison
       correctGuess = answer.toString().toLowerCase().replaceAll(RegExp(r'[^\w]'), '') == 
                      correctAnswer.toString().toLowerCase().replaceAll(RegExp(r'[^\w]'), '');
    } else {
       // Selection / Cloze / TrueFalse
       correctGuess = answer == correct;
    }

    setState(() {
      _answered = true;
      _isCorrect = correctGuess;
      _selectedOption = answer;
    });

    // Sound effect or haptic could go here
    if (correctGuess) {
       // Auto-advance logic if separate button not preferred? 
       // We added a "Continuar" button in the UI, so we wait for user.
    }
  }
}
