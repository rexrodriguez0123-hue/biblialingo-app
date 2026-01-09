import 'package:flutter/material.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  bool _answered = false;
  String? _selectedOption;
  bool _isCorrect = false;

  final String _correctAnswer = 'cielos';
  final List<String> _options = ['cielos', 'mares', 'abismos'];

  void _checkAnswer(String option) {
    setState(() {
      _selectedOption = option;
      _answered = true;
      _isCorrect = option == _correctAnswer;
    });

    if (_isCorrect) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Correcto! 🎉'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrecto. Inténtalo de nuevo.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
      // Allow trying again after a delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _answered = false;
            _selectedOption = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Práctica'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LinearProgressIndicator(value: 0.2, minHeight: 10),
            const SizedBox(height: 40),
            const Text(
              'Completa el versículo:',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                'En el principio creó Dios los ______ y la tierra.',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            ..._options.map((option) => Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: ElevatedButton(
                    onPressed: _answered ? null : () => _checkAnswer(option),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      backgroundColor: _answered && option == _selectedOption
                          ? (_isCorrect ? Colors.green.shade100 : Colors.red.shade100)
                          : Colors.white,
                      foregroundColor: _answered && option == _selectedOption
                          ? (_isCorrect ? Colors.green : Colors.red)
                          : Colors.blue,
                      side: BorderSide(
                        color: _answered && option == _selectedOption
                            ? (_isCorrect ? Colors.green : Colors.red)
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      option,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
