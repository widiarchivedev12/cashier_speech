import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

part 'app_state_provider.g.dart';

const kPlaceholderStoreId = '00000000-0000-0000-0000-000000000000';
const kPlaceholderDeviceId = 'device-local';

class AppState {
  const AppState({required this.deviceId, this.storeId});

  final String deviceId;
  final String? storeId;
}

@Riverpod(keepAlive: true)
class AppStateNotifier extends _$AppStateNotifier {
  @override
  Future<AppState> build() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString('device_id');
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString('device_id', deviceId);
    }
    return AppState(
      deviceId: deviceId,
      storeId: prefs.getString('store_id'),
    );
  }

  Future<void> setStoreId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('store_id', id);
    final current = state.value;
    state = AsyncData(AppState(
      deviceId: current?.deviceId ?? kPlaceholderDeviceId,
      storeId: id,
    ));
  }

  Future<void> clearStoreId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('store_id');
    final current = state.value;
    state = AsyncData(AppState(
      deviceId: current?.deviceId ?? kPlaceholderDeviceId,
    ));
  }
}

@Riverpod(keepAlive: true)
String storeId(Ref ref) =>
    ref.watch(appStateProvider).value?.storeId ?? kPlaceholderStoreId;

@Riverpod(keepAlive: true)
String deviceId(Ref ref) =>
    ref.watch(appStateProvider).value?.deviceId ?? kPlaceholderDeviceId;
