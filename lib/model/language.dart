enum Language {
  kr("ko", "한국어"),
  us("en-US", "English"),
  cn("zh-CN", "简体中文"),
  tw("zh-TW", "繁体中文"),
  jp("ja", "日本語"),
  ru("ru", "Русский язык"),
  de("de", "Deutsch"),
  fr("fr", "français"),
  es("es", "español"),
  sa("ar", "اللغة العربية"),
  id("id", "bahasa Indonesia"),
  vn("vi", "Tiếng Việt"),
  th("th", "แบบไทย"),
  tr("tr", "Türkçe"),
  ph("tl", "Tagalog"),
  kz("kk", "Қазақ тілі"),
  mn("mn", "Монгол хэл"),
  pt("pt", "Português"),
  uz("uz", "o'zbek");

  final String code;
  final String value;

  const Language(this.code, this.value);

  factory Language.fromCode(String code) {
    print(code);
    return Language.values.firstWhere((e) => e.code == code);
  }

  factory Language.fromName(String name) {
    return Language.values.firstWhere((e) => e.name == name);
  }
}
