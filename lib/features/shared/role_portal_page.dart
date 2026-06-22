import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/role_dashboard_service.dart';

class RolePortalPage extends StatefulWidget {
  final String endpoint;
  final String fallbackTitle;
  final Color accent;

  const RolePortalPage({
    super.key,
    required this.endpoint,
    required this.fallbackTitle,
    required this.accent,
  });

  @override
  State<RolePortalPage> createState() => _RolePortalPageState();
}

class _RolePortalPageState extends State<RolePortalPage> {
  final RoleDashboardService _service = RoleDashboardService();
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _service.getDashboard(widget.endpoint);
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _data?["title"]?.toString() ?? widget.fallbackTitle;
    final role = _data?["role"]?.toString() ?? widget.fallbackTitle;
    final summary = (_data?["summary"] as List?) ?? const [];
    final modules = (_data?["modules"] as List?) ?? const [];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF6EC),
        elevation: 0,
        foregroundColor: const Color(0xFF1C1C1E),
        title: Text(role, style: _title()),
      ),
      body: RefreshIndicator(
        color: widget.accent,
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          children: [
            _HeroCard(title: title, role: role, accent: widget.accent),
            const SizedBox(height: 14),
            if (_loading)
              _LoadingCard(accent: widget.accent)
            else ...[
              _SummaryGrid(summary: summary, accent: widget.accent),
              const SizedBox(height: 14),
              Text("Modules", style: _title(size: 18)),
              const SizedBox(height: 10),
              if (modules.isEmpty)
                _EmptyCard(accent: widget.accent)
              else
                ...modules.map(
                  (module) => _ModuleCard(
                    module: module as Map<String, dynamic>,
                    accent: widget.accent,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final String role;
  final Color accent;

  const _HeroCard({
    required this.title,
    required this.role,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: .30),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(role.toUpperCase(), style: _body(color: Colors.white70)),
                const SizedBox(height: 8),
                Text(title, style: _title(color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                  "Live workspace modules",
                  style: _body(color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .22),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final List<dynamic> summary;
  final Color accent;

  const _SummaryGrid({required this.summary, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        final item = index < summary.length
            ? summary[index] as Map<String, dynamic>
            : {"label": "-", "value": "0", "icon": "•"};
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == 2 ? 0 : 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .05),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["icon"]?.toString() ?? "•",
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item["value"]?.toString() ?? "0",
                    style: _title(size: 17),
                  ),
                  Text(item["label"]?.toString() ?? "-", style: _body()),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final Map<String, dynamic> module;
  final Color accent;

  const _ModuleCard({required this.module, required this.accent});

  @override
  Widget build(BuildContext context) {
    final items = (module["items"] as List?) ?? const [];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.apps_rounded, color: accent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  module["title"]?.toString() ?? "Module",
                  style: _title(size: 16),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: accent),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map(
                  (item) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1FBE8),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      item.toString(),
                      style: _body(color: const Color(0xFF357800)),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final Color accent;
  const _LoadingCard({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _plainCard(),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(color: accent, strokeWidth: 3),
          ),
          const SizedBox(width: 12),
          Text("Loading modules...", style: _body()),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final Color accent;
  const _EmptyCard({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _plainCard(),
      child: Text("No modules configured yet", style: _body(color: accent)),
    );
  }
}

BoxDecoration _plainCard() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(20),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: .05),
      blurRadius: 14,
      offset: const Offset(0, 4),
    ),
  ],
);

TextStyle _title({Color? color, double size = 20}) => GoogleFonts.inter(
  fontSize: size,
  fontWeight: FontWeight.w700,
  color: color ?? const Color(0xFF1C1C1E),
  height: 1.25,
);

TextStyle _body({Color? color}) => GoogleFonts.inter(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: color ?? const Color(0xFF8E8E93),
  height: 1.35,
);
