import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreen({
    super.key,
    required this.nextScreen,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _metaController;
  late Animation<double> _logoScale;
  late Animation<double> _logoPulse;
  late Animation<double> _metaFade;

  @override
  void initState() {
    super.initState();
    
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Logo scale animation - subtle pop in
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    // Subtle pulse animation
    _logoPulse = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.02), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.02, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.5, 1.0),
    ));

    // Meta branding controller
    _metaController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _metaFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _metaController, curve: Curves.easeIn),
    );

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _metaController.forward();
    });

    // Navigate after delay
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => widget.nextScreen,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _metaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Main content - centered logo
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_logoController]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScale.value * _logoPulse.value,
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF1877F2), // Facebook blue
                            Color(0xFF1877F2), // Solid for cleaner look, or subtle gradient
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1877F2).withValues(alpha: 0.3),
                            blurRadius: 24,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      alignment: Alignment.bottomCenter,
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 2), // Fine tune 'f' position
                        child: Text(
                          'f',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 64, // Larger 'f'
                            fontWeight: FontWeight.w900, // Thicker
                            fontFamily: 'Roboto', // Or system default, Helvetica is fine too
                            letterSpacing: -1.0,
                            height: 1.0, 
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Bottom - Meta branding (like real Facebook)
          AnimatedBuilder(
            animation: _metaFade,
            builder: (context, child) {
              return Opacity(
                opacity: _metaFade.value,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'from',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Meta infinity logo
                          CustomPaint(
                            size: const Size(24, 16),
                            painter: MetaLogoPainter(),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Beta',
                            style: TextStyle(
                              color: Color(0xFF1877F2),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Custom painter for Meta infinity logo
class MetaLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1877F2)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Left loop
    path.moveTo(size.width * 0.5, size.height * 0.5);
    path.cubicTo(
      size.width * 0.25, size.height * 0.1,
      size.width * 0.0, size.height * 0.3,
      size.width * 0.0, size.height * 0.5,
    );
    path.cubicTo(
      size.width * 0.0, size.height * 0.7,
      size.width * 0.25, size.height * 0.9,
      size.width * 0.5, size.height * 0.5,
    );
    
    // Right loop
    path.cubicTo(
      size.width * 0.75, size.height * 0.1,
      size.width * 1.0, size.height * 0.3,
      size.width * 1.0, size.height * 0.5,
    );
    path.cubicTo(
      size.width * 1.0, size.height * 0.7,
      size.width * 0.75, size.height * 0.9,
      size.width * 0.5, size.height * 0.5,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
