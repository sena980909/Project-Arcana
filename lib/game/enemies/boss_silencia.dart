/// Arcana: The Three Hearts - 보스: 마더 실렌시아
/// Chapter 3 보스 - 침묵의 성녀
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

/// 실렌시아 데이터
const silenciaData = EnemyData(
  type: EnemyType.boss,
  name: '마더 실렌시아',
  maxHealth: 1000,
  attack: 30,
  defense: 12,
  speed: 35,
  detectRange: 450,
  attackRange: 100,
  attackCooldown: 2.5,
  dropTable: [
    DropEntry(item: Items.silenciaTear, dropRate: 1.0),
    DropEntry(item: Items.largeHealthPotion, dropRate: 1.0, minQuantity: 3, maxQuantity: 4),
  ],
  expReward: 500,
  goldReward: 350,
);

/// 보스 페이즈
enum SilenciaPhase {
  mercy,     // Phase 1: 자비의 가면 (HP 100%~70%)
  judgment,  // Phase 2: 심판의 손 (HP 70%~35%)
  silence,   // Phase 3: 침묵의 진실 (HP 35%~0%)
}

/// 보스 상태
enum SilenciaState {
  idle,
  float,           // 떠다니기
  healingAura,     // 치유 오라 (실제로는 데미지)
  blessing,        // 축복의 손길 (속박)
  lightPillar,     // 빛의 기둥
  angelSummon,     // 천사 소환 이펙트
  judgment,        // 심판의 선언
  silentStrike,    // 침묵의 일격 (무음 공격)
  silentWave,      // 침묵의 파동 (광역)
  phaseTransition,
  dead,
}

/// 마더 실렌시아 - 침묵의 성녀
class BossSilencia extends BaseEnemy {
  BossSilencia({required super.position, this.onDefeat, this.onPhase3Start})
      : super(data: silenciaData) {
    size = Vector2(90, 120); // 날개 포함 큰 사이즈
  }

  /// 처치 콜백
  final VoidCallback? onDefeat;

  /// 페이즈 3 시작 콜백 (오디오 음소거용)
  final VoidCallback? onPhase3Start;

  /// 현재 페이즈
  SilenciaPhase _phase = SilenciaPhase.mercy;
  SilenciaPhase get phase => _phase;

  /// 페이즈 체크용 게터
  bool get isInJudgmentPhase => _phase == SilenciaPhase.judgment;
  bool get isInSilencePhase => _phase == SilenciaPhase.silence;

  /// 현재 상태
  SilenciaState _state = SilenciaState.float;

  /// 공격 타이머
  double _attackTimer = 0;

  /// 치유 오라 쿨다운
  double _healingCooldown = 0;
  static const double healingCooldownTime = 4.0;

  /// 축복 쿨다운
  double _blessingCooldown = 0;
  static const double blessingCooldownTime = 5.0;

  /// 빛의 기둥 쿨다운
  double _lightPillarCooldown = 0;
  static const double lightPillarCooldownTime = 6.0;

  /// 심판 쿨다운
  double _judgmentCooldown = 0;
  static const double judgmentCooldownTime = 8.0;

  /// 침묵 공격 쿨다운
  double _silentStrikeCooldown = 0;
  static const double silentStrikeCooldownTime = 3.0;

  /// 침묵 파동 쿨다운
  double _silentWaveCooldown = 0;
  static const double silentWaveCooldownTime = 7.0;

  /// 부유 높이
  double _floatOffset = 0;

  /// 애니메이션 타이머
  double _animTimer = 0;

  /// 페이즈 전환 중 여부
  bool _isTransitioning = false;

  /// 날개 펄럭임 타이머
  double _wingTimer = 0;

  /// 랜덤 생성기
  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _healingCooldown = 2.0; // 초기 딜레이
  }

  @override
  void update(double dt) {
    if (_state == SilenciaState.dead) return;

    _animTimer += dt;
    _wingTimer += dt;

    // 부유 효과
    _floatOffset = sin(_animTimer * 2) * 5;

    // 쿨다운 감소
    _healingCooldown = (_healingCooldown - dt).clamp(0.0, double.infinity);
    _blessingCooldown = (_blessingCooldown - dt).clamp(0.0, double.infinity);
    _lightPillarCooldown = (_lightPillarCooldown - dt).clamp(0.0, double.infinity);
    _judgmentCooldown = (_judgmentCooldown - dt).clamp(0.0, double.infinity);
    _silentStrikeCooldown = (_silentStrikeCooldown - dt).clamp(0.0, double.infinity);
    _silentWaveCooldown = (_silentWaveCooldown - dt).clamp(0.0, double.infinity);

    // 페이즈 전환 체크
    _checkPhaseTransition();

    // 페이즈 전환 중에는 다른 행동 안함
    if (_isTransitioning) {
      _attackTimer += dt;
      if (_attackTimer > 2.5) {
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
      if (_phase == SilenciaPhase.mercy && healthRatio <= 0.7) {
        _startPhaseTransition(SilenciaPhase.judgment);
      } else if (_phase == SilenciaPhase.judgment && healthRatio <= 0.35) {
        _startPhaseTransition(SilenciaPhase.silence);
      }
    }
  }

  /// 페이즈 전환 시작
  void _startPhaseTransition(SilenciaPhase newPhase) {
    _isTransitioning = true;
    _attackTimer = 0;
    _state = SilenciaState.phaseTransition;

    // 화면 효과
    ScreenShakeManager.heavyShake();

    // 페이즈별 효과
    if (newPhase == SilenciaPhase.judgment) {
      // 빛의 폭발
      gameRef.world.add(
        ParticleFactory.createExplosion(
          position: position,
          color: Colors.amber,
          particleCount: 40,
          speed: 200,
        ),
      );
    } else if (newPhase == SilenciaPhase.silence) {
      // 침묵의 파동 - 어두운 이펙트
      gameRef.world.add(
        ParticleFactory.createExplosion(
          position: position,
          color: Colors.grey.shade800,
          particleCount: 50,
          speed: 150,
        ),
      );
      // 페이즈 3 시작 콜백 (오디오 음소거)
      onPhase3Start?.call();
    }
  }

  /// 페이즈 전환 완료
  void _completePhaseTransition() {
    _isTransitioning = false;

    if (_phase == SilenciaPhase.mercy) {
      _phase = SilenciaPhase.judgment;
    } else if (_phase == SilenciaPhase.judgment) {
      _phase = SilenciaPhase.silence;
    }

    _state = SilenciaState.float;
    // 페이즈 3에서는 사운드 재생 안함
    if (_phase != SilenciaPhase.silence) {
      AudioManager.instance.playSfx(SoundEffect.bossAppear);
    }
  }

  /// AI 업데이트
  void _updateAI(double dt) {
    final player = _findPlayer();
    if (player == null) return;

    final distanceToPlayer = position.distanceTo(player.position);
    final directionToPlayer = (player.position - position).normalized();

    switch (_state) {
      case SilenciaState.idle:
      case SilenciaState.float:
        // 느린 추적 (성녀답게 우아하게)
        if (distanceToPlayer > data.attackRange) {
          final speed = _getSpeedForPhase();
          position += directionToPlayer * speed * dt;
        }

        // 공격 선택
        _selectAttack(distanceToPlayer, player);

      case SilenciaState.healingAura:
        _executeHealingAura(dt, player);

      case SilenciaState.blessing:
        _executeBlessing(dt, player);

      case SilenciaState.lightPillar:
        _executeLightPillar(dt, player);

      case SilenciaState.judgment:
        _executeJudgment(dt, player);

      case SilenciaState.silentStrike:
        _executeSilentStrike(dt, player);

      case SilenciaState.silentWave:
        _executeSilentWave(dt);

      default:
        break;
    }
  }

  /// 페이즈별 속도
  double _getSpeedForPhase() {
    switch (_phase) {
      case SilenciaPhase.mercy:
        return data.speed * 0.7; // 느리고 우아하게
      case SilenciaPhase.judgment:
        return data.speed * 1.0; // 보통 속도
      case SilenciaPhase.silence:
        return data.speed * 1.2; // 침묵 속에서 빠르게
    }
  }

  /// 공격 선택
  void _selectAttack(double distance, ArcanaPlayer player) {
    // 페이즈 3: 침묵 공격 우선
    if (_phase == SilenciaPhase.silence) {
      if (_silentWaveCooldown <= 0 && _random.nextDouble() < 0.4) {
        _state = SilenciaState.silentWave;
        _silentWaveCooldown = silentWaveCooldownTime;
        _attackTimer = 0;
        return;
      }

      if (_silentStrikeCooldown <= 0) {
        _state = SilenciaState.silentStrike;
        _silentStrikeCooldown = silentStrikeCooldownTime;
        _attackTimer = 0;
        return;
      }
    }

    // 페이즈 2+: 심판 공격
    if (_phase != SilenciaPhase.mercy && _judgmentCooldown <= 0 && distance < 200) {
      _state = SilenciaState.judgment;
      _judgmentCooldown = judgmentCooldownTime;
      _attackTimer = 0;
      return;
    }

    // 페이즈 2+: 빛의 기둥
    if (_phase != SilenciaPhase.mercy && _lightPillarCooldown <= 0) {
      _state = SilenciaState.lightPillar;
      _lightPillarCooldown = lightPillarCooldownTime;
      _attackTimer = 0;
      return;
    }

    // 페이즈 1: 치유 오라 (가짜 치유)
    if (_phase == SilenciaPhase.mercy && _healingCooldown <= 0) {
      _state = SilenciaState.healingAura;
      _healingCooldown = healingCooldownTime;
      _attackTimer = 0;
      return;
    }

    // 근거리: 축복 (속박)
    if (distance <= data.attackRange * 1.5 && _blessingCooldown <= 0) {
      _state = SilenciaState.blessing;
      _blessingCooldown = blessingCooldownTime;
      _attackTimer = 0;
      return;
    }
  }

  /// 치유 오라 실행 (실제로는 데미지)
  void _executeHealingAura(double dt, ArcanaPlayer player) {
    _attackTimer += dt;

    if (_attackTimer >= 1.5) {
      // 초록색 원형 이펙트 (치유처럼 보임)
      gameRef.world.add(
        ParticleFactory.createExplosion(
          position: position,
          color: Colors.green.shade300,
          particleCount: 20,
          speed: 100,
        ),
      );

      // 실제로는 데미지
      if (position.distanceTo(player.position) < 150) {
        player.takeDamage(data.attack * 0.8);
      }

      _state = SilenciaState.float;
    }
  }

  /// 축복 실행 (속박)
  void _executeBlessing(double dt, ArcanaPlayer player) {
    _attackTimer += dt;

    if (_attackTimer >= 0.8) {
      // 황금빛 속박 이펙트
      gameRef.world.add(
        ParticleFactory.createExplosion(
          position: player.position,
          color: Colors.amber,
          particleCount: 15,
          speed: 50,
        ),
      );

      // 데미지 + 짧은 속박 (속도 감소로 표현)
      if (position.distanceTo(player.position) < 120) {
        player.takeDamage(data.attack * 0.6);
        // 속박 효과는 플레이어 측에서 구현 필요
      }

      _state = SilenciaState.float;
    }
  }

  /// 빛의 기둥 실행
  void _executeLightPillar(double dt, ArcanaPlayer player) {
    _attackTimer += dt;

    if (_attackTimer >= 1.2) {
      // 플레이어 위치에 빛 기둥
      gameRef.world.add(
        ParticleFactory.createExplosion(
          position: player.position,
          color: Colors.white,
          particleCount: 30,
          speed: 250,
        ),
      );

      // 범위 데미지
      player.takeDamage(data.attack * 1.2);

      ScreenShakeManager.mediumShake();
      _state = SilenciaState.float;
    }
  }

  /// 심판 실행
  void _executeJudgment(double dt, ArcanaPlayer player) {
    _attackTimer += dt;

    if (_attackTimer >= 2.0) {
      // 거대한 빛의 폭발
      gameRef.world.add(
        ParticleFactory.createExplosion(
          position: position,
          color: Colors.amber,
          particleCount: 50,
          speed: 300,
        ),
      );

      // 광범위 데미지
      if (position.distanceTo(player.position) < 250) {
        player.takeDamage(data.attack * 1.5);
      }

      ScreenShakeManager.heavyShake();
      _state = SilenciaState.float;
    }
  }

  /// 침묵의 일격 (무음 공격)
  void _executeSilentStrike(double dt, ArcanaPlayer player) {
    _attackTimer += dt;

    if (_attackTimer >= 0.5) {
      final direction = (player.position - position).normalized();

      // 회색 슬래시 (소리 없이)
      gameRef.world.add(
        SlashEffect(
          position: position + direction * 60,
          direction: _vectorToDirection(direction),
          color: Colors.grey.shade700,
          effectSize: 80,
        ),
      );

      // 데미지 (강력함)
      if (position.distanceTo(player.position) < 100) {
        player.takeDamage(data.attack * 1.3);
      }

      // 페이즈 3에서는 사운드 재생 안함

      _state = SilenciaState.float;
    }
  }

  /// 침묵의 파동 (광역)
  void _executeSilentWave(double dt) {
    _attackTimer += dt;

    if (_attackTimer >= 1.5) {
      // 어두운 파동
      gameRef.world.add(
        ParticleFactory.createExplosion(
          position: position,
          color: Colors.black54,
          particleCount: 40,
          speed: 200,
        ),
      );

      // 전체 데미지
      final player = _findPlayer();
      if (player != null) {
        player.takeDamage(data.attack * 0.7);
      }

      ScreenShakeManager.mediumShake();
      _state = SilenciaState.float;
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
    _state = SilenciaState.dead;
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

    // 오라/후광
    _drawAura(canvas);

    // 날개
    _drawWings(canvas);

    // 몸체
    _drawBody(canvas);

    // 가면
    _drawMask(canvas);

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
        width: 50,
        height: 15,
      ),
      shadowPaint,
    );
  }

  /// 오라/후광 그리기
  void _drawAura(Canvas canvas) {
    final auraColor = switch (_phase) {
      SilenciaPhase.mercy => Colors.green.withValues(alpha: 0.2),
      SilenciaPhase.judgment => Colors.amber.withValues(alpha: 0.3),
      SilenciaPhase.silence => Colors.grey.withValues(alpha: 0.4),
    };

    final pulseSize = 10 + sin(_animTimer * 3) * 5;

    // 원형 후광
    canvas.drawCircle(
      Offset(size.x / 2, 35),
      30 + pulseSize,
      Paint()..color = auraColor,
    );
  }

  /// 날개 그리기 (6개, 부러진)
  void _drawWings(Canvas canvas) {
    final wingColor = _phase == SilenciaPhase.silence
        ? Colors.grey.shade600
        : Colors.white.withValues(alpha: 0.8);

    final wingPaint = Paint()
      ..color = wingColor
      ..style = PaintingStyle.fill;

    final wingFlap = sin(_wingTimer * 4) * 5;

    // 왼쪽 날개 3개
    for (int i = 0; i < 3; i++) {
      final yOffset = 20.0 + i * 15.0;
      final xOffset = -25.0 - i * 5.0;
      final brokenAngle = _phase == SilenciaPhase.silence ? 0.3 : 0.1;

      canvas.save();
      canvas.translate(size.x / 2 + xOffset, yOffset);
      canvas.rotate(-0.3 - brokenAngle * i + wingFlap * 0.02);

      // 깃털 형태
      final path = Path();
      path.moveTo(0, 0);
      path.quadraticBezierTo(-30, -10, -40 + i * 5, 5);
      path.quadraticBezierTo(-30, 10, 0, 5);
      path.close();

      canvas.drawPath(path, wingPaint);
      canvas.restore();
    }

    // 오른쪽 날개 3개
    for (int i = 0; i < 3; i++) {
      final yOffset = 20.0 + i * 15.0;
      final xOffset = 25.0 + i * 5.0;
      final brokenAngle = _phase == SilenciaPhase.silence ? 0.3 : 0.1;

      canvas.save();
      canvas.translate(size.x / 2 + xOffset, yOffset);
      canvas.rotate(0.3 + brokenAngle * i - wingFlap * 0.02);

      final path = Path();
      path.moveTo(0, 0);
      path.quadraticBezierTo(30, -10, 40 - i * 5, 5);
      path.quadraticBezierTo(30, 10, 0, 5);
      path.close();

      canvas.drawPath(path, wingPaint);
      canvas.restore();
    }
  }

  /// 몸체 그리기
  void _drawBody(Canvas canvas) {
    // 로브 색상
    final robeColor = switch (_phase) {
      SilenciaPhase.mercy => const Color(0xFFE8E8E8),
      SilenciaPhase.judgment => const Color(0xFFFFD700),
      SilenciaPhase.silence => const Color(0xFF4A4A4A),
    };

    final robePaint = Paint()
      ..color = robeColor
      ..style = PaintingStyle.fill;

    // 로브 몸체
    final robePath = Path();
    robePath.moveTo(size.x / 2 - 20, 40);
    robePath.lineTo(size.x / 2 - 30, size.y - 10);
    robePath.quadraticBezierTo(size.x / 2, size.y, size.x / 2 + 30, size.y - 10);
    robePath.lineTo(size.x / 2 + 20, 40);
    robePath.close();

    canvas.drawPath(robePath, robePaint);

    // 얼굴 (왼쪽 절반)
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.x / 2, 30),
        width: 30,
        height: 35,
      ),
      pi / 2,
      pi,
      true,
      Paint()..color = const Color(0xFFE0C8A8), // 피부색
    );
  }

  /// 황금 가면 그리기
  void _drawMask(Canvas canvas) {
    final maskPaint = Paint()
      ..color = Colors.amber.shade600
      ..style = PaintingStyle.fill;

    // 오른쪽 절반 가면
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.x / 2, 30),
        width: 30,
        height: 35,
      ),
      -pi / 2,
      pi,
      true,
      maskPaint,
    );

    // 가면 장식 (눈 슬릿)
    canvas.drawLine(
      Offset(size.x / 2 + 5, 25),
      Offset(size.x / 2 + 12, 25),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2,
    );

    // 페이즈 3: 금이 가는 효과
    if (_phase == SilenciaPhase.silence) {
      final crackPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(size.x / 2 + 3, 20),
        Offset(size.x / 2 + 10, 35),
        crackPaint,
      );
      canvas.drawLine(
        Offset(size.x / 2 + 8, 28),
        Offset(size.x / 2 + 15, 30),
        crackPaint,
      );
    }
  }

  /// 페이즈 전환 이펙트
  void _drawTransitionEffect(Canvas canvas) {
    final progress = (_attackTimer / 2.5).clamp(0.0, 1.0);
    final radius = progress * 180;

    final color = _phase == SilenciaPhase.mercy
        ? Colors.amber
        : Colors.grey;

    final paint = Paint()
      ..color = color.withValues(alpha: 1.0 - progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

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
        text: '마더 실렌시아, 침묵의 성녀',
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
      Offset((size.x - textPainter.width) / 2, -30),
    );
  }
}
