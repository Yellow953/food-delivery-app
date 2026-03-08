import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOutBack,
      ),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaleController.forward();
      _navigateAfterDelay();
    });
  }

  Future<void> _navigateAfterDelay() async {
    final authService = Get.find<AuthService>();
    // Wait for both: minimum splash time AND Firebase auth state to be known.
    // awaitAuthState() resolves as soon as Firebase emits (null = logged out,
    // User = logged in), so we never check isLoggedIn before Firebase is ready.
    await Future.wait([
      Future<void>.delayed(const Duration(milliseconds: 2000)),
      authService.awaitAuthState(),
    ]);
    if (!mounted) return;

    if (authService.isLoggedIn) {
      final uid = authService.currentUser.value!.uid;
      final userService = Get.find<UserService>();
      final role = await userService.fetchRoleForUid(uid);
      if (!mounted) return;
      Get.offAllNamed<void>(UserService.routeForRole(role));
    } else {
      Get.offAllNamed<void>(AppRoutes.auth);
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleController, _pulseController]),
          builder: (context, child) {
            final pulse = 1.0 + (_pulseController.value * 0.08);
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value * pulse,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.delivery_dining,
                      size: 88,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Delivery',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.secondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Order food, delivered fast',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
