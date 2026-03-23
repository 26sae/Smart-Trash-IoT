import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/app_provider.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p    = context.watch<AppProvider>();
    final user = p.user;
    final fill = p.fillLevel;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Avatar card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 54, height: 54,
                        decoration: BoxDecoration(
                          color: AppColors.greenDark,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          (user?.name.isNotEmpty == true)
                              ? user!.name[0].toUpperCase()
                              : 'A',
                          style: GoogleFonts.syne(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Admin User',
                              style: GoogleFonts.syne(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink),
                            ),
                            const SizedBox(height: 5),
                            StatusPill(
                                label: user?.role.name.capitalize() ?? 'Administrator',
                                color: AppColors.green),
                            const SizedBox(height: 6),
                            Text('HEAD OF SANITATION · TIP QC',
                                style: GoogleFonts.dmMono(
                                    fontSize: 9, color: AppColors.inkLight)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Account
              const SectionLabel('Account'),
              Card(
                child: Column(children: [
                  _InfoRow(k: 'Name',   v: user?.name  ?? '—'),
                  _InfoRow(k: 'Email',  v: user?.email ?? '—'),
                  _InfoRow(k: 'Role',   v: user?.role.name.capitalize() ?? '—'),
                  const _InfoRow(k: 'Access', v: 'Full System', last: true),
                ]),
              ),

              // ── System
              const SectionLabel('System'),
              Card(
                child: Column(children: [
                  const _InfoRow(k: 'Microcontroller', v: 'Arduino UNO'),
                  const _InfoRow(k: 'Sensor',          v: 'HC-SR04 Ultrasonic'),
                  const _InfoRow(k: 'Bin ID',          v: 'BIN-001'),
                  _InfoRow(k: 'Location',   v: p.bin?.location  ?? 'TIP QC Canteen'),
                  _InfoRow(
                    k: 'Fill Level',
                    v: '${fill.toInt()}%',
                    vc: statusColor(fill),
                    last: true,
                  ),
                ]),
              ),

              // ── Settings
              const SectionLabel(''),
              Card(
                child: Column(children: [
                  _SettingsTile(
                    title: 'Notifications',
                    subtitle: 'Bin overflow alerts',
                    onTap: () => _showInfo(context, 'Notifications',
                        'You will be notified when bin fill level reaches 90%.'),
                  ),
                  _SettingsTile(
                    title: 'How It Works',
                    subtitle: 'HC-SR04 + Arduino UNO',
                    onTap: () => _showInfo(context, 'How It Works',
                        'The HC-SR04 ultrasonic sensor measures the distance '
                        'from sensor to trash. Arduino converts this to a fill '
                        'percentage and uploads it to Firebase Realtime Database '
                        'every 5 minutes.'),
                  ),
                  _SettingsTile(
                    title: 'About',
                    subtitle: 'TripleB · IT32S6 · SAD 003',
                    onTap: () => _showInfo(context, 'About',
                        'Smart Trash Bin Monitoring System\n'
                        'Version 1.0.0\n'
                        'Team TRIPLEB — BSIT IT32S6\n'
                        'Technological Institute of the Philippines, QC'),
                    last: true,
                  ),
                ]),
              ),

              // ── Logout
              const SizedBox(height: 16),
              OutlineButton2(
                label: 'Logout',
                color: AppColors.red,
                onPressed: () => _confirmLogout(context),
              ),

              const SizedBox(height: 24),
              Text(
                'SMART TRASH v1.0.0 · TRIPLEB · TIP QC · IT32S6',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmMono(
                    fontSize: 9, color: AppColors.inkLight),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfo(BuildContext ctx, String title, String body) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(title,
            style: GoogleFonts.syne(
                fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(body,
            style: GoogleFonts.dmSans(
                fontSize: 13, color: AppColors.inkMid, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('OK',
                style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600, color: AppColors.green)),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('Sign Out',
            style: GoogleFonts.syne(
                fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to sign out?',
            style: GoogleFonts.dmSans(
                fontSize: 13, color: AppColors.inkMid)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.dmSans(color: AppColors.inkLight)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctx.read<AppProvider>().signOut();
            },
            child: Text('Sign Out',
                style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600, color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}

// ── Helpers

class _InfoRow extends StatelessWidget {
  final String k;
  final String v;
  final Color? vc;
  final bool last;
  const _InfoRow({required this.k, required this.v, this.vc, this.last = false});

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
          Text(k,
              style: GoogleFonts.dmSans(
                  fontSize: 12, color: AppColors.inkLight)),
          Flexible(
            child: Text(v,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: vc ?? AppColors.ink)),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool last;
  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink)),
                Text(subtitle,
                    style: GoogleFonts.dmSans(
                        fontSize: 11, color: AppColors.inkLight)),
              ],
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.border, size: 20),
          ],
        ),
      ),
    );
  }
}

extension StringExt on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
