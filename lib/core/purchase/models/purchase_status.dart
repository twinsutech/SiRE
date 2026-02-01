// lib/core/purchase/state/purchase_state.dart

import '../models/entitlement.dart';

/// ✅ 결제 상태(PurchaseState)
/// - 서버 없는 구조에서 앱 전체에서 공통으로 바라보는 "현재 권한 상태"를 표현합니다.
/// - 현재는 평생(Pro) 단일 상품이므로 entitlement만으로도 충분합니다.
/// - errorMessage는 로딩/복원/IAP 연동 시 문제 상황을 표시하기 위한 확장 포인트입니다.
class PurchaseState {
  final bool isLoading;
  final Entitlement entitlement;
  final String? errorMessage;

  const PurchaseState({
    required this.isLoading,
    required this.entitlement,
    this.errorMessage,
  });

  /// ✅ 앱 기본 상태: 무료(Free)
  const PurchaseState.free()
      : isLoading = false,
        entitlement = Entitlement.free,
        errorMessage = null;

  /// ✅ 로딩 상태 (앱 시작 시 로컬/스토어 상태 확인용)
  const PurchaseState.loading()
      : isLoading = true,
        entitlement = Entitlement.free,
        errorMessage = null;

  /// ✅ Pro 상태
  const PurchaseState.pro()
      : isLoading = false,
        entitlement = Entitlement.pro,
        errorMessage = null;

  /// ✅ 에러 상태
  const PurchaseState.error(String message)
      : isLoading = false,
        entitlement = Entitlement.free,
        errorMessage = message;

  bool get isPro => entitlement == Entitlement.pro;

  PurchaseState copyWith({
    bool? isLoading,
    Entitlement? entitlement,
    String? errorMessage,
  }) {
    return PurchaseState(
      isLoading: isLoading ?? this.isLoading,
      entitlement: entitlement ?? this.entitlement,
      errorMessage: errorMessage,
    );
  }
}
