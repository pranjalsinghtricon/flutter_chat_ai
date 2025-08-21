class LanguageModel {
  final String name;
  LanguageModel(this.name);

  factory LanguageModel.fromJson(String name) => LanguageModel(name);
}