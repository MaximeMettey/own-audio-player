import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../models/track.dart';
import '../config/api_config.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;

  late final AudioPlayer _player;
  List<Track> _queue = [];
  int _currentIndex = 0;

  AudioPlayerService._internal() {
    _player = AudioPlayer();
    _setupPlayerListeners();
  }

  AudioPlayer get player => _player;
  List<Track> get queue => _queue;
  int get currentIndex => _currentIndex;
  Track? get currentTrack =>
      _queue.isNotEmpty ? _queue[_currentIndex] : null;

  void _setupPlayerListeners() {
    // Listen to player state changes
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        skipToNext();
      }
    });
  }

  Future<void> playTrack(Track track, {List<Track>? queue}) async {
    try {
      if (queue != null) {
        _queue = queue;
        _currentIndex = queue.indexOf(track);
      } else {
        _queue = [track];
        _currentIndex = 0;
      }

      await _loadAndPlay(track);
    } catch (e) {
      print('Error playing track: $e');
      rethrow;
    }
  }

  Future<void> _loadAndPlay(Track track) async {
    final url = ApiConfig.getStreamUrl(track.id);
    await _player.setUrl(url);
    await _player.play();
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> skipToNext() async {
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
      await _loadAndPlay(_queue[_currentIndex]);
    } else {
      // End of queue, stop or loop
      await stop();
    }
  }

  Future<void> skipToPrevious() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      await _loadAndPlay(_queue[_currentIndex]);
    } else {
      // Beginning of queue, restart current track
      await seek(Duration.zero);
    }
  }

  Future<void> skipToIndex(int index) async {
    if (index >= 0 && index < _queue.length) {
      _currentIndex = index;
      await _loadAndPlay(_queue[_currentIndex]);
    }
  }

  Future<void> setQueue(List<Track> tracks, {int startIndex = 0}) async {
    _queue = tracks;
    _currentIndex = startIndex;
    if (tracks.isNotEmpty) {
      await _loadAndPlay(tracks[startIndex]);
    }
  }

  Future<void> addToQueue(Track track) async {
    _queue.add(track);
  }

  Future<void> removeFromQueue(int index) async {
    if (index >= 0 && index < _queue.length) {
      _queue.removeAt(index);
      if (index < _currentIndex) {
        _currentIndex--;
      } else if (index == _currentIndex) {
        if (_queue.isNotEmpty) {
          await _loadAndPlay(_queue[_currentIndex.clamp(0, _queue.length - 1)]);
        } else {
          await stop();
        }
      }
    }
  }

  Future<void> clearQueue() async {
    _queue.clear();
    _currentIndex = 0;
    await stop();
  }

  Future<void> setLoopMode(LoopMode mode) async {
    await _player.setLoopMode(mode);
  }

  Future<void> setShuffleModeEnabled(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<bool> get playingStream => _player.playingStream;

  bool get playing => _player.playing;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;

  void dispose() {
    _player.dispose();
  }
}

// Audio handler for background playback
class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayerService _audioService;

  AudioPlayerHandler(this._audioService) {
    _init();
  }

  void _init() {
    // Listen to player state and update playback state
    _audioService.playerStateStream.listen((state) {
      playbackState.add(playbackState.value.copyWith(
        playing: state.playing,
        processingState: _mapProcessingState(state.processingState),
      ));
    });

    // Listen to position changes
    _audioService.positionStream.listen((position) {
      playbackState.add(playbackState.value.copyWith(
        updatePosition: position,
      ));
    });
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  @override
  Future<void> play() => _audioService.play();

  @override
  Future<void> pause() => _audioService.pause();

  @override
  Future<void> stop() => _audioService.stop();

  @override
  Future<void> seek(Duration position) => _audioService.seek(position);

  @override
  Future<void> skipToNext() => _audioService.skipToNext();

  @override
  Future<void> skipToPrevious() => _audioService.skipToPrevious();

  @override
  Future<void> skipToQueueItem(int index) => _audioService.skipToIndex(index);
}
