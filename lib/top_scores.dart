import 'package:shared_preferences/shared_preferences.dart';

const String _key = '2048_top_scores';
const int _maxScores = 3;

/// Persists and retrieves the top [ _maxScores ] game scores.
class TopScores {
  static Future<List<int>> getTopScores() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    return raw.split(',').map((e) => int.tryParse(e) ?? 0).where((s) => s > 0).toList();
  }

  static Future<void> addScore(int score) async {
    if (score <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    final list = await getTopScores();
    list.add(score);
    list.sort((a, b) => b.compareTo(a));
    final top = list.take(_maxScores).join(',');
    await prefs.setString(_key, top);
  }
}
