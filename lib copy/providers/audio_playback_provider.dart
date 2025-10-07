import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioPlaybackState {
  final bool isPlaying;
  final String? messageId;
  final FlutterTts tts;

  AudioPlaybackState({
    required this.isPlaying,
    required this.messageId,
    required this.tts,
  });

  AudioPlaybackState copyWith({
    bool? isPlaying,
    String? messageId,
    FlutterTts? tts,
  }) {
    return AudioPlaybackState(
      isPlaying: isPlaying ?? this.isPlaying,
      messageId: messageId ?? this.messageId,
      tts: tts ?? this.tts,
    );
  }
}

class AudioPlaybackNotifier extends StateNotifier<AudioPlaybackState> {
  AudioPlaybackNotifier()
      : super(AudioPlaybackState(isPlaying: false, messageId: null, tts: FlutterTts())) {
    _initTts();
  }

  Future<void> _initTts() async {
    final flutterTts = state.tts;
    await flutterTts.setSharedInstance(true);
    await flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
      ],
      IosTextToSpeechAudioMode.defaultMode,
    );
  }

  Future<void> play(String messageId, String text, String locale, Map<String, dynamic>? voice) async {
    if (state.isPlaying) {
      await state.tts.stop();
    }
    await state.tts.setLanguage(locale);
    if (voice != null) {
      // Convert to Map<String, String>
      final voiceStr = voice.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      await state.tts.setVoice(voiceStr);
    }
    await state.tts.setPitch(1.0);
    await state.tts.setSpeechRate(0.4);
    state.tts.setCompletionHandler(() {
      stop();
    });
    state.tts.setCancelHandler(() {
      stop();
    });
    state.tts.setErrorHandler((msg) {
      stop();
    });
    // Set playing state only after TTS actually starts
    state.tts.setStartHandler(() {
      state = state.copyWith(isPlaying: true, messageId: messageId);
    });
    await state.tts.speak(text);
  }

  Future<void> stop() async {
    await state.tts.stop();
    state = state.copyWith(isPlaying: false, messageId: null);
  }
}

final audioPlaybackProvider =
    StateNotifierProvider<AudioPlaybackNotifier, AudioPlaybackState>((ref) {
      return AudioPlaybackNotifier();
    });
