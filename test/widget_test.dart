import 'package:flutter_test/flutter_test.dart';
import 'package:webkocluk_mobile/models/app_user.dart';

void main() {
  test('Role conversion maps correctly', () {
    expect(roleToString(AppUserRole.parent), 'parent');
    expect(roleFromString('student'), AppUserRole.student);
    expect(roleFromString('parent'), AppUserRole.parent);
  });
}
