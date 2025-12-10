import '../constants/app_constants.dart';

/// Utilidades para el reconocimiento y comparación de pronunciación
class SpeechUtils {
  // Cache para normalizaciones (optimización de rendimiento)
  static final Map<String, String> _normalizationCache = {};
  static const int _maxCacheSize = 100;

  /// Normaliza un texto para comparación (minúsculas, sin espacios extra, sin acentos)
  /// Usa cache para mejorar el rendimiento
  static String normalizeText(String text) {
    if (text.isEmpty) return text;
    
    // Verificar cache
    if (_normalizationCache.containsKey(text)) {
      return _normalizationCache[text]!;
    }

    // Normalizar texto
    final normalized = text
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '') // Eliminar caracteres especiales
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Guardar en cache (limitar tamaño)
    if (_normalizationCache.length >= _maxCacheSize) {
      _normalizationCache.remove(_normalizationCache.keys.first);
    }
    _normalizationCache[text] = normalized;

    return normalized;
  }

  /// Limpia el cache de normalización
  static void clearCache() {
    _normalizationCache.clear();
  }

  /// Calcula la distancia de Levenshtein entre dos strings (optimizado)
  /// Retorna el número mínimo de ediciones necesarias
  /// Usa optimización de espacio (solo dos filas en lugar de matriz completa)
  static int levenshteinDistance(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;
    
    // Optimización: si las strings son iguales, retornar 0
    if (s1 == s2) return 0;

    // Optimización: usar solo dos filas en lugar de matriz completa
    List<int> previousRow = List.generate(s2.length + 1, (i) => i);
    List<int> currentRow = List.filled(s2.length + 1, 0);

    for (int i = 1; i <= s1.length; i++) {
      currentRow[0] = i;
      for (int j = 1; j <= s2.length; j++) {
        int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        currentRow[j] = [
          previousRow[j] + 1, // eliminación
          currentRow[j - 1] + 1, // inserción
          previousRow[j - 1] + cost, // sustitución
        ].reduce((a, b) => a < b ? a : b);
      }
      
      // Intercambiar filas
      final temp = previousRow;
      previousRow = currentRow;
      currentRow = temp;
    }

    return previousRow[s2.length];
  }

  /// Calcula la similitud entre dos textos usando distancia de Levenshtein
  /// Retorna un valor entre 0.0 y 1.0, donde 1.0 es idéntico
  static double calculateSimilarity(String text1, String text2) {
    if (text1.isEmpty && text2.isEmpty) return 1.0;
    if (text1.isEmpty || text2.isEmpty) {
      // Si uno está vacío, usar longitud del otro
      int maxLen = text1.length > text2.length ? text1.length : text2.length;
      return maxLen > 0 ? 0.0 : 1.0;
    }

    int distance = levenshteinDistance(text1, text2);
    int maxLen = text1.length > text2.length ? text1.length : text2.length;
    
    if (maxLen == 0) return 1.0;
    
    // Calcular similitud basada en distancia
    double similarity = 1.0 - (distance / maxLen);
    return similarity;
  }

  /// Extrae palabras clave importantes de un texto
  static List<String> extractKeywords(String text) {
    // Palabras comunes a ignorar
    final stopWords = {'ni', 'es', 'el', 'la', 'de', 'a', 'en', 'un', 'una'};
    return text
        .split(' ')
        .where((word) => word.isNotEmpty && !stopWords.contains(word))
        .toList();
  }

  /// Verifica si el texto reconocido coincide con alguna pronunciación aceptada
  /// Retorna true si hay coincidencia, false en caso contrario
  /// Optimizado para salir temprano cuando encuentra coincidencia
  static bool checkPronunciation(
    String recognizedText,
    List<String> acceptedPronunciations,
  ) {
    String normalizedRecognized = normalizeText(recognizedText);

    // Si el texto reconocido está vacío, no aceptar
    if (normalizedRecognized.isEmpty) return false;

    // Pre-normalizar todas las pronunciaciones aceptadas (optimización)
    final normalizedAcceptedList = acceptedPronunciations
        .map((a) => normalizeText(a))
        .toList();

    for (int i = 0; i < normalizedAcceptedList.length; i++) {
      String normalizedAccepted = normalizedAcceptedList[i];

      // 1. Verificar coincidencia exacta (más rápido, verificar primero)
      if (normalizedRecognized == normalizedAccepted) {
        return true;
      }

      // 2. Verificar si contiene la frase completa o viceversa (rápido)
      if (normalizedRecognized.contains(normalizedAccepted) ||
          normalizedAccepted.contains(normalizedRecognized)) {
        return true;
      }

      // 3. Verificar distancia de edición directa (más rápido que similitud completa)
      int maxLen = normalizedRecognized.length > normalizedAccepted.length
          ? normalizedRecognized.length
          : normalizedAccepted.length;
      
      // Si las longitudes son muy diferentes, saltar cálculos costosos
      if (maxLen > 0) {
        int lengthDiff = (normalizedRecognized.length - normalizedAccepted.length).abs();
        if (lengthDiff <= maxLen * 0.5) { // Solo si la diferencia es razonable
          int distance = levenshteinDistance(normalizedRecognized, normalizedAccepted);
          
          // Verificar distancia de edición directa
          if (distance <= AppConstants.maxEditDistance &&
              distance <= (maxLen * 0.3)) {
            return true;
          }

          // 4. Verificar similitud usando distancia de Levenshtein (solo si es necesario)
          double similarity = 1.0 - (distance / maxLen);
          if (similarity >= AppConstants.pronunciationSimilarityThreshold) {
            return true;
          }
        }
      }

      // 5. Verificar palabras clave (solo si las verificaciones anteriores fallaron)
      // Esta es la verificación más costosa, así que la hacemos al final
      List<String> recognizedKeywords = extractKeywords(normalizedRecognized);
      List<String> acceptedKeywords = extractKeywords(normalizedAccepted);
      
      if (recognizedKeywords.isNotEmpty && acceptedKeywords.isNotEmpty) {
        int matchingKeywords = 0;
        for (String keyword in acceptedKeywords) {
          // Verificar si alguna palabra reconocida es similar a la palabra clave
          for (String recognized in recognizedKeywords) {
            if (recognized.contains(keyword) ||
                keyword.contains(recognized) ||
                levenshteinDistance(recognized, keyword) <= 2) {
              matchingKeywords++;
              break;
            }
          }
        }
        
        // Si al menos el 50% de las palabras clave coinciden, aceptar
        if (matchingKeywords >= (acceptedKeywords.length * 0.5).ceil()) {
          return true;
        }
      }
    }

    return false;
  }
}
