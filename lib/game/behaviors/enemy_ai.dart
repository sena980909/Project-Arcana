/// Arcana: The Three Hearts - 적 AI 상태 머신
/// PRD Phase 2: 배회(Idle) -> 추적(Chase) -> 공격(Attack)
library;

import 'dart:math';

import 'package:flame/components.dart';

/// 적 AI 상태
enum EnemyState {
  idle,   // 대기/배회
  chase,  // 추적
  attack, // 공격
  dead,   // 사망
}

/// 적 AI 컨트롤러
/// 상태 머신 기반 적 행동 관리
class EnemyAI {
  EnemyAI({
    required this.detectRange,
    required this.attackRange,
    required this.attackCooldown,
  });

  /// 플레이어 감지 범위
  final double detectRange;

  /// 공격 범위
  final double attackRange;

  /// 공격 쿨다운 (초)
  final double attackCooldown;

  /// 현재 상태
  EnemyState state = EnemyState.idle;

  /// 공격 쿨다운 타이머
  double _attackTimer = 0;

  /// 배회 타이머
  double _wanderTimer = 0;

  /// 배회 방향
  Vector2 _wanderDirection = Vector2.zero();

  /// 랜덤 생성기
  final _random = Random();

  /// AI 업데이트
  /// 반환값: 이동 방향 벡터 (정규화됨)
  Vector2 update({
    required double dt,
    required Vector2 enemyPosition,
    required Vector2 playerPosition,
    required void Function() onAttack,
  }) {
    // 사망 상태면 아무것도 하지 않음
    if (state == EnemyState.dead) {
      return Vector2.zero();
    }

    // 공격 쿨다운 감소
    if (_attackTimer > 0) {
      _attackTimer -= dt;
    }

    // 플레이어와의 거리 계산
    final distanceToPlayer = enemyPosition.distanceTo(playerPosition);

    // 상태 전이 로직
    _updateState(distanceToPlayer);

    // 상태별 행동
    return _executeState(
      dt: dt,
      enemyPosition: enemyPosition,
      playerPosition: playerPosition,
      distanceToPlayer: distanceToPlayer,
      onAttack: onAttack,
    );
  }

  /// 상태 전이 로직
  void _updateState(double distanceToPlayer) {
    switch (state) {
      case EnemyState.idle:
        // 플레이어 감지 시 추적 상태로 전이
        if (distanceToPlayer <= detectRange) {
          state = EnemyState.chase;
        }

      case EnemyState.chase:
        // 공격 범위 진입 시 공격 상태로 전이
        if (distanceToPlayer <= attackRange) {
          state = EnemyState.attack;
        }
        // 플레이어가 너무 멀어지면 대기 상태로 복귀
        else if (distanceToPlayer > detectRange * 1.5) {
          state = EnemyState.idle;
        }

      case EnemyState.attack:
        // 플레이어가 공격 범위를 벗어나면 추적 상태로 전이
        if (distanceToPlayer > attackRange * 1.2) {
          state = EnemyState.chase;
        }

      case EnemyState.dead:
        // 사망 상태는 변경 없음
        break;
    }
  }

  /// 상태별 행동 실행
  Vector2 _executeState({
    required double dt,
    required Vector2 enemyPosition,
    required Vector2 playerPosition,
    required double distanceToPlayer,
    required void Function() onAttack,
  }) {
    switch (state) {
      case EnemyState.idle:
        return _executeIdle(dt);

      case EnemyState.chase:
        return _executeChase(enemyPosition, playerPosition);

      case EnemyState.attack:
        _executeAttack(onAttack);
        // 공격 중에도 플레이어 방향으로 약간 이동
        return _executeChase(enemyPosition, playerPosition) * 0.3;

      case EnemyState.dead:
        return Vector2.zero();
    }
  }

  /// 대기/배회 행동
  Vector2 _executeIdle(double dt) {
    _wanderTimer -= dt;

    // 배회 타이머 만료 시 새 방향 설정
    if (_wanderTimer <= 0) {
      _wanderTimer = 2.0 + _random.nextDouble() * 3.0; // 2~5초

      // 50% 확률로 배회, 50% 확률로 정지
      if (_random.nextBool()) {
        final angle = _random.nextDouble() * 2 * pi;
        _wanderDirection = Vector2(cos(angle), sin(angle));
      } else {
        _wanderDirection = Vector2.zero();
      }
    }

    return _wanderDirection;
  }

  /// 추적 행동
  Vector2 _executeChase(Vector2 enemyPosition, Vector2 playerPosition) {
    final direction = playerPosition - enemyPosition;
    if (direction.length > 0) {
      return direction.normalized();
    }
    return Vector2.zero();
  }

  /// 공격 행동
  void _executeAttack(void Function() onAttack) {
    // 쿨다운이 끝났으면 공격
    if (_attackTimer <= 0) {
      onAttack();
      _attackTimer = attackCooldown;
    }
  }

  /// 사망 처리
  void die() {
    state = EnemyState.dead;
  }

  /// 상태 초기화
  void reset() {
    state = EnemyState.idle;
    _attackTimer = 0;
    _wanderTimer = 0;
    _wanderDirection = Vector2.zero();
  }
}
