/// Arcana: The Three Hearts - 보스: 이그드라
/// Chapter 1 보스 - 잊혀진 숲의 심장
library;

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../data/model/enemy_data.dart';
import '../../data/model/item.dart';
import '../characters/player.dart';
import '../managers/audio_manager.dart';
import 'base_enemy.dart';

/// 이그드라 데이터
const yggdraData = EnemyData(
  type: EnemyType.boss,
  name: '이그드라',
  maxHealth: 600,
  attack: 20,
  defense: 8,
  speed: 35,
  detectRange: 350,
  attackRange: 70,
  attackCooldown: 2.5,
  dropTable: [
    DropEntry(item: Items.yggdraTear, dropRate: 1.0),
    DropEntry(item: Items.healthPotion, dropRate: 1.0, minQuantity: 2, maxQuantity: 4),
  ],
  expReward: 250,
  goldReward: 150,
);

/// 보스 페이즈
enum YggdraPhase {
  sorrow,  // Phase 1: 슬픔 (HP 100%~50%)
  rage,    // Phase 2: 분노 (HP 50%~0%)
}

/// 보스 상태
enum YggdraState {
  idle,
  chase,
  tearAttack,    // 눈물 탄막
  rootAttack,    // 뿌리 공격
  thornSummon,   // 가시 소환
  charge,        // 돌진
  phaseTransition,
  dead,
}

/// 이그드라 - 잊혀진 숲의 심장
class BossYggdra extends BaseEnemy {
  BossYggdra({required super.position})
      : super(data: yggdraData) {
    size = Vector2(100, 120); // 거대한 나무 형태
  }

  /// 현재 페이즈
  YggdraPhase _phase = YggdraPhase.sorrow;
  YggdraPhase get phase => _phase;

  /// 분노 페이즈 여부
  bool get isInRagePhase => _phase == YggdraPhase.rage;

  /// 현재 상태
  YggdraState _state = YggdraState.idle;

  /// 공격 타이머
  double _attackTimer = 0;

  /// 눈물 공격 쿨다운
  double _tearCooldown = 0;
  static const double tearCooldownTime = 3.0;

  /// 가시 소환 쿨다운
  double _thornCooldown = 0;
  static const double thornCooldownTime = 6.0;

  /// 돌진 쿨다운
  double _chargeCooldown = 0;
  static const double chargeCooldownTime = 4.0;

  /// 페이즈 전환 중
  bool _isTransitioning = false;
  double _transitionTimer = 0;

  /// 애니메이션 타이머
  double _animTimer = 0;

  /// 눈물 파티클
  final List<_TearParticle> _tears = [];

  /// 가시 목록
  final List<_Thorn> _thorns = [];

  /// 돌진 중
  bool _isCharging = false;
  Vector2? _chargeTarget;
  double _chargeProgress = 0;

  /// 페이즈 전환 콜백
  void Function()? onPhaseChange;

  /// 처치 콜백
  void Function()? onDefeat;

  @override
  void update(double dt) {
    _animTimer += dt;

    // 쿨다운 감소
    if (_tearCooldown > 0) _tearCooldown -= dt;
    if (_thornCooldown > 0) _thornCooldown -= dt;
    if (_chargeCooldown > 0) _chargeCooldown -= dt;
    if (_attackTimer > 0) _attackTimer -= dt;

    // 페이즈 전환 체크
    if (!_isTransitioning && _phase == YggdraPhase.sorrow && health / data.maxHealth <= 0.5) {
      _startPhaseTransition();
    }

    // 페이즈 전환 중
    if (_isTransitioning) {
      _transitionTimer -= dt;
      if (_transitionTimer <= 0) {
        _completePhaseTransition();
      }
      return;
    }

    // 보스 AI
    _updateAI(dt);

    // 눈물 파티클 업데이트
    _updateTears(dt);

    // 가시 업데이트
    _updateThorns(dt);

    // 돌진 업데이트
    if (_isCharging) {
      _updateCharge(dt);
    }
  }

  /// AI 업데이트
  void _updateAI(double dt) {
    if (_state == YggdraState.dead) return;

    final player = _findPlayer();
    if (player == null) return;

    final distance = position.distanceTo(player.position);

    switch (_state) {
      case YggdraState.idle:
        if (distance < data.detectRange) {
          _state = YggdraState.chase;
        }

      case YggdraState.chase:
        _chasePlayer(player, dt);

        // 페이즈별 공격 패턴
        if (_phase == YggdraPhase.sorrow) {
          // Phase 1: 느린 눈물 공격
          if (_tearCooldown <= 0 && distance < 200) {
            _startTearAttack(player);
          } else if (_attackTimer <= 0 && distance < data.attackRange) {
            _performRootAttack(player);
          }
        } else {
          // Phase 2: 빠른 돌진 + 가시
          if (_chargeCooldown <= 0 && distance > 100) {
            _startCharge(player);
          } else if (_thornCooldown <= 0) {
            _summonThorns(player);
          } else if (_attackTimer <= 0 && distance < data.attackRange) {
            _performRootAttack(player);
          }
        }

      case YggdraState.tearAttack:
        _state = YggdraState.chase;

      case YggdraState.rootAttack:
        _state = YggdraState.chase;

      case YggdraState.thornSummon:
        _state = YggdraState.chase;

      case YggdraState.charge:
        if (!_isCharging) {
          _state = YggdraState.chase;
        }

      case YggdraState.phaseTransition:
      case YggdraState.dead:
        break;
    }
  }

  /// 플레이어 추격
  void _chasePlayer(ArcanaPlayer player, double dt) {
    if (_isCharging) return;

    final direction = (player.position - position).normalized();
    final speed = _phase == YggdraPhase.rage ? data.speed * 1.3 : data.speed;
    position += direction * speed * dt;
  }

  /// 눈물 공격 시작
  void _startTearAttack(ArcanaPlayer player) {
    _state = YggdraState.tearAttack;
    _tearCooldown = tearCooldownTime;

    // 여러 방향으로 눈물 발사
    final tearCount = _phase == YggdraPhase.sorrow ? 5 : 8;
    for (int i = 0; i < tearCount; i++) {
      final angle = (2 * pi / tearCount) * i;
      _tears.add(_TearParticle(
        position: position.clone(),
        velocity: Vector2(cos(angle), sin(angle)) * 80,
        damage: data.attack * 0.5,
      ));
    }
  }

  /// 뿌리 공격
  void _performRootAttack(ArcanaPlayer player) {
    _state = YggdraState.rootAttack;
    _attackTimer = data.attackCooldown;

    final distance = position.distanceTo(player.position);
    if (distance < data.attackRange + 20) {
      final damage = _phase == YggdraPhase.rage ? data.attack * 1.5 : data.attack;
      player.takeDamage(damage);
    }
  }

  /// 가시 소환
  void _summonThorns(ArcanaPlayer player) {
    _state = YggdraState.thornSummon;
    _thornCooldown = thornCooldownTime;

    // 플레이어 주변에 가시 소환
    final thornCount = 4;
    for (int i = 0; i < thornCount; i++) {
      final angle = (2 * pi / thornCount) * i + _animTimer;
      final offset = Vector2(cos(angle), sin(angle)) * 60;
      _thorns.add(_Thorn(
        position: player.position + offset,
        delay: i * 0.3,
        damage: data.attack * 0.8,
      ));
    }
  }

  /// 돌진 시작
  void _startCharge(ArcanaPlayer player) {
    _state = YggdraState.charge;
    _isCharging = true;
    _chargeTarget = player.position.clone();
    _chargeProgress = 0;
    _chargeCooldown = chargeCooldownTime;
  }

  /// 돌진 업데이트
  void _updateCharge(double dt) {
    _chargeProgress += dt * 3;

    if (_chargeProgress >= 1.0 || _chargeTarget == null) {
      _isCharging = false;
      _chargeProgress = 0;

      // 돌진 착지 데미지
      final player = _findPlayer();
      if (player != null) {
        final distance = position.distanceTo(player.position);
        if (distance < 60) {
          player.takeDamage(data.attack * 2);
        }
      }
    } else {
      // 돌진 이동
      final direction = (_chargeTarget! - position).normalized();
      position += direction * data.speed * 4 * dt;
    }
  }

  /// 눈물 파티클 업데이트
  void _updateTears(double dt) {
    for (final tear in _tears.toList()) {
      tear.position += tear.velocity * dt;
      tear.lifetime -= dt;

      // 플레이어와 충돌 체크
      final player = _findPlayer();
      if (player != null) {
        final distance = tear.position.distanceTo(player.position);
        if (distance < 20) {
          player.takeDamage(tear.damage);
          _tears.remove(tear);
          continue;
        }
      }

      if (tear.lifetime <= 0) {
        _tears.remove(tear);
      }
    }
  }

  /// 가시 업데이트
  void _updateThorns(double dt) {
    for (final thorn in _thorns.toList()) {
      thorn.delay -= dt;

      if (thorn.delay <= 0 && !thorn.triggered) {
        thorn.triggered = true;

        // 데미지 처리
        final player = _findPlayer();
        if (player != null) {
          final distance = thorn.position.distanceTo(player.position);
          if (distance < 30) {
            player.takeDamage(thorn.damage);
          }
        }
      }

      thorn.lifetime -= dt;
      if (thorn.lifetime <= 0) {
        _thorns.remove(thorn);
      }
    }
  }

  /// 페이즈 전환 시작
  void _startPhaseTransition() {
    _isTransitioning = true;
    _transitionTimer = 2.0;
    _state = YggdraState.phaseTransition;

    // 페이즈 전환 콜백
    onPhaseChange?.call();
  }

  /// 페이즈 전환 완료
  void _completePhaseTransition() {
    _isTransitioning = false;
    _phase = YggdraPhase.rage;
    _state = YggdraState.chase;

    // 분노 모드 진입 시 속도 증가
    AudioManager.instance.playSfx(SoundEffect.bossAppear);
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
  void spawnDeathEffect() {
    _state = YggdraState.dead;
    onDefeat?.call();
    super.spawnDeathEffect();
  }

  @override
  void renderEnemy(Canvas canvas) {
    // 흔들림 효과
    final sway = sin(_animTimer * 2) * 3;

    // 그림자
    _drawShadow(canvas);

    // 몸체 (거대한 나무 형태)
    _drawBody(canvas, sway);

    // 눈
    _drawEyes(canvas, sway);

    // 눈물 파티클
    _drawTears(canvas);

    // 가시
    _drawThorns(canvas);

    // 페이즈 전환 이펙트
    if (_isTransitioning) {
      _drawTransitionEffect(canvas);
    }

    // 분노 이펙트
    if (_phase == YggdraPhase.rage) {
      _drawRageAura(canvas);
    }

    // 보스 이름
    _drawBossName(canvas);
  }

  /// 그림자 그리기
  void _drawShadow(Canvas canvas) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y - 10),
        width: 80,
        height: 25,
      ),
      shadowPaint,
    );
  }

  /// 몸체 그리기
  void _drawBody(Canvas canvas, double sway) {
    final bodyColor = _phase == YggdraPhase.sorrow
        ? const Color(0xFF2E7D32)  // 짙은 녹색
        : const Color(0xFF4E342E); // 어두운 갈색 (분노)

    final bodyPaint = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.fill;

    // 줄기 (나무 몸통)
    final trunkPath = Path();
    trunkPath.moveTo(size.x / 2 - 25 + sway, size.y);
    trunkPath.lineTo(size.x / 2 - 35 + sway, size.y - 60);
    trunkPath.quadraticBezierTo(
      size.x / 2 + sway, size.y - 90,
      size.x / 2 + 35 + sway, size.y - 60,
    );
    trunkPath.lineTo(size.x / 2 + 25 + sway, size.y);
    trunkPath.close();

    canvas.drawPath(trunkPath, bodyPaint);

    // 나뭇잎/머리 부분
    final crownColor = _phase == YggdraPhase.sorrow
        ? const Color(0xFF1B5E20)
        : const Color(0xFF3E2723);

    final crownPaint = Paint()
      ..color = crownColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.x / 2 + sway, size.y / 3),
      35,
      crownPaint,
    );

    // 나뭇잎 디테일
    final leafPaint = Paint()
      ..color = crownColor.withValues(alpha: 0.7);

    for (int i = 0; i < 5; i++) {
      final angle = (2 * pi / 5) * i + _animTimer * 0.5;
      canvas.drawCircle(
        Offset(
          size.x / 2 + cos(angle) * 30 + sway,
          size.y / 3 + sin(angle) * 25,
        ),
        15,
        leafPaint,
      );
    }
  }

  /// 눈 그리기
  void _drawEyes(Canvas canvas, double sway) {
    final eyeColor = _phase == YggdraPhase.sorrow
        ? Colors.lightBlue
        : Colors.red;

    final eyePaint = Paint()
      ..color = eyeColor
      ..style = PaintingStyle.fill;

    // 눈물이 흐르는 효과 (슬픔 페이즈)
    if (_phase == YggdraPhase.sorrow) {
      final tearPaint = Paint()
        ..color = Colors.lightBlue.withValues(alpha: 0.5);

      canvas.drawRect(
        Rect.fromLTWH(
          size.x / 2 - 18 + sway,
          size.y / 3,
          4,
          30 + sin(_animTimer * 3) * 5,
        ),
        tearPaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          size.x / 2 + 14 + sway,
          size.y / 3,
          4,
          30 + sin(_animTimer * 3 + 1) * 5,
        ),
        tearPaint,
      );
    }

    // 눈
    canvas.drawCircle(
      Offset(size.x / 2 - 12 + sway, size.y / 3 - 5),
      6,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(size.x / 2 + 12 + sway, size.y / 3 - 5),
      6,
      eyePaint,
    );

    // 눈 빛
    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5);

    canvas.drawCircle(
      Offset(size.x / 2 - 14 + sway, size.y / 3 - 7),
      2,
      glowPaint,
    );
    canvas.drawCircle(
      Offset(size.x / 2 + 10 + sway, size.y / 3 - 7),
      2,
      glowPaint,
    );
  }

  /// 눈물 파티클 그리기
  void _drawTears(Canvas canvas) {
    final tearPaint = Paint()
      ..color = Colors.lightBlue
      ..style = PaintingStyle.fill;

    for (final tear in _tears) {
      // 월드 좌표를 로컬 좌표로 변환
      final localPos = tear.position - position;
      canvas.drawCircle(
        Offset(localPos.x + size.x / 2, localPos.y + size.y / 2),
        8,
        tearPaint,
      );
    }
  }

  /// 가시 그리기
  void _drawThorns(Canvas canvas) {
    final thornPaint = Paint()
      ..color = const Color(0xFF4E342E)
      ..style = PaintingStyle.fill;

    final warningPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (final thorn in _thorns) {
      final localPos = thorn.position - position;
      final thornX = localPos.x + size.x / 2;
      final thornY = localPos.y + size.y / 2;

      if (!thorn.triggered) {
        // 경고 표시
        canvas.drawCircle(
          Offset(thornX, thornY),
          25,
          warningPaint,
        );
      } else {
        // 가시 그리기
        final path = Path();
        path.moveTo(thornX, thornY - 30);
        path.lineTo(thornX - 8, thornY);
        path.lineTo(thornX + 8, thornY);
        path.close();
        canvas.drawPath(path, thornPaint);
      }
    }
  }

  /// 페이즈 전환 이펙트
  void _drawTransitionEffect(Canvas canvas) {
    final progress = 1 - (_transitionTimer / 2.0);
    final effectPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.3 + progress * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      50 + progress * 30,
      effectPaint,
    );
  }

  /// 분노 오라
  void _drawRageAura(Canvas canvas) {
    final auraPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.2 + sin(_animTimer * 4) * 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      55 + sin(_animTimer * 3) * 5,
      auraPaint,
    );
  }

  /// 보스 이름
  void _drawBossName(Canvas canvas) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '이그드라, 잊혀진 숲의 심장',
        style: TextStyle(
          color: _phase == YggdraPhase.sorrow ? Colors.lightBlue : Colors.red,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size.x - textPainter.width) / 2, -20),
    );
  }
}

/// 눈물 파티클
class _TearParticle {
  _TearParticle({
    required this.position,
    required this.velocity,
    required this.damage,
    this.lifetime = 3.0,
  });

  Vector2 position;
  Vector2 velocity;
  double damage;
  double lifetime;
}

/// 가시
class _Thorn {
  _Thorn({
    required this.position,
    required this.delay,
    required this.damage,
    this.lifetime = 1.5,
    this.triggered = false,
  });

  Vector2 position;
  double delay;
  double damage;
  double lifetime;
  bool triggered;
}
