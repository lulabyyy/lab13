/// Custom exceptions สำหรับ DataSource layer
/// throw exception → catch ใน Repository → return Left(Failure)

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    this.message = 'Server error occurred',
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

class CacheException implements Exception {
  final String message;

  const CacheException({this.message = 'Cache error occurred'});

  @override
  String toString() => 'CacheException: $message';
}

class DatabaseException implements Exception {
  final String message;

  const DatabaseException({this.message = 'Database error occurred'});

  @override
  String toString() => 'DatabaseException: $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'Network not available'});

  @override
  String toString() => 'NetworkException: $message';
}
