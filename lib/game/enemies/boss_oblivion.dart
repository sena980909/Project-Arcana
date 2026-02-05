/// Arcana: The Three Hearts - 최종 보스: 망각의 화신
/// Chapter 6 보스 - 망각의 옥좌
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

/// 망각의 화신 데이터
const oblivionData = EnemyData(
  type: EnemyType.boss,
  name: '망각의 화신',
  maxHealth: 1500,
  attack: 40,
  defense: 15,
  speed: 30,
  detectRange: 600,
  attackRange: 150,
  attackCooldown: 2.5,
  dropTable: [
    DropEntry(item: Items.oblivionTear, dropRate: 1.0),
    DropEntry(item: Items.arcanaThroneOfOblivion, dropRate: 1.0),
  ],
  expReward: 1000,
  goldReward: 500,
);

/// 망각의 화신 페이즈
enum OblivionPhase {
  pastOblivion,    // Phase 1: 과거의 망각 (HP 100%~70%)
  presentOblivion, // Phase 2: 현재의 망각 (HP 70%~40%)
  futureOblivion,  // Phase 3: 미래의 망각 (HP 40%~10%)
  finalBargain,    // Phase 4: 최후의 거래 (HP 10%~0%)
}

/// 망각의 화신 상태
enum OblivionState {
  idle,
  float,
  memoryErase,    // 기억 지우기 (Phase 1)
  existenceErase, // 존재 지우기 (Phase 2)
  futureErase,    // 미래 지우기 (Phase 3)
  voidAttack,     // 공허 공격
  summonFaces,    // 잊혀진 얼굴들 소환
  phaseTransition,
  bargaining,     // Phase 4: 거래 중
  defeated,
}

/// 최종 보스: 망각의 화신
class BossOblivion extends BaseEnemy {
  BossOblivion({
    required super.position,
    this.onPhase2Start,
    this.onPhase3Start,
    this.onPhase4Start,
    this.onThirdHeartTrigger,
  }) : super(data: oblivionData) {
    size = Vector2(120, 120);
  }

  /// Phase 2 시작 콜백
  final VoidCallback? onPhase2Start;

  /// Phase 3 시작 콜백
  final VoidCallback? onPhase3Start;

  /// Phase 4 시작 콜백 (최후의 거래)
  final VoidCallback? onPhase4Start;

  /// 세 번째 심장 트리거 콜백
  final VoidCallback? onThirdHeartTrigger;

  /// 현재 페이즈
  OblivionPhase _phase = OblivionPhase.pastOblivion;
  OblivionPhase get phase => _phase;

  /// 페이즈 체크용 게터
  bool get isInPresentPhase => _phase == OblivionPhase.presentOblivion;
  bool get isInFuturePhase => _phase == OblivionPhase.futureOblivion;
  bool get isInBargainPhase => _phase == OblivionPhase.finalBargain;

  /// 현재 상태
  OblivionState _state = OblivionState.float;

  /// 공격 타이머
  double _attackTimer = 0;

  /// 패턴 카운터
  int _patternCount = 0;

  /// 쿨다운들
  double _memoryCooldown = 0;
  double _existenceCooldown = 0;
  double _futureCooldown = 0;
  double _voidCooldown = 0;

  /// 시각 효과
  double _pulseTimer = 0;
  double _voidRadius = 80;
  final List<_ForgottenFace> _faces = [];
  double _faceSpawnTimer = 0;

  /// 페이즈 전환 중
  bool _isTransitioning = false;

  /// 세 번째 심장 트리거 완료 여부
  bool _thirdHeartTriggered = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _state = OblivionState.float;
  }

  @override
  void update(double dt) {
    // Phase 4에서는 전투 중지
    if (_state == OblivionState.bargaining || _state == OblivionState.defeated) {
      _updateVisuals(dt);
      return;
    }

    // 페이즈 업데이트
    _updatePhase();

    // 시각 효과 업데이트
    _updateVisuals(dt);

    // 얼굴들 업데이트
    _updateFaces(dt);

    // 쿨다운 감소
    _memoryCooldown = (_memoryCooldown - dt).clamp(0.0, double.infinity);
    _existenceCooldown = (_existenceCooldown - dt).clamp(0.0, double.infinity);
    _futureCooldown = (_futureCooldown - dt).clamp(0.0, double.infinity);
    _voidCooldown = (_voidCooldown - dt).clamp(0.0, double.infinity);
    _attackTimer += dt;

    // 페이즈 전환 중
    if (_isTransitioning) {
      if (_attackTimer > 2.5) {
        _completePhaseTransition();
      }
      return;
    }

    // 세 번째 심장 트리거 체크 (Phase 3에서 HP 20% 이하)
    if (_phase == OblivionPhase.futureOblivion &&
        !_thirdHeartTriggered &&
        health <= data.maxHealth * 0.20) {
      _thirdHeartTriggered = true;
      onThirdHeartTrigger?.call();
    }

    // AI 로직
    _updateAI(dt);

    super.update(dt);
  }

  void _updatePhase() {
    final hpPercent = health / data.maxHealth;

    if (!_isTransitioning) {
      if (_phase == OblivionPhase.pastOblivion && hpPercent <= 0.70) {
        _startPhaseTransition(OblivionPhase.presentOblivion);
        onPhase2Start?.call();
      } else if (_phase == OblivionPhase.presentOblivion && hpPercent <= 0.40) {
        _startPhaseTransition(OblivionPhase.futureOblivion);
        onPhase3Start?.call();
      } else if (_phase == OblivionPhase.futureOblivion && hpPercent <= 0.10) {
        _startPhaseTransition(OblivionPhase.finalBargain);
        onPhase4Start?.call();
      }
    }
  }

  void _startPhaseTransition(OblivionPhase newPhase) {
    _isTransitioning = true;
    _attackTimer = 0;
    _state = OblivionState.phaseTransition;

    // 화면 효과
    ScreenShakeManager.heavyShake();

    // 페이즈별 효과
    gameRef.world.add(
      ParticleFactory.createExplosion(
        position: position,
        color: Colors.purple.shade900,
        particleCount: 50,
        speed: 200,
      ),
    );

    _phase = newPhase;
  }

  void _completePhaseTransition() {
    _isTransitioning = false;
    _attackTimer = 0;

    if (_phase == OblivionPhase.finalBargain) {
      _state = OblivionState.bargaining;
    } else {
      _state = OblivionState.float;
    }
  }

  void _updateVisuals(double dt) {
    _pulseTimer += dt;

    // 공허 반경 맥동
    _voidRadius = 80 + sin(_pulseTimer * 2) * 20;

    // 얼굴 스폰
    _faceSpawnTimer += dt;
    if (_faceSpawnTimer >= 0.5) {
      _faceSpawnTimer = 0;
      _spawnFace();
    }
  }

  void _spawnFace() {
    if (_faces.length >= 8) return;

    final angle = Random().nextDouble() * pi * 2;
    final distance = 60 + Random().nextDouble() * 40;

    _faces.add(_ForgottenFace(
      angle: angle,
      distance: distance,
      speed: 0.5 + Random().nextDouble() * 0.5,
      fadeSpeed: 0.3 + Random().nextDouble() * 0.2,
    ));
  }

  void _updateFaces(double dt) {
    for (final face in _faces.toList()) {
      face.angle += face.speed * dt;
      face.life -= face.fadeSpeed * dt;

      if (face.life <= 0) {
        _faces.remove(face);
      }
    }
  }

  void _updateAI(double dt) {
    final player = _findPlayer();
    if (player == null) return;

    // 페이즈별 공격
    switch (_phase) {
      case OblivionPhase.pastOblivion:
        _executePastPhase(dt, player);
      case OblivionPhase.presentOblivion:
        _executePresentPhase(dt, player);
      case OblivionPhase.futureOblivion:
        _executeFuturePhase(dt, player);
      case OblivionPhase.finalBargain:
        // 전투 중지
        break;
    }
  }

  /// Phase 1: 과거의 망각
  void _executePastPhase(double dt, ArcanaPlayer player) {
    if (_attackTimer < 2.5) return;

    _patternCount = (_patternCount + 1) % 3;

    switch (_patternCount) {
      case 0:
        if (_memoryCooldown <= 0) {
          _executeMemoryErase(player);
          _memoryCooldown = 4.0;
        }
      case 1:
        _executeVoidWave();
      case 2:
        _executeSummonFaces(player);
    }

    _attackTimer = 0;
  }

  void _executeMemoryErase(ArcanaPlayer player) {
    _state = OblivionState.memoryErase;

    // 기억 지우기 - 디버프 구체 발사
    for (var i = 0; i < 5; i++) {
      final angle = Random().nextDouble() * pi * 2;
      final direction = Vector2(cos(angle), sin(angle));

      Future.delayed(Duration(milliseconds: i * 100), () {
        if (!isMounted) return;
        final orb = _MemoryOrb(
          direction: direction,
          damage: (data.attack * 0.3).toInt(),
        );
        orb.position = position.clone();
        parent?.add(orb);
      });
    }

    AudioManager.instance.playSfx(SoundEffect.bossAppear);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (isMounted) _state = OblivionState.float;
    });
  }

  void _executeVoidWave() {
    // 공허 파동
    for (var i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      final direction = Vector2(cos(angle), sin(angle));

      final wave = _VoidWave(
        direction: direction,
        damage: (data.attack * 0.4).toInt(),
      );
      wave.position = position.clone();
      parent?.add(wave);
    }
  }

  void _executeSummonFaces(ArcanaPlayer player) {
    // 잊혀진 얼굴들 공격
    for (var i = 0; i < 4; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (!isMounted) return;

        final offset = Vector2(
          (Random().nextDouble() - 0.5) * 150,
          (Random().nextDouble() - 0.5) * 150,
        );

        final attack = _FaceAttack(
          targetPos: player.position + offset,
          damage: (data.attack * 0.35).toInt(),
        );
        parent?.add(attack);
      });
    }
  }

  /// Phase 2: 현재의 망각
  void _executePresentPhase(double dt, ArcanaPlayer player) {
    if (_attackTimer < 2.0) return;

    _patternCount = (_patternCount + 1) % 4;

    switch (_patternCount) {
      case 0:
        if (_existenceCooldown <= 0) {
          _executeExistenceErase(player);
          _existenceCooldown = 5.0;
        }
      case 1:
        _executeVoidGrasp(player);
      case 2:
        _executeMemoryErase(player);
      case 3:
        _executeVoidWave();
    }

    _attackTimer = 0;
  }

  void _executeExistenceErase(ArcanaPlayer player) {
    _state = OblivionState.existenceErase;

    // 존재 지우기 - 플레이어 주변에 공허 영역 생성
    final void1 = _VoidZone(
      targetPos: player.position.clone(),
      damage: (data.attack * 0.5).toInt(),
      duration: 3.0,
    );
    parent?.add(void1);

    AudioManager.instance.playSfx(SoundEffect.bossAppear);

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (isMounted) _state = OblivionState.float;
    });
  }

  void _executeVoidGrasp(ArcanaPlayer player) {
    // 공허의 손 - 플레이어를 향해 손 공격
    for (var i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 300), () {
        if (!isMounted) return;

        final grasp = _VoidGrasp(
          targetPos: player.position.clone(),
          damage: (data.attack * 0.4).toInt(),
        );
        parent?.add(grasp);
      });
    }
  }

  /// Phase 3: 미래의 망각
  void _executeFuturePhase(double dt, ArcanaPlayer player) {
    if (_attackTimer < 1.8) return;

    _patternCount = (_patternCount + 1) % 5;

    switch (_patternCount) {
      case 0:
        if (_futureCooldown <= 0) {
          _executeFutureErase(player);
          _futureCooldown = 4.0;
        }
      case 1:
        _executeVoidBarrage(player);
      case 2:
        _executeExistenceErase(player);
      case 3:
        _executeSummonFaces(player);
      case 4:
        _executeVoidWave();
    }

    _attackTimer = 0;
  }

  void _executeFutureErase(ArcanaPlayer player) {
    _state = OblivionState.futureErase;

    // 미래 지우기 - 전방위 공격
    for (var i = 0; i < 12; i++) {
      final angle = i * pi / 6;
      final direction = Vector2(cos(angle), sin(angle));

      Future.delayed(Duration(milliseconds: i * 50), () {
        if (!isMounted) return;

        final beam = _FutureBeam(
          direction: direction,
          damage: (data.attack * 0.3).toInt(),
        );
        beam.position = position.clone();
        parent?.add(beam);
      });
    }

    AudioManager.instance.playSfx(SoundEffect.bossAppear);

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (isMounted) _state = OblivionState.float;
    });
  }

  void _executeVoidBarrage(ArcanaPlayer player) {
    // 공허 연발
    for (var i = 0; i < 8; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (!isMounted) return;

        final direction = (player.position - position).normalized();
        final spread = Vector2(
          (Random().nextDouble() - 0.5) * 0.4,
          (Random().nextDouble() - 0.5) * 0.4,
        );

        final shot = _VoidShot(
          direction: (direction + spread).normalized(),
          damage: (data.attack * 0.25).toInt(),
        );
        shot.position = position.clone();
        parent?.add(shot);
      });
    }
  }

  ArcanaPlayer? _findPlayer() {
    try {
      return gameRef.world.children.whereType<ArcanaPlayer>().first;
    } catch (_) {
      return null;
    }
  }

  @override
  void takeDamage(double damage) {
    // Phase 4에서는 대미지 무시
    if (_phase == OblivionPhase.finalBargain) return;

    // HP 10% 이하로 내려가지 않음 (Phase 4 트리거용)
    if (health - damage < data.maxHealth * 0.10) {
      health = data.maxHealth * 0.10;
      return;
    }

    super.takeDamage(damage);
  }

  @override
  void renderEnemy(Canvas canvas) {
    // 공허 바디 (형체 없음)
    final centerX = size.x / 2;
    final centerY = size.y / 2;

    // 공허 코어
    final voidGradient = RadialGradient(
      colors: [
        const Color.fromRGBO(0, 0, 0, 0.95),
        Color.fromRGBO(20, 0, 40, 0.8 + sin(_pulseTimer * 3) * 0.1),
        const Color.fromRGBO(40, 0, 60, 0.0),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final voidRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: _voidRadius * 2,
      height: _voidRadius * 2,
    );

    canvas.drawOval(
      voidRect,
      Paint()..shader = voidGradient.createShader(voidRect),
    );

    // 잊혀진 얼굴들
    for (final face in _faces) {
      final faceX = centerX + cos(face.angle) * face.distance;
      final faceY = centerY + sin(face.angle) * face.distance;

      canvas.drawCircle(
        Offset(faceX, faceY),
        8,
        Paint()..color = Color.fromRGBO(150, 100, 200, face.life * 0.5),
      );

      // 눈
      canvas.drawCircle(
        Offset(faceX - 2, faceY - 2),
        2,
        Paint()..color = Color.fromRGBO(255, 255, 255, face.life * 0.7),
      );
      canvas.drawCircle(
        Offset(faceX + 2, faceY - 2),
        2,
        Paint()..color = Color.fromRGBO(255, 255, 255, face.life * 0.7),
      );
    }

    // 중앙의 눈 (Phase에 따라 색상 변경)
    final eyeColor = switch (_phase) {
      OblivionPhase.pastOblivion => const Color.fromRGBO(100, 100, 255, 1.0),
      OblivionPhase.presentOblivion => const Color.fromRGBO(100, 255, 100, 1.0),
      OblivionPhase.futureOblivion => const Color.fromRGBO(255, 100, 100, 1.0),
      OblivionPhase.finalBargain => const Color.fromRGBO(255, 255, 255, 1.0),
    };

    // 눈 발광
    canvas.drawCircle(
      Offset(centerX, centerY),
      15 + sin(_pulseTimer * 4) * 3,
      Paint()
        ..color = eyeColor.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
    );

    // 눈 코어
    canvas.drawCircle(
      Offset(centerX, centerY),
      8,
      Paint()..color = eyeColor,
    );

    // 동공
    canvas.drawCircle(
      Offset(centerX, centerY),
      3,
      Paint()..color = Colors.black,
    );

    // Phase 4 특수 효과
    if (_phase == OblivionPhase.finalBargain) {
      // 거래 가능 표시 - 주변에 빛나는 원
      canvas.drawCircle(
        Offset(centerX, centerY),
        _voidRadius + 20 + sin(_pulseTimer * 2) * 10,
        Paint()
          ..color = Color.fromRGBO(255, 255, 255, 0.3 + sin(_pulseTimer * 3) * 0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }
}

/// 잊혀진 얼굴 클래스
class _ForgottenFace {
  _ForgottenFace({
    required this.angle,
    required this.distance,
    required this.speed,
    required this.fadeSpeed,
  });

  double angle;
  double distance;
  double speed;
  double fadeSpeed;
  double life = 1.0;
}

/// 기억 구체
class _MemoryOrb extends PositionComponent with HasGameRef {
  _MemoryOrb({
    required this.direction,
    required this.damage,
  }) : super(size: Vector2(16, 16), anchor: Anchor.center);

  final Vector2 direction;
  final int damage;
  double _lifetime = 2.5;

  @override
  void update(double dt) {
    super.update(dt);

    position += direction * 100 * dt;
    _lifetime -= dt;

    if (_lifetime <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      8,
      Paint()
        ..color = Color.fromRGBO(100, 100, 255, 0.7 * (_lifetime / 2.5))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }
}

/// 공허 파동
class _VoidWave extends PositionComponent with HasGameRef {
  _VoidWave({
    required this.direction,
    required this.damage,
  }) : super(size: Vector2(30, 30), anchor: Anchor.center);

  final Vector2 direction;
  final int damage;
  double _lifetime = 1.5;

  @override
  void update(double dt) {
    super.update(dt);

    position += direction * 150 * dt;
    _lifetime -= dt;

    if (_lifetime <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final opacity = (_lifetime / 1.5).clamp(0.0, 1.0);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y / 2),
        width: 30,
        height: 15,
      ),
      Paint()..color = Color.fromRGBO(40, 0, 60, 0.6 * opacity),
    );
  }
}

/// 얼굴 공격
class _FaceAttack extends PositionComponent with HasGameRef {
  _FaceAttack({
    required this.targetPos,
    required this.damage,
  }) : super(size: Vector2(40, 40), anchor: Anchor.center);

  final Vector2 targetPos;
  final int damage;
  double _timer = 0;
  bool _attacked = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = targetPos;
  }

  @override
  void update(double dt) {
    super.update(dt);

    _timer += dt;

    if (_timer >= 0.8 && !_attacked) {
      _attacked = true;
      // 대미지 처리 가능
    }

    if (_timer > 1.2) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = (_timer / 0.8).clamp(0.0, 1.0);
    final fadeOut = _timer > 0.8 ? (1.2 - _timer) / 0.4 : 1.0;

    // 경고 원
    if (_timer < 0.8) {
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        20 * progress,
        Paint()
          ..color = Color.fromRGBO(255, 0, 0, 0.3 * (1 - progress))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // 얼굴
    final faceOpacity = _timer < 0.8 ? progress : fadeOut;
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      15,
      Paint()..color = Color.fromRGBO(100, 50, 150, faceOpacity),
    );

    // 눈
    canvas.drawCircle(
      Offset(size.x / 2 - 4, size.y / 2 - 2),
      3,
      Paint()..color = Color.fromRGBO(255, 255, 255, faceOpacity),
    );
    canvas.drawCircle(
      Offset(size.x / 2 + 4, size.y / 2 - 2),
      3,
      Paint()..color = Color.fromRGBO(255, 255, 255, faceOpacity),
    );
  }
}

/// 공허 영역
class _VoidZone extends PositionComponent with HasGameRef {
  _VoidZone({
    required this.targetPos,
    required this.damage,
    required this.duration,
  }) : super(size: Vector2(100, 100), anchor: Anchor.center);

  final Vector2 targetPos;
  final int damage;
  final double duration;
  double _timer = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = targetPos;
  }

  @override
  void update(double dt) {
    super.update(dt);

    _timer += dt;

    if (_timer > duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = (_timer / duration).clamp(0.0, 1.0);
    final fadeIn = _timer < 0.5 ? _timer / 0.5 : 1.0;
    final fadeOut = _timer > duration - 0.5 ? (duration - _timer) / 0.5 : 1.0;
    final opacity = fadeIn * fadeOut;

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      50,
      Paint()
        ..color = Color.fromRGBO(0, 0, 0, 0.7 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // 테두리
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      50,
      Paint()
        ..color = Color.fromRGBO(80, 0, 120, 0.5 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }
}

/// 공허의 손
class _VoidGrasp extends PositionComponent with HasGameRef {
  _VoidGrasp({
    required this.targetPos,
    required this.damage,
  }) : super(size: Vector2(60, 80), anchor: Anchor.bottomCenter);

  final Vector2 targetPos;
  final int damage;
  double _timer = 0;
  double _height = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = targetPos;
  }

  @override
  void update(double dt) {
    super.update(dt);

    _timer += dt;

    if (_timer < 0.5) {
      // 경고
    } else if (_timer < 1.0) {
      _height = (_timer - 0.5) * 2 * 80;
    } else if (_timer < 1.3) {
      _height = 80;
    } else {
      _height = 80 * (1 - (_timer - 1.3) / 0.3);
    }

    if (_timer > 1.6) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (_timer < 0.5) {
      // 경고 표시
      canvas.drawOval(
        Rect.fromCenter(center: Offset(size.x / 2, 0), width: 40, height: 15),
        Paint()
          ..color = const Color(0x60800080)
          ..style = PaintingStyle.fill,
      );
      return;
    }

    // 손 그리기
    final path = Path();
    path.moveTo(size.x / 2 - 15, 0);
    path.quadraticBezierTo(
      size.x / 2 - 20,
      -_height / 2,
      size.x / 2 - 10,
      -_height,
    );
    path.lineTo(size.x / 2 + 10, -_height);
    path.quadraticBezierTo(
      size.x / 2 + 20,
      -_height / 2,
      size.x / 2 + 15,
      0,
    );
    path.close();

    canvas.drawPath(
      path,
      Paint()..color = const Color(0xDD200040),
    );

    // 손가락들
    for (var i = -2; i <= 2; i++) {
      final fingerX = size.x / 2 + i * 6;
      canvas.drawLine(
        Offset(fingerX, -_height),
        Offset(fingerX + i * 2, -_height - 15),
        Paint()
          ..color = const Color(0xDD200040)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }
  }
}

/// 미래 빔
class _FutureBeam extends PositionComponent with HasGameRef {
  _FutureBeam({
    required this.direction,
    required this.damage,
  }) : super(size: Vector2(200, 10));

  final Vector2 direction;
  final int damage;
  double _lifetime = 0.8;

  @override
  void update(double dt) {
    super.update(dt);

    _lifetime -= dt;

    if (_lifetime <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final angle = atan2(direction.y, direction.x);
    final opacity = (_lifetime / 0.8).clamp(0.0, 1.0);

    canvas.save();
    canvas.rotate(angle);

    canvas.drawRect(
      Rect.fromLTWH(0, -5, 200, 10),
      Paint()
        ..color = Color.fromRGBO(255, 50, 50, 0.6 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    canvas.restore();
  }
}

/// 공허 발사체
class _VoidShot extends PositionComponent with HasGameRef {
  _VoidShot({
    required this.direction,
    required this.damage,
  }) : super(size: Vector2(12, 12), anchor: Anchor.center);

  final Vector2 direction;
  final int damage;
  double _lifetime = 2.0;

  @override
  void update(double dt) {
    super.update(dt);

    position += direction * 180 * dt;
    _lifetime -= dt;

    if (_lifetime <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      6,
      Paint()
        ..color = Color.fromRGBO(40, 0, 60, 0.8 * (_lifetime / 2.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }
}
