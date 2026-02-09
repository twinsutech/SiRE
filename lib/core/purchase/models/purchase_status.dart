// // lib/core/purchase/state/purchase_state.dart
//
// import '../models/entitlement.dart';
//
// /// ✅ 결제 상태(PurchaseState)
// /// - 서버 없는 구조에서 앱 전체에서 공통으로 바라보는 "현재 권한 상태"를 표현합니다.
// /// - 현재는 평생(Pro) 단일 상품이므로 entitlement만으로도 충분합니다.
// /// - errorMessage는 로딩/복원/IAP 연동 시 문제 상황을 표시하기 위한 확장 포인트입니다.
// class PurchaseState {
//   final bool isLoading;
//   final Entitlement entitlement;
//   final String? errorMessage;
//
//   const PurchaseState({
//     required this.isLoading,
//     required this.entitlement,
//     this.errorMessage,
//   });
//
//   /// ✅ 앱 기본 상태: 무료(Free)
//   const PurchaseState.free()
//       : isLoading = false,
//         entitlement = Entitlement.free,
//         errorMessage = null;
//
//   /// ✅ 로딩 상태 (앱 시작 시 로컬/스토어 상태 확인용)
//   const PurchaseState.loading()
//       : isLoading = true,
//         entitlement = Entitlement.free,
//         errorMessage = null;
//
//   /// ✅ Pro 상태
//   const PurchaseState.pro()
//       : isLoading = false,
//         entitlement = Entitlement.pro,
//         errorMessage = null;
//
//   /// ✅ 에러 상태
//   const PurchaseState.error(String message)
//       : isLoading = false,
//         entitlement = Entitlement.free,
//         errorMessage = message;
//
//   bool get isPro => entitlement == Entitlement.pro;
//
//   PurchaseState copyWith({
//     bool? isLoading,
//     Entitlement? entitlement,
//     String? errorMessage,
//   }) {
//     return PurchaseState(
//       isLoading: isLoading ?? this.isLoading,
//       entitlement: entitlement ?? this.entitlement,
//       errorMessage: errorMessage,
//     );
//   }
// }

import '../models/entitlement.dart';

/// ✅ 결제 및 무료 체험 상태(PurchaseState)
/// - 서버 없는 구조에서 앱 전체에서 공통으로 바라보는 "현재 권한 상태"를 표현합니다.
class PurchaseState {
  final bool isLoading;
  final Entitlement entitlement;
  final String? errorMessage;

  // 📍 무료 체험 기능을 위한 필드 추가
  final bool isTrialActive;      // 현재 무료 체험이 활성화 중인지 여부
  final int remainingTrialCount; // 남은 무료 체험 가능 횟수

  const PurchaseState({
    required this.isLoading,
    required this.entitlement,
    this.isTrialActive = false,      // 기본값 false
    this.remainingTrialCount = 3,    // 기본값 3회
    this.errorMessage,
  });

  /// ✅ 앱 기본 상태: 무료(Free)
  /// - 처음 실행 시 기본적으로 3회의 체험 횟수를 가집니다.
  const PurchaseState.free({int remainingTrialCount = 3, bool isTrialActive = false})
      : isLoading = false,
        entitlement = Entitlement.free,
        isTrialActive = isTrialActive,
        remainingTrialCount = remainingTrialCount,
        errorMessage = null;

  /// ✅ 로딩 상태 (앱 시작 시 로컬/스토어 상태 확인용)
  const PurchaseState.loading()
      : isLoading = true,
        entitlement = Entitlement.free,
        isTrialActive = false,
        remainingTrialCount = 3,
        errorMessage = null;

  /// ✅ Pro 상태
  const PurchaseState.pro({int remainingTrialCount = 0, bool isTrialActive = false})
      : isLoading = false,
        entitlement = Entitlement.pro,
        isTrialActive = isTrialActive,
        remainingTrialCount = remainingTrialCount,
        errorMessage = null;

  /// ✅ 에러 상태
  const PurchaseState.error(String message)
      : isLoading = false,
        entitlement = Entitlement.free,
        isTrialActive = false,
        remainingTrialCount = 3,
        errorMessage = message;

  // Pro 권한 판단 로직
  bool get isPro => entitlement == Entitlement.pro;

  // 📍 copyWith 메서드에 새 필드 반영 (에러 해결 핵심)
  PurchaseState copyWith({
    bool? isLoading,
    Entitlement? entitlement,
    String? errorMessage,
    bool? isTrialActive,
    int? remainingTrialCount,
  }) {
    return PurchaseState(
      isLoading: isLoading ?? this.isLoading,
      entitlement: entitlement ?? this.entitlement,
      errorMessage: errorMessage ?? this.errorMessage,
      isTrialActive: isTrialActive ?? this.isTrialActive,
      remainingTrialCount: remainingTrialCount ?? this.remainingTrialCount,
    );
  }
}