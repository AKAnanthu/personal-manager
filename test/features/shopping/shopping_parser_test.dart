import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping_parser.dart';

/// (input line, name, quantity, unit, needsReview)
typedef Case = (String, String, String?, String?, bool);

void main() {
  group('single lines', () {
    const cases = <Case>[
      // The PRD example.
      ('Milk 2', 'Milk', '2', null, false),
      ('Bread 1', 'Bread', '1', null, false),
      ('Rice 5 kg', 'Rice', '5', 'kg', false),
      ('Sugar 2 kg', 'Sugar', '2', 'kg', false),
      ('Eggs 12', 'Eggs', '12', null, false),
      ('Soap 4', 'Soap', '4', null, false),
      // Quantity first.
      ('2 Milk', 'Milk', '2', null, false),
      ('5 kg rice', 'Rice', '5', 'kg', false),
      ('5kg rice', 'Rice', '5', 'kg', false),
      ('5 kg of rice', 'Rice', '5', 'kg', false),
      ('2x milk', 'Milk', '2', null, false),
      ('2 x milk', 'Milk', '2', null, false),
      ('2 dozen eggs', 'Eggs', '2', 'dozen', false),
      // Separators.
      ('Milk - 2', 'Milk', '2', null, false),
      ('Milk – 2', 'Milk', '2', null, false),
      ('Milk: 2', 'Milk', '2', null, false),
      ('Milk=2', 'Milk', '2', null, false),
      ('Milk x2', 'Milk', '2', null, false),
      ('Milk x 2', 'Milk', '2', null, false),
      ('Milk × 2', 'Milk', '2', null, false),
      ('Milk 2x', 'Milk', '2', null, false),
      // Units, any case, with or without a space, plurals and synonyms.
      ('Rice 5kg', 'Rice', '5', 'kg', false),
      ('Rice 5 KG', 'Rice', '5', 'kg', false),
      ('Rice 5 kgs', 'Rice', '5', 'kg', false),
      ('Atta 10 kilo', 'Atta', '10', 'kg', false),
      ('Jeera 100 g', 'Jeera', '100', 'g', false),
      ('Jeera 100gm', 'Jeera', '100', 'g', false),
      ('Jeera 100 gms', 'Jeera', '100', 'g', false),
      ('Jeera 200 grams', 'Jeera', '200', 'g', false),
      ('Oil 1 l', 'Oil', '1', 'l', false),
      ('Oil 1L', 'Oil', '1', 'l', false),
      ('Oil 1 ltr', 'Oil', '1', 'l', false),
      ('Oil 2 litres', 'Oil', '2', 'l', false),
      ('Curd 500ml', 'Curd', '500', 'ml', false),
      ('Banana 6 pcs', 'Banana', '6', 'pcs', false),
      ('Banana 6 nos', 'Banana', '6', 'pcs', false),
      ('Maggi 4 pkt', 'Maggi', '4', 'pkt', false),
      ('Biscuits 3 packets', 'Biscuits', '3', 'pkt', false),
      ('Eggs 1 dozen', 'Eggs', '1', 'dozen', false),
      ('Coke 2 bottles', 'Coke', '2', 'bottle', false),
      ('Rice 5 kg.', 'Rice', '5', 'kg', false),
      // Decimals and fractions.
      ('Onion 1.5 kg', 'Onion', '1.5', 'kg', false),
      ('Onion 1,5 kg', 'Onion', '1.5', 'kg', false),
      ('Ginger 1/2 kg', 'Ginger', '1/2', 'kg', false),
      ('Ginger 1 / 4 kg', 'Ginger', '1/4', 'kg', false),
      ('Ginger ½ kg', 'Ginger', '1/2', 'kg', false),
      ('Atta 1 1/2 kg', 'Atta', '1 1/2', 'kg', false),
      ('Atta 1½ kg', 'Atta', '1 1/2', 'kg', false),
      ('1/2 kg ginger', 'Ginger', '1/2', 'kg', false),
      ('Milk 02', 'Milk', '2', null, false),
      ('Milk 2.0', 'Milk', '2', null, false),
      // Names with digits or several words.
      ('7up 2', '7up', '2', null, false),
      ('Vitamin B12 tablets 1', 'Vitamin B12 tablets', '1', null, false),
      ('Basmati rice 5 kg', 'Basmati rice', '5', 'kg', false),
      ('toor dal 1kg', 'Toor dal', '1', 'kg', false),
      ('Garlic 250 g', 'Garlic', '250', 'g', false),
      ('5 garlic', 'Garlic', '5', null, false),
      // Bullets, numbering, emojis, spacing.
      ('- Milk 2', 'Milk', '2', null, false),
      ('* Milk 2', 'Milk', '2', null, false),
      ('• Milk 2', 'Milk', '2', null, false),
      ('1. Milk 2', 'Milk', '2', null, false),
      ('1) Milk 2', 'Milk', '2', null, false),
      ('(3) Milk 2', 'Milk', '2', null, false),
      ('🥛 Milk 2', 'Milk', '2', null, false),
      ('Milk 2 👍🏽', 'Milk', '2', null, false),
      ('✅ Milk 2', 'Milk', '2', null, false),
      ('   Milk    2   ', 'Milk', '2', null, false),
      ('[ ] Milk 2', 'Milk', '2', null, false),
      ('1. 2 milk', 'Milk', '2', null, false),
      // Non-Latin names.
      ('दूध 2', 'दूध', '2', null, false),
      ('പാൽ 2 l', 'പാൽ', '2', 'l', false),
      // Missing or unclear quantity → review, never a silent default.
      ('Tomatoes', 'Tomatoes', null, null, true),
      ('Rice kg', 'Rice', null, 'kg', true),
      ('Milk 0', 'Milk', null, null, true),
      ('Call 9876543210', 'Call', null, null, true),
      ('2 milk 3', '2 milk 3', null, null, true),
      ('Size 10 shoes', 'Size 10 shoes', null, null, true),
      ('Ginger 1/0 kg', 'Ginger', null, 'kg', true),
    ];
    for (final (input, name, qty, unit, review) in cases) {
      test(input, () {
        final items = ShoppingParser.parse(input);
        expect(items, hasLength(1), reason: '$items');
        final i = items.single;
        expect(
          (i.name, i.quantity, i.unit, i.needsReview),
          (name, qty, unit, review),
        );
        expect(i.line, input.trim());
      });
    }
  });

  group('lines that are not items', () {
    for (final input in [
      '',
      '   ',
      '----',
      '123',
      '2 kg',
      '🙏🙏',
      '<Media omitted>',
      'Messages and calls are end-to-end encrypted. No one outside of '
              'this chat can read them.'
          .trim(),
      'This message was deleted',
    ]) {
      test('"$input"', () => expect(ShoppingParser.parse(input), isEmpty));
    }
  });

  group('WhatsApp copy prefixes', () {
    for (final (input, name) in [
      ('[03/11/26, 6:30 PM] Asha: Milk 2', 'Milk'),
      ('[03/11/2026, 18:30:12] Asha Menon: Milk 2', 'Milk'),
      ('03/11/2026, 18:30 - Asha: Milk 2', 'Milk'),
      ('3/11/26, 6:30 pm - Amma 🌸: Milk 2', 'Milk'),
      ('03.11.26, 18:30 - +91 98765 43210: Milk 2', 'Milk'),
    ]) {
      test(input, () {
        final i = ShoppingParser.parse(input).single;
        expect((i.name, i.quantity), (name, '2'));
      });
    }

    test('a colon in the item is not mistaken for a sender', () {
      final i = ShoppingParser.parse('Milk: 2').single;
      expect((i.name, i.quantity), ('Milk', '2'));
    });
  });

  test('a full message: blank lines skipped, order kept, CRLF ok', () {
    const msg =
        '[03/11/26, 6:30 PM] Amma: Milk 2\r\n'
        'Bread 1\r\n'
        '\r\n'
        'Rice 5 kg\n'
        '  \n'
        'Tomatoes\n'
        'Sugar 2 kg, Eggs 12; Soap 4\n';
    final items = ShoppingParser.parse(msg);
    expect(items.map((i) => i.name), [
      'Milk',
      'Bread',
      'Rice',
      'Tomatoes',
      'Sugar',
      'Eggs',
      'Soap',
    ]);
    expect(items.where((i) => i.needsReview).map((i) => i.name), ['Tomatoes']);
  });

  test('a decimal comma does not split a line', () {
    final items = ShoppingParser.parse('Onion 1,5 kg');
    expect(items.single.quantity, '1.5');
  });

  group('quantity helpers', () {
    test('values', () {
      expect(ShoppingParser.quantityValue('2'), 2);
      expect(ShoppingParser.quantityValue('1.5'), 1.5);
      expect(ShoppingParser.quantityValue('1,5'), 1.5);
      expect(ShoppingParser.quantityValue('1/2'), 0.5);
      expect(ShoppingParser.quantityValue('1 1/2'), 1.5);
      expect(ShoppingParser.quantityValue('½'), 0.5);
      for (final bad in ['', '0', '-1', 'abc', '1/0', '1..2', '2 kg']) {
        expect(ShoppingParser.quantityValue(bad), isNull, reason: bad);
      }
    });

    test('adding for merges', () {
      expect(ShoppingParser.addQuantities('2', '3'), '5');
      expect(ShoppingParser.addQuantities('1/2', '1'), '1.5');
      expect(ShoppingParser.addQuantities('0.25', '0.5'), '0.75');
      expect(ShoppingParser.addQuantities('2', '?'), isNull);
    });

    test('units', () {
      expect(ShoppingParser.canonicalUnit('KGs'), 'kg');
      expect(ShoppingParser.canonicalUnit('litre'), 'l');
      expect(ShoppingParser.canonicalUnit('bananas'), isNull);
    });

    test('parseOne for typed items', () {
      expect(
        ShoppingParser.parseOne('rice 5 kg'),
        const ParsedItem(
          name: 'Rice',
          quantity: '5',
          unit: 'kg',
          line: 'rice 5 kg',
        ),
      );
      expect(ShoppingParser.parseOne('   '), isNull);
    });
  });
}
