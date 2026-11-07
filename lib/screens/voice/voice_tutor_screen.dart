import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../config/theme.dart';

class VoiceTutorScreen extends StatefulWidget {
  const VoiceTutorScreen({super.key});

  @override
  State<VoiceTutorScreen> createState() => _VoiceTutorScreenState();
}

class _VoiceTutorScreenState extends State<VoiceTutorScreen> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isListening = false;
  bool _isSpeaking = false;
  String _recognizedText = '';
  String _aiResponse = '';
  List<Map<String, String>> _conversation = [];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
  }

  void _initSpeech() async {
    await _speechToText.initialize();
  }

  void _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
  }

  void _startListening() async {
    if (!_speechToText.isAvailable) return;

    setState(() {
      _isListening = true;
    });

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
      },
    );
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
    
    if (_recognizedText.isNotEmpty) {
      _processVoiceInput();
    }
  }

  void _processVoiceInput() {
    // Add user message to conversation
    setState(() {
      _conversation.add({'role': 'user', 'text': _recognizedText});
    });

    // Get AI response (would call Edge Function)
    setState(() {
      _aiResponse = 'AI response for: $_recognizedText';
      _conversation.add({'role': 'ai', 'text': _aiResponse});
    });

    // Speak the response
    _speakResponse(_aiResponse);
  }

  void _speakResponse(String text) async {
    setState(() {
      _isSpeaking = true;
    });

    await _flutterTts.speak(text);

    setState(() {
      _isSpeaking = false;
    });
  }

  void _stopSpeaking() async {
    await _flutterTts.stop();
    setState(() {
      _isSpeaking = false;
    });
  }

  @override
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Tutor'),
        backgroundColor: AppTheme.primaryGreen,
        actions: [
          if (_isSpeaking)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: _stopSpeaking,
              tooltip: 'Stop Speaking',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _conversation.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mic, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text('Tap the microphone to start'),
                        const SizedBox(height: 8),
                        Text('Speak to ask questions', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _conversation.length,
                    itemBuilder: (context, index) {
                      final message = _conversation[index];
                      final isUser = message['role'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isUser ? AppTheme.primaryGreen : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message['text'] ?? '',
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                if (_recognizedText.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _recognizedText,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      heroTag: 'mic',
                      onPressed: _isListening ? _stopListening : _startListening,
                      backgroundColor: _isListening ? Colors.red : AppTheme.primaryGreen,
                      child: Icon(_isListening ? Icons.stop : Icons.mic),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
