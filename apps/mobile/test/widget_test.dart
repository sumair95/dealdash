import 'package:flutter_test/flutter_test.dart';

import 'package:dealdash/core/constants/app_constants.dart';

void main() {
  test('app constants are defined', () {
    expect(AppConstants.appName, 'DealDash');
    expect(AppConstants.freeSearchLimit, 10);
  });
}
