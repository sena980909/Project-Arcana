/// Arcana: The Three Hearts - 보스: 거대 슬라임
/// Chapter 1 보스 몬스터
library;

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../data/model/enemy_data.dart';
import '../../data/model/item.dart';
import '../characters/player.dart';
import 'base_enemy.dart';

/// 보스 슬라임 데이터
const bossSlimeData = EnemyData(
  type: EnemyType.boss,
  name: '거대 슬라임',
  maxHealth: 500,
  attack: 25,
  defense: 10,
  speed: 40,
  detectRange: 300,
  attackRange: 60,
  attackCooldown: 2.0,
  dropTable: [
    DropEntry(item: Items.ironSword, dropRate: 1.0),
    DropEntry(item: Items.healthPotion, dropRate: 1.0, minQuantity: 3, maxQuantity: 5),
  ],
  expReward: 200,
  goldReward: 100,
);

/// 보스 상태
enum BossState {
  idle,
  chase,
  attack,
  jumpAttack,
  summon,
  rage,
  dead,
}

/// 보스 슬라임
class BossSlime extends BaseEnemy {
  BossSlime({required super.position})
      : super(data: bossSlimeData) {
    size = Vector2(96, 96); // 일반 슬라임의 3배 크기
  }

  /// 보스 상태
  BossState _bossState = BossState.idle;

  /// 점프 공격 타이머
  double _jumpAttackTimer = 0;

  /// 점프 공격 쿨다운
  static const double jumpAttackCooldown = 5.0;

  /// 소환 쿨다운
  double _summonTimer = 0;
  static const double summonCooldown = 8.0;

  /// 분노 모드 여부
  bool _isEnraged = false;

  /// 통통 튀는 애니메이션
  double _bounceTimer = 0;

  /// 점프 중 여부
  bool _isJumping = false;
  double _jumpProgress = 0;
  Vector2? _jumpTarget;

  /// 분노 모드 돌입 체력 비율
  static const double rageThreshold = 0.3;

  @override
  void update(double dt) {
    // 기본 AI 대신 커스텀 보스 AI 사용
    _updateBossAI(dt);

    // 애니메이션 타이머
    _bounceTimer += dt * (_isEnraged ? 4 : 2);

    // 점프 공격 쿨다운
    if (_jumpAttackTimer > 0) {
      _jumpAttackTimer -= dt;
    }

    // 소환 쿨다운
    if (_summonTimer > 0) {
      _summonTimer -= dt;
    }

    // 점프 처리
    if (_isJumping) {
      _updateJump(dt);
    }

    // 분노 모드 체크
    if (!_isEnraged && health / data.maxHealth <= rageThreshold) {
      _enterRageMode();
    }
  }

  /// 보스 AI 업데이트
  void _updateBossAI(double dt) {
    if (_bossState == BossState.dead) return;

    final player = _findPlayer();
    if (player == null) return;

    final distanceToPlayer = position.distanceTo(player.position);

    switch (_bossState) {
      case BossState.idle:
        if (distanceToPlayer < data.detectRange) {
          _bossState = BossState.chase;
        }

      case BossState.chase:
        _chasePlayer(player, dt);

        // 점프 공격 조건
        if (_jumpAttackTimer <= 0 && distanceToPlayer > 100) {
          _startJumpAttack(player);
        }
        // 소환 조건
        else if (_summonTimer <= 0 && _isEnraged) {
          _summonMinions();
        }
        // 일반 공격 조건
        else if (distanceToPlayer < data.attackRange) {
          _bossState = BossState.attack;
          _performAttack(player);
        }

      case BossState.attack:
        // 공격 후 추격으로
        _bossState = BossState.chase;

      case BossState.jumpAttack:
        // 점프 중이면 대기
        if (!_isJumping) {
          _bossState = BossState.chase;
        }

      case BossState.summon:
        _bossState = BossState.chase;

      case BossState.rage:
        _bossState = BossState.chase;

      case BossState.dead:
        break;
    }
  }

  /// 플레이어 추격
  void _chasePlayer(ArcanaPlayer player, double dt) {
    if (_isJumping) return;

    final direction = (player.position - position).normalized();
    final speed = _isEnraged ? data.speed * 1.5 : data.speed;
    position += direction * speed * dt;
  }

  /// 점프 공격 시작
  void _startJumpAttack(ArcanaPlayer player) {
    _bossState = BossState.jumpAttack;
    _isJumping = true;
    _jumpProgress = 0;
    _jumpTarget = player.position.clone();
    _jumpAttackTimer = jumpAttackCooldown;
  }

  /// 점프 업데이트
  void _updateJump(double dt) {
    _jumpProgress += dt * 2; // 0.5초 동안 점프

    if (_jumpProgress >= 1.0) {
      _isJumping = false;
      _jumpProgress = 0;

      // 착지 시 범위 피해
      _landingDamage();
    } else if (_jumpTarget != null) {
      // 점프 중 위치 보간
      final startPos = position;
      position = startPos + (_jumpTarget! - startPos) * dt * 4;
    }
  }

  /// 착지 피해
  void _landingDamage() {
    final player = _findPlayer();
    if (player == null) return;

    final distance = position.distanceTo(player.position);
    if (distance < 80) {
      player.takeDamage(data.attack * 1.5);
    }
  }

  /// 미니언 소환
  void _summonMinions() {
    _bossState = BossState.summon;
    _summonTimer = summonCooldown;

    // TODO: 실제 슬라임 소환 구현
    // 지금은 시각 효과만
  }

  /// 분노 모드 진입
  void _enterRageMode() {
    _isEnraged = true;
    _bossState = BossState.rage;
  }

  /// 일반 공격
  void _performAttack(ArcanaPlayer player) {
    final damage = _isEnraged ? data.attack * 1.3 : data.attack;
    player.takeDamage(damage);
  }

  /// 플레이어 찾기
  ArcanaPlayer? _findPlayer() {
    try {
      return gameRef.world.children.whereType<ArcanaPlayer>().first;
    } catch (_) {
      return null;
    }
  }

  @override
  void renderEnemy(Canvas canvas) {
    // 튀는 효과
    final bounceOffset = sin(_bounceTimer) * 4;
    final squishFactor = 1.0 + cos(_bounceTimer) * 0.08;

    // 점프 중 높이
    final jumpHeight = _isJumping ? sin(_jumpProgress * 3.14159) * 50 : 0.0;

    // 그림자
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final shadowScale = _isJumping ? 0.5 + (1 - _jumpProgress) * 0.5 : 1.0;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y - 8),
        width: 70 * squishFactor * shadowScale,
        height: 20 * shadowScale,
      ),
      shadowPaint,
    );

    // 몸체 색상 (분노 모드면 빨간색)
    final bodyColor = _isEnraged
        ? Colors.red.shade400
        : Colors.green.shade400;

    final bodyPaint = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.fill;

    // 몸체 높이
    final bodyHeight = 60 - bounceOffset.abs();
    final bodyWidth = 70 * squishFactor;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y / 2 - bounceOffset - jumpHeight),
        width: bodyWidth,
        height: bodyHeight,
      ),
      bodyPaint,
    );

    // 하이라이트
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2 - 12, size.y / 2 - 18 - bounceOffset - jumpHeight),
        width: 18,
        height: 12,
      ),
      highlightPaint,
    );

    // 눈
    _drawEyes(canvas, bounceOffset + jumpHeight);

    // 분노 표시
    if (_isEnraged) {
      _drawRageEffect(canvas, bounceOffset + jumpHeight);
    }

    // 보스 이름
    _drawBossName(canvas);
  }

  /// 눈 그리기
  void _drawEyes(Canvas canvas, double offset) {
    final eyePaint = Paint()
      ..color = _isEnraged ? Colors.yellow : Colors.black
      ..style = PaintingStyle.fill;

    // 왼쪽 눈
    canvas.drawCircle(
      Offset(size.x / 2 - 15, size.y / 2 - 8 - offset),
      8,
      eyePaint,
    );

    // 오른쪽 눈
    canvas.drawCircle(
      Offset(size.x / 2 + 15, size.y / 2 - 8 - offset),
      8,
      eyePaint,
    );

    // 눈 하이라이트
    if (!_isEnraged) {
      final eyeHighlightPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(size.x / 2 - 17, size.y / 2 - 10 - offset),
        3,
        eyeHighlightPaint,
      );

      canvas.drawCircle(
        Offset(size.x / 2 + 13, size.y / 2 - 10 - offset),
        3,
        eyeHighlightPaint,
      );
    }
  }

  /// 분노 이펙트
  void _drawRageEffect(Canvas canvas, double offset) {
    final ragePaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y / 2 - offset),
        width: 80 + sin(_bounceTimer * 2) * 5,
        height: 65 + sin(_bounceTimer * 2) * 5,
      ),
      ragePaint,
    );
  }

  /// 보스 이름
  void _drawBossName(Canvas canvas) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: data.name,
        style: TextStyle(
          color: _isEnraged ? Colors.red : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size.x - textPainter.width) / 2, -24),
    );
  }
}
