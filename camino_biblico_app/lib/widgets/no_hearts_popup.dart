import 'package:flutter/material.dart';

class NoHeartsPopup extends StatefulWidget {
  final String? timeUntilRegeneration;
  final VoidCallback onRecharge;
  final VoidCallback onGoHome;

  const NoHeartsPopup({
    super.key,
    this.timeUntilRegeneration,
    required this.onRecharge,
    required this.onGoHome,
  });

  @override
  State<NoHeartsPopup> createState() => _NoHeartsPopupState();
}

class _NoHeartsPopupState extends State<NoHeartsPopup> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _heartPulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation para entrada del popup
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Pulse animation para el badge de tiempo
    _heartPulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _heartPulseController, curve: Curves.easeInOut),
    );

    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _heartPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sección Superior: Corazones Vacíos
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            const Color(0xFF374151),
                            const Color(0xFF1F2937),
                          ]
                        : [
                            const Color(0xFFF9FAFB),
                            Colors.white,
                          ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                child: Column(
                  children: [
                    // Círculo decorativo de fondo
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (isDark
                                    ? const Color(0xFF4B5563)
                                    : const Color(0xFFE2E8F0))
                                .withOpacity(0.3),
                          ),
                        ),
                        // Fila de Corazones Vacíos
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            3,
                            (index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: ScaleTransition(
                                scale: index == 1 ? _pulseAnimation : AlwaysStoppedAnimation(1.0),
                                child: Icon(
                                  Icons.favorite,
                                  size: 56,
                                  color: isDark
                                      ? const Color(0xFF6B7280).withOpacity(0.6)
                                      : const Color(0xFFCBD5E1).withOpacity(0.8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Badge de tiempo de regeneración
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F2937) : const Color(0xFF1F2937),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.schedule,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Próximo corazón en ${widget.timeUntilRegeneration ?? "14:59"}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Contenido del Texto
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
                child: Column(
                  children: [
                    Text(
                      '¡Sin corazones!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF1F2937),
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Necesitas corazones para continuar con las lecciones. ¡No dejes que tu racha se pierda!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF6B7280),
                            height: 1.5,
                          ),
                    ),
                    const SizedBox(height: 24),
                    // Botón Recargar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.onRecharge,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1), // Indigo
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 4,
                          shadowColor: const Color(0xFF6366F1).withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.flash_on, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Recargar ahora',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Botón Volver al Inicio
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: widget.onGoHome,
                        style: TextButton.styleFrom(
                          foregroundColor: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF64748B),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.home_outlined, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Volver al inicio',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: isDark
                                        ? const Color(0xFF9CA3AF)
                                        : const Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
