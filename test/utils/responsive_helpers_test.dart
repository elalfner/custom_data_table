import 'package:custom_data_table/custom_data_table.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calculateContentHeight Unit Tests', () {
    test('returns 0 when itemCount is 0', () {
      expect(
        calculateContentHeight(
          itemCount: 0,
          minRowHeight: 40,
          dividerHeight: 1,
        ),
        0,
      );
    });

    test('calculates height correctly for populated list', () {
      expect(
        calculateContentHeight(
          itemCount: 3,
          minRowHeight: 40,
          dividerHeight: 1,
        ),
        122, // (40 * 3) + (1 * 2) = 120 + 2 = 122
      );
    });
  });

  group('ScreenSizeExtension Unit Tests', () {
    test('returns correct padding for each screen size', () {
      expect(ScreenSize.small.padding, 16.0);
      expect(ScreenSize.medium.padding, 20.0);
      expect(ScreenSize.large.padding, 40.0);
    });
  });
}
