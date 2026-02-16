import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstract interface — ใช้สำหรับ DI (inject mock ตอน test ได้)
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Implementation จริง — ใช้ connectivity_plus
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
