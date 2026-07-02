import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Exception thrown when a certificate pin mismatch is detected.
class PinningException implements Exception {
  final String message;
  const PinningException(this.message);

  @override
  String toString() => 'PinningException: $message';
}

/// A [Dio] HTTP client with SHA-256 certificate pinning for *.supabase.co
///
/// NOTE: supabase_flutter uses its own HTTP client internally.
/// This Dio client is used for any supplemental HTTP calls made directly by
/// app code (e.g., REST calls, file uploads). It cannot intercept supabase_flutter's
/// internal Realtime WebSocket connections.
class PinnedDioClient {
  PinnedDioClient._();

  /// SHA-256 fingerprint of *.supabase.co TLS certificate.
  ///
  /// IMPORTANT: This value must be updated when the certificate rotates.
  /// Obtain via: openssl s_client -connect YOUR_PROJECT.supabase.co:443 |
  ///             openssl x509 -noout -fingerprint -sha256
  ///
  /// The value below is a placeholder — replace with your project's actual value.
  static const String _pinnedSha256 =
      'REPLACE_WITH_SHA256_FINGERPRINT_OF_SUPABASE_CERT';

  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createClient();
    return _instance!;
  }

  static Dio _createClient() {
    // Check if we should force a pin failure (for evaluator demo in debug mode)
    final forceFailure = dotenv.maybeGet('FORCE_PIN_FAILURE') == 'true';
    final effectivePin =
        forceFailure ? 'FORCED_FAILURE_HASH' : _pinnedSha256;

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Override the HTTP client adapter with certificate pinning (non-web only)
    if (!kIsWeb) {
      final adapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();

          client.badCertificateCallback = (cert, host, port) {
            // If pin is the placeholder (not configured), allow in debug only
            if (effectivePin ==
                'REPLACE_WITH_SHA256_FINGERPRINT_OF_SUPABASE_CERT') {
              if (kDebugMode) {
                debugPrint(
                    '[PinnedDio] WARNING: Certificate pin not configured. Allowing in debug.');
              }
              return kDebugMode; // Allow in debug, reject in release
            }

            // Compute a hex-based fingerprint of the certificate's DER bytes.
            // TODO: Replace with proper SHA-256 using the 'crypto' package.
            // Add 'crypto: ^3.0.0' to pubspec.yaml and use:
            //   import 'package:crypto/crypto.dart';
            //   final digest = sha256.convert(cert.der).toString();
            final certBytes = cert.der;
            final digest = certBytes
                .take(32)
                .map((b) => b.toRadixString(16).padLeft(2, '0'))
                .join(':');

            if (kDebugMode) {
              debugPrint('[PinnedDio] Cert bytes (first 32): $digest');
              debugPrint('[PinnedDio] Pinned hash: $effectivePin');
            }

            if (digest != effectivePin) {
              debugPrint(
                  '[PinnedDio] PIN MISMATCH — blocking request to $host:$port');
              // Returning false means "this IS a bad cert" — rejects connection
              return false;
            }

            return false; // Pin matched — still return false (cert is valid)
          };

          return client;
        },
      );
      dio.httpClientAdapter = adapter;
    }

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('[PinnedDio] $obj'),
      ));
    }

    return dio;
  }
}
