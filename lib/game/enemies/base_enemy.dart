/// Arcana: The Three Hearts - 기본 적 클래스
/// 모든 적의 공통 기능 정의
library;

import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../config/constants.dart';
import '../../data/model/enemy_data.dart';
import '../behaviors/enemy_ai.dart';
import '../characters/player.dart';
import '../decorations/dropped_item.dart';
import '../effects/effects.dart';
import '../managers/audio_manager.dart';

/// 기본 적 클래스
abstract class BaseEnemy extends PositionComponent
    with CollisionCallbacks, HasGameRef {
  BaseEnemy({
    required Vector2 position,
    required this.data,
  }) : super(
          position: position,
          size: Vector2(32, 32),
          anchor: Anchor.center,
          // Y-소팅: 초기값, update에서 동적 갱신
          priority: 1000,
        );

  /// 적 데이터
  final EnemyData data;

  /// 현재 체력
  late double health;

  /// AI 컨트롤러
  late EnemyAI ai;

  /// 흔들림 효과 타이머
  double _shakeTimer = 0;
  double _shakeIntensity = 0;
  Vector2? _originalPosition;

  /// 피격 무적 시간
  double _invincibleTimer = 0;

  /// 피격 플래시 효과
  final HitFlashEffect _hitFlash = HitFlashEffect(duration: 0.08, intensity: 1.0);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 체력 초기화
    health = data.maxHealth;

    // AI 초기화
    ai = EnemyAI(
      detectRange: data.detectRange,
      attackRange: data.attackRange,
      attackCooldown: data.attackCooldown,
    );

    // 히트박스 설정
    // Note: Flame에서 onLoad 완료 전까지 컴포넌트는 update/render되지 않으므로
    // 히트박스 등록 지연 문제는 발생하지 않음 (TC-046 검증 완료)
    add(
      RectangleHitbox(
        size: Vector2(28, 28),
        position: Vector2(2, 2),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 무적 시간 감소
    if (_invincibleTimer > 0) {
      _invincibleTimer -= dt;
    }

    // 피격 플래시 업데이트
    _hitFlash.update(dt);

    // 흔들림 효과
    if (_shakeTimer > 0) {
      _shakeTimer -= dt;
      _applyShakeEffect();
    } else if (_originalPosition != null && _shakeIntensity > 0) {
      position = _originalPosition!.clone();
      _shakeIntensity = 0;
    }

    // AI 업데이트
    final player = _findPlayer();
    if (player != null) {
      final moveDirection = ai.update(
        dt: dt,
        enemyPosition: position,
        playerPosition: player.position,
        onAttack: () => _performAttack(player),
      );

      // 이동
      if (!moveDirection.isZero()) {
        position += moveDirection * data.speed * dt;
      }
    }

    // Y-소팅: Y좌표 기반 렌더링 순서 (높은 Y = 앞에 렌더링)
    priority = 1000 + position.y.toInt();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 체력바
    _drawHealthBar(canvas);

    // 서브클래스에서 외형 구현
    renderEnemy(canvas);

    // 피격 플래시 효과 (흰색 오버레이)
    _hitFlash.render(canvas, Rect.fromLTWH(0, 0, size.x, size.y));
  }

  /// 적 외형 렌더링 (서브클래스에서 구현)
  void renderEnemy(Canvas canvas);

  /// 체력바 그리기
  void _drawHealthBar(Canvas canvas) {
    // 체력 비율 클램프 (음수/초과 방지)
    final healthRatio = (health / data.maxHealth).clamp(0.0, 1.0);

    // 배경
    final bgPaint = Paint()
      ..color = Colors.red.shade900
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, -8, size.x, 4),
      bgPaint,
    );

    // 현재 체력
    final fgPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, -8, size.x * healthRatio, 4),
      fgPaint,
    );
  }

  /// 플레이어 찾기
  ArcanaPlayer? _findPlayer() {
    try {
      return gameRef.world.children.whereType<ArcanaPlayer>().first;
    } catch (_) {
      return null;
    }
  }

  /// 공격 수행
  void _performAttack(ArcanaPlayer player) {
    // 플레이어에게 데미지
    final damage = _calculateDamage();
    player.takeDamage(damage);
  }

  /// 데미지 계산 (PRD 4.1)
  double _calculateDamage() {
    final random = Random();
    final randomMultiplier = CombatConstants.damageRandomMin +
        random.nextDouble() *
            (CombatConstants.damageRandomMax - CombatConstants.damageRandomMin);
    return data.attack * randomMultiplier;
  }

  /// 데미지 받기
  void takeDamage(double damage) {
    // 무적 상태면 무시
    if (_invincibleTimer > 0) return;

    // 방어력 적용
    final actualDamage = _calculateActualDamage(damage);
    health -= actualDamage;

    // 피격 사운드 재생
    AudioManager.instance.playSfx(SoundEffect.enemyHit);

    // 피격 플래시 효과
    _hitFlash.trigger();

    // 피격 파티클 효과
    gameRef.world.add(
      ParticleFactory.createHitSparks(
        position: position,
        direction: Vector2(0, -1),
        color: Colors.white,
        particleCount: 6,
      ),
    );

    // 임팩트 이펙트
    gameRef.world.add(
      ImpactEffect(
        position: position,
        color: Colors.orange,
        effectSize: 25,
      ),
    );

    // 데미지 표시
    _showDamageText(actualDamage);

    // 흔들림 효과
    _startShakeEffect();

    // 히트스톱
    _applyHitStop();

    // 짧은 무적 시간
    _invincibleTimer = 0.1;

    // 사망 처리
    if (health <= 0) {
      _die();
    }
  }

  /// 실제 데미지 계산
  double _calculateActualDamage(double rawDamage) {
    final reduction = data.defense * CombatConstants.defenseMultiplier;
    final actualDamage = rawDamage - reduction;
    return actualDamage < CombatConstants.minimumDamage
        ? CombatConstants.minimumDamage.toDouble()
        : actualDamage;
  }

  /// 사망 처리
  void _die() {
    ai.die();

    // 사망 사운드 재생
    AudioManager.instance.playSfx(SoundEffect.enemyDeath);

    // 사망 이펙트 (서브클래스에서 오버라이드 가능)
    spawnDeathEffect();

    // 화면 흔들림
    ScreenShakeManager.mediumShake();

    // 아이템 드롭
    _dropItems();

    // 방 클리어 카운트 알림 (스테이지 이동 활성화용)
    if (gameRef is ArcanaGameInterface) {
      (gameRef as ArcanaGameInterface).notifyEnemyKilled();
    }

    // 제거
    removeFromParent();
  }

  /// 사망 이펙트 생성 (서브클래스에서 오버라이드 가능)
  void spawnDeathEffect() {
    // 기본 폭발 이펙트
    gameRef.world.add(
      ParticleFactory.createExplosion(
        position: position,
        color: Colors.red,
        particleCount: 15,
        speed: 80,
      ),
    );
  }

  /// 아이템 드롭
  void _dropItems() {
    final random = Random();

    for (final dropEntry in data.dropTable) {
      if (random.nextDouble() <= dropEntry.dropRate) {
        final quantity = dropEntry.minQuantity +
            random.nextInt(dropEntry.maxQuantity - dropEntry.minQuantity + 1);

        for (int i = 0; i < quantity; i++) {
          // 약간의 랜덤 오프셋
          final offset = Vector2(
            (random.nextDouble() - 0.5) * 32,
            (random.nextDouble() - 0.5) * 32,
          );

          gameRef.world.add(
            DroppedItem(
              item: dropEntry.item,
              position: position + offset,
            ),
          );
        }
      }
    }
  }

  /// 데미지 텍스트 표시
  void _showDamageText(double damage) {
    add(
      DamageText(
        text: damage.toInt().toString(),
        position: Vector2(size.x / 2, -20),
      ),
    );
  }

  /// 흔들림 효과 시작
  void _startShakeEffect() {
    _shakeTimer = 0.2;
    _shakeIntensity = 4.0;
    _originalPosition ??= position.clone();
  }

  /// 흔들림 효과 적용
  void _applyShakeEffect() {
    if (_originalPosition == null) return;

    final random = Random();
    final offsetX = (random.nextDouble() - 0.5) * 2 * _shakeIntensity;
    final offsetY = (random.nextDouble() - 0.5) * 2 * _shakeIntensity;

    position = _originalPosition! + Vector2(offsetX, offsetY);
  }

  /// 히트스톱 효과
  void _applyHitStop() {
    // 대화 중이거나 이미 일시정지 상태면 히트스톱 스킵
    if (gameRef is ArcanaGameInterface) {
      final game = gameRef as ArcanaGameInterface;
      if (game.isGamePaused) {
        return;
      }
    }

    gameRef.pauseEngine();
    Future.delayed(
      Duration(milliseconds: (UIConstants.hitStopDuration * 1000).toInt()),
      () {
        if (gameRef.paused) {
          // 대화나 메뉴로 인한 일시정지가 아닌 경우에만 재개
          if (gameRef is ArcanaGameInterface) {
            final currentGame = gameRef as ArcanaGameInterface;
            if (!currentGame.isGamePaused) {
              gameRef.resumeEngine();
            }
          } else {
            gameRef.resumeEngine();
          }
        }
      },
    );
  }
}

/// 데미지 텍스트 컴포넌트
class DamageText extends PositionComponent {
  DamageText({
    required this.text,
    required Vector2 position,
  }) : super(position: position);

  final String text;
  double _elapsed = 0;
  final double duration = UIConstants.damageNumberDuration;

  @override
  void update(double dt) {
    super.update(dt);

    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
      return;
    }

    position.y -= 30 * dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progress = _elapsed / duration;
    final opacity = 1.0 - progress;

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.yellow.withValues(alpha: opacity),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, 0));
  }
}
