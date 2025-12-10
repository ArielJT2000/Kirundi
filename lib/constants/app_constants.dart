import 'package:flutter/material.dart';

/// Constantes de la aplicación para mantener consistencia visual
class AppConstants {
  // ==================== COLORES ====================

  // Colores principales
  static const Color primaryColor = Color(0xFF2E7D32); // Verde principal
  static const Color primaryDarkColor = Color(0xFF1B5E20); // Verde oscuro
  static const Color primaryLightColor = Color(0xFF4CAF50); // Verde claro

  // Colores de estado
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);

  // Colores de fondo
  static const Color backgroundColor = Color(0xFFF5F5F5); // Colors.grey[50]
  static const Color cardBackgroundColor = Colors.white;
  static const Color overlayColor = Color(0x80000000); // Negro con 50% opacidad

  // Colores de texto
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textTertiaryColor = Color(0xFF9E9E9E);

  // Colores específicos de componentes
  static const Color microphoneActiveColor = Color(
    0xFFEF5350,
  ); // Rojo para mic activo
  static const Color indicatorActiveColor = primaryColor;
  static const Color indicatorInactiveColor = Color(0xFFE0E0E0);

  // ==================== TIPOGRAFÍA ====================

  static const String fontFamily = 'Roboto';

  // Tamaños de fuente
  static const double fontSizeDisplayLarge = 42.0;
  static const double fontSizeDisplayMedium = 32.0;
  static const double fontSizeDisplaySmall = 28.0;
  static const double fontSizeHeadline = 24.0;
  static const double fontSizeTitle = 20.0;
  static const double fontSizeBodyLarge = 18.0;
  static const double fontSizeBodyMedium = 16.0;
  static const double fontSizeBodySmall = 14.0;
  static const double fontSizeCaption = 12.0;

  // Pesos de fuente
  static const FontWeight fontWeightBold = FontWeight.bold;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightRegular = FontWeight.normal;

  // Espaciado de letras
  static const double letterSpacingWide = 2.0;
  static const double letterSpacingNormal = 0.5;
  static const double letterSpacingTight = 0.0;

  // ==================== ESPACIADO ====================

  // Espaciado vertical
  static const double spacingXSmall = 8.0;
  static const double spacingSmall = 16.0;
  static const double spacingMedium = 24.0;
  static const double spacingLarge = 32.0;
  static const double spacingXLarge = 40.0;
  static const double spacingXXLarge = 60.0;

  // Espaciado horizontal
  static const double paddingXSmall = 8.0;
  static const double paddingSmall = 12.0;
  static const double paddingMedium = 20.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  static const double paddingXXLarge = 40.0;

  // ==================== TAMAÑOS DE COMPONENTES ====================

  // Botones
  static const double buttonHeight = 56.0;
  static const double buttonBorderRadius = 16.0;

  // Cards
  static const double cardBorderRadius = 24.0;
  static const double cardPadding = 32.0;

  // Micrófono
  static const double microphoneSize = 100.0;
  static const double microphoneIconSize = 50.0;

  // Indicadores
  static const double indicatorSize = 8.0;
  static const double indicatorSpacing = 4.0;

  // Iconos
  static const double iconSizeLarge = 100.0;
  static const double iconSizeMedium = 50.0;
  static const double iconSizeSmall = 24.0;

  // ==================== SOMBRAS ====================

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 20.0,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get microphoneShadow => [
    BoxShadow(
      color: primaryColor.withValues(alpha: 0.4),
      blurRadius: 20.0,
      spreadRadius: 5.0,
    ),
  ];

  static List<BoxShadow> get microphoneActiveShadow => [
    BoxShadow(
      color: microphoneActiveColor.withValues(alpha: 0.4),
      blurRadius: 20.0,
      spreadRadius: 5.0,
    ),
  ];

  static List<BoxShadow> get successModalShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 30.0,
      spreadRadius: 10.0,
    ),
  ];

  // ==================== DURACIONES ====================

  static const Duration animationDurationFast = Duration(milliseconds: 200);
  static const Duration animationDurationNormal = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
  static const Duration animationDurationSuccess = Duration(milliseconds: 2000);
  static const Duration animationDurationPulse = Duration(milliseconds: 1500);

  // Reconocimiento de voz
  static const Duration speechListenDuration = Duration(seconds: 10);
  static const Duration speechPauseDuration = Duration(seconds: 5);
  static const Duration snackBarDuration = Duration(seconds: 2);
  static const Duration successDisplayDuration = Duration(seconds: 2);
  static const Duration noVoiceTimeout = Duration(milliseconds: 1300); // 1.3 segundos sin voz
  
  // Umbral de detección de voz para activar animación
  static const double voiceDetectionThreshold = -30.0; // dB

  // ==================== CURVAS DE ANIMACIÓN ====================

  static const Curve animationCurveDefault = Curves.easeInOut;
  static const Curve animationCurveElastic = Curves.elasticOut;
  static const Curve animationCurvePulse = Curves.easeInOut;

  // ==================== TEXTO ====================

  static const String appTitle = 'CCI San Pedro Sula';
  static const String screenTitle = 'Practica Tu Pronunciación';
  static const String pronunciationLabel = 'Pronuncia:';
  static const String listeningText = 'Escuchando... Habla ahora';
  static const String readyText = 'Toca el micrófono para comenzar';
  static const String successTitle = '¡Excelente!';
  static const String welcomeMessage = 'Bienvenido a CCI San Pedro Sula';
  static const String errorSpeechNotAvailable =
      'El reconocimiento de voz no está disponible';
  static const String errorTryAgain =
      'Intenta de nuevo. Escucha bien la pronunciación.';
  static const String restartButton = 'Reiniciar';
  static const String testMicrophoneButton = 'Probar Micrófono';
  static const String pronunciationHintLabel = 'Pista de pronunciación:';
  static const String testMicrophoneText =
      'Di algo para probar el micrófono...';
  static const String testMicrophoneSuccess =
      '¡Micrófono funcionando correctamente!';
  static const String testMicrophoneError =
      'No se detectó audio. Verifica el micrófono.';

  // ==================== CONFIGURACIÓN DE RECONOCIMIENTO DE VOZ ====================

  static const String speechLocale = 'es'; // Puedes cambiar según necesites
  static const double pronunciationSimilarityThreshold =
      0.4; // Más permisivo (antes 0.7)
  static const int maxEditDistance = 3; // Distancia máxima de edición permitida

  // ==================== TEMA ====================

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: backgroundColor,
  );
}
