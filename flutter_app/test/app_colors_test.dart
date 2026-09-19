import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monera/core/constants/app_colors.dart';

void main() {
  test('uses the supplied Monera palette', () {
    expect(AppColors.background, const Color(0xFF063D2E));
    expect(AppColors.primaryAccent, const Color(0xFFB7FF3B));
    expect(AppColors.textPrimary, const Color(0xFFFFFFFF));
    expect(AppColors.textSecondary, const Color(0xFFDBE5E1));
  });
}
