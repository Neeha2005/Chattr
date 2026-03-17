// lib/widgets/export_sheet.dart
// ✨ Beautiful bottom sheet for choosing export format
//    Shows PDF preview, share options, and export progress

import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/export_service.dart';
import '../theme/app_theme.dart';
import '../theme/persona_theme.dart';

class ExportSheet extends StatefulWidget {
  final List<Message> messages;
  final PersonaTheme persona;
  final String chatTitle;

  const ExportSheet({
    super.key,
    required this.messages,
    required this.persona,
    required this.chatTitle,
  });

  // ── Static show method ────────────────────────────────────────────────────
  static Future<void> show({
    required BuildContext context,
    required List<Message> messages,
    required PersonaTheme persona,
    String chatTitle = 'Chat Export',
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ExportSheet(
        messages: messages,
        persona: persona,
        chatTitle: chatTitle,
      ),
    );
  }

  @override
  State<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<ExportSheet>
    with SingleTickerProviderStateMixin {
  bool _isExporting = false;
  String _exportStatus = '';

  late AnimationController _animController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _exportPdf() async {
    setState(() {
      _isExporting = true;
      _exportStatus = 'Generating PDF…';
    });

    await ExportService.exportAsPdf(
      context: context,
      messages: widget.messages,
      persona: widget.persona,
      chatTitle: widget.chatTitle,
    );

    if (mounted) {
      setState(() {
        _isExporting = false;
        _exportStatus = '';
      });
      Navigator.pop(context);
    }
  }

  Future<void> _exportTxt() async {
    setState(() {
      _isExporting = true;
      _exportStatus = 'Preparing text file…';
    });

    await ExportService.exportAsTxt(
      context: context,
      messages: widget.messages,
      persona: widget.persona,
      chatTitle: widget.chatTitle,
    );

    if (mounted) {
      setState(() {
        _isExporting = false;
        _exportStatus = '';
      });
      Navigator.pop(context);
    }
  }

  Future<void> _previewPdf() async {
    Navigator.pop(context);
    await ExportService.previewPdf(
      context: context,
      messages: widget.messages,
      persona: widget.persona,
      chatTitle: widget.chatTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pt = widget.persona;

    return SlideTransition(
      position: _slideAnim,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle ─────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ── Header ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [pt.primary, pt.secondary]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.ios_share_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Export Chat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : AppTheme.lightText,
                          ),
                        ),
                        Text(
                          '${widget.messages.length} messages · ${pt.name}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white38
                                : AppTheme.lightSubtext,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Stats row ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _StatChip(
                    label: 'Messages',
                    value: '${widget.messages.length}',
                    color: pt.primary,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    label: 'Your msgs',
                    value:
                    '${widget.messages.where((m) => m.isUser).length}',
                    color: pt.secondary,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    label: 'AI replies',
                    value:
                    '${widget.messages.where((m) => !m.isUser).length}',
                    color: pt.primary,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Divider(
                height: 1,
                color:
                isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
            const SizedBox(height: 8),

            // ── Export options ──────────────────────────────────────
            if (_isExporting)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: pt.primary),
                    const SizedBox(height: 16),
                    Text(
                      _exportStatus,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white54
                            : AppTheme.lightSubtext,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // PDF option
              _ExportOption(
                icon: Icons.picture_as_pdf_rounded,
                iconColor: const Color(0xFFEF4444),
                title: 'Export as PDF',
                subtitle: 'Branded PDF with cover page & chat bubbles',
                badge: 'RECOMMENDED',
                badgeColor: pt.primary,
                isDark: isDark,
                onTap: _exportPdf,
              ),

              // Preview PDF
              _ExportOption(
                icon: Icons.preview_rounded,
                iconColor: pt.primary,
                title: 'Preview PDF',
                subtitle: 'View before exporting',
                isDark: isDark,
                onTap: _previewPdf,
              ),

              // TXT option
              _ExportOption(
                icon: Icons.text_snippet_outlined,
                iconColor: const Color(0xFF6366F1),
                title: 'Export as Text (.txt)',
                subtitle: 'Plain text file, easy to read anywhere',
                isDark: isDark,
                onTap: _exportTxt,
              ),
            ],

            const SizedBox(height: 16),

            // Cancel button
            if (!_isExporting)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isDark
                              ? AppTheme.darkBorder
                              : AppTheme.lightBorder,
                        ),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white54
                            : AppTheme.lightSubtext,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Stat Chip ─────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white38 : AppTheme.lightSubtext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Export Option Row ─────────────────────────────────────────────────────────
class _ExportOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;
  final Color? badgeColor;
  final bool isDark;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
    this.badge,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : AppTheme.lightText,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor!.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge!,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: badgeColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white38
                          : AppTheme.lightSubtext,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white24 : AppTheme.lightSubtext,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}