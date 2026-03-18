import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jugaad_fix/models/jugaad_model.dart';
import 'package:jugaad_fix/data/sample_data.dart';
import 'package:jugaad_fix/services/firestore_service.dart';

class _PrefsKeys {
  static const upvotedIds = 'upvoted_ids';
  static const bookmarkedIds = 'bookmarked_ids';
  static const userJugaads = 'user_jugaads';
  static const themeMode = 'theme_mode';
}

class StorageService {
  StorageService._(this._prefs);

  final SharedPreferences _prefs;

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
  }

  Future<List<Jugaad>> loadAllJugaads() async {
    final upvoted =
        _prefs.getStringList(_PrefsKeys.upvotedIds) ?? <String>[];
    final bookmarked =
        _prefs.getStringList(_PrefsKeys.bookmarkedIds) ?? <String>[];
    final userJson = _prefs.getString(_PrefsKeys.userJugaads);

    final List<Jugaad> localUserCreated =
        userJson == null || userJson.isEmpty
            ? <Jugaad>[]
            : Jugaad.decodeList(userJson)
                .map<Jugaad>((j) => j.copyWithState(
                      upvotes: upvoted.contains(j.id)
                          ? (j.upvotes + 1)
                          : j.upvotes,
                      isBookmarked: bookmarked.contains(j.id),
                    ))
                .toList();

    final List<Jugaad> base = initialJugaads
        .map<Jugaad>((j) => j.copyWithState(
              upvotes: upvoted.contains(j.id)
                  ? (j.upvotes + 1)
                  : j.upvotes,
              isBookmarked: bookmarked.contains(j.id),
            ))
        .toList();

    List<Jugaad> newFromFirestore = <Jugaad>[];
    try {
      final List<Jugaad> firestoreJugaads =
          await FirestoreService.fetchSubmittedJugaads()
              .timeout(const Duration(seconds: 5));
      final Set<String> localIds =
          localUserCreated.map((j) => j.id).toSet();
      newFromFirestore = firestoreJugaads
          .where((j) => !localIds.contains(j.id))
          .map<Jugaad>((j) => j.copyWithState(
                upvotes: upvoted.contains(j.id)
                    ? (j.upvotes + 1)
                    : j.upvotes,
                isBookmarked: bookmarked.contains(j.id),
              ))
          .toList();
    } catch (e) {
      newFromFirestore = <Jugaad>[];
    }

    return <Jugaad>[...base, ...localUserCreated, ...newFromFirestore];
  }

  Future<void> toggleUpvote(String id) async {
    final existing =
        _prefs.getStringList(_PrefsKeys.upvotedIds) ?? <String>[];
    if (existing.contains(id)) {
      existing.remove(id);
      await FirestoreService.removeLiked(id);
    } else {
      existing.add(id);
      await FirestoreService.addLiked(id);
      await FirestoreService.upvoteJugaad(id);
    }
    await _prefs.setStringList(_PrefsKeys.upvotedIds, existing);
  }

  Future<void> toggleBookmark(String id) async {
    final existing =
        _prefs.getStringList(_PrefsKeys.bookmarkedIds) ?? <String>[];
    if (existing.contains(id)) {
      existing.remove(id);
      await FirestoreService.removeBookmark(id);
    } else {
      existing.add(id);
      await FirestoreService.addBookmark(id);
    }
    await _prefs.setStringList(_PrefsKeys.bookmarkedIds, existing);
  }

  Future<void> addUserJugaad(Jugaad jugaad) async {
    final existingJson = _prefs.getString(_PrefsKeys.userJugaads);
    final List<Jugaad> list =
        existingJson == null || existingJson.isEmpty
            ? <Jugaad>[]
            : Jugaad.decodeList(existingJson);
    list.add(jugaad);
    await _prefs.setString(
        _PrefsKeys.userJugaads, Jugaad.encodeList(list));
    await FirestoreService.submitJugaad(jugaad);
  }

  Future<bool> deleteUserJugaad(String jugaadId) async {
    final existingJson = _prefs.getString(_PrefsKeys.userJugaads);
    if (existingJson != null && existingJson.isNotEmpty) {
      final list = Jugaad.decodeList(existingJson);
      list.removeWhere((j) => j.id == jugaadId);
      await _prefs.setString(
          _PrefsKeys.userJugaads, Jugaad.encodeList(list));
    }

    final upvoted =
        _prefs.getStringList(_PrefsKeys.upvotedIds) ?? <String>[];
    upvoted.remove(jugaadId);
    await _prefs.setStringList(_PrefsKeys.upvotedIds, upvoted);

    final bookmarked =
        _prefs.getStringList(_PrefsKeys.bookmarkedIds) ?? <String>[];
    bookmarked.remove(jugaadId);
    await _prefs.setStringList(_PrefsKeys.bookmarkedIds, bookmarked);

    final deleted = await FirestoreService.deleteJugaad(jugaadId);
    return deleted;
  }

  String? loadThemeMode() => _prefs.getString(_PrefsKeys.themeMode);

  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(_PrefsKeys.themeMode, mode);
  }
}