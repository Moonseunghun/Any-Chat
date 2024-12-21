import 'dart:ui';

enum Language {
  kr("ko", "한국어", Locale('ko', 'KR')),
  us("en-US", "English", Locale('en', 'US')),
  cn("zh-CN", "简体中文", Locale('zh', 'CN')),
  tw("zh-TW", "繁体中文", Locale('zh', 'TW')),
  jp("ja", "日本語", Locale('ja', 'JP')),
  ru("ru", "Русский язык", Locale('ru')),
  de("de", "Deutsch", Locale('de', 'DE')),
  fr("fr", "français", Locale('fr', 'FR')),
  es("es", "español", Locale('es', 'ES')),
  sa("ar", "اللغة العربية", Locale('ar', 'SA')),
  id("id", "bahasa Indonesia", Locale('id', 'ID')),
  vn("vi", "Tiếng Việt", Locale('vi', 'VN')),
  th("th", "แบบไทย", Locale('th', 'TH')),
  tr("tr", "Türkçe", Locale('tr', 'TR')),
  ph("tl", "Tagalog", Locale('tl', 'PH')),
  kz("kk", "Қазақ тілі", Locale('kz')),
  mn("mn", "Монгол хэл", Locale('mn', 'MN')),
  pt("pt", "Português", Locale('pt', 'PT')),
  uz("uz", "o'zbek", Locale('uz', 'UZ')),
  ms("ms", "Bahasa Malaysia", Locale('ms', 'MY'));

  final String code;
  final String value;
  final Locale locale;

  const Language(this.code, this.value, this.locale);

  factory Language.fromCode(String code) {
    return Language.values.firstWhere((e) => e.code == code);
  }

  factory Language.fromName(String name) {
    return Language.values.firstWhere((e) => e.name == name);
  }
}
