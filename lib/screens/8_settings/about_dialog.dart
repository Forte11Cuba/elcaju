import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:elcaju/l10n/app_localizations.dart';
import '../../core/constants/colors.dart';

/// Muestra el diálogo "Acerca de" de ElCaju
void showElCajuAboutDialog(BuildContext context, String appVersion) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.deepVoidPurple,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/img/elcajucubano.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'El Caju',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'v$appVersion',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            L10n.of(context)!.aboutTagline,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          _buildAboutDescription(context),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            L10n.of(context)!.close,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildAboutDescription(BuildContext context) {
  final description = L10n.of(context)!.aboutDescription;
  const keyword = 'LaChispa';
  final index = description.indexOf(keyword);
  if (index == -1) {
    return Text(
      description,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        color: AppColors.textSecondary.withValues(alpha: 0.7),
      ),
      textAlign: TextAlign.center,
    );
  }
  final before = description.substring(0, index);
  final after = description.substring(index + keyword.length);
  return RichText(
    textAlign: TextAlign.center,
    text: TextSpan(
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        color: AppColors.textSecondary.withValues(alpha: 0.7),
      ),
      children: [
        TextSpan(text: before),
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: GestureDetector(
            onTap: () => _openLaChispa(context),
            child: Text(
              keyword,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.secondaryAction,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.secondaryAction,
              ),
            ),
          ),
        ),
        TextSpan(text: after),
      ],
    ),
  );
}

Future<void> _openLaChispa(BuildContext context) async {
  final url = Uri.parse('https://app.lachispa.me');
  try {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.couldNotOpenLink),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
