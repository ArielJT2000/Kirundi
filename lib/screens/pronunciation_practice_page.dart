import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../constants/app_constants.dart';
import '../models/kirundi_phrase.dart';
import '../data/phrases_data.dart';
import '../utils/speech_utils.dart';

class PronunciationPracticePage extends StatefulWidget {
  const PronunciationPracticePage({super.key});

  @override
  State<PronunciationPracticePage> createState() =>
      _PronunciationPracticePageState();
}

class _PronunciationPracticePageState extends State<PronunciationPracticePage>
    with TickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isInitialized = false;
  String _recognizedText = '';
  int _currentPhraseIndex = 0;
  bool _showSuccessAnimation = false;
  bool _isVoiceDetected = false; // Para detectar si hay voz activa
  bool _isTestingMicrophone = false; // Modo de prueba del micrófono
  Timer? _noVoiceTimer; // Timer para detectar cuando no hay voz por 1.3s

  late AnimationController _successAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _shakeAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeXAnimation;
  late Animation<double> _shakeYAnimation;

  final List<KirundiPhrase> _phrases = PhrasesData.phrases;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Animación de éxito
    _successAnimationController = AnimationController(
      duration: AppConstants.animationDurationSuccess,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successAnimationController,
        curve: AppConstants.animationCurveElastic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successAnimationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Animación de pulso para el micrófono
    _pulseAnimationController = AnimationController(
      duration: AppConstants.animationDurationPulse,
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: AppConstants.animationCurvePulse,
      ),
    );

    // Animación de temblor para el micrófono cuando está escuchando
    _shakeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );

    // Animación de temblor en X (horizontal) - más pronunciada
    _shakeXAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: -4.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 4.0, end: -4.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -4.0, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: _shakeAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    // Animación de temblor en Y (vertical) - más pronunciada
    _shakeYAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: -3.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -3.0, end: 3.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 3.0, end: -3.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -3.0, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: _shakeAnimationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;

        if (status == 'done' ||
            status == 'notListening' ||
            status == 'listeningStopped') {
          setState(() {
            _isListening = false;
            _isVoiceDetected = false;
          });
          // Detener animación de temblor cuando el reconocimiento termina
          _shakeAnimationController.stop();
          _shakeAnimationController.reset();
        }
      },
      onError: (error) {
        if (!mounted) return;
        
        setState(() {
          _isListening = false;
          _isVoiceDetected = false;
          _isInitialized = false; // Marcar como no inicializado para reinicializar
        });
        
        // Detener animaciones
        _shakeAnimationController.stop();
        _shakeAnimationController.reset();
        
        // Reinicializar después de un breve delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _initializeSpeech();
          }
        });
        
        // Mostrar mensaje de error más amigable
        String errorMessage = _getErrorMessage(error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppConstants.errorColor,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: () {
                _initializeSpeech();
              },
            ),
          ),
        );
      },
    );

    setState(() {
      _isInitialized = available;
    });
  }

  void _startListening() async {
    // Asegurarse de que el reconocimiento anterior esté completamente detenido y cancelado
    try {
      if (_isListening) {
        _speech.stop();
      }
      _speech.cancel();
    } catch (e) {
      // Ignorar errores si ya está detenido
    }

    // Limpiar el estado inmediatamente
    setState(() {
      _isListening = false;
      _isVoiceDetected = false;
      _recognizedText = '';
    });

    // Pausa para asegurar que el estado se limpie completamente
    await Future.delayed(const Duration(milliseconds: 200));

    // Verificar y reinicializar si es necesario
    if (!_isInitialized) {
      await _initializeSpeech();
    }

    if (!_isInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(AppConstants.errorSpeechNotAvailable),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
      return;
    }

    // Verificar que el reconocimiento esté disponible antes de iniciar
    bool isAvailable = _speech.isAvailable;
    if (!isAvailable) {
      // Reinicializar si no está disponible
      setState(() {
        _isInitialized = false;
      });
      await _initializeSpeech();

      if (!_isInitialized) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(AppConstants.errorSpeechNotAvailable),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        }
        return;
      }
    }

    setState(() {
      _isListening = true;
      _recognizedText = '';
      _isVoiceDetected = false;
    });
    
    // Iniciar timer de no voz al comenzar
    _startNoVoiceTimer();

    try {
      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;

          final newText = result.recognizedWords.toLowerCase().trim();
          
          // Solo actualizar si el texto cambió (optimización: evitar setState innecesario)
          if (newText != _recognizedText) {
            setState(() {
              _recognizedText = newText;
            });
          }

          if (result.finalResult && !_isTestingMicrophone) {
            _checkPronunciation(_recognizedText);
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenFor: AppConstants.speechListenDuration,
          pauseFor: AppConstants.speechPauseDuration,
          localeId: AppConstants.speechLocale,
          cancelOnError: false,
          partialResults: true,
          listenMode: stt.ListenMode.confirmation,
        ),
        onSoundLevelChange: (level) {
          if (!mounted) return;

          // Detectar si hay voz activa basado en el nivel de audio
          bool isVoiceDetected = level > AppConstants.voiceDetectionThreshold;

          // Solo actualizar estado si cambió (optimización: evitar setState innecesario)
          if (isVoiceDetected != _isVoiceDetected) {
            _isVoiceDetected = isVoiceDetected;
            
            // Activar o desactivar animación de temblor según detección de voz
            if (isVoiceDetected) {
              // Iniciar temblor cuando se detecta voz
              _shakeAnimationController.repeat();
              // Cancelar timer de no voz
              _noVoiceTimer?.cancel();
              _noVoiceTimer = null;
            } else {
              // Detener temblor cuando no hay voz
              _shakeAnimationController.stop();
              _shakeAnimationController.reset();
              // Iniciar timer para detectar si no hay voz por 1.3 segundos
              _startNoVoiceTimer();
            }
            
            // Actualizar UI solo si es necesario (optimización)
            if (mounted) {
              setState(() {});
            }
          } else if (isVoiceDetected) {
            // Si sigue detectando voz, cancelar timer de no voz si existe
            _noVoiceTimer?.cancel();
            _noVoiceTimer = null;
          }
        },
      );
    } catch (e) {
      // Si hay un error al iniciar el reconocimiento, limpiar el estado
      if (mounted) {
        setState(() {
          _isListening = false;
          _isVoiceDetected = false;
        });
        _shakeAnimationController.stop();
        _shakeAnimationController.reset();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar el micrófono: $e'),
            backgroundColor: AppConstants.errorColor,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: () {
                _resetSpeechRecognition().then((_) {
                  if (mounted && !_isListening) {
                    _startListening();
                  }
                });
              },
            ),
          ),
        );
      }
    }
  }

  void _stopListening() {
    try {
      // Detener y cancelar completamente el reconocimiento
      if (_speech.isListening) {
        _speech.stop();
      }
      _speech.cancel();
    } catch (e) {
      // Ignorar errores al detener si ya está detenido
    }

    // Cancelar timer de no voz
    _noVoiceTimer?.cancel();
    _noVoiceTimer = null;

    setState(() {
      _isListening = false;
      _isVoiceDetected = false;
      _recognizedText = '';
      _isTestingMicrophone = false;
    });

    // Detener animación de temblor
    _shakeAnimationController.stop();
    _shakeAnimationController.reset();
  }

  /// Reinicia completamente el reconocimiento de voz
  Future<void> _resetSpeechRecognition() async {
    _stopListening();
    await Future.delayed(const Duration(milliseconds: 200));

    // Reinicializar si es necesario
    if (!_isInitialized) {
      await _initializeSpeech();
    }
  }

  /// Inicia un timer que detecta cuando no hay voz por 1.3 segundos
  void _startNoVoiceTimer() {
    // Cancelar timer anterior si existe
    _noVoiceTimer?.cancel();
    
    // Iniciar nuevo timer
    _noVoiceTimer = Timer(AppConstants.noVoiceTimeout, () {
      if (!mounted || !_isListening) return;
      
      // Si después de 1.3 segundos no hay voz, finalizar el reconocimiento
      if (!_isVoiceDetected && _recognizedText.isNotEmpty) {
        // Procesar el texto reconocido antes de detener
        if (!_isTestingMicrophone) {
          _checkPronunciation(_recognizedText);
        } else {
          _stopListening();
          setState(() {
            _isTestingMicrophone = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(AppConstants.testMicrophoneSuccess),
                backgroundColor: AppConstants.successColor,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } else if (!_isVoiceDetected) {
        // Si no hay texto reconocido y no hay voz, simplemente detener
        _stopListening();
      }
    });
  }

  /// Convierte códigos de error en mensajes amigables para el usuario
  String _getErrorMessage(dynamic error) {
    String errorCode = error.toString().toLowerCase();
    
    // Errores comunes y sus mensajes
    if (errorCode.contains('error_unknown') || errorCode.contains('209')) {
      return 'Error del reconocimiento de voz. Intenta de nuevo o verifica los permisos del micrófono.';
    } else if (errorCode.contains('error_network')) {
      return 'Error de conexión. Verifica tu conexión a internet.';
    } else if (errorCode.contains('error_audio')) {
      return 'Error de audio. Verifica que el micrófono esté funcionando.';
    } else if (errorCode.contains('error_client')) {
      return 'Error del cliente. Intenta reiniciar la aplicación.';
    } else if (errorCode.contains('error_permission')) {
      return 'Permisos del micrófono denegados. Activa los permisos en configuración.';
    } else if (errorCode.contains('error_no_match')) {
      return 'No se detectó habla. Intenta hablar más claro o más cerca del micrófono.';
    } else if (errorCode.contains('error_server')) {
      return 'Error del servidor. Intenta de nuevo en unos momentos.';
    } else if (errorCode.contains('error_timeout')) {
      return 'Tiempo de espera agotado. Intenta de nuevo.';
    } else {
      // Mensaje genérico para otros errores
      return 'Error: $error. Intenta de nuevo.';
    }
  }

  void _checkPronunciation(String recognizedText) {
    final currentPhrase = _phrases[_currentPhraseIndex];
    bool isCorrect = SpeechUtils.checkPronunciation(
      recognizedText,
      currentPhrase.acceptedPronunciations,
    );

    if (isCorrect) {
      // Detener el reconocimiento antes de mostrar éxito
      _stopListening();
      _showSuccess();
    } else {
      // Detener el reconocimiento de voz cuando hay error y reiniciar
      _resetSpeechRecognition();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(AppConstants.errorTryAgain),
            backgroundColor: AppConstants.warningColor,
            duration: AppConstants.snackBarDuration,
          ),
        );
      }
    }
  }

  void _showSuccess() {
    setState(() {
      _showSuccessAnimation = true;
    });

    _successAnimationController.forward().then((_) {
      Future.delayed(AppConstants.successDisplayDuration, () {
        if (mounted) {
          setState(() {
            _showSuccessAnimation = false;
          });
          _successAnimationController.reset();
          _nextPhrase();
        }
      });
    });
  }

  void _nextPhrase() {
    setState(() {
      _currentPhraseIndex = (_currentPhraseIndex + 1) % _phrases.length;
      _recognizedText = '';
    });
  }

  /// Reinicia la aplicación al inicio (primera frase)
  void _restartFromBeginning() {
    _stopListening();
    setState(() {
      _currentPhraseIndex = 0;
      _recognizedText = '';
      _isTestingMicrophone = false;
    });
  }

  /// Prueba el micrófono sin verificar pronunciación
  void _testMicrophone() async {
    if (_isListening) {
      _stopListening();
    }

    setState(() {
      _isTestingMicrophone = true;
      _recognizedText = '';
    });

    await Future.delayed(const Duration(milliseconds: 200));

    if (!_isInitialized) {
      await _initializeSpeech();
    }

    if (!_isInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(AppConstants.errorSpeechNotAvailable),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
      setState(() {
        _isTestingMicrophone = false;
      });
      return;
    }

    setState(() {
      _isListening = true;
    });
    
    // Iniciar timer de no voz al comenzar
    _startNoVoiceTimer();

    try {
      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;

          final newText = result.recognizedWords;
          
          // Solo actualizar si el texto cambió (optimización: evitar setState innecesario)
          if (newText != _recognizedText) {
            setState(() {
              _recognizedText = newText;
            });
          }

          if (result.finalResult && result.recognizedWords.isNotEmpty) {
            // Mostrar éxito si se detectó algo
            _stopListening();
            setState(() {
              _isTestingMicrophone = false;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(AppConstants.testMicrophoneSuccess),
                  backgroundColor: AppConstants.successColor,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenFor: const Duration(seconds: 5),
          pauseFor: const Duration(seconds: 3),
          localeId: AppConstants.speechLocale,
          cancelOnError: false,
          partialResults: true,
        ),
        onSoundLevelChange: (level) {
          if (!mounted) return;
          bool wasVoiceDetected = _isVoiceDetected;
          bool isVoiceDetected = level > AppConstants.voiceDetectionThreshold;

          if (isVoiceDetected != wasVoiceDetected) {
            setState(() {
              _isVoiceDetected = isVoiceDetected;
            });

            if (isVoiceDetected) {
              _shakeAnimationController.repeat();
            } else {
              _shakeAnimationController.stop();
              _shakeAnimationController.reset();
            }
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isListening = false;
          _isTestingMicrophone = false;
        });
        _shakeAnimationController.stop();
        _shakeAnimationController.reset();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar el micrófono: $e'),
            backgroundColor: AppConstants.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _noVoiceTimer?.cancel();
    _successAnimationController.dispose();
    _pulseAnimationController.dispose();
    _shakeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPhrase = _phrases[_currentPhraseIndex];
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Contenido principal
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppConstants.spacingXLarge),
                    // Título (optimizado con RepaintBoundary)
                    RepaintBoundary(
                      child: Text(
                        AppConstants.screenTitle,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeDisplaySmall,
                          fontWeight: AppConstants.fontWeightBold,
                          color: colorScheme.primary,
                          letterSpacing: AppConstants.letterSpacingNormal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    // Botones de acción
                    _buildActionButtons(colorScheme),
                    const SizedBox(height: AppConstants.spacingLarge),
                    // Card con la frase en Kirundi
                    _buildPhraseCard(currentPhrase),
                    const SizedBox(height: AppConstants.spacingLarge),
                    // Pista de pronunciación
                    if (!_isTestingMicrophone)
                      _buildPronunciationHint(currentPhrase, colorScheme),
                    if (!_isTestingMicrophone)
                      const SizedBox(height: AppConstants.spacingLarge),
                    // Texto reconocido
                    if (_recognizedText.isNotEmpty) ...[
                      _buildRecognizedTextContainer(
                        _recognizedText,
                        colorScheme,
                      ),
                      const SizedBox(height: AppConstants.spacingXLarge),
                    ],
                    // Botón de micrófono
                    _buildMicrophoneButton(colorScheme),
                    const SizedBox(height: AppConstants.spacingSmall),
                    // Texto de instrucción
                    Text(
                      _isTestingMicrophone
                          ? AppConstants.testMicrophoneText
                          : (_isListening
                              ? AppConstants.listeningText
                              : AppConstants.readyText),
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeBodyMedium,
                        color: AppConstants.textSecondaryColor,
                        fontWeight: AppConstants.fontWeightMedium,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXLarge),
                    // Indicador de frase (solo si no está en modo test)
                    if (!_isTestingMicrophone) _buildPhraseIndicators(colorScheme),
                  ],
                ),
              ),
            ),
            // Animación de éxito
            if (_showSuccessAnimation) _buildSuccessAnimation(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhraseCard(KirundiPhrase phrase) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.cardPadding),
        decoration: BoxDecoration(
          color: AppConstants.cardBackgroundColor,
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          boxShadow: AppConstants.cardShadow,
        ),
        child: Column(
          children: [
            Text(
              AppConstants.pronunciationLabel,
              style: TextStyle(
                fontSize: AppConstants.fontSizeBodyMedium,
                color: AppConstants.textSecondaryColor,
                fontWeight: AppConstants.fontWeightMedium,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              phrase.kirundi,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeDisplayLarge,
                fontWeight: AppConstants.fontWeightBold,
                color: AppConstants.primaryDarkColor,
                letterSpacing: AppConstants.letterSpacingWide,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              phrase.translation,
              style: TextStyle(
                fontSize: AppConstants.fontSizeBodyLarge,
                color: AppConstants.textSecondaryColor,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecognizedTextContainer(String text, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: AppConstants.fontSizeBodyMedium,
          color: colorScheme.onPrimaryContainer,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMicrophoneButton(ColorScheme colorScheme) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseAnimation,
          _shakeXAnimation,
          _shakeYAnimation,
        ]),
        builder: (context, child) {
          return Transform.translate(
            offset: (_isListening && _isVoiceDetected)
                ? Offset(_shakeXAnimation.value, _shakeYAnimation.value)
                : Offset.zero,
            child: Transform.scale(
              scale: _isListening ? _pulseAnimation.value : 1.0,
              child: GestureDetector(
                onTap: _isListening ? _stopListening : _startListening,
                child: Container(
                  width: AppConstants.microphoneSize,
                  height: AppConstants.microphoneSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening
                        ? AppConstants.microphoneActiveColor
                        : colorScheme.primary,
                    boxShadow: _isListening
                        ? AppConstants.microphoneActiveShadow
                        : AppConstants.microphoneShadow,
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    size: AppConstants.microphoneIconSize,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhraseIndicators(ColorScheme colorScheme) {
    return RepaintBoundary(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _phrases.length,
          (index) => Container(
            width: AppConstants.indicatorSize,
            height: AppConstants.indicatorSize,
            margin: const EdgeInsets.symmetric(
              horizontal: AppConstants.indicatorSpacing,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == _currentPhraseIndex
                  ? AppConstants.indicatorActiveColor
                  : AppConstants.indicatorInactiveColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _successAnimationController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                color: AppConstants.overlayColor,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.paddingXXLarge),
                    decoration: BoxDecoration(
                      color: AppConstants.cardBackgroundColor,
                      borderRadius: BorderRadius.circular(
                        AppConstants.cardBorderRadius,
                      ),
                      boxShadow: AppConstants.successModalShadow,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: AppConstants.iconSizeLarge,
                          color: AppConstants.successColor,
                        ),
                        const SizedBox(height: AppConstants.spacingSmall),
                        Text(
                          AppConstants.successTitle,
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeDisplayMedium,
                            fontWeight: AppConstants.fontWeightBold,
                            color: AppConstants.successColor,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingSmall),
                        Text(
                          AppConstants.welcomeMessage,
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeTitle,
                            color: AppConstants.textPrimaryColor,
                            fontWeight: AppConstants.fontWeightMedium,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Botón de reinicio
        ElevatedButton.icon(
          onPressed: _isListening ? null : _restartFromBeginning,
          icon: const Icon(Icons.refresh, size: 20),
          label: const Text(AppConstants.restartButton),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.secondary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingSmall,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
            ),
          ),
        ),
        // Botón de test del micrófono
        ElevatedButton.icon(
          onPressed: _isListening ? _stopListening : _testMicrophone,
          icon: Icon(
            _isTestingMicrophone ? Icons.stop : Icons.mic_external_on,
            size: 20,
          ),
          label: Text(
            _isTestingMicrophone
                ? 'Detener'
                : AppConstants.testMicrophoneButton,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isTestingMicrophone
                ? AppConstants.errorColor
                : colorScheme.tertiary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingSmall,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPronunciationHint(KirundiPhrase phrase, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: AppConstants.spacingXSmall),
              Text(
                AppConstants.pronunciationHintLabel,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeBodyMedium,
                  fontWeight: AppConstants.fontWeightSemiBold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            phrase.pronunciationHint,
            style: TextStyle(
              fontSize: AppConstants.fontSizeBodySmall,
              color: AppConstants.textSecondaryColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
