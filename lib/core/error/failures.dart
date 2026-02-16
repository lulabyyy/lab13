import 'package:equatable/equatable.dart';

/// Base Failure class — ทุก error ใน app จะเป็น subclass ของ Failure
/// ใช้ร่วมกับ dartz Either<Failure, Success>
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Server error — API ตอบกลับผิดพลาด
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'เกิดข้อผิดพลาดจาก Server',
    super.statusCode,
  });
}

/// Network error — ไม่มีอินเทอร์เน็ต
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้',
  });
}

/// Cache error — อ่าน/เขียน cache ไม่ได้
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'ไม่สามารถอ่านข้อมูลจาก Cache ได้',
  });
}

/// Database error — SQLite ผิดพลาด
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    super.message = 'เกิดข้อผิดพลาดจากฐานข้อมูล',
  });
}

/// Not Found — ไม่พบข้อมูลที่ค้นหา
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'ไม่พบข้อมูลที่ค้นหา',
    super.statusCode = 404,
  });
}

/// Timeout — API ตอบช้าเกินไป
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'การเชื่อมต่อใช้เวลานานเกินไป',
  });
}
