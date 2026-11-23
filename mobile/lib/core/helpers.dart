import 'package:flutter/services.dart';

class Helpers {
  // Format angka menjadi ribuan (misal 1000 -> 1.000)
  static String formatNumber(dynamic value) {
    if (value == null) return '0';
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed == null) return '0';
      value = parsed;
    }
    
    String str = value.toString();
    if (str.contains('.')) {
      str = str.split('.').first; // Hapus desimal
    }
    
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (Match match) => '${match[1]}.');
  }

  // Membersihkan titik dari string (misal 1.000 -> 1000)
  static double parseNumber(String text) {
    if (text.isEmpty) return 0.0;
    return double.tryParse(text.replaceAll('.', '')) ?? 0.0;
  }
}

// Class untuk membuat input real-time hanya angka dan format ribuan
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    final String newText = newValue.text.replaceAll('.', '');
    final double? value = double.tryParse(newText);
    if (value == null) return oldValue;

    final String formatted = Helpers.formatNumber(value);
    
    // Perbaikan: Menjaga posisi kursor agar tidak melompat ke akhir
    int selectionIndex = newValue.selection.end;
    int dotCountBefore = 0;
    for (int i = 0; i < selectionIndex && i < newValue.text.length; i++) {
      if (newValue.text[i] == '.') dotCountBefore++;
    }
    
    int newDotCount = 0;
    int finalSelection = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (i - newDotCount == selectionIndex - dotCountBefore) {
        finalSelection = i;
      }
      if (formatted[i] == '.') newDotCount++;
    }
    if (finalSelection == 0 && formatted.isNotEmpty) finalSelection = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: finalSelection),
    );
  }
}