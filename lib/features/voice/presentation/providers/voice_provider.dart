import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_parser/voice_parser.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../voice/data/parse_log_repository.dart';

part 'voice_provider.g.dart';

enum VoiceStatus { idle, listening, done, error }

class VoiceState {
  const VoiceState({
    this.status = VoiceStatus.idle,
    this.transcript = '',
    this.parseResult,
    this.errorMessage,
  });

  final VoiceStatus status;
  final String transcript;
  final ParseResult? parseResult;
  final String? errorMessage;

  bool get isListening => status == VoiceStatus.listening;
  bool get isDone => status == VoiceStatus.done;

  VoiceState copyWith({
    VoiceStatus? status,
    String? transcript,
    ParseResult? parseResult,
    String? errorMessage,
  }) =>
      VoiceState(
        status: status ?? this.status,
        transcript: transcript ?? this.transcript,
        parseResult: parseResult ?? this.parseResult,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

@Riverpod(keepAlive: true)
ParseLogRepository parseLogRepository(Ref ref) =>
    ParseLogRepository(ref.watch(appDatabaseProvider));

@riverpod
class VoiceNotifier extends _$VoiceNotifier {
  late final SpeechToText _stt;
  bool _initialized = false;

  @override
  VoiceState build() {
    _stt = SpeechToText();
    return const VoiceState();
  }

  Future<bool> _initialize() async {
    if (_initialized) return true;
    _initialized = await _stt.initialize(
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') &&
            state.status == VoiceStatus.listening) {
          state = state.copyWith(status: VoiceStatus.idle);
        }
      },
      onError: (error) {
        state = VoiceState(
          status: VoiceStatus.error,
          transcript: state.transcript,
          errorMessage: error.errorMsg,
        );
        _initialized = false;
      },
    );
    return _initialized;
  }

  Future<void> startListening() async {
    if (!(await _initialize())) {
      state = const VoiceState(
        status: VoiceStatus.error,
        errorMessage: 'Speech recognition tidak tersedia di perangkat ini.',
      );
      return;
    }

    state = const VoiceState(status: VoiceStatus.listening);
    await _stt.listen(
      onResult: (result) {
        state = state.copyWith(transcript: result.recognizedWords);
        if (result.finalResult && state.isListening) {
          state = state.copyWith(status: VoiceStatus.idle);
        }
      },
      listenOptions: SpeechListenOptions(
        localeId: 'id_ID',
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> stopListening() async {
    await _stt.stop();
    state = state.copyWith(status: VoiceStatus.idle);
  }

  void setParseResult(ParseResult result, String transcript) {
    state = VoiceState(
      status: VoiceStatus.done,
      transcript: transcript,
      parseResult: result,
    );
  }

  void reset() {
    state = const VoiceState();
  }
}
