import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/app_provider.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

/// Janitor's entire interface — one screen, one action.
class JanitorScreen extends StatefulWidget {
  const JanitorScreen({super.key});
  @override
  State<JanitorScreen> createState() => _JanitorScreenState();
}

class _JanitorScreenState extends State<JanitorScreen> {
  bool _done = false;

  Future<void> _markEmpty() async {
    await context.read<AppProvider>().markCollected();
    if (!mounted) return;
    setState(() => _done = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _done = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p    = context.watch<AppProvider>();
    final fill = p.fillLevel;
    final col  = statusColor(fill);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header
            Container(
              width: double.infinity,
              color: AppColors.greenDark,
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TIP QC — Canteen',
                      style: GoogleFonts.dmSans(
                          fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
                  const SizedBox(height: 4),
                  Text('Smart Trash',
                      style: GoogleFonts.syne(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.4)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Container(
                      width: 5, height: 5,
                      decoration: const BoxDecoration(
                          color: AppColors.greenMid, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text('ARDUINO · LIVE',
                        style: GoogleFonts.dmMono(
                            fontSize: 9,
                            color: Colors.white.withValues(alpha: 0.5),
                            letterSpacing: 0.8)),
                  ]),
                ],
              ),
            ),

            // ── Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 28, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Big gauge
                    FillGauge(fill: fill, size: 148),
                    const SizedBox(height: 20),

                    StatusPill(label: statusLabel(fill), color: col),
                    const SizedBox(height: 10),

                    Text(
                      statusMessage(fill),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppColors.inkMid,
                          height: 1.5),
                    ),
                    const SizedBox(height: 6),

                    Text('BIN-001 · TIP QC CANTEEN',
                        style: GoogleFonts.dmMono(
                            fontSize: 9, color: AppColors.inkLight)),
                    const SizedBox(height: 28),

                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: fill / 100,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation(col),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Empty',
                            style: GoogleFonts.dmMono(
                                fontSize: 8, color: AppColors.inkLight)),
                        Text('Full',
                            style: GoogleFonts.dmMono(
                                fontSize: 8, color: AppColors.inkLight)),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Action
                    if (_done)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.greenLight,
                          border: Border.all(
                              color: AppColors.green.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(children: [
                          Text('MARKED AS EMPTY',
                              style: GoogleFonts.dmMono(
                                  fontSize: 11,
                                  color: AppColors.green,
                                  letterSpacing: 0.6)),
                          const SizedBox(height: 4),
                          Text('Bin logged as collected.',
                              style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: AppColors.inkMid)),
                        ]),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PrimaryButton(
                              label: 'Mark Bin as Empty',
                              onPressed: _markEmpty),
                          const SizedBox(height: 8),
                          Text(
                            'Only press after physically emptying the bin.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                                fontSize: 11, color: AppColors.inkLight),
                          ),
                        ],
                      ),

                    const SizedBox(height: 32),

                    // Collection guide
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('COLLECTION GUIDE',
                                style: GoogleFonts.dmMono(
                                    fontSize: 9, color: AppColors.inkLight)),
                            const SizedBox(height: 10),
                            ...[
                              ['≥ 90%', 'Collect immediately', AppColors.red],
                              ['≥ 70%', 'Collect today', AppColors.amber],
                              ['≥ 40%', 'Monitor', AppColors.yellow],
                              ['< 40%', 'No action needed', AppColors.green],
                            ].asMap().entries.map((e) {
                              final i   = e.key;
                              final row = e.value;
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 7),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(row[0] as String,
                                            style: GoogleFonts.dmMono(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: row[2] as Color)),
                                        Text(row[1] as String,
                                            style: GoogleFonts.dmSans(
                                                fontSize: 12,
                                                color: AppColors.inkMid)),
                                      ],
                                    ),
                                  ),
                                  if (i < 3) const SlimDivider(),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Sign out strip
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    p.user?.name ?? 'Janitor',
                    style: GoogleFonts.dmMono(
                        fontSize: 9, color: AppColors.inkLight),
                  ),
                  OutlinedButton(
                    onPressed: () => context.read<AppProvider>().signOut(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.inkLight,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('Sign Out',
                        style: GoogleFonts.dmSans(
                            fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
