import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import 'package:jugaad_fix/models/jugaad_model.dart';
import 'package:jugaad_fix/services/firestore_service.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.jugaad,
    this.onToggleBookmark,
    this.onToggleUpvote,
  });

  final Jugaad jugaad;
  final VoidCallback? onToggleBookmark;
  final VoidCallback? onToggleUpvote;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _userRating = 0;
  double _averageRating = 0.0;
  int _ratingCount = 0;
  bool _isLoadingRating = true;
  bool _isSubmittingRating = false;
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.jugaad.isBookmarked;
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    try {
      final userRating = await FirestoreService.getUserRating(
          widget.jugaad.id);
      final jugaadRating = await FirestoreService.getJugaadRating(
          widget.jugaad.id);
      if (mounted) {
        setState(() {
          _userRating = userRating;
          _averageRating =
              jugaadRating['averageRating'] as double;
          _ratingCount = jugaadRating['ratingCount'] as int;
          _isLoadingRating = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingRating = false);
    }
  }

  Future<void> _submitRating(int stars) async {
    setState(() => _isSubmittingRating = true);
    try {
      await FirestoreService.submitRating(
          widget.jugaad.id, stars);
      await _loadRatings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${_starLabel(stars)} Rating save ho gaya!'),
            backgroundColor: const Color(0xFFFF6B00),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Rating save nahi hua, try again!')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmittingRating = false);
      }
    }
  }

  String _starLabel(int stars) {
    switch (stars) {
      case 1:
        return '⭐ Bekaar';
      case 2:
        return '⭐⭐ Theek Hai';
      case 3:
        return '⭐⭐⭐ Accha Hai';
      case 4:
        return '⭐⭐⭐⭐ Bahut Accha';
      case 5:
        return '⭐⭐⭐⭐⭐ Ekdum Jhakaas!';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF110806) : const Color(0xFFFFF8F0);
    final cardColor =
        isDark ? const Color(0xFF1C110D) : Colors.white;
    final textColor =
        isDark ? Colors.white : const Color(0xFF2C1810);
    final primary = const Color(0xFFFF6B00);
    final authorLine = widget.jugaad.authorName == null
        ? ''
        : 'By ${widget.jugaad.authorName}';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Jugaad Details',
          style: GoogleFonts.balooBhai2(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: primary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_outline_rounded,
              color: _isBookmarked
                  ? primary
                  : textColor.withOpacity(0.7),
            ),
            onPressed: () {
              setState(() => _isBookmarked = !_isBookmarked);
              widget.onToggleBookmark?.call();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.jugaad.categoryEmoji,
                  style: const TextStyle(fontSize: 26),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.jugaad.categoryLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (widget.jugaad.isUserCreated)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.jugaad.upvotes >= 5
                          ? Colors.green.withOpacity(0.12)
                          : Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.jugaad.upvotes >= 5
                            ? Colors.green.withOpacity(0.4)
                            : Colors.orange.withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      widget.jugaad.upvotes >= 5
                          ? '✅ Verified'
                          : '⏳ Pending',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: widget.jugaad.upvotes >= 5
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.jugaad.title,
              style: GoogleFonts.balooBhai2(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            if (authorLine.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                authorLine,
                style: TextStyle(
                  fontSize: 13,
                  color: textColor.withOpacity(0.5),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: primary.withOpacity(0.15)),
              ),
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.jugaad.description,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Average rating ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: primary.withOpacity(0.15)),
              ),
              child: _isLoadingRating
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFF6B00),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(
                              _averageRating == 0.0
                                  ? 'No ratings yet'
                                  : _averageRating
                                      .toStringAsFixed(1),
                              style: GoogleFonts.balooBhai2(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: primary,
                              ),
                            ),
                            if (_averageRating > 0) ...[
                              const SizedBox(width: 8),
                              const Text('⭐',
                                  style: TextStyle(
                                      fontSize: 28)),
                            ],
                          ],
                        ),
                        if (_ratingCount > 0)
                          Text(
                            '$_ratingCount ${_ratingCount == 1 ? 'rating' : 'ratings'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor.withOpacity(0.5),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            final filled =
                                i < _averageRating.round();
                            return Icon(
                              filled
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: filled
                                  ? primary
                                  : textColor.withOpacity(0.3),
                              size: 28,
                            );
                          }),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 16),

            // ── User rating ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: primary.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userRating == 0
                        ? '⭐ Rate this jugaad'
                        : '✏️ Tumhari rating: ${_starLabel(_userRating)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final starValue = i + 1;
                      return GestureDetector(
                        onTap: _isSubmittingRating
                            ? null
                            : () => _submitRating(starValue),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4),
                          child: Icon(
                            starValue <= _userRating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: starValue <= _userRating
                                ? primary
                                : textColor.withOpacity(0.3),
                            size: 40,
                          ),
                        ),
                      );
                    }),
                  ),
                  if (_isSubmittingRating) ...[
                    const SizedBox(height: 8),
                    const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFF6B00),
                        ),
                      ),
                    ),
                  ],
                  if (_userRating > 0 &&
                      !_isSubmittingRating) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Tap any star to change rating',
                        style: TextStyle(
                          fontSize: 11,
                          color: textColor.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Upvote button ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.onToggleUpvote?.call();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                          'Jhakaas! Upvote registered 👍'),
                      backgroundColor: primary,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.thumb_up_alt_rounded),
                label: Text(
                  'Upvote (${widget.jugaad.upvotes})',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Share button ──
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _shareJugaad(widget.jugaad),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: BorderSide(
                      color: primary.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(
                      vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.share_rounded),
                label: const Text(
                  'Share Jugaad',
                  style:
                      TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _shareJugaad(Jugaad jugaad) {
    final text = '${jugaad.title}\n\n${jugaad.description}\n\n'
        '— Jugaad Fix app se 👍';
    Share.share(text);
  }
}