import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'quiz_service.dart';
import 'result_screen.dart';
import 'main.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _score = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchQuizData();
    });
  }

  void _fetchQuizData() {
    Provider.of<QuizService>(context, listen: false).fetchQuiz();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _answerQuestion(int selectedIndex) {
    final quizService = Provider.of<QuizService>(context, listen: false);
    if (quizService.quiz != null) {
      setState(() {
        if (selectedIndex == quizService.quiz!.questions[_currentQuestionIndex].correctAnswerIndex) {
          _score++;
        }
        if (_currentQuestionIndex < quizService.quiz!.questions.length - 1) {
          _currentQuestionIndex++;
          _animationController.reset();
          _animationController.forward();
        } else {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => ResultScreen(score: _score, totalQuestions: quizService.quiz!.questions.length),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Quiz'),
        actions: [
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.light ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Consumer<QuizService>(
        builder: (context, quizService, child) {
          if (quizService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (quizService.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(quizService.error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      quizService.resetError();
                      _fetchQuizData();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (quizService.quiz == null) {
            return const Center(child: Text('No quiz data available'));
          } else {
            final currentQuestion = quizService.quiz!.questions[_currentQuestionIndex];
            _animationController.forward();
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1}/${quizService.quiz!.questions.length}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentQuestion.question,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    ...currentQuestion.options.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: Curves.easeInOut.transform(_animationController.value),
                              child: child,
                            );
                          },
                          child: ElevatedButton(
                            onPressed: () => _answerQuestion(entry.key),
                            child: Text(entry.value),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

