import '../models/kirundi_phrase.dart';

/// Datos de las frases en Kirundi relacionadas con la fe
class PhrasesData {
  /// Lista de frases en Kirundi para practicar pronunciación
  static final List<KirundiPhrase> phrases = [
    KirundiPhrase(
      kirundi: 'Imana ni nziza',
      translation: 'Dios es bueno',
      acceptedPronunciations: [
        'imana ni nziza',
        'imana nziza',
        'imana ni nzisa',
        'imana nzisa',
        'imana',
        'nziza',
      ],
      pronunciationHint: 'Pronuncia: "I-ma-na ni n-zi-za" (Imana como "Imana", nziza como "nziza")',
    ),
    KirundiPhrase(
      kirundi: 'Imana ni ikomeye',
      translation: 'Dios es maravilloso',
      acceptedPronunciations: [
        'imana ni ikomeye',
        'imana ikomeye',
        'imana ni ikomeie',
        'imana ikomeie',
        'ikomeye',
      ],
      pronunciationHint: 'Pronuncia: "I-ma-na ni i-ko-me-ye" (ikomeye como "i-ko-me-ye")',
    ),
    KirundiPhrase(
      kirundi: 'Imana ni mukuru',
      translation: 'Dios es grande',
      acceptedPronunciations: [
        'imana ni mukuru',
        'imana mukuru',
        'imana ni mukulu',
        'mukuru',
        'mukulu',
      ],
      pronunciationHint: 'Pronuncia: "I-ma-na ni mu-ku-ru" (mukuru como "mu-ku-ru")',
    ),
    KirundiPhrase(
      kirundi: 'Imana ni umwizigirwa',
      translation: 'Dios es fiel',
      acceptedPronunciations: [
        'imana ni umwizigirwa',
        'imana umwizigirwa',
        'imana ni umwizigirua',
        'umwizigirwa',
        'wizigirwa',
      ],
      pronunciationHint: 'Pronuncia: "I-ma-na ni um-wi-zi-gir-wa" (umwizigirwa como "um-wi-zi-gir-wa")',
    ),
    KirundiPhrase(
      kirundi: 'Imana ni umukama',
      translation: 'Dios es el Señor',
      acceptedPronunciations: [
        'imana ni umukama',
        'imana umukama',
        'imana ni umukama',
        'umukama',
        'mukama',
      ],
      pronunciationHint: 'Pronuncia: "I-ma-na ni u-mu-ka-ma" (umukama como "u-mu-ka-ma")',
    ),
  ];

  /// Obtiene una frase aleatoria
  static KirundiPhrase getRandomPhrase() {
    return phrases[DateTime.now().millisecond % phrases.length];
  }

  /// Obtiene el total de frases disponibles
  static int get totalPhrases => phrases.length;
}
