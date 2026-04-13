import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

// ── Section label
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.dmMono(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: AppColors.inkLight,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Status pill (outlined badge)
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const StatusPill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.dmMono(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Info row (key / value)
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool last;
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: last
              ? BorderSide.none
              : const BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 12, color: AppColors.inkLight)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.dmMono(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slim divider
class SlimDivider extends StatelessWidget {
  const SlimDivider({super.key});
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: AppColors.border);
}

// ── Primary button
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool danger;
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: danger ? AppColors.red : AppColors.green,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ── Outline button
class OutlineButton2 extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  const OutlineButton2({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.green;
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: c,
          side: BorderSide(color: c, width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ── Fill gauge (circular progress)
class FillGauge extends StatelessWidget {
  final double fill;
  final double size;
  const FillGauge({super.key, required this.fill, this.size = 96});

  @override
  Widget build(BuildContext context) {
    final col = statusColor(fill);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: fill / 100,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(col),
              strokeWidth: size * 0.083,
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: fill.toInt().toString(),
                      style: GoogleFonts.syne(
                        fontSize: size * 0.22,
                        fontWeight: FontWeight.w800,
                        color: col,
                        height: 1,
                      ),
                    ),
                    TextSpan(
                      text: '%',
                      style: GoogleFonts.syne(
                        fontSize: size * 0.11,
                        fontWeight: FontWeight.w700,
                        color: col,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'FULL',
                style: GoogleFonts.dmMono(
                  fontSize: size * 0.08,
                  color: AppColors.inkLight,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Mini stat card
class MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const MiniStatCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.dmMono(
                fontSize: 9,
                color: AppColors.inkLight,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: GoogleFonts.syne(
                fontSize: value.length > 8 ? 13 : 17,
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Loading screen
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.greenDark,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

// ── Error banner
class ErrorBanner extends StatelessWidget {
  final String message;
  const ErrorBanner(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.red),
      ),
    );
  }
}
