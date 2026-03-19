import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/sample_data.dart';
import '../models/jugaad_model.dart';
import 'detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  final Function(String) onCategorySelected;
  final List<Jugaad> allJugaads;
  final Future<void> Function(Jugaad) onToggleBookmark;
  final Future<void> Function(Jugaad) onToggleUpvote;

  const ExploreScreen({
    super.key,
    required this.onCategorySelected,
    required this.allJugaads,
    required this.onToggleBookmark,
    required this.onToggleUpvote,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String? _selectedCategoryKey;
  String? _selectedCategoryLabel;
  String? _selectedCategoryEmoji;

  Jugaad get _featuredJugaad {
    final all = List<Jugaad>.from(widget.allJugaads);
    all.sort((a, b) => b.upvotes.compareTo(a.upvotes));
    return all.first;
  }

  List<Jugaad> get _filteredJugaads {
    if (_selectedCategoryKey == null) return [];
    return widget.allJugaads
        .where((j) => j.categoryKey == _selectedCategoryKey)
        .toList()
      ..sort((a, b) => b.upvotes.compareTo(a.upvotes));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF110806) : const Color(0xFFFFF8F0);
    final cardColor =
        isDark ? const Color(0xFF1C110D) : Colors.white;
    final textColor =
        isDark ? Colors.white : const Color(0xFF2C1810);
    final primary = const Color(0xFFFF6B00);
    final categories = JugaadCategories.categories;

    if (_selectedCategoryKey != null) {
      return _buildCategoryJugaads(
          bgColor, cardColor, textColor, primary);
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔍 Explore',
                      style: GoogleFonts.balooBhai2(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: primary,
                      ),
                    ),
                    Text(
                      'Sabhi categories ek jagah',
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildFeaturedCard(context, textColor),
                    const SizedBox(height: 24),
                    Text(
                      '📦 All Categories',
                      style: GoogleFonts.balooBhai2(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final cat = categories[index];
                    final count = widget.allJugaads
                        .where((j) => j.categoryKey == cat['key'])
                        .length;
                    return _buildCategoryCard(
                      context,
                      cat,
                      count,
                      cardColor,
                      textColor,
                    );
                  },
                  childCount: categories.length,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryJugaads(
    Color bgColor,
    Color cardColor,
    Color textColor,
    Color primary,
  ) {
    final jugaads = _filteredJugaads;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategoryKey = null;
                        _selectedCategoryLabel = null;
                        _selectedCategoryEmoji = null;
                      });
                    },
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: textColor,
                    ),
                  ),
                  Text(
                    _selectedCategoryEmoji ?? '',
                    style: const TextStyle(fontSize: 26),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedCategoryLabel ?? '',
                      style: GoogleFonts.balooBhai2(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: primary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${jugaads.length}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: jugaads.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_rounded,
                              size: 48,
                              color: primary.withOpacity(0.4)),
                          const SizedBox(height: 12),
                          Text(
                            'Koi jugaad nahi mila!',
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor.withOpacity(0.5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          16, 0, 16, 24),
                      itemCount: jugaads.length,
                      itemBuilder: (context, index) {
                        final jugaad = jugaads[index];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(
                                jugaad: jugaad,
                                onToggleBookmark: () async {
                                  await widget
                                      .onToggleBookmark(jugaad);
                                  if (mounted) setState(() {});
                                },
                                onToggleUpvote: () async {
                                  await widget
                                      .onToggleUpvote(jugaad);
                                  if (mounted) setState(() {});
                                },
                              ),
                            ),
                          ),
                          child: Container(
                            margin:
                                const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius:
                                  BorderRadius.circular(16),
                              border: Border.all(
                                color: primary.withOpacity(0.15),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  jugaad.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  jugaad.shortDescription,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        textColor.withOpacity(0.7),
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.thumb_up_alt_rounded,
                                      size: 14,
                                      color: primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${jugaad.upvotes} upvotes',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (jugaad.isUserCreated)
                                      Container(
                                        padding: const EdgeInsets
                                            .symmetric(
                                            horizontal: 8,
                                            vertical: 3),
                                        decoration: BoxDecoration(
                                          color: jugaad.upvotes >= 5
                                              ? Colors.green
                                                  .withOpacity(0.12)
                                              : Colors.orange
                                                  .withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(
                                                  20),
                                        ),
                                        child: Text(
                                          jugaad.upvotes >= 5
                                              ? '✅ Verified'
                                              : '⏳ Pending',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight:
                                                FontWeight.w700,
                                            color:
                                                jugaad.upvotes >= 5
                                                    ? Colors.green
                                                    : Colors.orange,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(
      BuildContext context, Color textColor) {
    final featured = _featuredJugaad;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailScreen(
            jugaad: featured,
            onToggleBookmark: () async {
              await widget.onToggleBookmark(featured);
              if (mounted) setState(() {});
            },
            onToggleUpvote: () async {
              await widget.onToggleUpvote(featured);
              if (mounted) setState(() {});
            },
          ),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B00), Color(0xFFFF8C00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B00).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '⭐ Aaj ka Jugaad',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              featured.title,
              style: GoogleFonts.balooBhai2(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              featured.shortDescription,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.85),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.thumb_up_outlined,
                    color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${featured.upvotes} upvotes',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12),
                ),
                const SizedBox(width: 12),
                Text(
                  featured.categoryEmoji,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 4),
                Text(
                  featured.categoryLabel,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    Map<String, String> cat,
    int count,
    Color cardColor,
    Color textColor,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryKey = cat['key'];
          _selectedCategoryLabel = cat['label'];
          _selectedCategoryEmoji = cat['emoji'];
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFF6B00).withOpacity(0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              cat['emoji']!,
              style: const TextStyle(fontSize: 34),
            ),
            const SizedBox(height: 8),
            Text(
              cat['label']!,
              style: GoogleFonts.balooBhai2(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B00).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count jugaads',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFFFF6B00),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}