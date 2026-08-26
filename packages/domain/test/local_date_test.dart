import 'package:dopa_domain/dopa_domain.dart';
import 'package:test/test.dart';

void main() {
  group('LocalDate', () {
    test('parses, formats, compares, and adds days', () {
      final date = LocalDate.parse('2024-02-29');

      expect(date, LocalDate(2024, 2, 29));
      expect(date.toIso8601String(), '2024-02-29');
      expect(date.addDays(1), LocalDate(2024, 3, 1));
      expect(date.compareTo(LocalDate(2024, 3, 1)), isNegative);
    });

    test('captures the calendar fields of the supplied local DateTime', () {
      final local = DateTime(2026, 8, 26, 23, 59);

      expect(LocalDate.fromLocal(local), LocalDate(2026, 8, 26));
    });

    test('rejects normalized and malformed dates', () {
      expect(() => LocalDate(2023, 2, 29), throwsArgumentError);
      expect(() => LocalDate(2026, 13, 1), throwsArgumentError);
      expect(() => LocalDate.parse('2026-8-01'), throwsFormatException);
      expect(() => LocalDate.parse('2026-02-30'), throwsFormatException);
    });
  });
}
