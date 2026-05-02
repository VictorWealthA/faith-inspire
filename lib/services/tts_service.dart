import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  Future<void>? _initFuture;
  bool _hasStartedSpeaking = false;
  bool _stopRequested = false;
  Completer<void>? _startCompleter;
  Completer<void>? _speechCompleter;

  TtsService() {
    _initFuture = _initialize();
  }

  Future<void> _initialize() async {
    _tts.setStartHandler(() {
      _hasStartedSpeaking = true;
      _stopRequested = false;
      _completeStart();
    });

    _tts.setCompletionHandler(() {
      _completePendingSpeech();
    });

    _tts.setCancelHandler(() {
      if (_stopRequested) {
        _completePendingSpeech();
      } else {
        _completePendingSpeech(
          error: Exception('Speech playback was cancelled.'),
        );
      }
    });

    _tts.setErrorHandler((message) {
      final details = message?.toString();
      _completePendingSpeech(
        error: Exception(
          details == null || details.isEmpty
              ? 'Text-to-speech failed to start.'
              : details,
        ),
      );
    });

    try {
      await _tts.awaitSpeakCompletion(false);
      await _configurePlatformAudio();
      await _configureLanguage();
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
    } catch (_) {
      // Best-effort initialization; speak/stop calls still handle runtime issues.
    }
  }

  Future<void> _configurePlatformAudio() async {
    if (kIsWeb) {
      return;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        await _tts.setAudioAttributesForNavigation();
        break;
      case TargetPlatform.iOS:
        await _tts.setSharedInstance(true);
        await _tts.autoStopSharedSession(true);
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          const [
            IosTextToSpeechAudioCategoryOptions.duckOthers,
            IosTextToSpeechAudioCategoryOptions
                .interruptSpokenAudioAndMixWithOthers,
          ],
          IosTextToSpeechAudioMode.voicePrompt,
        );
        break;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        break;
    }
  }

  Future<void> _configureLanguage() async {
    for (final language in const ['en-US', 'en-GB']) {
      try {
        final isAvailable = await _tts.isLanguageAvailable(language);
        if (isAvailable == true) {
          await _tts.setLanguage(language);
          return;
        }
      } catch (_) {
        // Keep current platform default when explicit language selection fails.
      }
    }
  }

  Future<void> _ensureInitialized() async {
    _initFuture ??= _initialize();
    await _initFuture;

    // Warm up engine binding on Android by touching voices.
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        await _tts.getVoices;
        return;
      } catch (_) {
        if (attempt == 0) {
          await Future<void>.delayed(const Duration(milliseconds: 250));
        }
      }
    }
  }

  Future<void> speak(String text) async {
    await _ensureInitialized();

    final hasPendingSpeech =
        _speechCompleter != null && !_speechCompleter!.isCompleted;
    if (hasPendingSpeech || _hasStartedSpeaking) {
      await stop();
    }

    _stopRequested = false;
    _hasStartedSpeaking = false;
    final startCompleter = Completer<void>();
    final speechCompleter = Completer<void>();
    _startCompleter = startCompleter;
    _speechCompleter = speechCompleter;

    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final result = await _tts.speak(
          text,
          focus: !kIsWeb && defaultTargetPlatform == TargetPlatform.android,
        );
        if (result == 1) {
          await startCompleter.future.timeout(
            const Duration(seconds: 3),
            onTimeout: () => throw Exception(
              'Text-to-speech did not start. Check the device volume, silent mode, and installed TTS voices.',
            ),
          );
          await speechCompleter.future;
          return;
        }
      } catch (error) {
        if (attempt == 1) {
          _stopRequested = true;
          try {
            await _tts.stop();
          } catch (_) {
            // Ignore shutdown errors while surfacing the original failure.
          }
          _completePendingSpeech(error: error);
          rethrow;
        }

        // Retry once after a short delay in case engine bind is still finishing.
      }

      if (attempt == 0) {
        await Future<void>.delayed(const Duration(milliseconds: 350));
      }
    }

    throw Exception('Unable to start text-to-speech engine.');
  }

  Future<void> stop() async {
    final hasPendingSpeech =
        _speechCompleter != null && !_speechCompleter!.isCompleted;
    if (!_hasStartedSpeaking && !hasPendingSpeech) {
      return;
    }

    await _ensureInitialized();
    _stopRequested = true;
    try {
      await _tts.stop();
    } finally {
      _completePendingSpeech();
    }
  }

  Future<void> pause() async {
    if (!_hasStartedSpeaking) {
      return;
    }

    await _ensureInitialized();
    await _tts.pause();
  }

  void _completeStart() {
    final startCompleter = _startCompleter;
    if (startCompleter != null && !startCompleter.isCompleted) {
      startCompleter.complete();
    }
  }

  void _completePendingSpeech({Object? error}) {
    _hasStartedSpeaking = false;

    final startCompleter = _startCompleter;
    final speechCompleter = _speechCompleter;

    _startCompleter = null;
    _speechCompleter = null;
    _stopRequested = false;

    if (error != null) {
      if (startCompleter != null && !startCompleter.isCompleted) {
        startCompleter.completeError(error);
      }
      if (speechCompleter != null && !speechCompleter.isCompleted) {
        speechCompleter.completeError(error);
      }
      return;
    }

    if (startCompleter != null && !startCompleter.isCompleted) {
      startCompleter.complete();
    }
    if (speechCompleter != null && !speechCompleter.isCompleted) {
      speechCompleter.complete();
    }
  }
}
