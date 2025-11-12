import 'package:cas_house/main_global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('statusColor mapuje statusy poprawnie', () {
    expect(statusColor('naprawiony'), Colors.green);
    expect(statusColor('solved'), Colors.green);
    expect(statusColor('w trakcie'), Colors.orange);
    expect(statusColor('in progress'), Colors.orange);
    expect(statusColor('nowy'), Colors.red);
    expect(statusColor('cokolwiek'), Colors.red);
    expect(statusColor('SoLvEd'), Colors.green); // case-insensitive
  });
}
