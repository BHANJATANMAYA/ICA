import 'dart:math';

/// A utility to generate RFC 4122 compliant version 4 UUIDs.
/// Used for inserting UUID-compliant primary keys (e.g. for geofence_logs,
/// notifications, etc.) into the remote Postgres/Supabase database.
class UuidGenerator {
  UuidGenerator._();

  /// Generates a random version 4 UUID.
  static String generate() {
    final random = Random.secure();
    final hexDigits = '0123456789abcdef';
    
    final charCodes = List<int>.generate(36, (index) {
      if (index == 8 || index == 13 || index == 18 || index == 23) {
        return 45; // '-' character code
      }
      if (index == 14) {
        return 52; // '4' character code
      }
      int hexVal = random.nextInt(16);
      if (index == 19) {
        hexVal = (hexVal & 0x3) | 0x8; // variant 8, 9, a, or b
      }
      return hexDigits.codeUnitAt(hexVal);
    });
    
    return String.fromCharCodes(charCodes);
  }
}
