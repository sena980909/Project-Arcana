/// Arcana: The Three Hearts - 보스: 리리아나의 환영
/// Chapter 4 보스 - 피어난 원한
library;

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../data/model/enemy_data.dart';
import '../../data/model/item.dart';
import '../characters/player.dart';
import '../effects/effects.dart';
import '../managers/audio_manager.dart';
import 'base_enemy.dart';

/// 리리아나 데이터
const lilianaData = EnemyData(
  type: EnemyType.boss,
  name: '리리아나의 환영',
  maxHealth: 1200,
  attack: 35,
  defense: 8,
  speed: 45,
  detectRange: 500,
  attackRange: 90,
  attackCooldown: 2.0,
  dropTable: [
    DropEntry(item: Items.lilianaTear, dropRate: 1.0),
    DropEntry(item: Items.largeHealthPotion, dropRate: 1.0, minQuantity: 3, maxQuantity: 5),
  ],
  expReward: 600,
  goldReward: 400,
);

/// 보스 페이즈
enum LilianaPhase {
  love,       // Phase 1: 사랑의 기억 (HP 100%~65%)
  betrayal,   // Phase 2: 배신의 고통 (HP 65%~30%)
  forgiveness,// Phase 3: 용서와 원한 사이 (HP 30%~0%)
}

/// 보스 상태
enum LilianaState {
  idle,
  float,         // 부유
  rosePetal,     // 장미 꽃잎 (Phase 1)
  embrace,       // 포옹 공격 (Phase 1)
  thornStorm,    // 가시 폭풍 (Phase 2)
  bloodVine,     // 피의 덩굴 (Phase 2)
  chaosAttack,   // 혼란 공격 (Phase 3)
  cryAttack,     // 울면서 공격 (Phase 3)
  phaseTransition,
  dead,
}

/// 리리아나의 환영 - 피어난 원한
class BossLiliana extends BaseEnemy {
  BossLiliana({required super.position, this.onDefeat})
      : super(data: lilianaData) {
    size = Vector2(70, 100); // 여성 형태
  }

  /// 처치 콜백
  final VoidCallback? onDefeat;

  /// 현재 페이즈
  LilianaPhase _phase = LilianaPhase.love;
  LilianaPhase get phase => _phase;

  /// 페이즈 체크용 게터
  bool get isInBetrayalPhase => _phase == LilianaPhase.betrayal;
  bool get isInForgivenessPhase => _phase == LilianaPhase.forgiveness;

  /// 현재 상태
  LilianaState _state = LilianaState.float;

  /// 공격 타이머
  double _attackTimer = 0;

  /// 장미 꽃잎 쿨다운
  double _roseCooldown = 0;
  static const double roseCooldownTime = 3.0;

  /// 포옹 쿨다운
  double _embraceCooldown = 0;
  static const double embraceCooldownTime = 5.0;

  /// 가시 폭풍 쿨다운
  double _thornCooldown = 0;
  static const double thornCooldownTime = 4.0;

  /// 덩굴 쿨다운
  double _vineCooldown = 0;
  static const double vineCooldownTime = 6.0;

  /// 혼란 공격 쿨다운
  double _chaosCooldown = 0;
  static const double chaosCooldownTime = 3.0;

  /// 울음 공격 쿨다운
  double _cryCooldown = 0;
  static const double cryCooldownTime = 5.0;

  /// 부유 높이
  double _floatOffset = 0;

  /// 애니메이션 타이머
  double _animTimer = 0;

  /// 페이즈 전환 중 여부
  bool _isTransitioning = false;

  /// 눈물 효과 타이머
  double _tearTimer = 0;

  /// 랜덤 생성기
  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _roseCooldown = 1.5; // 초기 딜레이
  }

  @override
  void update(double dt) {
    if (_state == LilianaState.dead) return;

    _animTimer += dt;
    _tearTimer += dt;

    // 부유 효과
    _floatOffset = sin(_animTimer * 2.5) * 6;

    // 쿨다운 감소
    _roseCooldown = (_roseCooldown - dt).clamp(0.0, double.infinity);
    _embraceCooldown = (_embraceCooldown - dt).clamp(0.0, double.infinity);
    _thornCooldown = (_thornCooldown - dt).clamp(0.0, double.infinity);
    _vineCooldown = (_vineCooldown - dt).clamp(0.0, double.infinity);
    _chaosCooldown = (_chaosCooldown - dt).clamp(0.0, double.infinity);
    _cryCooldown = (_cryCooldown - dt).clamp(0.0, double.infinity);

    // 페이즈 전환 체크
    _checkPhaseTransition();

    // 페이즈 전환 중에는 다른 행동 안함
    if (_isTransitioning) {
      _attackTimer += dt;
      if (_attackTimer > 2.0) {
        _completePhaseTransition();
      }
      return;
    }

    // AI 로직
    _updateAI(dt);

    super.update(dt);
  }

  /// 페이즈 전환 체크
  void _checkPhaseTransition() {
    final healthRatio = health / data.maxHealth;

    if (!_isTransitioning) {
      if (_phase == LilianaPhase.love && healthRatio <= 0.65) {
        _startPhaseTransition(LilianaPhase.betrayal);
      } else if (_phase == LilianaPhase.betrayal && healthRatio <= 0.30) {
        _startPhaseTransition(LilianaPhase.forgiveness);
      }
    }
  }

  /// 페이즈 전환 시작
  void _startPhaseTransition(LilianaPhase newPhase) {
    _isTransitioning = true;
    _attackTimer = 0;
    _state = LilianaState.phaseTransition;

    // 화면 효과
    ScreenShakeManager.heavyShake();

    // 페이즈별 효과
    if (newPhase == LilianaPhase.betrayal) {
      // 가시 폭발
      gameRef.world.add(
        ParticleFactory.createExplosion(
          position: position,
          color: Colors.red.shade900,
          particleCount: 40,
          speed: 180,
        ),
      );
    } else if (newPhase == LilianaPhase.forgiveness) {
      // 눈물 효과
      gameRef.world.add(
        ParticleFactory.createExplosion(
          position: position,
          color: Colors.pink.shade200,
          particleCount: 50,
          speed: 120,
        ),
      );
    }
  }

  /// 페이즈 전환 완료
  void _completePhaseTransition() {
    _isTransitioning = false;

    if (_phase == LilianaPhase.love) {
      _phase = LilianaPhase.betrayal;
    } else if (_phase == LilianaPhase.betrayal) {
      _phase = LilianaPhase.forgiveness;
    }

    _state = LilianaState.float;
    AudioManager.instance.playSfx(SoundEffect.bossAppear);
  }

  /// AI 업데이트
  void _updateAI(double dt) {
    final player = _findPlayer();
    if (player == null) return;

    final distanceToPlayer = position.distanceTo(player.position);
    final directionToPlayer = (player.position - position).normalized();

    switch (_state) {
      case LilianaState.idle:
      case LilianaState.float:
        // 부드러운 추적
        if (distanceToPlayer > data.attackRange) {
          final speed = _getSpeedForPhase();
          position += directionToPlayer * speed * dt;
        }

        // 공격 선택
        _selectAttack(distanceToPlayer, player);

      case LilianaState.rosePetal:
        _executeRosePetal(dt, player);

      case LilianaState.embrace:
        _executeEmbrace(dt, player);

      case LilianaState.thornStorm:
        _executeThornStorm(dt, player);

      case LilianaState.bloodVine:
        _executeBloodVine(dt, player);

      case LilianaState.chaosAttack:
        _executeChaosAttack(dt, player);

      case LilianaState.cryAttack:
        _executeCryAttack(dt, player);

      default:
        break;
    }
  }

  /// 페이즈별 속도
  double _getSpeedForPhase() {
    switch (_phase) {
      case LilianaPhase.love:
        return data.speed * 0.8; // 우아하게
      case LilianaPhase.betrayal:
        return data.speed * 1.2; // 분노로 빠르게
      case LilianaPhase.forgiveness:
        return data.speed * 1.0; // 불규칙
    }
  }

  /// 공격 선택
  void _selectAttack(double distance, ArcanaPlayer player) {
    switch (_phase) {
      case LilianaPhase.love:
        // Phase 1: 아름다운 공격
        if (distance <= data.attackRange * 1.5 && _embraceCooldown <= 0) {
          _state = LilianaState.embrace;
          _embraceCooldown = embraceCooldownTime;
          _attackTimer = 0;
          return;
        }
        if (_roseCooldown <= 0) {
          _state = LilianaState.rosePetal;
          _roseCooldown = roseCooldownTime;
          _attackTimer = 0;
          return;
        }

      case LilianaPhase.betrayal:
        // Phase 2: 가시와 덩굴
        if (_vineCooldown <= 0 && _random.nextDouble() < 0.4) {
          _state = LilianaState.bloodVine;
          _vineCooldown = vineCooldownTime;
          _attackTimer = 0;
          return;
        }
        if (_thornCooldown <= 0) {
          _state = LilianaState.thornStorm;
          _thornCooldown = thornCooldownTime;
          _attackTimer = 0;
          return;
        }

      case LilianaPhase.forgiveness:
        // Phase 3: 불규칙 패턴
        if (_cryCooldown <= 0 && _random.nextDouble() < 0.5) {
          _state = LilianaState.cryAttack;
          _cryCooldown = cryCooldownTime;
          _attackTimer = 0;
          return;
        }
        if (_chaosCooldown <= 0) {
          _state = LilianaState.chaosAttack;
          _chaosCooldown = chaosCooldownTime;
          _attackTimer = 0;
          return;
        }
    }
  }

  /// 장미 꽃잎 공격 (Phase 1)
  void _executeRosePetal(double dt, ArcanaPlayer player) {
    _attackTimer += dt;

    if (_attackTimer >= 1.0) {
      // 분홍 꽃잎 퍼지기
      for (int i = 0; i < 8; i++) {
        final angle = i * (2 * pi / 8);
        final offset = Vector2(cos(angle), sin(angle)) * 30;

        gameRef.world.add(
          ParticleFactory.createExplosion(
            position: position + offset,
            color: Colors.pink.shade300,
            particleCount: 5,
            speed: 100,
          ),
        );
      }

      // 범위 데미지
      if (position.distanceTo(player.position) < 150) {
        player.takeDamage(data.attack * 0.7);
      }

      _state = LilianaState.float;
    }
  }

  /// 포옹 공격 (Phase 1)
  void _executeEmbrace(double dt, ArcanaPlayer player) {
    _attackTimer += dt;

    if (_attackTimer >= 0.8) {
      // 하트 이펙트
      gameRef.world.add(
        ParticleFactory.createExplosion(
          position: player.position,
          color: Colors.red.shade400,
          particleCount: 15,
          speed: 60,
        ),
      );

      // 근접 데미지
      if (position.distanceTo(player.position) < 100) {
        player.takeDamage(data.attack);
      }

      _state = LilianaState.float;
    }
  }

  /// 가시 폭풍 (Phase 2)
  void _executeThornStorm(double dt, ArcanaPlayer player) {
    _attackTimer += dt;

    if (_attackTimer >= 1.2) {
      // 가시 폭풍 이펙트
      gameRef.world.add(
        ParticleFactory.createExplosion(
          position: position,
          color: Colors.red.shade900,
          particleCount: 35,
          speed: 220,
        ),
      );

      // 광범위 데미지
      if (position.distanceTo(player.position) < 200) {
        player.takeDamage(data.attack * 1.3);
      }

      ScreenShakeManager.mediumShake();
      _state = LilianaState.float;
    }
  }

  /// 피의 덩굴 (Phase 2)
  void _executeBloodVine(double dt, ArcanaPlayer player) {
    _attackTimer += dt;

    if (_attackTimer >= 1.5) {
      // 덩굴이 플레이어 위치에서 솟아오름
      gameRef.world.add(
        ParticleFactory.createExplosion(
          position: player.position,
          color: Colors.red.shade800,
          particleCount: 25,
          speed: 150,
        ),
      );

      // 속박 + 데미지
      player.takeDamage(data.attack * 1.5);

      ScreenShakeManager.lightShake();
      _state = LilianaState.float;
    }
  }

  /// 혼란 공격 (Phase 3)
  void _executeChaosAttack(double dt, ArcanaPlayer player) {
    _attackTimer += dt;

    if (_attackTimer >= 0.6) {
      // 불규칙 방향으로 공격
      final randomAngle = _random.nextDouble() * 2 * pi;
      final randomDir = Vector2(cos(randomAngle), sin(randomAngle));

      gameRef.world.add(
        SlashEffect(
          position: position + randomDir * 50,
          direction: _vectorToDirection(randomDir),
          color: _random.nextBool() ? Colors.pink : Colors.red.shade900,
          effectSize: 60,
        ),
      );

      // 데미지
      if (position.distanceTo(player.position) < 100) {
        player.takeDamage(data.attack * 0.8);
      }

      _state = LilianaState.float;
    }
  }

  /// 울면서 공격 (Phase 3)
  void _executeCryAttack(double dt, ArcanaPlayer player) {
    _attackTimer += dt;

    if (_attackTimer >= 2.0) {
      // 눈물 폭발
      gameRef.world.add(
        ParticleFactory.createExplosion(
          position: position,
          color: Colors.white,
          particleCount: 40,
          speed: 180,
        ),
      );

      // 전체 범위 데미지 (낮음)
      player.takeDamage(data.attack * 0.5);

      ScreenShakeManager.heavyShake();
      _state = LilianaState.float;
    }
  }

  /// 플레이어 찾기
  ArcanaPlayer? _findPlayer() {
    try {
      return gameRef.world.children.whereType<ArcanaPlayer>().first;
    } catch (_) {
      return null;
    }
  }

  /// Vector2를 PlayerDirection으로 변환
  PlayerDirection _vectorToDirection(Vector2 direction) {
    if (direction.x.abs() > direction.y.abs()) {
      return direction.x > 0 ? PlayerDirection.right : PlayerDirection.left;
    } else {
      return direction.y > 0 ? PlayerDirection.down : PlayerDirection.up;
    }
  }

  @override
  void spawnDeathEffect() {
    _state = LilianaState.dead;
    onDefeat?.call();
    super.spawnDeathEffect();
  }

  @override
  void renderEnemy(Canvas canvas) {
    // 부유 오프셋 적용
    canvas.save();
    canvas.translate(0, _floatOffset);

    // 그림자
    _drawShadow(canvas);

    // 장미 오라
    _drawRoseAura(canvas);

    // 몸체
    _drawBody(canvas);

    // 상처 (가슴의 검 상처)
    _drawWound(canvas);

    // 눈물 (Phase 3에서)
    if (_phase == LilianaPhase.forgiveness) {
      _drawTears(canvas);
    }

    // 페이즈 전환 이펙트
    if (_isTransitioning) {
      _drawTransitionEffect(canvas);
    }

    // 보스 이름
    _drawBossName(canvas);

    canvas.restore();
  }

  /// 그림자 그리기
  void _drawShadow(Canvas canvas) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y - 5 - _floatOffset),
        width: 45,
        height: 15,
      ),
      shadowPaint,
    );
  }

  /// 장미 오라 그리기
  void _drawRoseAura(Canvas canvas) {
    final auraColor = switch (_phase) {
      LilianaPhase.love => Colors.pink.withValues(alpha: 0.2),
      LilianaPhase.betrayal => Colors.red.shade900.withValues(alpha: 0.3),
      LilianaPhase.forgiveness => Colors.white.withValues(alpha: 0.25),
    };

    final pulseSize = 8 + sin(_animTimer * 3) * 4;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y / 2),
        width: size.x + pulseSize * 2,
        height: size.y + pulseSize,
      ),
      Paint()..color = auraColor,
    );
  }

  /// 몸체 그리기
  void _drawBody(Canvas canvas) {
    // 드레스 색상
    final dressColor = switch (_phase) {
      LilianaPhase.love => const Color(0xFFFFB6C1), // 연분홍
      LilianaPhase.betrayal => const Color(0xFF8B0000), // 암적색
      LilianaPhase.forgiveness => const Color(0xFFE8E8E8), // 백색
    };

    // 드레스
    final dressPath = Path();
    dressPath.moveTo(size.x / 2 - 18, 35);
    dressPath.lineTo(size.x / 2 - 28, size.y - 8);
    dressPath.quadraticBezierTo(size.x / 2, size.y + 5, size.x / 2 + 28, size.y - 8);
    dressPath.lineTo(size.x / 2 + 18, 35);
    dressPath.close();

    canvas.drawPath(dressPath, Paint()..color = dressColor);

    // 머리카락
    final hairColor = _phase == LilianaPhase.betrayal
        ? Colors.red.shade900
        : const Color(0xFF8B4513);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, 25),
        width: 32,
        height: 38,
      ),
      Paint()..color = hairColor,
    );

    // 얼굴
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, 25),
        width: 25,
        height: 30,
      ),
      Paint()..color = const Color(0xFFFFE4C4), // 피부색
    );

    // 눈
    final eyeColor = _phase == LilianaPhase.betrayal ? Colors.red : Colors.brown;
    canvas.drawCircle(Offset(size.x / 2 - 5, 23), 3, Paint()..color = eyeColor);
    canvas.drawCircle(Offset(size.x / 2 + 5, 23), 3, Paint()..color = eyeColor);
  }

  /// 상처 그리기 (가슴의 검 상처에서 장미가 핌)
  void _drawWound(Canvas canvas) {
    // 상처
    canvas.drawLine(
      Offset(size.x / 2, 42),
      Offset(size.x / 2, 55),
      Paint()
        ..color = Colors.red.shade900
        ..strokeWidth = 3,
    );

    // 장미
    canvas.drawCircle(
      Offset(size.x / 2, 50),
      6 + sin(_animTimer * 4) * 1,
      Paint()..color = Colors.red,
    );
  }

  /// 눈물 그리기 (Phase 3)
  void _drawTears(Canvas canvas) {
    final tearPaint = Paint()..color = Colors.white.withValues(alpha: 0.8);

    // 왼쪽 눈물
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.x / 2 - 7,
          26 + sin(_tearTimer * 5) * 2,
          2,
          8 + sin(_tearTimer * 3) * 2,
        ),
        const Radius.circular(1),
      ),
      tearPaint,
    );

    // 오른쪽 눈물
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.x / 2 + 5,
          26 + sin(_tearTimer * 5 + 1) * 2,
          2,
          8 + sin(_tearTimer * 3 + 1) * 2,
        ),
        const Radius.circular(1),
      ),
      tearPaint,
    );
  }

  /// 페이즈 전환 이펙트
  void _drawTransitionEffect(Canvas canvas) {
    final progress = (_attackTimer / 2.0).clamp(0.0, 1.0);
    final radius = progress * 150;

    final color = _phase == LilianaPhase.love
        ? Colors.red
        : Colors.pink;

    final paint = Paint()
      ..color = color.withValues(alpha: 1.0 - progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      radius,
      paint,
    );
  }

  /// 보스 이름 그리기
  void _drawBossName(Canvas canvas) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '리리아나, 피어난 원한',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size.x - textPainter.width) / 2, -25),
    );
  }
}
