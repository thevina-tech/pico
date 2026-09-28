import 'package:flutter_test/flutter_test.dart';
import 'package:pico/core/utils/input_sanitizer.dart';

void main() {
  group('InputSanitizer - Username', () {
    test('sanitizeUsername removes non-alphanumeric and non-underscore characters', () {
      expect(InputSanitizer.sanitizeUsername('striker@99!'), equals('striker99'));
      expect(InputSanitizer.sanitizeUsername('  joao_pro  '), equals('joao_pro'));
      expect(InputSanitizer.sanitizeUsername("Bob'); DROP TABLE;--"), equals('BobDROPTABLE'));
      expect(InputSanitizer.sanitizeUsername('<script>alert(1)</script>'), equals('scriptalert1script'));
      expect(InputSanitizer.sanitizeUsername('user\x00name\x1F'), equals('username'));
    });

    test('sanitizeUsername truncates to 20 characters', () {
      final long = 'a' * 30;
      final sanitized = InputSanitizer.sanitizeUsername(long);
      expect(sanitized.length, equals(20));
      expect(sanitized, equals('a' * 20));
    });

    test('isValidUsername validates correctly', () {
      // Valid usernames
      expect(InputSanitizer.isValidUsername('striker99'), isTrue);
      expect(InputSanitizer.isValidUsername('CR7'), isTrue);
      expect(InputSanitizer.isValidUsername('ronaldo_fan_1'), isTrue);
      expect(InputSanitizer.isValidUsername('a' * 20), isTrue);

      // Invalid usernames
      expect(InputSanitizer.isValidUsername(''), isFalse);
      expect(InputSanitizer.isValidUsername('ab'), isFalse); // < 3 chars
      expect(InputSanitizer.isValidUsername('a' * 21), isFalse); // > 20 chars
      expect(InputSanitizer.isValidUsername('striker 99'), isFalse); // spaces
      expect(InputSanitizer.isValidUsername('user@domain'), isFalse); // special char
      expect(InputSanitizer.isValidUsername('user-name'), isFalse); // hyphen
      expect(InputSanitizer.isValidUsername("admin'--"), isFalse); // SQL injection
      expect(InputSanitizer.isValidUsername('user\x00name'), isFalse); // null byte
    });

    test('usernameFormatters allow only valid characters and limit length', () {
      final formatters = InputSanitizer.usernameFormatters;
      expect(formatters.length, equals(2));
    });
  });

  group('InputSanitizer - League Name', () {
    test('sanitizeLeagueName strips dangerous characters and collapses whitespace', () {
      expect(
        InputSanitizer.sanitizeLeagueName('  The <Champions> ; "League"  '),
        equals('The Champions League'),
      );
      expect(
        InputSanitizer.sanitizeLeagueName("Premier 'League' \\ ; DROP"),
        equals('Premier League DROP'),
      );
      expect(
        InputSanitizer.sanitizeLeagueName('League   with    many     spaces'),
        equals('League with many spaces'),
      );
      expect(
        InputSanitizer.sanitizeLeagueName('Null\x00Byte\x1FLeague'),
        equals('NullByteLeague'),
      );
    });

    test('sanitizeLeagueName truncates to 30 characters', () {
      final long = 'A' * 40;
      final sanitized = InputSanitizer.sanitizeLeagueName(long);
      expect(sanitized.length, equals(30));
    });

    test('isValidLeagueName checks sanitized length 3-30', () {
      expect(InputSanitizer.isValidLeagueName('Premier League'), isTrue);
      expect(InputSanitizer.isValidLeagueName('La Liga Friends'), isTrue);
      expect(InputSanitizer.isValidLeagueName('Ab'), isFalse); // Too short
      expect(InputSanitizer.isValidLeagueName(''), isFalse);
      expect(InputSanitizer.isValidLeagueName('   '), isFalse);
      expect(InputSanitizer.isValidLeagueName('<<<>>>;;;'), isFalse); // Stripped to empty
    });
  });

  group('InputSanitizer - Chat Messages', () {
    test('sanitizeChatMessage strips null bytes and control chars', () {
      expect(
        InputSanitizer.sanitizeChatMessage('Hello\x00World\x1F!'),
        equals('HelloWorld!'),
      );
      expect(
        InputSanitizer.sanitizeChatMessage('   Great goal!   '),
        equals('Great goal!'),
      );
    });

    test('sanitizeChatMessage limits length to 500 characters', () {
      final long = 'M' * 600;
      final sanitized = InputSanitizer.sanitizeChatMessage(long);
      expect(sanitized.length, equals(500));
    });
  });

  group('InputSanitizer - Invite Codes', () {
    test('sanitizeInviteCode extracts uppercase alphanumeric up to 6 characters', () {
      expect(InputSanitizer.sanitizeInviteCode('k9x2p1'), equals('K9X2P1'));
      expect(InputSanitizer.sanitizeInviteCode('k9-x2_p1!extra'), equals('K9X2P1'));
      expect(InputSanitizer.sanitizeInviteCode('abc'), equals('ABC'));
    });

    test('isValidInviteCode requires exactly 6 alphanumeric characters', () {
      expect(InputSanitizer.isValidInviteCode('K9X2P1'), isTrue);
      expect(InputSanitizer.isValidInviteCode('ABCDEF'), isTrue);
      expect(InputSanitizer.isValidInviteCode('123456'), isTrue);
      expect(InputSanitizer.isValidInviteCode('K9X2P'), isFalse); // 5 chars
      expect(InputSanitizer.isValidInviteCode('K9X2P12'), isFalse); // 7 chars
      expect(InputSanitizer.isValidInviteCode('K9X 2P'), isFalse); // space
      expect(InputSanitizer.isValidInviteCode('K9X-2P'), isFalse); // dash
    });
  });

  group('InputSanitizer - Search Query', () {
    test('sanitizeSearchQuery strips control characters and limits length', () {
      expect(InputSanitizer.sanitizeSearchQuery('  Real Madrid\x00  '), equals('Real Madrid'));
      final long = 'a' * 60;
      expect(InputSanitizer.sanitizeSearchQuery(long).length, equals(50));
    });
  });

  group('InputSanitizer - SQL Wildcards Escaping', () {
    test('escapeSqlWildcards escapes underscore, percent, and backslash', () {
      expect(InputSanitizer.escapeSqlWildcards('john_doe'), equals(r'john\_doe'));
      expect(InputSanitizer.escapeSqlWildcards('100%real'), equals(r'100\%real'));
      expect(InputSanitizer.escapeSqlWildcards(r'path\to_file%'), equals(r'path\\to\_file\%'));
    });
  });
}
