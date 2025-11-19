import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/track.dart';
import '../services/audio_service.dart';

class PlayerProvider with ChangeNotifier {
  final AudioPlayerService _audioService = AudioPlayerService();

  Track? _currentTrack;
  List<Track> _queue = [];
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  LoopMode _loopMode = LoopMode.off;
  bool _shuffleMode = false;

  PlayerProvider() {
    _init();
  }

  void _init() {
    // Listen to audio service streams
    _audioService.playingStream.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
    });

    _audioService.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    _audioService.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
      notifyListeners();
    });

    _audioService.playerStateStream.listen((state) {
      _currentTrack = _audioService.currentTrack;
      _queue = _audioService.queue;
      notifyListeners();
    });
  }

  // Getters
  Track? get currentTrack => _currentTrack;
  List<Track> get queue => _queue;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  LoopMode get loopMode => _loopMode;
  bool get shuffleMode => _shuffleMode;
  double get progress =>
      _duration.inMilliseconds > 0
          ? _position.inMilliseconds / _duration.inMilliseconds
          : 0.0;

  // Player controls
  Future<void> playTrack(Track track, {List<Track>? queue}) async {
    try {
      await _audioService.playTrack(track, queue: queue);
      _currentTrack = track;
      _queue = queue ?? [track];
      notifyListeners();
    } catch (e) {
      print('Error playing track: $e');
    }
  }

  Future<void> play() async {
    await _audioService.play();
  }

  Future<void> pause() async {
    await _audioService.pause();
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> stop() async {
    await _audioService.stop();
    _currentTrack = null;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  Future<void> skipToNext() async {
    await _audioService.skipToNext();
  }

  Future<void> skipToPrevious() async {
    await _audioService.skipToPrevious();
  }

  Future<void> skipToIndex(int index) async {
    await _audioService.skipToIndex(index);
  }

  // Queue management
  Future<void> setQueue(List<Track> tracks, {int startIndex = 0}) async {
    await _audioService.setQueue(tracks, startIndex: startIndex);
    _queue = tracks;
    notifyListeners();
  }

  Future<void> addToQueue(Track track) async {
    await _audioService.addToQueue(track);
    _queue = _audioService.queue;
    notifyListeners();
  }

  Future<void> removeFromQueue(int index) async {
    await _audioService.removeFromQueue(index);
    _queue = _audioService.queue;
    notifyListeners();
  }

  Future<void> clearQueue() async {
    await _audioService.clearQueue();
    _queue = [];
    _currentTrack = null;
    notifyListeners();
  }

  // Playback settings
  Future<void> toggleLoopMode() async {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
        break;
      case LoopMode.all:
        _loopMode = LoopMode.one;
        break;
      case LoopMode.one:
        _loopMode = LoopMode.off;
        break;
    }
    await _audioService.setLoopMode(_loopMode);
    notifyListeners();
  }

  Future<void> toggleShuffle() async {
    _shuffleMode = !_shuffleMode;
    await _audioService.setShuffleModeEnabled(_shuffleMode);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    await _audioService.setVolume(volume);
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
