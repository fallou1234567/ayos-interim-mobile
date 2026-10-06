import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool rememberMe = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() {
    context.go('/app');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      body: Stack(
        children: [
          // ==========================================================
          // BACKGROUND IMAGE
          // ==========================================================

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Image.asset(
              'assets/images/splash.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // ==========================================================
          // LOGO AYOS
          // ==========================================================
          Positioned(
            top: 16,
            left: 8,
            child: Image.asset(
              'assets/images/logo2.png',
              width: 108,
              fit: BoxFit.contain,
            ),
          ),

          // ==========================================================
          // ZONE BLANCHE AVEC COURBE
          // ==========================================================
          Positioned(
            top: 215,
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipPath(
              clipper: LoginWhiteClipper(),
              child: Container(color: AppColors.white),
            ),
          ),

          // ==========================================================
          // CONTENU DU FORMULAIRE
          // ==========================================================
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(8, 300, 8, 30),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ====================================================
                  // TITRE
                  // ====================================================

                  const Center(
                    child: Text(
                      'Heureuse de vous revoir.',
                      style: AppTextStyles.title,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Center(
                    child: Text(
                      'Vos missions et votre planning vous attendent.',
                      style: AppTextStyles.subtitle,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ====================================================
                  // EMAIL
                  // ====================================================
                  const Text('Adresse e-mail', style: AppTextStyles.label),

                  const SizedBox(height: 8),

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'votre@email.fr',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ====================================================
                  // PASSWORD
                  // ====================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Mot de passe', style: AppTextStyles.label),

                      GestureDetector(
                        onTap: () {},

                        child: const Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,

                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),

                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },

                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ====================================================
                  // REMEMBER ME
                  // ====================================================
                  Row(
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: Checkbox(
                          value: rememberMe,
                          activeColor: AppColors.navy,

                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,

                          onChanged: (value) {
                            setState(() {
                              rememberMe = value ?? false;
                            });
                          },
                        ),
                      ),

                      const SizedBox(width: 2),

                      const Text(
                        'Rester connecté sur cet appareil',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ====================================================
                  // LOGIN BUTTON
                  // ====================================================
                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: _login,

                      child: const Text('Ouvrir mon espace  →'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// COURBE DE LA PARTIE BLANCHE
// ================================================================

class LoginWhiteClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, 15);

    // Courbe gauche → centre
    path.quadraticBezierTo(size.width * 0.25, -5, size.width * 0.50, 20);

    // Courbe centre → droite
    path.quadraticBezierTo(size.width * 0.75, 5, size.width, 15);

    path.lineTo(size.width, size.height);

    path.lineTo(0, size.height);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
