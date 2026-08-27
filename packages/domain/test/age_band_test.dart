import 'package:dopa_domain/dopa_domain.dart';
import 'package:test/test.dart';

void main() {
  group('ageBandOn', () {
    test('blocks the day before the 14th birthday and allows the birthday', () {
      final birth = LocalDate(2012, 8, 27);

      expect(
        ageBandOn(dateOfBirth: birth, today: LocalDate(2026, 8, 26)),
        AgeBand.under14,
      );
      expect(
        ageBandOn(dateOfBirth: birth, today: LocalDate(2026, 8, 27)),
        AgeBand.age14To17,
      );
    });

    test('becomes adult on the 18th birthday', () {
      final birth = LocalDate(2008, 3, 1);

      expect(
        ageBandOn(dateOfBirth: birth, today: LocalDate(2026, 2, 28)),
        AgeBand.age14To17,
      );
      expect(
        ageBandOn(dateOfBirth: birth, today: LocalDate(2026, 3, 1)),
        AgeBand.adult18Plus,
      );
    });

    test('maps February 29 births onto February 28 in non-leap years', () {
      final birth = LocalDate(2008, 2, 29);

      expect(
        ageBandOn(dateOfBirth: birth, today: LocalDate(2022, 2, 27)),
        AgeBand.under14,
      );
      expect(
        ageBandOn(dateOfBirth: birth, today: LocalDate(2022, 2, 28)),
        AgeBand.age14To17,
      );
    });
  });

  group('needsAgeReattestation', () {
    test('rechecks age14To17 after 12 calendar months', () {
      expect(
        needsAgeReattestation(
          ageBand: AgeBand.age14To17,
          ageAttestedOn: LocalDate(2025, 8, 27),
          today: LocalDate(2026, 8, 26),
        ),
        isFalse,
      );
      expect(
        needsAgeReattestation(
          ageBand: AgeBand.age14To17,
          ageAttestedOn: LocalDate(2025, 8, 27),
          today: LocalDate(2026, 8, 27),
        ),
        isTrue,
      );
      expect(
        needsAgeReattestation(
          ageBand: AgeBand.adult18Plus,
          ageAttestedOn: LocalDate(2025, 8, 27),
          today: LocalDate(2026, 8, 27),
        ),
        isFalse,
      );
    });
  });
}
