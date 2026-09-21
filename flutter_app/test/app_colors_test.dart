import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monera/core/constants/app_colors.dart';

void main() {
  test('uses the supplied Monera palette', () {
    expect(AppColors.background, const Color(0xFFF5F6F8));
    expect(AppColors.darkGreen, const Color(0xFF063D2E));
    expect(AppColors.lime, const Color(0xFFB7FF3B));
    expect(AppColors.textPrimary, const Color(0xFF0F172A));
    expect(AppColors.textSecondary, const Color(0xFF64748B));
  });
}
