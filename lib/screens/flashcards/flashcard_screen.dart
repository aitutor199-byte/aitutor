import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/flashcard.dart';
import '../../providers/auth_provider.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> with SingleTickerProviderStateMixin {
  bool _isFlipped = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  List<Flashcard> _flashcards = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _loadFlashcards();
  }

  void _loadFlashcards() {
    // Load flashcards from Supabase
    setState(() {
      _flashcards = [];
    });
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
    if (_isFlipped) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _nextCard() {
    if (_currentIndex < _flashcards.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
      _controller.reset();
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFlipped = false;
      });
      _controller.reset();
    }
  }

  void _markCard(String difficulty) {
    // Update card difficulty and schedule next review
    // This would use spaced repetition algorithm
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Marked as $difficulty')),
    );
    _nextCard();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_flashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Flashcards'),
          backgroundColor: AppTheme.primaryGreen,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.style, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text('No flashcards yet'),
              const SizedBox(height: 8),
              Text('Generate flashcards using AI', style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate with AI'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purple),
              ),
            ],
          ),
        ),
      );
    }

    final card = _flashcards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        backgroundColor: AppTheme.primaryGreen,
        actions: [
          Text('${_currentIndex + 1} / ${_flashcards.length}'),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: _flipCard,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(_animation.value * 3.14159),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 300,
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          _isFlipped ? card.back : card.front,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousCard,
                    child: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _nextCard,
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _markCard('easy'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                    child: const Text('Easy'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _markCard('medium'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.orange),
                    child: const Text('Medium'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _markCard('hard'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Hard'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
