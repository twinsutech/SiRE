// lib/core/purchase/models/entitlement.dart

/// ✅ 앱 내 권한(Entitlement) 정의
/// - 현재는 "평생 Pro" 단일 상품만 운영하므로 pro/free만 있으면 충분합니다.
/// - 추후 구독/추가 등급이 생기면 여기 enum만 확장하면 됩니다.
enum Entitlement {
  free,
  pro,
}
