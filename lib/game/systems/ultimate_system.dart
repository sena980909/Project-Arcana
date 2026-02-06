/// Arcana: The Three Hearts - 궁극기 시스템
library;

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../data/models/skill_data.dart';
import '../../data/models/player_state.dart';
import '../../data/repositories/config_repository.dart';
import '../player.dart';
import '../enemy.dart';

/// 궁극기 사용 결과
class UltimateResult {
  const UltimateResult({
    required this.success,
    this.message,
    this.damage = 0,
    this.hitCount = 0,
    this.healAmount = 0,
  });

  final bool success;
  final String? message;
  final double damage;
  final int hitCount;
  final double healAmount;
}

/// 궁극기 시스템
class UltimateSystem {
  UltimateSystem({
    required this.player,
    required this.world,
    required this.getEnemies,
    this.onHeartGaugeUsed,
    this.onHeal,
    this.onBuffApplied,
    this.onTimeStop,
  });

  final Player player;
  final World world;
  final List<Enemy> Function() getEnemies;
  final void Function()? onHeartGaugeUsed;
  final void Function(double amount)? onHeal;
  final void Function(String buffType, double value, double duration)? onBuffApplied;
  final void Function(double duration)? onTimeStop;

  /// 궁극기 사용
  UltimateResult useUltimate(HeartCollection hearts, int heartGauge) {
    if (heartGauge < 100) {
      return UltimateResult(
        success: false,
        message: '심장 게이지가 부족합니다 ($heartGauge/100)',
      );
    }

    // 심장 게이지 소모
    onHeartGaugeUsed?.call();

    // 어떤 궁극기를 사용할지 결정
    String ultimateType;
    if (hearts.hasAll) {
      ultimateType = 'unified';
    } else if (hearts.courage) {
      ultimateType = 'courage';
    } else if (hearts.wisdom) {
      ultimateType = 'wisdom';
    } else if (hearts.love) {
      ultimateType = 'love';
    } else {
      // 심장이 없으면 기본 궁극기
      return _executeBasicUltimate();
    }

    final ultimateData = ConfigRepository.instance.getUltimateByHeart(ultimateType);
    if (ultimateData == null) {
      return _executeBasicUltimate();
    }

    return _executeUltimate(ultimateData);
  }

  /// 기본 궁극기 (심장 없음)
  UltimateResult _executeBasicUltimate() {
    final enemies = getEnemies();
    int hitCount = 0;
    double totalDamage = 0;
    const damage = 50.0;
    const radius = 100.0;

    for (final enemy in enemies) {
      if (enemy.isDead) continue;

      final distance = (enemy.position - player.position).length;
      if (distance <= radius) {
        enemy.takeDamage(damage);
        hitCount++;
        totalDamage += damage;
      }
    }

    // 이펙트 생성
    final effect = UltimateEffectComponent(
      position: player.position.clone(),
      radius: radius,
      color: Colors.white,
      duration: 0.5,
    );
    world.add(effect);

    return UltimateResult(
      success: true,
      message: '기본 궁극기 발동!',
      damage: totalDamage,
      hitCount: hitCount,
    );
  }

  /// 궁극기 실행
  UltimateResult _executeUltimate(UltimateData ultimate) {
    switch (ultimate.heartType) {
      case 'courage':
        return _executeCourageUltimate(ultimate);
      case 'wisdom':
        return _executeWisdomUltimate(ultimate);
      case 'love':
        return _executeLoveUltimate(ultimate);
      case 'unified':
        return _executeUnifiedUltimate(ultimate);
      default:
        return _executeBasicUltimate();
    }
  }

  /// 용기의 궁극기 - 화염 폭발
  UltimateResult _executeCourageUltimate(UltimateData ultimate) {
    final enemies = getEnemies();
    int hitCount = 0;
    double totalDamage = 0;

    for (final enemy in enemies) {
      if (enemy.isDead) continue;

      final distance = (enemy.position - player.position).length;
      if (distance <= ultimate.radius) {
        enemy.takeDamage(ultimate.damage);
        hitCount++;
        totalDamage += ultimate.damage;

        // 화상 효과 (데이터에서 가져옴)
        if (ultimate.effect['burn'] == true) {
          // TODO: 화상 상태이상 적용
        }
      }
    }

    // 화염 폭발 이펙트
    final effect = UltimateEffectComponent(
      position: player.position.clone(),
      radius: ultimate.radius,
      color: Colors.orange,
      duration: 0.8,
      particleCount: 20,
    );
    world.add(effect);

    return UltimateResult(
      success: true,
      message: '${ultimate.name} 발동!',
      damage: totalDamage,
      hitCount: hitCount,
    );
  }

  /// 지혜의 궁극기 - 시간 정지
  UltimateResult _executeWisdomUltimate(UltimateData ultimate) {
    // 시간 정지 효과
    onTimeStop?.call(ultimate.duration);

    // 마나 회복
    if (ultimate.effect.containsKey('manaRegen')) {
      final manaRegen = (ultimate.effect['manaRegen'] as num).toDouble();
      // TODO: 마나 회복 콜백
    }

    // 시간 정지 이펙트
    final effect = TimeStopEffectComponent(
      position: player.position.clone(),
      radius: ultimate.radius,
      duration: ultimate.duration,
    );
    world.add(effect);

    return UltimateResult(
      success: true,
      message: '${ultimate.name} 발동! (${ultimate.duration}초)',
    );
  }

  /// 사랑의 궁극기 - 완전 회복
  UltimateResult _executeLoveUltimate(UltimateData ultimate) {
    double healAmount = 0;

    // 풀 회복
    if (ultimate.effect['fullHeal'] == true) {
      healAmount = player.maxHp - player.hp;
      onHeal?.call(player.maxHp);
    }

    // 실드 효과
    if (ultimate.effect.containsKey('shield')) {
      final shieldValue = (ultimate.effect['shield'] as num).toDouble();
      final shieldDuration =
          (ultimate.effect['shieldDuration'] as num?)?.toDouble() ?? 5.0;
      onBuffApplied?.call('shield', shieldValue, shieldDuration);
    }

    // 회복 이펙트
    final effect = HealEffectComponent(
      target: player,
      duration: 1.0,
    );
    world.add(effect);

    return UltimateResult(
      success: true,
      message: '${ultimate.name} 발동!',
      healAmount: healAmount,
    );
  }

  /// 통합 궁극기 - 세 심장의 조화
  UltimateResult _executeUnifiedUltimate(UltimateData ultimate) {
    final enemies = getEnemies();
    int hitCount = 0;
    double totalDamage = 0;
    double healAmount = 0;

    // 광역 데미지
    for (final enemy in enemies) {
      if (enemy.isDead) continue;

      final distance = (enemy.position - player.position).length;
      if (distance <= ultimate.radius) {
        enemy.takeDamage(ultimate.damage);
        hitCount++;
        totalDamage += ultimate.damage;
      }
    }

    // 회복
    if (ultimate.effect.containsKey('heal')) {
      healAmount = (ultimate.effect['heal'] as num).toDouble();
      onHeal?.call(healAmount);
    }

    // 데미지 버프
    if (ultimate.effect.containsKey('damageBoost')) {
      final boost = (ultimate.effect['damageBoost'] as num).toDouble();
      final duration =
          (ultimate.effect['damageBoostDuration'] as num?)?.toDouble() ?? 5.0;
      onBuffApplied?.call('damage', boost, duration);
    }

    // 무적
    if (ultimate.effect['invincible'] == true) {
      final duration =
          (ultimate.effect['invincibleDuration'] as num?)?.toDouble() ?? 2.0;
      onBuffApplied?.call('invincible', 1, duration);
    }

    // 통합 궁극기 이펙트
    final effect = UnifiedUltimateEffectComponent(
      position: player.position.clone(),
      radius: ultimate.radius,
      duration: 1.5,
    );
    world.add(effect);

    return UltimateResult(
      success: true,
      message: '${ultimate.name} 발동!',
      damage: totalDamage,
      hitCount: hitCount,
      healAmount: healAmount,
    );
  }
}

/// 궁극기 이펙트 컴포넌트
class UltimateEffectComponent extends PositionComponent {
  UltimateEffectComponent({
    required Vector2 position,
    required this.radius,
    required this.color,
    required this.duration,
    this.particleCount = 10,
  }) : super(position: position, anchor: Anchor.center);

  final double radius;
  final Color color;
  final double duration;
  final int particleCount;

  double _elapsed = 0;
  final List<_Particle> _particles = [];

  @override
  void onLoad() {
    super.onLoad();

    // 파티클 생성
    final random = Random();
    for (int i = 0; i < particleCount; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 50 + random.nextDouble() * 100;
      _particles.add(_Particle(
        angle: angle,
        speed: speed,
        size: 3 + random.nextDouble() * 5,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
    }

    // 파티클 업데이트
    for (final p in _particles) {
      p.distance += p.speed * dt;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progress = (_elapsed / duration).clamp(0.0, 1.0);

    // 메인 원형 파동
    final waveRadius = radius * progress;
    final waveAlpha = ((1 - progress) * 150).toInt();

    final wavePaint = Paint()
      ..color = color.withAlpha(waveAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(Offset.zero, waveRadius, wavePaint);

    // 내부 채우기
    final fillPaint = Paint()
      ..color = color.withAlpha((waveAlpha * 0.3).toInt())
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset.zero, waveRadius * 0.8, fillPaint);

    // 파티클
    for (final p in _particles) {
      final x = cos(p.angle) * p.distance;
      final y = sin(p.angle) * p.distance;
      final alpha = ((1 - progress) * 200).toInt();

      final particlePaint = Paint()
        ..color = color.withAlpha(alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), p.size * (1 - progress * 0.5), particlePaint);
    }
  }
}

class _Particle {
  _Particle({
    required this.angle,
    required this.speed,
    required this.size,
  });

  final double angle;
  final double speed;
  final double size;
  double distance = 0;
}

/// 시간 정지 이펙트
class TimeStopEffectComponent extends PositionComponent {
  TimeStopEffectComponent({
    required Vector2 position,
    required this.radius,
    required this.duration,
  }) : super(position: position, anchor: Anchor.center);

  final double radius;
  final double duration;

  double _elapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);

    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progress = (_elapsed / duration).clamp(0.0, 1.0);

    // 시간 정지 영역
    final alpha = ((1 - progress * 0.5) * 50).toInt();
    final paint = Paint()
      ..color = Colors.blue.withAlpha(alpha)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset.zero, radius, paint);

    // 시계 같은 패턴
    final linePaint = Paint()
      ..color = Colors.blue.withAlpha((alpha * 2).clamp(0, 255))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 12; i++) {
      final angle = i * pi / 6;
      final innerRadius = radius * 0.7;
      final outerRadius = radius * 0.9;

      canvas.drawLine(
        Offset(cos(angle) * innerRadius, sin(angle) * innerRadius),
        Offset(cos(angle) * outerRadius, sin(angle) * outerRadius),
        linePaint,
      );
    }
  }
}

/// 회복 이펙트
class HealEffectComponent extends Component {
  HealEffectComponent({
    required this.target,
    required this.duration,
  });

  final PositionComponent target;
  final double duration;

  double _elapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);

    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }
}

/// 통합 궁극기 이펙트
class UnifiedUltimateEffectComponent extends PositionComponent {
  UnifiedUltimateEffectComponent({
    required Vector2 position,
    required this.radius,
    required this.duration,
  }) : super(position: position, anchor: Anchor.center);

  final double radius;
  final double duration;

  double _elapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);

    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progress = (_elapsed / duration).clamp(0.0, 1.0);

    // 세 가지 색상의 동심원
    final colors = [Colors.red, Colors.blue, Colors.green];
    for (int i = 0; i < 3; i++) {
      final offset = i * 0.1;
      final waveProgress = (progress - offset).clamp(0.0, 1.0);
      final waveRadius = radius * waveProgress;
      final alpha = ((1 - waveProgress) * 150).toInt();

      final paint = Paint()
        ..color = colors[i].withAlpha(alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawCircle(Offset.zero, waveRadius, paint);
    }

    // 중앙 발광
    final glowAlpha = ((1 - progress) * 200).toInt();
    final glowPaint = Paint()
      ..color = Colors.white.withAlpha(glowAlpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawCircle(Offset.zero, 30 * (1 - progress * 0.5), glowPaint);
  }
}
