import 'package:flutter/material.dart';

class MoodleUtils {
  /// Moodle'dan gelen çoklu dil etiketli metinleri ayrıştırır.
  /// Örn: {mlang tr}Türkçe{mlang}{mlang en}English{mlang}
  static String parseMultilang(String text, [String? languageCode]) {
    if (text.isEmpty) return text;

    // Eğer mlang etiketi yoksa direkt döndür
    if (!text.contains('{mlang')) return text;

    // RegEx ile dilleri ve içeriklerini ayıkla
    // {mlang ([a-z]+)}(.*?){mlang}
    final regExp = RegExp(r'\{mlang ([a-z]+)\}(.*?)\{mlang\}', dotAll: true);
    final matches = regExp.allMatches(text);

    if (matches.isEmpty) return text;

    final langMap = <String, String>{};
    for (final match in matches) {
      final lang = match.group(1);
      final content = match.group(2);
      if (lang != null && content != null) {
        langMap[lang] = content.trim();
      }
    }

    // 1. İstenen dil varsa onu döndür
    if (languageCode != null && langMap.containsKey(languageCode)) {
      return langMap[languageCode]!;
    }

    // 2. İstenen dil yoksa ama sistem dili tr/en ise onları dene
    if (langMap.containsKey('tr')) return langMap['tr']!;
    if (langMap.containsKey('en')) return langMap['en']!;

    // 3. Hiçbiri yoksa ilk bulunan dili döndür
    return langMap.values.first;
  }

  /// Moodle metinlerinde sıkça bulunan HTML etiketlerini ve &nbsp; gibi yapıları temizler
  static String stripHtml(String text) {
    if (text.isEmpty) return text;
    
    // HTML etiketlerini temizle
    String stripped = text.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // Yaygın HTML entity'lerini temizle
    stripped = stripped
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
        
    return stripped;
  }
}
