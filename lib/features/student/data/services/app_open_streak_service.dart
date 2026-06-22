import 'package:shared_preferences/shared_preferences.dart';

class AppOpenStreakService {
  static const _prefsKey = 'app_open_dates';

  Future<void> recordOpenToday() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _dateKey(DateTime.now());
    final openDates = prefs.getStringList(_prefsKey) ?? [];

    if (!openDates.contains(todayKey)) {
      openDates.add(todayKey);
      final cutoff = DateTime.now().subtract(const Duration(days: 14));
      final trimmed = openDates.where((d) {
        final parsed = _parseKey(d);
        return parsed != null && parsed.isAfter(cutoff);
      }).toList();
      await prefs.setStringList(_prefsKey, trimmed);
    }
  }

  Future<List<bool>> getWeekOpenStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final openDates = (prefs.getStringList(_prefsKey) ?? []).toSet();
    final today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - DateTime.monday));

    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      return openDates.contains(_dateKey(day));
    });
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DateTime? _parseKey(String key) {
    final parts = key.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }
}