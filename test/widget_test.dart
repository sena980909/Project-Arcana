// Arcana: The Three Hearts - 기본 위젯 테스트

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:arcana_the_three_hearts/main.dart';

void main() {
  testWidgets('MainMenuScreen displays title', (WidgetTester tester) async {
    // 앱 빌드
    await tester.pumpWidget(
      const ProviderScope(
        child: ArcanaApp(),
      ),
    );

    // 타이틀 확인
    expect(find.text('ARCANA'), findsOneWidget);
    expect(find.text('The Three Hearts'), findsOneWidget);
    expect(find.text('START GAME'), findsOneWidget);
  });
}
