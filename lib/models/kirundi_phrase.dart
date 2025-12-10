/// Modelo para representar una frase en Kirundi con su traducción
/// y variaciones aceptadas de pronunciación
class KirundiPhrase {
  /// Texto de la frase en Kirundi
  final String kirundi;

  /// Traducción al español
  final String translation;

  /// Lista de pronunciaciones aceptadas (variaciones permitidas)
  final List<String> acceptedPronunciations;

  /// Pista de pronunciación en español (guía fonética)
  final String pronunciationHint;

  const KirundiPhrase({
    required this.kirundi,
    required this.translation,
    required this.acceptedPronunciations,
    required this.pronunciationHint,
  });

  /// Crea una copia del objeto con valores opcionales modificados
  KirundiPhrase copyWith({
    String? kirundi,
    String? translation,
    List<String>? acceptedPronunciations,
    String? pronunciationHint,
  }) {
    return KirundiPhrase(
      kirundi: kirundi ?? this.kirundi,
      translation: translation ?? this.translation,
      acceptedPronunciations:
          acceptedPronunciations ?? this.acceptedPronunciations,
      pronunciationHint: pronunciationHint ?? this.pronunciationHint,
    );
  }

  @override
  String toString() {
    return 'KirundiPhrase(kirundi: $kirundi, translation: $translation)';
  }
}
