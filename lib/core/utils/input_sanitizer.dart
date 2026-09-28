import 'package:flutter/services.dart';

/// Centralized utility for client-side input sanitization, filtering, and validation.
///
/// Ensures all user-supplied input (usernames, league names, chat messages, invite codes, etc.)
/// is thoroughly sanitized and stripped of null bytes, control characters, SQL injection characters,
/// and script tags before being transmitted to Supabase.
abstract final class InputSanitizer {
  /// Regular expression matching strictly alphanumeric characters and underscores.
  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');

  /// Regular expression to match any character NOT allowed in usernames.
  static final RegExp _usernameDisallowedChars = RegExp(r'[^a-zA-Z0-9_]');

  /// Regular expression to match null bytes and non-printable ASCII control characters.
  static final RegExp _controlCharsRegex = RegExp(r'[\x00-\x1F\x7F]');

  /// Regular expression matching dangerous characters commonly used in injection / XSS:
  /// null bytes, control chars, angle brackets (< >), quotes (" '), backslash (\), semicolons (;).
  static final RegExp _dangerousCharsRegex = RegExp(r'[\x00-\x1F\x7F<>"' "'" r';\\]');

  /// Regular expression matching multiple consecutive whitespace characters.
  static final RegExp _multipleWhitespaceRegex = RegExp(r'\s+');

  /// Regular expression for invite codes: exactly 6 uppercase alphanumeric characters.
  static final RegExp _inviteCodeRegex = RegExp(r'^[A-Z0-9]{6}$');

  // ==========================================
  // USERNAME
  // ==========================================

  /// TextInputFormatters to attach to username [TextField]s.
  /// Physically blocks typing anything other than letters, numbers, and underscores,
  /// and caps input length to 20 characters.
  static List<TextInputFormatter> get usernameFormatters => [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
        LengthLimitingTextInputFormatter(20),
      ];

  /// Strips any invalid characters from [input], trims whitespace, and limits length to 20.
  static String sanitizeUsername(String input) {
    var cleaned = input.replaceAll(_usernameDisallowedChars, '').trim();
    if (cleaned.length > 20) {
      cleaned = cleaned.substring(0, 20);
    }
    return cleaned;
  }

  /// Returns `true` if [input] is a valid username:
  /// - 3 to 20 characters long
  /// - Contains only alphanumeric characters and underscores `[a-zA-Z0-9_]`
  /// - No spaces, null bytes, or special characters
  static bool isValidUsername(String input) {
    return _usernameRegex.hasMatch(input.trim());
  }

  // ==========================================
  // LEAGUE NAME
  // ==========================================

  /// TextInputFormatters for league name [TextField]s.
  /// Denies null bytes, control characters, angle brackets, quotes, semicolons, and backslashes,
  /// and limits maximum length to 30 characters.
  static List<TextInputFormatter> get leagueNameFormatters => [
        FilteringTextInputFormatter.deny(_dangerousCharsRegex),
        LengthLimitingTextInputFormatter(30),
      ];

  /// Strips dangerous characters (< > ; " ' \ and control characters) from [input],
  /// collapses multiple consecutive whitespace characters to a single space,
  /// trims whitespace, and limits length to 30 characters.
  static String sanitizeLeagueName(String input) {
    var cleaned = input
        .replaceAll(_dangerousCharsRegex, '')
        .replaceAll(_multipleWhitespaceRegex, ' ')
        .trim();
    if (cleaned.length > 30) {
      cleaned = cleaned.substring(0, 30);
    }
    return cleaned;
  }

  /// Returns `true` if [input] is a valid league name:
  /// - Sanitized length between 3 and 30 characters
  /// - Does not contain dangerous characters
  static bool isValidLeagueName(String input) {
    final cleaned = sanitizeLeagueName(input);
    return cleaned.length >= 3 && cleaned.length <= 30;
  }

  // ==========================================
  // CHAT MESSAGES
  // ==========================================

  /// TextInputFormatters for chat message [TextField]s.
  /// Denies null bytes and non-printable control characters,
  /// and limits length to 500 characters.
  static List<TextInputFormatter> get chatMessageFormatters => [
        FilteringTextInputFormatter.deny(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]')),
        LengthLimitingTextInputFormatter(500),
      ];

  /// Strips null bytes, non-printable control characters, and collapses runaway newlines.
  /// Caps length to 500 characters.
  static String sanitizeChatMessage(String input) {
    var cleaned = input
        .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '')
        .trim();
    if (cleaned.length > 500) {
      cleaned = cleaned.substring(0, 500);
    }
    return cleaned;
  }

  // ==========================================
  // INVITE CODES
  // ==========================================

  /// Strips everything except uppercase alphanumeric characters, capping at 6 characters.
  static String sanitizeInviteCode(String input) {
    final uppercase = input.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    return uppercase.length > 6 ? uppercase.substring(0, 6) : uppercase;
  }

  /// Returns `true` if [input] is exactly a 6-character uppercase alphanumeric code.
  static bool isValidInviteCode(String input) {
    return _inviteCodeRegex.hasMatch(input.trim().toUpperCase());
  }

  // ==========================================
  // SEARCH QUERIES
  // ==========================================

  /// TextInputFormatters for search [TextField]s.
  /// Limits length to 50 characters and denies control characters.
  static List<TextInputFormatter> get searchFormatters => [
        FilteringTextInputFormatter.deny(_controlCharsRegex),
        LengthLimitingTextInputFormatter(50),
      ];

  /// Sanitizes search query strings by stripping null bytes and control characters,
  /// trimming, and limiting length to 50 characters.
  static String sanitizeSearchQuery(String input) {
    var cleaned = input.replaceAll(_controlCharsRegex, '').trim();
    if (cleaned.length > 50) {
      cleaned = cleaned.substring(0, 50);
    }
    return cleaned;
  }

  // ==========================================
  // POSTGRES / SUPABASE ESCAPING
  // ==========================================

  /// Escapes PostgreSQL LIKE/ILIKE wildcards (`_` and `%`) so user input in
  /// Supabase `.ilike('username', ...)` is treated as literal characters rather
  /// than matching arbitrary characters.
  static String escapeSqlWildcards(String input) {
    return input.replaceAll(r'\', r'\\').replaceAll('_', r'\_').replaceAll('%', r'\%');
  }
}
