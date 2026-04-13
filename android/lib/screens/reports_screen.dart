import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/app_provider.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _filing     = false;
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
    setState(() { _submitting = false; _filing = false; });
  }

  Future<void> _updateStatus(String id, String status) async {
    await context.read<AppProvider>().updateReportStatus(id, status);
  }

  Future<void> _deleteReport(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Report',
            style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to delete this resolved report?',
            style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.inkMid)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.dmSans(color: AppColors.inkLight)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, color: AppColors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<AppProvider>().deleteReport(id);
    }
  }

  Color _statusColor(ReportStatus s) {
    switch (s) {
      case ReportStatus.resolved:   return AppColors.green;
      case ReportStatus.inProgress: return AppColors.amber;
      case ReportStatus.pending:    return AppColors.inkMid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p       = context.watch<AppProvider>();
    final reports = p.reports;
    final isAdmin = p.isAdmin;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          TextButton(
            onPressed: () => setState(() => _filing = !_filing),
            child: Text(
              _filing ? 'Cancel' : '+ File',
              style: GoogleFonts.dmSans(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: _filing ? AppColors.inkLight : AppColors.green),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_filing)
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('NEW REPORT · TIP QC CANTEEN',
                        style: GoogleFonts.dmMono(
                            fontSize: 9, color: AppColors.inkLight, letterSpacing: 0.8)),
                    const SizedBox(height: 8),
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
            Expanded(
              child: reports.isEmpty
                  ? Center(
                      child: Text('No reports filed yet.',
                          style: GoogleFonts.dmMono(fontSize: 11, color: AppColors.inkLight)))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                      itemCount: reports.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text('REPORTS · ${reports.length}'.toUpperCase(),
                                style: GoogleFonts.dmMono(
                                    fontSize: 9, color: AppColors.inkLight, letterSpacing: 1.2)),
                          );
                        }
                        final r = reports[index - 1];
                        return _ReportCard(
                          report: r,
                          isAdmin: isAdmin,
                          statusColor: _statusColor(r.status),
                          onStart: r.status == ReportStatus.pending
                              ? () => _updateStatus(r.id, 'inProgress') : null,
                          onResolve: r.status != ReportStatus.resolved
                              ? () => _updateStatus(r.id, 'resolved') : null,
                          onDelete: isAdmin && r.status == ReportStatus.resolved
                              ? () => _deleteReport(r.id) : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Report report;
  final bool isAdmin;
  final Color statusColor;
  final VoidCallback? onStart;
  final VoidCallback? onResolve;
  final VoidCallback? onDelete;

  const _ReportCard({
    required this.report,
    required this.isAdmin,
    required this.statusColor,
    this.onStart,
    this.onResolve,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(report.id,
                    style: GoogleFonts.dmMono(
                        fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.ink)),
                Row(children: [
                  StatusPill(label: report.statusLabel, color: statusColor),
                  if (onDelete != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDelete,
                      child: Icon(Icons.delete_outline,
                          size: 16, color: AppColors.red.withValues(alpha: 0.7)),
                    ),
                  ],
                ]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.issue,
                    style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.inkMid, height: 1.5)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('${report.filedBy} · ${_timeAgo(report.createdAt)}',
                          style: GoogleFonts.dmMono(fontSize: 9, color: AppColors.inkLight)),
                    ),
                    if (isAdmin && report.status != ReportStatus.resolved)
                      Row(children: [
                        if (onStart != null) ...[
                          _ActionChip(label: 'Start', color: AppColors.amber, onTap: onStart!),
                          const SizedBox(width: 6),
                        ],
                        if (onResolve != null)
                          _ActionChip(label: 'Resolve', color: AppColors.green, onTap: onResolve!),
                      ]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24)   return '${diff.inHours} hr ago';
    return DateFormat('MMM d').format(dt);
  }
}

class _ActionChip extends StatelessWidget {
  final String label; final Color color; final VoidCallback onTap;
  const _ActionChip({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            border: Border.all(color: color), borderRadius: BorderRadius.circular(6)),
        child: Text(label,
            style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
      ),
    );
  }
}