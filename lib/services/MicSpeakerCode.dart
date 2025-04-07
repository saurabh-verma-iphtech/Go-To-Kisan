import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MicSpeakerWidget extends StatefulWidget {
  final Function onListeningStart;
  final Function onListeningStop;

  MicSpeakerWidget({
    required this.onListeningStart,
    required this.onListeningStop,
  });

  @override
  _MicSpeakerWidgetState createState() => _MicSpeakerWidgetState();
}

class _MicSpeakerWidgetState extends State<MicSpeakerWidget> {
  bool _isListening = false;
  String _voiceInput = '';
  stt.SpeechToText _speech = stt.SpeechToText();
  String _localeId = 'en_IN';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    bool available = await _speech.initialize();

    if (available) {
      List<stt.LocaleName> locales = await _speech.locales();
      final systemLocale = await _speech.systemLocale();
      _localeId = systemLocale?.localeId ?? 'en_IN';
      print('🌍 Using locale: $_localeId');
    }
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );

    if (available) {
      setState(() {
        _isListening = true;
      });
      widget
          .onListeningStart(); // Notify the parent widget that listening has started.
      _speech.listen(
        localeId: _localeId,
        onResult: (result) {
          setState(() {
            _voiceInput = result.recognizedWords;
          });
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
    widget
        .onListeningStop(); // Notify the parent widget that listening has stopped.
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 1.0, end: _isListening ? 1.4 : 1.0),
        duration: const Duration(milliseconds: 500),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening ? Colors.redAccent : Colors.transparent,
                boxShadow:
                    _isListening
                        ? [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.6),
                            blurRadius: 10,
                            spreadRadius: 4,
                          ),
                        ]
                        : [],
              ),
              child: IconButton(
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? Colors.white : Colors.black54,
                ),
                onPressed: () {
                  if (_isListening) {
                    _stopListening();
                  } else {
                    _startListening();
                  }
                },
              ),
            ),
          );
        },
      ),
      onPressed: () {
        if (_isListening) {
          _stopListening();
        } else {
          _startListening();
        }
      },
    );
  }
}
