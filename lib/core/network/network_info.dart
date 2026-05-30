import 'package:injectable/injectable.dart';

/// Abstraction over connectivity checks so repositories can short-circuit with
/// a [NetworkFailure] before hitting the wire. Kept minimal — a real impl can
/// later swap in `connectivity_plus` without touching callers.
abstract interface class NetworkInfo {
  Future<bool> get isConnected;
}

@LazySingleton(as: NetworkInfo)
class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl();

  // Dio surfaces connectivity failures as DioException(connectionError),
  // which the FailureMapper already turns into NetworkFailure. This guard is
  // an optional fast-path; assume connected and let the request decide.
  @override
  Future<bool> get isConnected async => true;
}
