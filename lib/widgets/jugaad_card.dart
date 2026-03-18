import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:jugaad_fix/models/jugaad_model.dart';

class JugaadCard extends StatelessWidget {
  const JugaadCard({
    super.key,
    required this.jugaad,
    required this.index,
    required this.onTap,
    required this.onToggleUpvote,
    required this.onToggleBookmark,
    required this.onShare,
    this.onDelete,
  });

  final Jugaad jugaad;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onToggleUpvote;
  final VoidCallback onToggleBookmark;
  final VoidCallback onShare;
  final VoidCallback? onDelete;

  bool get _isOwner {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (!jugaad.isUserCreated) return false;
  // If createdByUid is null (older local jugaad), allow delete anyway
  if (jugaad.createdByUid == null) return true;
  return jugaad.createdByUid == uid;
}

  bool get _isVerified => jugaad.upvotes >= 5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 450),
      child: SlideAnimation(
        verticalOffset: 40,
        curve: Curves.easeOutCubic,
        child: FadeInAnimation(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: _isOwner
                    ? Border.all(
                        color: theme.colorScheme.primary
                            .withOpacity(0.3),
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top row: category + bookmark ──
                    Row(
                      children: [
                        Text(
                          jugaad.categoryEmoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            jugaad.categoryLabel,
                            overflow: TextOverflow.ellipsis,
                            style:
                                theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Delete button — only for owner
                        if (_isOwner && onDelete != null)
                          GestureDetector(
                            onTap: () =>
                                _confirmDelete(context),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              margin: const EdgeInsets.only(
                                  right: 6),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        GestureDetector(
                          onTap: onToggleBookmark,
                          child: Icon(
                            jugaad.isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_outline_rounded,
                            size: 22,
                            color: jugaad.isBookmarked
                                ? theme.colorScheme.primary
                                : theme.iconTheme.color
                                    ?.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // ── Title ──
                    Text(
                      jugaad.title,
                      style:
                          theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // ── Short description ──
                    Text(
                      jugaad.shortDescription,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Bottom row ──
                    Row(
                      children: [
                        // Upvote button
                        InkWell(
                          borderRadius:
                              BorderRadius.circular(24),
                          onTap: onToggleUpvote,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withOpacity(0.08),
                              borderRadius:
                                  BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.thumb_up_alt_rounded,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${jugaad.upvotes}',
                                  style: theme.textTheme
                                      .labelMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Community + verified/pending badge
                        if (jugaad.isUserCreated) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _isVerified
                                  ? Colors.green.withOpacity(0.12)
                                  : Colors.orange.withOpacity(0.12),
                              borderRadius:
                                  BorderRadius.circular(24),
                              border: Border.all(
                                color: _isVerified
                                    ? Colors.green.withOpacity(0.4)
                                    : Colors.orange.withOpacity(0.4),
                              ),
                            ),
                            child: Text(
                              _isVerified
                                  ? '✅ Verified'
                                  : '⏳ Pending',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _isVerified
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ),
                        ],

                        const Spacer(),

                        // Share button
                        GestureDetector(
                          onTap: onShare,
                          child: Icon(
                            Icons.share_rounded,
                            size: 20,
                            color: theme.iconTheme.color
                                ?.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '🗑️ Delete Jugaad?',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          '"${jugaad.title}" permanently delete ho jaayega. Kya pakka karna hai?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              onDelete?.call();
            },
            child: const Text('Delete Karo'),
          ),
        ],
      ),
    );
  }
}