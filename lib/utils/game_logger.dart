/// Arcana: The Three Hearts - 게임 로거
/// 플랫폼에 따라 네이티브(파일) 또는 웹(콘솔) 구현을 사용합니다.
library;

export 'game_logger_native.dart'
    if (dart.library.html) 'game_logger_web.dart';
