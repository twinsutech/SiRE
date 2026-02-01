//package com.obj.sire
//
//import android.os.Bundle
//import android.util.Log
//import com.google.android.play.core.integrity.IntegrityManagerFactory
//import com.google.android.play.core.integrity.IntegrityTokenRequest
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodChannel
//import java.security.SecureRandom
//import java.util.Base64
//
//class MainActivity : FlutterActivity() {
//
//    private val channelName = "com.obj.sire/integrity"
//
//    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
//            .setMethodCallHandler { call, result ->
//                when (call.method) {
//                    "requestIntegrityToken" -> {
//                        val nonce = generateNonce()
//
//                        requestIntegrityToken(
//                            nonce = nonce,
//                            onSuccess = { token ->
//                                Log.d("Integrity", "Token OK (len=${token.length})")
//                                result.success(
//                                    mapOf(
//                                        "ok" to true,
//                                        "nonce" to nonce,
//                                        "token" to token
//                                    )
//                                )
//                            },
//                            onError = { code, message ->
//                                Log.e("Integrity", "Token FAIL code=$code msg=$message")
//                                result.success(
//                                    mapOf(
//                                        "ok" to false,
//                                        "nonce" to nonce,
//                                        "errorCode" to code,
//                                        "errorMessage" to message
//                                    )
//                                )
//                            }
//                        )
//                    }
//                    else -> result.notImplemented()
//                }
//            }
//    }
//
//    private fun requestIntegrityToken(
//        nonce: String,
//        onSuccess: (String) -> Unit,
//        onError: (Int, String) -> Unit
//    ) {
//        val integrityManager = IntegrityManagerFactory.create(this)
//
//        val request = IntegrityTokenRequest.builder()
//            .setNonce(nonce)
//            .build()
//
//        integrityManager.requestIntegrityToken(request)
//            .addOnSuccessListener { response ->
//                onSuccess(response.token())
//            }
//            .addOnFailureListener { e ->
//                // 에러코드가 별도로 안 내려오는 케이스가 많아 우선 -1로 통일
//                onError(-1, e.message ?: "Integrity request failed")
//            }
//    }
//
//    private fun generateNonce(): String {
//        val bytes = ByteArray(32)
//        SecureRandom().nextBytes(bytes)
//        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes)
//    }
//}



package com.obj.sire

import android.util.Log
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant // ✅ [추가] 플러그인 등록 강제
import java.security.SecureRandom

class MainActivity : FlutterActivity() {

    private val channelName = "com.obj.sire/integrity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // ✅ Flutter 기본 플러그인 등록을 먼저 수행합니다.
        // - 일부 환경에서 super.configureFlutterEngine()만으로 플러그인 등록이 누락되는 케이스가 있어,
        //   GeneratedPluginRegistrant를 명시적으로 호출해 Pigeon 채널(in_app_purchase_android 등)을 보장합니다.
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        // ✅ Play Integrity 전용 MethodChannel (기존 기능 유지)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestIntegrityToken" -> {
                        val nonce = generateNonce()

                        requestIntegrityToken(
                            nonce = nonce,
                            onSuccess = { token ->
                                Log.d("Integrity", "Token OK (len=${token.length})")
                                result.success(
                                    mapOf(
                                        "ok" to true,
                                        "nonce" to nonce,
                                        "token" to token
                                    )
                                )
                            },
                            onError = { code, message ->
                                Log.e("Integrity", "Token FAIL code=$code msg=$message")
                                result.success(
                                    mapOf(
                                        "ok" to false,
                                        "nonce" to nonce,
                                        "errorCode" to code,
                                        "errorMessage" to message
                                    )
                                )
                            }
                        )
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun requestIntegrityToken(
        nonce: String,
        onSuccess: (String) -> Unit,
        onError: (Int, String) -> Unit
    ) {
        val integrityManager = IntegrityManagerFactory.create(this)

        val request = IntegrityTokenRequest.builder()
            .setNonce(nonce)
            .build()

        integrityManager.requestIntegrityToken(request)
            .addOnSuccessListener { response ->
                onSuccess(response.token())
            }
            .addOnFailureListener { e ->
                // 에러코드가 별도로 안 내려오는 케이스가 많아 우선 -1로 통일
                onError(-1, e.message ?: "Integrity request failed")
            }
    }

    private fun generateNonce(): String {
        val bytes = ByteArray(32)
        SecureRandom().nextBytes(bytes)

        // ✅ [수정] java.util.Base64 대신 android.util.Base64 사용 (API 호환성 안정)
        // URL_SAFE + NO_WRAP으로 URL-safe 형태로 만들고,
        // padding("=")은 제거해 기존 withoutPadding()과 동일한 효과를 냅니다.
        val encoded = android.util.Base64.encodeToString(
            bytes,
            android.util.Base64.URL_SAFE or android.util.Base64.NO_WRAP
        )
        return encoded.trimEnd('=')
    }
}
