import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_state_provider.g.dart';

// M2 placeholder — replaced by real auth state in M4.
const kPlaceholderStoreId = '00000000-0000-0000-0000-000000000000';
const kPlaceholderDeviceId = 'device-local';

@Riverpod(keepAlive: true)
String storeId(Ref ref) => kPlaceholderStoreId;

@Riverpod(keepAlive: true)
String deviceId(Ref ref) => kPlaceholderDeviceId;
