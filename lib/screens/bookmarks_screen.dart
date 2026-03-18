import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import 'package:jugaad_fix/models/jugaad_model.dart';
import 'package:jugaad_fix/widgets/jugaad_card.dart';
import 'package:jugaad_fix/screens/detail_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({
    super.key,
    required this.bookmarked,
    required this.onToggleBookmark,
    required this.onToggleUpvote,
    required this.onDeleteJugaad,
  });

  final List<Jugaad> bookmarked;
  final void Function(Jugaad) onToggleBookmark;
  final void Function(Jugaad) onToggleUpvote;
  final Future<void> Function(Jugaad) onDeleteJugaad;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF110806) : const Color(0xFFFFF8F0);
    final textColor =
        isDark ? Colors.white : const Color(0xFF2C1810);
    final primary = const Color(0xFFFF6B00);

    return Container(
      color: bgColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔖 Saved Jugaads',
                          style: GoogleFonts.balooBhai2(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: primary,
                          ),
                        ),
                        Text(
                          bookmarked.isEmpty
                              ? 'Abhi kuch save nahi kiya'
                              : '${bookmarked.length} jugaad${bookmarked.length == 1 ? '' : 's'} saved',
                          style: TextStyle(
                            fontSize: 13,
                            color: textColor.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (bookmarked.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${bookmarked.length}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Content ──
            Expanded(
              child: bookmarked.isEmpty
                  ? _buildEmptyState(theme, primary, textColor)
                  : AnimationLimiter(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: bookmarked.length,
                        itemBuilder: (context, index) {
                          final item = bookmarked[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 400),
                            child: SlideAnimation(
                              verticalOffset: 30,
                              child: FadeInAnimation(
                                child: JugaadCard(
  jugaad: item,
  index: index,
  onTap: () => _openDetail(context, item),
  onToggleUpvote: () => onToggleUpvote(item),
  onToggleBookmark: () => onToggleBookmark(item),
  onShare: () => _share(item),
  onDelete: item.isUserCreated
      ? () => onDeleteJugaad(item)
      : null,
),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      ThemeData theme, Color primary, Color textColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.bookmark_outline_rounded,
                size: 48,
                color: primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Abhi kuch save nahi kiya!',
              style: GoogleFonts.balooBhai2(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Jo jugaad pasand aaye usko 🔖 tap karke\nsave karo — yahan milega hamesha.',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: textColor.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primary.withOpacity(0.3)),
              ),
              child: Text(
                '💡 Home pe jaao aur jugaad explore karo',
                style: TextStyle(
                  fontSize: 13,
                  color: primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, Jugaad jugaad) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: DetailScreen(jugaad: jugaad),
          ),
        ),
      ),
    );
  }

  void _share(Jugaad jugaad) {
    final text = '${jugaad.title}\n\n${jugaad.description}\n\n'
        '— Jugaad Fix app se 👍';
    Share.share(text);
  }
}