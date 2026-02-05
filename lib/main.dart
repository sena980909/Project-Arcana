/// Arcana: The Three Hearts - 앱 진입점
/// PRD 3.2: 앱 초기화 및 실행
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/arcana_app.dart';
import 'data/services/save_manager.dart';
import 'game/managers/audio_manager.dart';

/// 앱 메인 진입점
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 화면 방향 고정 (가로)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // 전체 화면 모드
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // 세이브 매니저 초기화
  await SaveManager.instance.initialize();

  // 오디오 매니저 초기화
  await AudioManager.instance.initialize();

  // TODO: Firebase 초기화 (추후 구현)
  // await Firebase.initializeApp();

  runApp(const ArcanaApp());
}
