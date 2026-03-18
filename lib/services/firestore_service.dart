import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jugaad_fix/models/jugaad_model.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static DocumentReference _userDoc() =>
      _db.collection('users').doc(_uid);

  static Future<void> addLiked(String jugaadId) async {
    if (_uid == null) return;
    await _userDoc().set({
      'likedIds': FieldValue.arrayUnion([jugaadId]),
    }, SetOptions(merge: true));
  }

  static Future<void> removeLiked(String jugaadId) async {
    if (_uid == null) return;
    await _userDoc().set({
      'likedIds': FieldValue.arrayRemove([jugaadId]),
    }, SetOptions(merge: true));
  }

  static Future<void> addBookmark(String jugaadId) async {
    if (_uid == null) return;
    await _userDoc().set({
      'bookmarkedIds': FieldValue.arrayUnion([jugaadId]),
    }, SetOptions(merge: true));
  }

  static Future<void> removeBookmark(String jugaadId) async {
    if (_uid == null) return;
    await _userDoc().set({
      'bookmarkedIds': FieldValue.arrayRemove([jugaadId]),
    }, SetOptions(merge: true));
  }

  static Future<void> submitJugaad(Jugaad jugaad) async {
    if (_uid == null) return;
    await _db.collection('jugaads').doc(jugaad.id).set({
      'id': jugaad.id,
      'title': jugaad.title,
      'categoryKey': jugaad.categoryKey,
      'categoryEmoji': jugaad.categoryEmoji,
      'categoryLabel': jugaad.categoryLabel,
      'shortDescription': jugaad.shortDescription,
      'description': jugaad.description,
      'authorName': jugaad.authorName,
      'isUserCreated': true,
      'createdAt': jugaad.createdAt,
      'createdByUid': _uid,
      'upvotes': 0,
      'status': 'pending',
      'averageRating': 0.0,
      'ratingCount': 0,
      'submittedAt': FieldValue.serverTimestamp(),
    });

    await _userDoc().set({
      'submittedIds': FieldValue.arrayUnion([jugaad.id]),
      'displayName': FirebaseAuth.instance.currentUser?.displayName,
      'email': FirebaseAuth.instance.currentUser?.email,
      'joinedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<bool> deleteJugaad(String jugaadId) async {
    if (_uid == null) return false;
    try {
      final doc =
          await _db.collection('jugaads').doc(jugaadId).get();
      if (!doc.exists) return false;
      final data = doc.data() as Map<String, dynamic>;
      if (data['createdByUid'] != _uid) return false;
      await _db.collection('jugaads').doc(jugaadId).delete();
      await _userDoc().set({
        'submittedIds': FieldValue.arrayRemove([jugaadId]),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Jugaad>> fetchSubmittedJugaads() async {
    try {
      final snapshot = await _db
          .collection('jugaads')
          .where('isUserCreated', isEqualTo: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Jugaad(
          id: data['id'] as String,
          title: data['title'] as String,
          categoryKey: data['categoryKey'] as String,
          categoryEmoji: data['categoryEmoji'] as String,
          categoryLabel: data['categoryLabel'] as String,
          shortDescription: data['shortDescription'] as String,
          description: data['description'] as String,
          authorName: data['authorName'] as String?,
          isUserCreated: true,
          createdAt: data['createdAt'] as String?,
          createdByUid: data['createdByUid'] as String?,
          upvotes: data['upvotes'] as int? ?? 0,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> upvoteJugaad(String jugaadId) async {
    if (_uid == null) return;
    final ref = _db.collection('jugaads').doc(jugaadId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final current =
          (snap.data()?['upvotes'] as int?) ?? 0;
      final newCount = current + 1;
      tx.update(ref, {
        'upvotes': newCount,
        if (newCount >= 5) 'status': 'verified',
      });
    });
  }

  // ── Star Rating ──

  // Submit or update a star rating (1-5)
  static Future<void> submitRating(
      String jugaadId, int stars) async {
    if (_uid == null) return;
    final ratingRef = _db
        .collection('jugaads')
        .doc(jugaadId)
        .collection('ratings')
        .doc(_uid);
    final jugaadRef =
        _db.collection('jugaads').doc(jugaadId);

    await _db.runTransaction((tx) async {
      final ratingSnap = await tx.get(ratingRef);
      final jugaadSnap = await tx.get(jugaadRef);

      int oldStars = 0;
      if (ratingSnap.exists) {
        oldStars =
            (ratingSnap.data()?['stars'] as int?) ?? 0;
      }

      double currentAvg = 0.0;
      int currentCount = 0;

      if (jugaadSnap.exists) {
        currentAvg =
            (jugaadSnap.data()?['averageRating'] as num?)
                    ?.toDouble() ??
                0.0;
        currentCount =
            (jugaadSnap.data()?['ratingCount'] as int?) ?? 0;
      }

      double newAvg;
      int newCount;

      if (ratingSnap.exists && oldStars > 0) {
        // Update existing rating
        final totalStars = currentAvg * currentCount;
        final updatedTotal = totalStars - oldStars + stars;
        newCount = currentCount;
        newAvg = updatedTotal / newCount;
      } else {
        // New rating
        final totalStars = currentAvg * currentCount;
        newCount = currentCount + 1;
        newAvg = (totalStars + stars) / newCount;
      }

      // Round to 1 decimal
      newAvg = double.parse(newAvg.toStringAsFixed(1));

      tx.set(ratingRef, {
        'stars': stars,
        'uid': _uid,
        'ratedAt': FieldValue.serverTimestamp(),
      });

      if (jugaadSnap.exists) {
        tx.update(jugaadRef, {
          'averageRating': newAvg,
          'ratingCount': newCount,
        });
      } else {
        tx.set(jugaadRef, {
          'averageRating': newAvg,
          'ratingCount': newCount,
        }, SetOptions(merge: true));
      }
    });
  }

  // Fetch current user's rating for a jugaad
  static Future<int> getUserRating(String jugaadId) async {
    if (_uid == null) return 0;
    try {
      final doc = await _db
          .collection('jugaads')
          .doc(jugaadId)
          .collection('ratings')
          .doc(_uid)
          .get();
      if (!doc.exists) return 0;
      return (doc.data()?['stars'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Fetch average rating and count for a jugaad
  static Future<Map<String, dynamic>> getJugaadRating(
      String jugaadId) async {
    try {
      final doc = await _db
          .collection('jugaads')
          .doc(jugaadId)
          .get();
      if (!doc.exists) {
        return {'averageRating': 0.0, 'ratingCount': 0};
      }
      return {
        'averageRating':
            (doc.data()?['averageRating'] as num?)
                    ?.toDouble() ??
                0.0,
        'ratingCount':
            (doc.data()?['ratingCount'] as int?) ?? 0,
      };
    } catch (e) {
      return {'averageRating': 0.0, 'ratingCount': 0};
    }
  }
}