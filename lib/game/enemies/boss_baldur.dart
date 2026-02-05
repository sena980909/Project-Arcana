/// Arcana: The Three Hearts - 보스: 발두르
/// Chapter 2 보스 - 몰락한 왕
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

/// 발두르 데이터
const baldurData = EnemyData(
  type: EnemyType.boss,
  name: '발두르',
  maxHealth: 800,
  attack: 25,
  defense: 10,
  speed: 40,
  detectRange: 400,
  attackRange: 80,
  attackCooldown: 2.0,
  dropTable: [
    DropEntry(item: Items.baldurTear, dropRate: 1.0),
    DropEntry(item: Items.largeHealthPotion, dropRate: 1.0, minQuantity: 2, maxQuantity: 3),
  ],
  expReward: 400,
  goldReward: 250,
);

/// 보스 페이즈
enum BaldurPhase {
  dignity,  // Phase 1: 왕의 위엄 (HP 100%~60%)
  madness,  // Phase 2: 광기의 폭군 (HP 60%~30%)
  despair,  // Phase 3: 텅 빈 껍데기 (HP 30%~0%)
}

/// 보스 상태
enum BaldurState {
  idle,
  chase,
  slashCombo,    // 검 휘두르기 콤보
  decree,        // 왕의 칙령 (범위 공격)
  shadowClone,   // 분신 소환
  wail,          // 울부짖음 (전체 공격)
  selfHarm,      // 자해 폭발
  phaseTransition,
  dead,
}

/// 발두르 - 몰락한 왕
class BossBaldur extends BaseEnemy {
  BossBaldur({required super.position, this.onDefeat})
      : super(data: baldurData) {
    size = Vector2(80, 100); // 갑옷 입은 왕
  }

  /// 처치 콜백
  final VoidCallback? onDefeat;

  /// 현재 페이즈
  BaldurPhase _phase = BaldurPhase.dignity;
  BaldurPhase get phase => _phase;

  /// 페이즈 체크용 게터
  bool get isInMadnessPhase => _phase == BaldurPhase.madness;
  bool get isInDespairPhase => _phase == BaldurPhase.despair;

  /// 현재 상태
  BaldurState _state = BaldurState.idle;

  /// 공격 타이머
  double _attackTimer = 0;

  /// 슬래시 콤보 쿨다운
  double _slashCooldown = 0;
  static const double slashCooldownTime = 2.5;

  /// 칙령 쿨다운
  double _decreeCooldown = 0;
  static const double decreeCooldownTime = 5.0;

  /// 분신 쿨다운
  double _cloneCooldown = 0;
  static const double cloneCooldownTime = 8.0;

  /// 울부짖음 쿨다운
  double _wailCooldown = 0;
  static const double wailCooldownTime = 10.0;

  /// 자해 쿨다운
  double _selfHarmCooldown = 0;
  static const double selfHarmCooldownTime = 6.0;

  /// 슬래시 콤보 카운트
  int _slashCount = 0;

  /// 애니메이션 타이머
  double _animTimer = 0;

  /// 페이즈 전환 중 여부
  bool _isTransitioning = false;

  /// 랜덤 생성기
  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _decreeCooldown = 3.0; // 초기 딜레이
  }

  @override
  void update(double dt) {
    if (_state == BaldurState.dead) return;

    _animTimer += dt;

    // 쿨다운 감소
    _slashCooldown = (_slashCooldown - dt).clamp(0.0, double.infinity);
    _decreeCooldown = (_decreeCooldown - dt).clamp(0.0, double.infinity);
    _cloneCooldown = (_cloneCooldown - dt).clamp(0.0, double.infinity);
    _wailCooldown = (_wailCooldown - dt).clamp(0.0, double.infinity);
    _selfHarmCooldown = (_selfHarmCooldown - dt).clamp(0.0, double.infinity);

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
      if (_phase == BaldurPhase.dignity && healthRatio <= 0.6) {
        _startPhaseTransition(BaldurPhase.madness);
      } else if (_phase == BaldurPhase.madness && healthRatio <= 0.3) {
        _startPhaseTransition(BaldurPhase.despair);
      }
    }
  }

  /// 페이즈 전환 시작
  void _startPhaseTransition(BaldurPhase newPhase) {
    _isTransitioning = true;
    _attackTimer = 0;
    _state = BaldurState.phaseTransition;

    // 화면 효과
    ScreenShakeManager.heavyShake();

    // 페이즈별 효과
    if (newPhase == BaldurPhase.madness) {
      // 분노 폭발 이펙트
      gameRef.world.add(
        ParticleFactory.createExplosion(
          position: position,
          color: Colors.red,
          particleCount: 30,
          speed: 150,
        ),
      );
    } else if (newPhase == BaldurPhase.despair) {
      // 절망 이펙트
      gameRef.world.add(
        ParticleFactory.createExplosion(
          position: position,
          color: Colors.purple,
          particleCount: 40,
          speed: 100,
        ),
      );
    }
  }

  /// 페이즈 전환 완료
  void _completePhaseTransition() {
    _isTransitioning = false;

    if (_phase == BaldurPhase.dignity) {
      _phase = BaldurPhase.madness;
    } else if (_phase == BaldurPhase.madness) {
      _phase = BaldurPhase.despair;
    }

    _state = BaldurState.chase;
    AudioManager.instance.playSfx(SoundEffect.bossAppear);
  }

  /// AI 업데이트
  void _updateAI(double dt) {
    final player = _findPlayer();
    if (player == null) return;

    final distanceToPlayer = position.distanceTo(player.position);
    final directionToPlayer = (player.position - position).normalized();

    switch (_state) {
      case BaldurState.idle:
      case BaldurState.chase:
        // 플레이어 추적
        if (distanceToPlayer > data.attackRange) {
          final speed = _getSpeedForPhase();
          position += directionToPlayer * speed * dt;
        }

        // 공격 선택
        _selectAttack(distanceToPlayer, player);

      case BaldurState.slashCombo:
        _executeSlashCombo(dt, player);

      case BaldurState.decree:
        _executeDecree(dt, player);

      case BaldurState.shadowClone:
        _executeShadowClone(dt);

      case BaldurState.wail:
        _executeWail(dt);

      case BaldurState.selfHarm:
        _executeSelfHarm(dt);

      default:
        break;
    }
  }

  /// 페이즈별 속도
  double _getSpeedForPhase() {
    switch (_phase) {
      case BaldurPhase.dignity:
        return data.speed * 0.8; // 느리지만 위엄있게
      case BaldurPhase.madness:
        return data.speed * 1.3; // 빠르고 난폭하게
      case BaldurPhase.despair:
        return data.speed * 1.0; // 느려지지만 불안정
    }
  }

  /// 공격 선택
  void _selectAttack(double distance, ArcanaPlayer player) {
    // 페이즈 3: 자해 우선
    if (_phase == BaldurPhase.despair && _selfHarmCooldown <= 0 && _random.nextDouble() < 0.3) {
      _state = BaldurState.selfHarm;
      _selfHarmCooldown = selfHarmCooldownTime;
      _attackTimer = 0;
      return;
    }

    // 페이즈 3: 울부짖음
    if (_phase == BaldurPhase.despair && _wailCooldown <= 0) {
      _state = BaldurState.wail;
      _wailCooldown = wailCooldownTime;
      _attackTimer = 0;
      return;
    }

    // 페이즈 2+: 분신 소환
    if (_phase != BaldurPhase.dignity && _cloneCooldown <= 0) {
      _state = BaldurState.shadowClone;
      _cloneCooldown = cloneCooldownTime;
      _attackTimer = 0;
      return;
    }

    // 원거리: 칙령 사용
    if (distance > 150 && _decreeCooldown <= 0) {
      _state = BaldurState.decree;
      _decreeCooldown = decreeCooldownTime;
      _attackTimer = 0;
      return;
    }

    // 근거리: 슬래시 콤보
    if (distance <= data.attackRange && _slashCooldown <= 0) {
      _state = BaldurState.slashCombo;
      _slashCooldown = slashCooldownTime;
      _attackTimer = 0;
      _slashCount = 0;
      return;
    }
  }

  /// 슬래시 콤보 실행
  void _executeSlashCombo(double dt, ArcanaPlayer player) {
    _attackTimer += dt;

    final comboCount = _phase == BaldurPhase.dignity ? 2 : 4;
    final comboInterval = _phase == BaldurPhase.dignity ? 0.5 : 0.3;

    if (_attackTimer >= comboInterval && _slashCount < comboCount) {
      _attackTimer = 0;
      _slashCount++;

      // 슬래시 이펙트
      final direction = (player.position - position).normalized();
      gameRef.world.add(
        SlashEffect(
          position: position + direction * 50,
          direction: _vectorToDirection(direction),
          color: _phase == BaldurPhase.dignity ? Colors.amber : Colors.red,
          effectSize: 70,
        ),
      );

      // 데미지
      if (position.distanceTo(player.position) < 80) {
        final damage = _phase == BaldurPhase.madness ? data.attack * 1.3 : data.attack;
        player.takeDamage(damage);
      }

      AudioManager.instance.playSfx(SoundEffect.playerAttack);
    }

    if (_slashCount >= comboCount) {
      _state = BaldurState.chase;
    }
  }

  /// 왕의 칙령 실행 (범위 공격)
  void _executeDecree(double dt, ArcanaPlayer player) {
    _attackTimer += dt;

    if (_attackTimer >= 1.0) {
      // 원형 범위 공격
      gameRef.world.add(
        ParticleFactory.createExplosion(
          position: position,
          color: Colors.amber,
          particleCount: 25,
          speed: 200,
        ),
      );

      // 범위 내 플레이어에게 데미지
      if (position.distanceTo(player.position) < 180) {
        player.takeDamage(data.attack * 1.5);
      }

      ScreenShakeManager.mediumShake();
      _state = BaldurState.chase;
    }
  }

  /// 분신 소환 실행
  void _executeShadowClone(double dt) {
    _attackTimer += dt;

    if (_attackTimer >= 0.5) {
      // 분신 이펙트 (실제 분신은 구현 복잡도로 이펙트만)
      for (int i = 0; i < 3; i++) {
        final angle = i * (2 * pi / 3);
        final offset = Vector2(cos(angle), sin(angle)) * 60;

        gameRef.world.add(
          ParticleFactory.createExplosion(
            position: position + offset,
            color: Colors.purple.withValues(alpha: 0.5),
            particleCount: 10,
            speed: 50,
          ),
        );
      }

      _state = BaldurState.chase;
    }
  }

  /// 울부짖음 실행 (전체 화면 공격)
  void _executeWail(double dt) {
    _attackTimer += dt;

    if (_attackTimer >= 1.5) {
      // 화면 전체 흔들림
      ScreenShakeManager.heavyShake();

      // 전체 범위 데미지 (회피 불가)
      final player = _findPlayer();
      if (player != null) {
        player.takeDamage(data.attack * 0.5);
      }

      // 절망 이펙트
      gameRef.world.add(
        ParticleFactory.createExplosion(
          position: position,
          color: Colors.black,
          particleCount: 50,
          speed: 300,
        ),
      );

      _state = BaldurState.chase;
    }
  }

  /// 자해 폭발 실행
  void _executeSelfHarm(double dt) {
    _attackTimer += dt;

    if (_attackTimer >= 1.0) {
      // 자해 (자신도 데미지)
      health -= data.maxHealth * 0.05;

      // 폭발 공격
      final player = _findPlayer();
      if (player != null && position.distanceTo(player.position) < 150) {
        player.takeDamage(data.attack * 2.0);
      }

      // 피 이펙트
      gameRef.world.add(
        ParticleFactory.createExplosion(
          position: position,
          color: Colors.red.shade900,
          particleCount: 30,
          speed: 120,
        ),
      );

      ScreenShakeManager.heavyShake();
      _state = BaldurState.chase;
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
    _state = BaldurState.dead;
    onDefeat?.call();
    super.spawnDeathEffect();
  }

  @override
  void renderEnemy(Canvas canvas) {
    // 흔들림 효과 (페이즈 3에서 더 강하게)
    final shake = _phase == BaldurPhase.despair
        ? sin(_animTimer * 8) * 3
        : sin(_animTimer * 2) * 1;

    // 그림자
    _drawShadow(canvas);

    // 몸체
    _drawBody(canvas, shake);

    // 왕관
    _drawCrown(canvas, shake);

    // 검은 눈물
    _drawBlackTears(canvas, shake);

    // 페이즈 전환 이펙트
    if (_isTransitioning) {
      _drawTransitionEffect(canvas);
    }

    // 페이즈별 오라
    _drawPhaseAura(canvas);

    // 보스 이름
    _drawBossName(canvas);
  }

  /// 그림자 그리기
  void _drawShadow(Canvas canvas) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y - 8),
        width: 60,
        height: 20,
      ),
      shadowPaint,
    );
  }

  /// 몸체 그리기
  void _drawBody(Canvas canvas, double shake) {
    // 페이즈별 색상
    final bodyColor = switch (_phase) {
      BaldurPhase.dignity => const Color(0xFF4A4A4A), // 회색 갑옷
      BaldurPhase.madness => const Color(0xFF8B0000), // 핏빛
      BaldurPhase.despair => const Color(0xFF2F2F2F), // 어두운 회색
    };

    final bodyPaint = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.fill;

    // 갑옷 몸체
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.x / 2 - 25 + shake, 30, 50, 55),
      const Radius.circular(5),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // 어깨 갑옷
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2 - 30 + shake, 40),
        width: 25,
        height: 20,
      ),
      bodyPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2 + 30 + shake, 40),
        width: 25,
        height: 20,
      ),
      bodyPaint,
    );

    // 머리 (부패한)
    final headColor = _phase == BaldurPhase.despair
        ? const Color(0xFF3D3D3D)
        : const Color(0xFF5D5D5D);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2 + shake, 22),
        width: 35,
        height: 40,
      ),
      Paint()..color = headColor,
    );

    // 눈 (검은 눈물이 흐르는)
    final eyePaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(size.x / 2 - 8 + shake, 20), 4, eyePaint);
    canvas.drawCircle(Offset(size.x / 2 + 8 + shake, 20), 4, eyePaint);
  }

  /// 왕관 그리기
  void _drawCrown(Canvas canvas, double shake) {
    final crownColor = _phase == BaldurPhase.dignity
        ? Colors.amber
        : Colors.amber.shade800;

    final crownPaint = Paint()
      ..color = crownColor
      ..style = PaintingStyle.fill;

    // 왕관 (살점에 박힌)
    final crownPath = Path();
    crownPath.moveTo(size.x / 2 - 15 + shake, 8);
    crownPath.lineTo(size.x / 2 - 12 + shake, 0);
    crownPath.lineTo(size.x / 2 - 5 + shake, 6);
    crownPath.lineTo(size.x / 2 + shake, -2);
    crownPath.lineTo(size.x / 2 + 5 + shake, 6);
    crownPath.lineTo(size.x / 2 + 12 + shake, 0);
    crownPath.lineTo(size.x / 2 + 15 + shake, 8);
    crownPath.close();

    canvas.drawPath(crownPath, crownPaint);

    // 보석
    canvas.drawCircle(
      Offset(size.x / 2 + shake, 4),
      3,
      Paint()..color = Colors.red,
    );
  }

  /// 검은 눈물 그리기
  void _drawBlackTears(Canvas canvas, double shake) {
    final tearPaint = Paint()..color = Colors.black;

    // 왼쪽 눈물
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.x / 2 - 10 + shake,
          22 + sin(_animTimer * 3) * 2,
          3,
          10 + sin(_animTimer * 2) * 3,
        ),
        const Radius.circular(1),
      ),
      tearPaint,
    );

    // 오른쪽 눈물
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.x / 2 + 7 + shake,
          22 + sin(_animTimer * 3 + 1) * 2,
          3,
          10 + sin(_animTimer * 2 + 1) * 3,
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

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 1.0 - progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      radius,
      paint,
    );
  }

  /// 페이즈별 오라
  void _drawPhaseAura(Canvas canvas) {
    if (_phase == BaldurPhase.dignity) return;

    final auraColor = _phase == BaldurPhase.madness
        ? Colors.red.withValues(alpha: 0.2)
        : Colors.purple.withValues(alpha: 0.3);

    final auraPaint = Paint()
      ..color = auraColor
      ..style = PaintingStyle.fill;

    final pulseSize = 5 + sin(_animTimer * 4) * 3;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y / 2),
        width: size.x + pulseSize * 2,
        height: size.y + pulseSize * 2,
      ),
      auraPaint,
    );
  }

  /// 보스 이름 그리기
  void _drawBossName(Canvas canvas) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '발두르, 몰락한 왕',
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
