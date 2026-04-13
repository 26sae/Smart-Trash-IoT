import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/app_provider.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class JanitorScreen extends StatefulWidget {
  const JanitorScreen({super.key});
  @override
  State<JanitorScreen> createState() => _JanitorScreenState();
}

class _JanitorScreenState extends State<JanitorScreen> {
  int _tab = 0; // 0 = Bins, 1 = Reports

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              color: AppColors.greenDark,
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TIP QC — Canteen',
                      style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.5))),
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
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                            color: AppColors.greenMid, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('ESP32 · LIVE',
                        style: GoogleFonts.dmMono(
                            fontSize: 9,
                            color: Colors.white.withValues(alpha: 0.5),
                            letterSpacing: 0.8)),
                  ]),
                ],
              ),
            ),

            // Tab bar
            Container(
              color: AppColors.white,
              child: Row(
                children: [
                  _TabBtn(
                      label: 'Bins',
                      active: _tab == 0,
                      onTap: () => setState(() => _tab = 0)),
                  _TabBtn(
                    label: 'Reports',
                    active: _tab == 1,
                    badge: p.pendingReports,
                    onTap: () => setState(() => _tab = 1),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _tab == 0 ? _BinsTab(p: p) : _ReportsTab(p: p),
            ),

            // Sign out strip
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(p.user?.name ?? 'Janitor',
                      style: GoogleFonts.dmMono(
                          fontSize: 9, color: AppColors.inkLight)),
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

// ── Tab button
class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final int badge;
  final VoidCallback onTap;
  const _TabBtn(
      {required this.label,
      required this.active,
      required this.onTap,
      this.badge = 0});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.green : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: active ? AppColors.green : AppColors.inkLight)),
              if (badge > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$badge',
                      style: GoogleFonts.dmMono(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bins Tab — two separate bin cards
class _BinsTab extends StatelessWidget {
  final AppProvider p;
  const _BinsTab({required this.p});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        children: [
          _BinCard(
            label: 'Biodegradable',
            binId: 'BIN-001',
            fill: p.fillLevel1,
            accentColor: AppColors.green,
          ),
          const SizedBox(height: 14),
          _BinCard(
            label: 'Non-Biodegradable',
            binId: 'BIN-002',
            fill: p.fillLevel2,
            accentColor: const Color(0xFF1565C0),
          ),
        ],
      ),
    );
  }
}

class _BinCard extends StatefulWidget {
  final String label;
  final String binId;
  final double fill;
  final Color accentColor;
  const _BinCard({
    required this.label,
    required this.binId,
    required this.fill,
    required this.accentColor,
  });
  @override
  State<_BinCard> createState() => _BinCardState();
}

class _BinCardState extends State<_BinCard> {
  bool _done = false;

  Future<void> _markEmpty() async {
    await context.read<AppProvider>().markCollected(widget.binId);
    if (!mounted) return;
    setState(() => _done = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _done = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final fill = widget.fill;
    final col = statusColor(fill);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Label
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: widget.accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: widget.accentColor.withValues(alpha: 0.3)),
              ),
              child: Text(widget.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: widget.accentColor,
                      letterSpacing: 0.5)),
            ),
            const SizedBox(height: 16),

            // Gauge
            FillGauge(fill: fill, size: 120),
            const SizedBox(height: 14),

            StatusPill(label: statusLabel(fill), color: col),
            const SizedBox(height: 8),
            Text(statusMessage(fill),
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                    fontSize: 12, color: AppColors.inkMid, height: 1.5)),
            const SizedBox(height: 6),
            Text('${widget.binId} · TIP QC CANTEEN',
                style:
                    GoogleFonts.dmMono(fontSize: 9, color: AppColors.inkLight)),
            const SizedBox(height: 16),

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
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Empty',
                  style: GoogleFonts.dmMono(
                      fontSize: 8, color: AppColors.inkLight)),
              Text('Full',
                  style: GoogleFonts.dmMono(
                      fontSize: 8, color: AppColors.inkLight)),
            ]),
            const SizedBox(height: 16),

            // Action
            if (_done)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  border:
                      Border.all(color: AppColors.green.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(children: [
                  Text('MARKED AS EMPTY',
                      style: GoogleFonts.dmMono(
                          fontSize: 10,
                          color: AppColors.green,
                          letterSpacing: 0.6)),
                  const SizedBox(height: 4),
                  Text('Bin logged as collected.',
                      style: GoogleFonts.dmSans(
                          fontSize: 11, color: AppColors.inkMid)),
                ]),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: _markEmpty,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.accentColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size(double.infinity, 46),
                    ),
                    child: Text('Mark ${widget.label} Bin as Empty',
                        style: GoogleFonts.dmSans(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 6),
                  Text('Only press after physically emptying the bin.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                          fontSize: 11, color: AppColors.inkLight)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ── Reports Tab — janitor can view and file, but not Start/Resolve
class _ReportsTab extends StatefulWidget {
  final AppProvider p;
  const _ReportsTab({required this.p});
  @override
  State<_ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<_ReportsTab> {
  bool _filing = false;
  bool _submitting = false;
  final _draftCtrl = TextEditingController();

  @override
  void dispose() {
    _draftCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _draftCtrl.text.trim();
    if (text.length < 10) return;
    setState(() => _submitting = true);
    await context.read<AppProvider>().fileReport(text);
    if (!mounted) return;
    _draftCtrl.clear();
    setState(() {
      _submitting = false;
      _filing = false;
    });
  }

  Color _statusColor(ReportStatus s) {
    switch (s) {
      case ReportStatus.resolved:
        return AppColors.green;
      case ReportStatus.inProgress:
        return AppColors.amber;
      case ReportStatus.pending:
        return AppColors.inkMid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reports = widget.p.reports;

    return Column(
      children: [
        // File button bar
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('REPORTS · ${reports.length}',
                  style: GoogleFonts.dmMono(
                      fontSize: 9,
                      color: AppColors.inkLight,
                      letterSpacing: 1.2)),
              TextButton(
                onPressed: () => setState(() => _filing = !_filing),
                child: Text(_filing ? 'Cancel' : '+ File Report',
                    style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _filing ? AppColors.inkLight : AppColors.green)),
              ),
            ],
          ),
        ),

        // File form
        if (_filing)
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _draftCtrl,
                  maxLines: 3,
                  style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.ink),
                  decoration: const InputDecoration(
                    hintText: 'Describe the issue... (min 10 characters)',
                  ),
                ),
                const SizedBox(height: 10),
                PrimaryButton(
                  label: _submitting ? 'Submitting...' : 'Submit Report',
                  onPressed: _submitting ? null : _submit,
                ),
              ],
            ),
          ),

        // Report list — read only for janitor
        Expanded(
          child: reports.isEmpty
              ? Center(
                  child: Text('No reports filed yet.',
                      style: GoogleFonts.dmMono(
                          fontSize: 11, color: AppColors.inkLight)))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
                  itemCount: reports.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final r = reports[i];
                    final sc = _statusColor(r.status);
                    return Card(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom:
                                        BorderSide(color: AppColors.border))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(r.id,
                                    style: GoogleFonts.dmMono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.ink)),
                                StatusPill(label: r.statusLabel, color: sc),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.issue,
                                    style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: AppColors.inkMid,
                                        height: 1.5)),
                                const SizedBox(height: 8),
                                Text('${r.filedBy} · ${_timeAgo(r.createdAt)}',
                                    style: GoogleFonts.dmMono(
                                        fontSize: 9,
                                        color: AppColors.inkLight)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return DateFormat('MMM d').format(dt);
  }
}
