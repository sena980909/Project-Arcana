/// Arcana: The Three Hearts - 데이터베이스 서비스
/// 플랫폼에 따라 네이티브(SQLite) 또는 웹(localStorage) 구현을 사용합니다.
library;

export 'save_slot.dart';
export 'database_service_native.dart'
    if (dart.library.html) 'database_service_web.dart';
