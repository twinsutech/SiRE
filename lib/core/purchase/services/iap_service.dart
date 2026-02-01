// // lib/core/purchase/services/iap_service.dart
//
// import 'dart:async';
//
// import 'package:in_app_purchase/in_app_purchase.dart';
//
// /// ✅ [정리] SiRE IAP 상품 ID
// /// - 평생(Pro) 단일 상품
// const String kSireProLifetimeProductId = 'sire_pro_lifetime';
//
// /// ✅ [정리] IAP 서비스 (in_app_purchase 래퍼)
// /// - 서버 없는 구조이므로 영수증 서버 검증은 하지 않습니다.
// /// - 대신 "구매 완료/복원" 이벤트를 신뢰하고 Pro 상태를 활성화하는 흐름입니다.
// /// - 핵심:
// ///   1) 상품 조회(queryProductDetails)
// ///   2) 구매(buyNonConsumable)
// ///   3) 구매 스트림 리스닝(purchaseStream)
// ///   4) 구매 완료 처리(completePurchase / acknowledge)
// class IapService {
//   final InAppPurchase _iap = InAppPurchase.instance;
//
//   StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
//
//   /// ✅ 스토어 연결 가능 여부
//   Future<bool> isAvailable() async {
//     return _iap.isAvailable();
//   }
//
//   /// ✅ 구매 스트림 리스닝 시작
//   /// - UI 레벨에서 한 번만 호출되도록 PurchaseController에서 관리합니다.
//   /// - 콜백으로 구매 업데이트를 전달합니다.
//   void startListening({
//     required void Function(List<PurchaseDetails> purchases) onPurchasesUpdated,
//     required void Function(Object error) onError,
//   }) {
//     // 이미 구독 중이면 중복 구독 방지
//     if (_purchaseSub != null) return;
//
//     _purchaseSub = _iap.purchaseStream.listen(
//           (purchases) => onPurchasesUpdated(purchases),
//       onError: onError,
//     );
//   }
//
//   /// ✅ 상품 정보 조회
//   Future<ProductDetails?> queryProLifetimeProduct() async {
//     final response = await _iap.queryProductDetails({kSireProLifetimeProductId});
//     if (response.error != null) return null;
//     if (response.productDetails.isEmpty) return null;
//     return response.productDetails.first;
//   }
//
//   /// ✅ 평생(Pro) 구매 시작
//   Future<void> buyProLifetime(ProductDetails product) async {
//     final purchaseParam = PurchaseParam(productDetails: product);
//     await _iap.buyNonConsumable(purchaseParam: purchaseParam);
//   }
//
//   /// ✅ 구매 복원 (Android에서도 호출 가능)
//   /// - 실제로는 restorePurchases가 purchaseStream으로 restored 이벤트를 흘려줍니다.
//   Future<void> restore() async {
//     await _iap.restorePurchases();
//   }
//
//   /// ✅ 구매 완료(ack/complete) 처리
//   /// - 구매 완료 후에는 반드시 completePurchase 호출 필요
//   Future<void> completeIfNeeded(PurchaseDetails purchase) async {
//     if (purchase.pendingCompletePurchase) {
//       await _iap.completePurchase(purchase);
//     }
//   }
//
//   /// ✅ dispose
//   void dispose() {
//     _purchaseSub?.cancel();
//     _purchaseSub = null;
//   }
// }



// lib/core/purchase/services/iap_service.dart

import 'dart:async';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';

// ✅ [추가] Android 전용: queryPastPurchases() 사용
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

/// ✅ [정리] SiRE IAP 상품 ID
/// - 평생(Pro) 단일 상품
const String kSireProLifetimeProductId = 'sire_pro_lifetime';

/// ✅ [정리] IAP 서비스 (in_app_purchase 래퍼)
/// - 서버 없는 구조이므로 영수증 서버 검증은 하지 않습니다.
/// - 대신 "구매 완료/복원" 이벤트를 신뢰하고 Pro 상태를 활성화하는 흐름입니다.
/// - 핵심:
///   1) 상품 조회(queryProductDetails)
///   2) 구매(buyNonConsumable)
///   3) 구매 스트림 리스닝(purchaseStream)
///   4) 구매 완료 처리(completePurchase / acknowledge)
///
/// ✅ [추가]
/// - 서버 없이 "환불/취소(권한 회수)"를 최대한 반영하기 위해,
///   Android에서는 queryPastPurchases()를 통해 "현재 소유(owned) 목록"을 조회하여
///   SKU가 존재하는지로 Pro 유지 여부를 판단할 수 있습니다.
/// - 단, 오프라인/스토어 연결 불가/캐시 갱신 전에는 최신 상태가 아닐 수 있습니다.
class IapService {
  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  /// ✅ 스토어 연결 가능 여부
  Future<bool> isAvailable() async {
    return _iap.isAvailable();
  }

  /// ✅ 구매 스트림 리스닝 시작
  /// - UI 레벨에서 한 번만 호출되도록 PurchaseController에서 관리합니다.
  /// - 콜백으로 구매 업데이트를 전달합니다.
  void startListening({
    required void Function(List<PurchaseDetails> purchases) onPurchasesUpdated,
    required void Function(Object error) onError,
  }) {
    // 이미 구독 중이면 중복 구독 방지
    if (_purchaseSub != null) return;

    _purchaseSub = _iap.purchaseStream.listen(
          (purchases) => onPurchasesUpdated(purchases),
      onError: onError,
    );
  }

  /// ✅ 상품 정보 조회
  Future<ProductDetails?> queryProLifetimeProduct() async {
    final response = await _iap.queryProductDetails({kSireProLifetimeProductId});
    if (response.error != null) return null;
    if (response.productDetails.isEmpty) return null;
    return response.productDetails.first;
  }

  /// ✅ 평생(Pro) 구매 시작
  Future<void> buyProLifetime(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// ✅ 구매 복원 (Android에서도 호출 가능)
  /// - 실제로는 restorePurchases가 purchaseStream으로 restored 이벤트를 흘려줍니다.
  Future<void> restore() async {
    await _iap.restorePurchases();
  }

  /// ✅ 구매 완료(ack/complete) 처리
  /// - 구매 완료 후에는 반드시 completePurchase 호출 필요
  Future<void> completeIfNeeded(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  // ---------------------------------------------------------------------------
  // ✅ [추가] 서버 없는 구조에서 가능한 "스토어 기반 소유(owned) 재검증"
  // ---------------------------------------------------------------------------

  /// ✅ 평생(Pro) 상품이 "현재 소유(owned)" 상태인지 확인합니다.
  ///
  /// - 서버/Developer API/RTDN 없이 할 수 있는 현실적인 방법:
  ///   Android: queryPastPurchases() → pastPurchases 목록에 SKU가 존재하는지 확인
  ///
  /// ⚠️ 한계:
  /// - 오프라인/스토어 연결 불가 시 최신 상태 확인 불가
  /// - Play 캐시 갱신 전에는 환불 직후에도 목록이 즉시 반영되지 않을 수 있음
  Future<bool> isProLifetimeOwned() async {
    // 현재 운영 범위가 Google Play(Android) 기준이므로 Android 중심으로 처리합니다.
    if (!Platform.isAndroid) return false;

    final available = await isAvailable();
    if (!available) return false;

    final androidAddition =
    _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();

    final QueryPurchaseDetailsResponse response =
    await androidAddition.queryPastPurchases();

    if (response.error != null) {
      // 상위 레벨(Controller)에서 UX 정책에 따라 처리할 수 있도록 예외로 전달
      throw Exception(response.error!.message ?? 'queryPastPurchases failed');
    }

    final pastPurchases = response.pastPurchases;

    // "현재 소유" 판단:
    // - productID 일치
    // - status가 purchased/restored 인 항목 존재 여부
    final owned = pastPurchases.any((p) {
      final isTarget = p.productID == kSireProLifetimeProductId;
      final isEntitled = p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored;
      return isTarget && isEntitled;
    });

    return owned;
  }

  /// ✅ dispose
  void dispose() {
    _purchaseSub?.cancel();
    _purchaseSub = null;
  }
}
