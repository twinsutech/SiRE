import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../models/entitlement.dart';
// ✅ [수정] 이 파일에서는 앱 내부 purchase_status.dart를 사용하지 않으므로 import 제거
// - in_app_purchase의 PurchaseStatus와 이름 충돌 가능
// import '../models/purchase_status.dart';
import '../models/purchase_status.dart';
import '../services/iap_service.dart';
import 'purchase_state.dart';

/// ✅ [정리] SharedPreferences 키
/// - 서버 없는 구조에서 "구매 완료 여부"를 로컬에 저장해두면
///   앱 재실행 시에도 Pro 상태를 빠르게 복원할 수 있습니다.
/// - 실제 결제 완료/복원 이벤트가 들어오면 이 값을 업데이트합니다.
const String _kPrefIsProLifetime = 'purchase_is_pro_lifetime';
// 📍 [추가] 무료 체험 관련 키
const String _kPrefTrialCount = 'purchase_trial_remaining_count';

/// ✅ 앱 전역 구매 상태 Provider
final purchaseControllerProvider =
StateNotifierProvider<PurchaseController, PurchaseState>((ref) {
  final controller = PurchaseController();
  ref.onDispose(controller.dispose); // ✅ 스트림 구독 해제
  return controller;
});

/// ✅ 앱 어디서나 Pro 여부만 간단히 읽기 위한 Provider
/// - [수정] 실제 구매 완료 상태이거나, 현재 세션에서 무료 체험이 활성 상태이면 true를 반환합니다.
final isProProvider = Provider<bool>((ref) {
  final state = ref.watch(purchaseControllerProvider);
  return state.isPro || state.isTrialActive;
});

/// ✅ [추가] 남은 무료 체험 횟수를 읽기 위한 Provider
final trialCountProvider = Provider<int>((ref) {
  final state = ref.watch(purchaseControllerProvider);
  return state.remainingTrialCount;
});

/// ✅ Entitlement 자체가 필요할 때를 위한 Provider
final entitlementProvider = Provider<Entitlement>((ref) {
  final state = ref.watch(purchaseControllerProvider);
  return state.entitlement;
});

/// ✅ [추가] Settings 등에서 "검증 결과 메시지"를 테스트하기 위한 리턴 모델
/// - UI에서 이 결과를 보고 SnackBar/Toast만 띄우면 됩니다.
class StoreVerifyResult {
  final bool storeAvailable; // 스토어 연결 가능 여부
  final bool? owned; // null이면 소유 여부 판단 불가(에러/미지원 등)
  final String? message; // UI에 그대로 띄우기 좋은 메시(테스트용)

  const StoreVerifyResult({
    required this.storeAvailable,
    required this.owned,
    required this.message,
  });
}

/// ✅ 구매 상태 컨트롤러
/// - 서버 없는 구조이므로 영수증 서버 검증은 하지 않습니다.
/// - 대신 "구매 완료/복원" 이벤트(purchaseStream)를 신뢰해 Pro 상태를 활성화합니다.
///
/// ⚠️ 중요:
/// - 이전에 발생한 에러("Null is not a subtype of Ref...")는
///   컨트롤러 내부에 Riverpod Ref를 필드로 들고 사용하면서 런타임 타입이 꼬인 케이스였습니다.
/// - 그래서 이 컨트롤러는 Ref를 저장하지 않고, IAP 서비스/스트림을 직접 관리합니다.
///
/// ✅ [추가]
/// - 서버/RTDN 없이 "환불/취소(권한 회수)"를 최대한 반영하려면
///   앱 시작 시점에 "스토어 소유(owned) 재검증"을 수행해야 합니다.
/// - Android: queryPastPurchases() 기반
/// - 스토어 연결 불가/오프라인이면 로컬 캐시를 유지하여 UX를 보호합니다.
class PurchaseController extends StateNotifier<PurchaseState> {
  PurchaseController() : super(const PurchaseState.loading()) {
    _init();
    _startListeningToPurchases();
  }

  final IapService _iap = IapService();

  /// ✅ purchaseStream 구독 핸들
  /// - 이전 코드에서는 _purchaseSub가 선언만 되어 있고 실제로 할당되지 않아
  ///   dispose 시 cancel이 동작하지 않는 문제가 생길 수 있었습니다.
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  /// ✅ 앱 시작 시 구매 상태 초기화 (로컬 저장값 기반)
  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isPro = prefs.getBool(_kPrefIsProLifetime) ?? false;

      // 📍 [추가] 무료 체험 횟수 로드 (기본값 3회)
      final trialCount = prefs.getInt(_kPrefTrialCount) ?? 3;

      // 1) 로컬 캐시로 즉시 화면 상태 복원 (UX: 빠르게 진입)
      if (isPro) {
        state = PurchaseState.pro(remainingTrialCount: trialCount);
      } else {
        state = PurchaseState.free(remainingTrialCount: trialCount);
      }

      // 2) ✅ [추가] 앱 시작 시점에 "스토어 소유(owned) 재검증" 수행
      // - 환불/취소 반영(owned 목록에서 SKU가 빠질 수 있음)
      // - 앱 재설치/기기 변경 등으로 prefs가 초기화되었어도 owned면 다시 Pro 복구 가능
      await _verifyProOwnershipAtAppStart();
    } catch (e) {
      // 로컬 로드 실패 시에도 앱 진입은 허용하되, Free로 안전하게 처리합니다.
      state = PurchaseState.error(e.toString());
    }
  }

  /// 📍 [추가] 무료 체험 시작 함수
  Future<void> startTrial() async {
    if (state.remainingTrialCount <= 0 || state.isPro) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final newCount = state.remainingTrialCount - 1;
      await prefs.setInt(_kPrefTrialCount, newCount);

      // 현재 상태에 체험 활성화 및 횟수 차감 반영
      state = state.copyWith(
        isTrialActive: true,
        remainingTrialCount: newCount,
      );
    } catch (e) {
      state = PurchaseState.error(e.toString());
    }
  }

  /// ✅ [추가] Settings 진입 등 "원하는 시점"에 스토어 소유(owned) 재검증을 재실행하기 위한 공개 메서드
  ///
  /// - SettingsScreen에서 이 메서드를 호출하면 됩니다.
  /// - 일단은 "메시지가 뜨는지만" 테스트 목적이므로,
  ///   결과를 StoreVerifyResult로 리턴하고, UI에서 SnackBar를 띄우는 방식이 가장 안전합니다.
  ///
  /// 정책:
  /// - 스토어 연결 가능하고, owned=true  → Pro 유지/복구
  /// - 스토어 연결 가능하고, owned=false → Pro 해제(환불/취소 반영)
  /// - 스토어 연결 불가/에러 → 로컬 캐시 유지(UX 보호)
  Future<StoreVerifyResult> verifyEntitlementFromStore() async {
    try {
      // 로딩 플래그만 켜고(상태 타입은 유지), UX를 크게 흔들지 않습니다.
      state = state.copyWith(isLoading: true, errorMessage: null);

      final available = await _iap.isAvailable();
      if (!available) {
        // 스토어 연결 불가면 캐시 유지
        state = state.copyWith(isLoading: false);

        return const StoreVerifyResult(
          storeAvailable: false,
          owned: null,
          message: 'Store not available (cache kept)',
        );
      }

      final owned = await _iap.isProLifetimeOwned();

      final prefs = await SharedPreferences.getInstance();
      final cachedIsPro = prefs.getBool(_kPrefIsProLifetime) ?? false;

      if (owned && !cachedIsPro) {
        // ✅ owned인데 로컬이 false면 → Pro 복구(재설치/기기변경 대응)
        await setPro(true);
      } else if (!owned && cachedIsPro) {
        // ✅ 로컬은 true인데 owned가 아니면 → Pro 해제(환불/취소 반영)
        await setPro(false);
      } else {
        // 동일 상태면 유지
      }

      state = state.copyWith(isLoading: false);

      return StoreVerifyResult(
        storeAvailable: true,
        owned: owned,
        //message: owned ? 'Owned = true (Pro 유지/복구)' : 'Owned = false (Pro 해제 가능)',
        message: null, // ✅ 메시지 생성 안 함
      );
    } catch (e) {
      // 스토어 확인 실패 시 즉시 박탈하면 CS/UX 문제가 커질 수 있으므로 캐시 유지
      state = state.copyWith(
        isLoading: false,
        // 앱 시작 단계에서는 과한 에러 노출을 피하기 위해 메시지를 최소화합니다.
        // 필요하면 Settings 화면에서만 노출하도록 분기할 수 있습니다.
        errorMessage: null,
      );

      return StoreVerifyResult(
        storeAvailable: true,
        owned: null,
        message: 'Verify failed (cache kept): ${e.toString()}',
      );
    }
  }

  /// ✅ [추가] 앱 시작 시점 스토어 기반 소유(owned) 재검증
  ///
  /// 정책:
  /// - 스토어 연결 가능하고, owned=true  → Pro 유지/복구
  /// - 스토어 연결 가능하고, owned=false → Pro 해제(환불/취소 반영)
  /// - 스토어 연결 불가/에러 → 로컬 캐시 유지(UX 보호)
  Future<void> _verifyProOwnershipAtAppStart() async {
    try {
      // 로딩 플래그만 켜고(상태 타입은 유지), UX를 크게 흔들지 않습니다.
      state = state.copyWith(isLoading: true, errorMessage: null);

      final available = await _iap.isAvailable();
      if (!available) {
        // 스토어 연결 불가면 캐시 유지
        state = state.copyWith(isLoading: false);
        return;
      }

      final owned = await _iap.isProLifetimeOwned();

      final prefs = await SharedPreferences.getInstance();
      final cachedIsPro = prefs.getBool(_kPrefIsProLifetime) ?? false;

      if (owned && !cachedIsPro) {
        // ✅ owned인데 로컬이 false면 → Pro 복구(재설치/기기변경 대응)
        await setPro(true);
      } else if (!owned && cachedIsPro) {
        // ✅ 로컬은 true인데 owned가 아니면 → Pro 해제(환불/취소 반영)
        await setPro(false);
      } else {
        // 동일 상태면 유지
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      // 스토어 확인 실패 시 즉시 박탈하면 CS/UX 문제가 커질 수 있으므로 캐시 유지
      state = state.copyWith(
        isLoading: false,
        // 앱 시작 단계에서는 과한 에러 노출을 피하기 위해 메시지를 최소화합니다.
        // 필요하면 Settings 화면에서만 노출하도록 분기할 수 있습니다.
        errorMessage: null,
      );
    }
  }

  /// ✅ 구매 스트림 리스닝
  void _startListeningToPurchases() {
    // 이미 구독 중이면 중복 방지
    if (_purchaseSub != null) return;

    // ✅ 핵심: in_app_purchase의 purchaseStream을 직접 구독해야
    // dispose에서 정상 cancel이 가능합니다.
    _purchaseSub = InAppPurchase.instance.purchaseStream.listen(
          (purchases) async {
        for (final p in purchases) {
          // ✅ 결제 진행 중 (pending) 상태 처리
          // - UI에서 로딩 표시를 유지하고 싶으면 여기서 isLoading true로 둡니다.
          if (p.status == PurchaseStatus.pending) {
            state = state.copyWith(isLoading: true, errorMessage: null);
            continue;
          }

          // ✅ 오류 상태
          if (p.status == PurchaseStatus.error) {
            state = PurchaseState.error(p.error?.message ?? 'Purchase error');

            // ✅ complete(acknowledge) 처리
            // - error 상태에서도 pendingCompletePurchase가 true일 수 있으므로 안전하게 처리
            await _iap.completeIfNeeded(p);
            continue;
          }

          // ✅ 사용자 취소 등 (플러그인 버전에 따라 canceled가 올 수 있음)
          // - PurchaseStatus enum에 canceled가 없다면 이 분기는 컴파일에 영향 없음(아래처럼 안전 처리)
          // - 여기서는 로딩만 끄고 종료합니다.
          if (p.status.toString() == 'PurchaseStatus.canceled') {
            state = state.copyWith(isLoading: false, errorMessage: null);
            await _iap.completeIfNeeded(p);
            continue;
          }

          // ✅ 구매 완료 or 복원 완료면 Pro 활성화
          if (p.status == PurchaseStatus.purchased ||
              p.status == PurchaseStatus.restored) {
            // ⚠️ 서버 검증(권장)을 하지 않는 구조이므로 여기서는 일단 성공을 신뢰합니다.
            // TODO(권장): 서버 검증 도입 시, 여기에서 purchaseToken/verificationData를 검증 후 setPro(true)

            if (p.productID == kSireProLifetimeProductId) {
              await setPro(true);
            }
          }

          // ✅ complete(acknowledge) 처리
          await _iap.completeIfNeeded(p);
        }

        // 이벤트 처리 끝나면 로딩 종료
        state = state.copyWith(isLoading: false);
      },
      onError: (err) {
        state = PurchaseState.error(err.toString());
      },
    );
  }

  /// ✅ Pro 상태로 변경(저장 포함)
  Future<void> setPro(bool value) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kPrefIsProLifetime, value);

      if (value) {
        // 📍 Pro 구매 시 체험 상태는 해제하고 Pro로 진입
        state = PurchaseState.pro(
          remainingTrialCount: state.remainingTrialCount,
          isTrialActive: false,
        );
      } else {
        state = PurchaseState.free(remainingTrialCount: state.remainingTrialCount);
      }
    } catch (e) {
      state = PurchaseState.error(e.toString());
    }
  }

  /// ✅ 상태 다시 로드
  /// - 로컬 저장값 기반으로 빠르게 상태를 복구합니다.
  /// - "스토어 복원(restorePurchases)"은 별도 버튼에서 호출하는 구조가 더 안정적입니다.
  Future<void> reload() async {
    state = const PurchaseState.loading();
    await _init();
  }

  // ---------------------------------------------------------------------------
  // ✅ IAP 연동 메서드 (Settings/Paywall에서 호출)
  // ---------------------------------------------------------------------------

  /// ✅ 평생(Pro) 구매 시작
  Future<void> purchaseProLifetime() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final available = await _iap.isAvailable();
      if (!available) {
        state = PurchaseState.error('Store not available');
        return;
      }

      final product = await _iap.queryProLifetimeProduct();
      if (product == null) {
        state =
            PurchaseState.error('Product not found: $kSireProLifetimeProductId');
        return;
      }

      // buyNonConsumable 호출 후 결과는 purchaseStream에서 처리됩니다.
      await _iap.buyProLifetime(product);

      // 여기서 바로 pro 처리하지 않습니다.
      // 실제 성공/복원/에러는 purchaseStream에서 들어오므로, UI는 로딩만 잠깐 꺼줍니다.
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = PurchaseState.error(e.toString());
    }
  }

  /// ✅ 구매 복원
  Future<void> restorePurchases() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final available = await _iap.isAvailable();
      if (!available) {
        state = PurchaseState.error('Store not available');
        return;
      }

      // restore 호출 후 결과는 purchaseStream에서 처리됩니다.
      await _iap.restore();

      // ✅ (선택) 복원 직후에도 owned 재확인하고 싶다면 아래를 활성화할 수 있습니다.
      // - 서버 없이 환불/취소 반영 정확도를 조금 더 올리는 용도
      // await _verifyProOwnershipAtAppStart();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = PurchaseState.error(e.toString());
    }
  }

  /// ✅ dispose
  @override
  void dispose() {
    _purchaseSub?.cancel();
    _purchaseSub = null;
    _iap.dispose();
    super.dispose();
  }
}