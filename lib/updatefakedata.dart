import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'splashscreen.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageSelectPage extends StatelessWidget {
  const LanguageSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF4F7),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Language Icon with circular background
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.language,
                  size: 60,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'select_language'.tr(),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // English Button
              _buildLanguageButton(
                context,
                title: 'English',
                color: Colors.green.shade600,
                icon: Icons.translate,
                locale: const Locale('en'),
              ),
              const SizedBox(height: 20),

              // Hindi Button
              _buildLanguageButton(
                context,
                title: 'हिंदी(Under Devlopement)',
                color: Colors.grey,
                icon: Icons.g_translate,
                locale: const Locale('hi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(
    BuildContext context, {
    required String title,
    required Color color,
    required IconData icon,
    required Locale locale,
  }) {
    return InkWell(
      onTap: () async {
        await context.setLocale(locale);
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (_) => const SplashScreen()),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          height: 55,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
