import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards localization completeness: every key present in one locale must
/// exist in the other, so no string silently falls back to its key.
void main() {
  Set<String> flatKeys(String path) {
    final json = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
    final keys = <String>{};
    void walk(String prefix, Map<String, dynamic> map) {
      map.forEach((key, value) {
        final full = prefix.isEmpty ? key : '$prefix.$key';
        if (value is Map<String, dynamic>) {
          walk(full, value);
        } else {
          keys.add(full);
        }
      });
    }

    walk('', json);
    return keys;
  }

  test('tr and en translation files have identical key sets', () {
    final en = flatKeys('assets/translations/en.json');
    final tr = flatKeys('assets/translations/tr.json');

    expect(en.difference(tr), isEmpty, reason: 'keys missing from tr.json');
    expect(tr.difference(en), isEmpty, reason: 'keys missing from en.json');
  });
}
