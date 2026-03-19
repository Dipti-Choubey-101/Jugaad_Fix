import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jugaad_fix/data/sample_data.dart';
import 'package:jugaad_fix/firebase_options.dart';
import 'package:jugaad_fix/models/jugaad_model.dart';
import 'package:jugaad_fix/screens/bookmarks_screen.dart';
import 'package:jugaad_fix/screens/home_screen.dart';
import 'package:jugaad_fix/screens/explore_screen.dart';
import 'package:jugaad_fix/screens/submit_screen.dart';
import 'package:jugaad_fix/screens/login_screen.dart';
import 'package:jugaad_fix/screens/detail_screen.dart';
import 'package:jugaad_fix/screens/splash_screen.dart';
import 'package:jugaad_fix/services/storage_service.dart';
import 'package:jugaad_fix/services/notification_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.init();
  await NotificationService.requestPermission();
  await NotificationService.scheduleDailyJugaad();
  final storage = await StorageService.init();
  final jugaads = await storage.loadAllJugaads();
  runApp(JugaadFixRoot(storage: storage, initialJugaads: jugaads));
}

class JugaadFixRoot extends StatefulWidget {
  const JugaadFixRoot({
    super.key,
    required this.storage,
    required this.initialJugaads,
  });

  final StorageService storage;
  final List<Jugaad> initialJugaads;

  @override
  State<JugaadFixRoot> createState() => _JugaadFixRootState();
}

class _JugaadFixRootState extends State<JugaadFixRoot> {
  late List<Jugaad> _jugaads;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _jugaads = widget.initialJugaads;
    final storedTheme = widget.storage.loadThemeMode();
    if (storedTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else if (storedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jugaad Fix',
      themeMode: _themeMode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
  return MaterialPageRoute(
    builder: (context) => _MainApp(
      jugaads: _jugaads,
      storage: widget.storage,
      themeMode: _themeMode,
      onToggleTheme: _toggleTheme,
      onToggleUpvote: _handleToggleUpvote,
      onToggleBookmark: _handleToggleBookmark,
      onAddJugaad: _handleAddJugaad,
      onDeleteJugaad: _handleDeleteJugaad,
    ),
  );
}
        return null;
      },
    );
  }

  Future<void> _handleToggleUpvote(Jugaad target) async {
    await widget.storage.toggleUpvote(target.id);
    final updated = await widget.storage.loadAllJugaads();
    if (!mounted) return;
    setState(() => _jugaads = updated);
  }

  Future<void> _handleToggleBookmark(Jugaad target) async {
    await widget.storage.toggleBookmark(target.id);
    final updated = await widget.storage.loadAllJugaads();
    if (!mounted) return;
    setState(() => _jugaads = updated);
  }

  Future<void> _handleAddJugaad(Jugaad jugaad) async {
    await widget.storage.addUserJugaad(jugaad);
    final updated = await widget.storage.loadAllJugaads();
    if (!mounted) return;
    setState(() => _jugaads = updated);
  }

  Future<void> _handleDeleteJugaad(Jugaad jugaad) async {
    if (!jugaad.isUserCreated) return;
    await widget.storage.deleteUserJugaad(jugaad.id);
    final updated = await widget.storage.loadAllJugaads();
    if (!mounted) return;
    setState(() => _jugaads = updated);
  }

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
        widget.storage.saveThemeMode('dark');
      } else {
        _themeMode = ThemeMode.light;
        widget.storage.saveThemeMode('light');
      }
    });
  }
}

// ── Main App Shell ──
class _MainApp extends StatefulWidget {
  const _MainApp({
    required this.jugaads,
    required this.storage,
    required this.themeMode,
    required this.onToggleTheme,
    required this.onToggleUpvote,
    required this.onToggleBookmark,
    required this.onAddJugaad,
    required this.onDeleteJugaad,
  });

  final List<Jugaad> jugaads;
  final StorageService storage;
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;
  final Future<void> Function(Jugaad) onToggleUpvote;
  final Future<void> Function(Jugaad) onToggleBookmark;
  final Future<void> Function(Jugaad) onAddJugaad;
  final Future<void> Function(Jugaad) onDeleteJugaad;

  @override
  State<_MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<_MainApp> {
  int _currentIndex = 0;
  String _selectedCategoryKey = '';

  void _onCategorySelected(String categoryKey) {
    setState(() {
      _selectedCategoryKey = categoryKey;
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName =
        user?.displayName ?? user?.email?.split('@')[0] ?? 'Jugaadi';

    return Scaffold(
      body: _buildBody(userName),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              if (index == 2) {
                _openSubmitScreen();
                return;
              }
              setState(() => _currentIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore_rounded),
                label: 'Explore',
              ),
              NavigationDestination(
                icon: Icon(Icons.add_circle_outline_rounded),
                selectedIcon: Icon(Icons.add_circle_rounded),
                label: 'Submit',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_outline_rounded),
                selectedIcon: Icon(Icons.bookmark_rounded),
                label: 'Saved',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 5),
            color: const Color(0xFF110806),
            child: const Text(
              'Made with ❤️ by Dipti Choubey',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFFFF6B00),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(String userName) {
    final bookmarked = widget.jugaads
        .where((j) => j.isBookmarked)
        .toList(growable: false);
    final sorted = [...widget.jugaads]
      ..sort((a, b) => b.upvotes.compareTo(a.upvotes));

    switch (_currentIndex) {
      case 0:
        return HomeScreen(
          allJugaads: sorted,
          onToggleUpvote: widget.onToggleUpvote,
          onToggleBookmark: widget.onToggleBookmark,
          onOpenSubmit: _openSubmitScreen,
          onDeleteJugaad: widget.onDeleteJugaad,
          initialCategoryKey: _selectedCategoryKey,
          onCategoryConsumed: () {
            setState(() => _selectedCategoryKey = '');
          },
        );
      case 1:
  return ExploreScreen(
    onCategorySelected: _onCategorySelected,
    allJugaads: widget.jugaads,
    onToggleBookmark: widget.onToggleBookmark,
    onToggleUpvote: widget.onToggleUpvote,
  );
      case 3:
        return BookmarksScreen(
          bookmarked: bookmarked,
          onToggleBookmark: widget.onToggleBookmark,
          onToggleUpvote: widget.onToggleUpvote,
          onDeleteJugaad: widget.onDeleteJugaad,
        );
      case 4:
        return _buildProfile(userName);
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _openSubmitScreen() async {
    final created = await Navigator.of(context).push<Jugaad>(
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
            child: const SubmitScreen(),
          ),
        ),
      ),
    );

    if (created != null) {
      await widget.onAddJugaad(created);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shandaar! Jugaad submit ho gaya 🎉'),
          ),
        );
      }
    }
  }

  Widget _buildProfile(String userName) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = widget.themeMode == ThemeMode.dark ||
        (widget.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness ==
                Brightness.dark);
    final bgColor =
        isDark ? const Color(0xFF110806) : const Color(0xFFFFF8F0);
    final cardColor =
        isDark ? const Color(0xFF1C110D) : Colors.white;
    final textColor =
        isDark ? Colors.white : const Color(0xFF2C1810);
    final primary = const Color(0xFFFF6B00);

    final totalLiked =
        widget.jugaads.where((j) => j.upvotes > 0).length;
    final totalBookmarked =
        widget.jugaads.where((j) => j.isBookmarked).length;
    final totalSubmitted =
        widget.jugaads.where((j) => j.isUserCreated).length;

    return Container(
      color: bgColor,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                '👤 Profile',
                style: GoogleFonts.balooBhai2(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: primary,
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primary,
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty
                            ? userName[0].toUpperCase()
                            : 'J',
                        style: GoogleFonts.balooBhai2(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '🔥 Jugaad Enthusiast',
                      style: TextStyle(
                        fontSize: 12,
                        color: primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final liked = widget.jugaads
                          .where((j) => j.upvotes > 0)
                          .toList();
                      _showJugaadListSheet(context,
                          '❤️ Liked Jugaads', liked,
                          cardColor, textColor, primary);
                    },
                    child: _profileStat('❤️',
                        totalLiked.toString(), 'Liked',
                        cardColor, textColor, primary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final saved = widget.jugaads
                          .where((j) => j.isBookmarked)
                          .toList();
                      _showJugaadListSheet(context,
                          '🔖 Saved Jugaads', saved,
                          cardColor, textColor, primary);
                    },
                    child: _profileStat('🔖',
                        totalBookmarked.toString(), 'Saved',
                        cardColor, textColor, primary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final posted = widget.jugaads
                          .where((j) => j.isUserCreated)
                          .toList();
                      _showJugaadListSheet(context,
                          '✍️ My Jugaads', posted,
                          cardColor, textColor, primary);
                    },
                    child: _profileStat('✍️',
                        totalSubmitted.toString(), 'Posted',
                        cardColor, textColor, primary),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: primary.withOpacity(0.15)),
              ),
              child: Column(
                children: [
                  _settingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About Jugaad Fix',
                    subtitle: 'App ke baare mein jaano',
                    color: primary,
                    textColor: textColor,
                    onTap: () => _showAboutDialog(context,
                        isDark, cardColor, textColor, primary),
                  ),
                  Divider(height: 1, color: primary.withOpacity(0.1)),
                  _settingsTile(
                    icon: isDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    title: 'Toggle Theme',
                    subtitle: isDark
                        ? 'Switch to Light Mode'
                        : 'Switch to Dark Mode',
                    color: primary,
                    textColor: textColor,
                    onTap: widget.onToggleTheme,
                  ),
                  Divider(height: 1, color: primary.withOpacity(0.1)),
                  _settingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Test Notification',
                    subtitle: 'Ek jugaad abhi dekho notification mein',
                    color: primary,
                    textColor: textColor,
                    onTap: () async {
                      await NotificationService.showTestNotification();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notification bhej diya! 🔔'),
                          ),
                        );
                      }
                    },
                  ),
                  Divider(height: 1, color: primary.withOpacity(0.1)),
                 _settingsTile(
  icon: Icons.logout_rounded,
  title: 'Logout',
  subtitle: 'Sign out of your account',
  color: Colors.red,
  textColor: textColor,
  onTap: () async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
  },
),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Made with ❤️ in India\nBy Dipti Choubey',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: textColor.withOpacity(0.5),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showJugaadListSheet(
    BuildContext context,
    String title,
    List<Jugaad> jugaads,
    Color cardColor,
    Color textColor,
    Color primary,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        builder: (_, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Row(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.balooBhai2(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: primary,
                    ),
                  ),
                  const Spacer(),
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
                            'Abhi kuch nahi hai yahan',
                            style: TextStyle(
                              fontSize: 15,
                              color: textColor.withOpacity(0.5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: controller,
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: jugaads.length,
                      itemBuilder: (context, index) {
                        final j = jugaads[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DetailScreen(jugaad: j),
                              ),
                            );
                          },
                          child: Container(
                            margin:
                                const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.06),
                              borderRadius:
                                  BorderRadius.circular(14),
                              border: Border.all(
                                color: primary.withOpacity(0.15),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(j.categoryEmoji,
                                    style: const TextStyle(
                                        fontSize: 22)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        j.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight:
                                              FontWeight.w700,
                                          color: textColor,
                                        ),
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        j.categoryLabel,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: primary,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.thumb_up_alt_rounded,
                                      size: 13,
                                      color:
                                          primary.withOpacity(0.7),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${j.upvotes}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: primary,
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

  void _showAboutDialog(
    BuildContext context,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color primary,
  ) {
    final textColorFaded = textColor.withOpacity(0.65);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary,
                  ),
                  child: Center(
                    child: Text(
                      'JF',
                      style: GoogleFonts.balooBhai2(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jugaad Fix',
                      style: GoogleFonts.balooBhai2(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: primary,
                      ),
                    ),
                    Text(
                      'Roz ke problems, desi style ke solutions.',
                      style: TextStyle(
                          fontSize: 12, color: textColorFaded),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: _statCard('125+', 'Jugaads',
                        cardColor, primary, textColor)),
                const SizedBox(width: 10),
                Expanded(
                    child: _statCard('25', 'Categories',
                        cardColor, primary, textColor)),
                const SizedBox(width: 10),
                Expanded(
                    child: _statCard('100%', 'Desi',
                        cardColor, primary, textColor)),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Jugaad Fix ek community-sourced Indian life hacks ka adda hai — '
              'yahan power cut se leke monsoon tak, har situation ke liye kisi na '
              'kisi ne pehle hi ek solid jugaad nikaal rakha hai.',
              style: TextStyle(
                  fontSize: 14, height: 1.6, color: textColor),
            ),
            const SizedBox(height: 16),
            Text(
              'App kya karta hai?',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textColor),
            ),
            const SizedBox(height: 10),
            _aboutPoint('Smart feed of 125+ Indian life hacks.',
                textColor, primary),
            _aboutPoint(
                '25 categories – power cut, kitchen, travel, money & more.',
                textColor, primary),
            _aboutPoint(
                'Offline-first – sab data aapke phone mein safe.',
                textColor, primary),
            _aboutPoint(
                'Upvotes & bookmarks – favourite jugaad kabhi na bhoolo.',
                textColor, primary),
            _aboutPoint(
                'Community submissions – apna hack bhejo!',
                textColor, primary),
            const SizedBox(height: 20),
            Text(
              'Version 1.0.0  •  Made with ❤️ in India',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: textColorFaded),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileStat(
    String emoji,
    String value,
    String label,
    Color cardColor,
    Color textColor,
    Color primary,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: primary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: textColor.withOpacity(0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: textColor,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: textColor.withOpacity(0.5),
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: textColor.withOpacity(0.3),
      ),
    );
  }

  Widget _aboutPoint(
      String text, Color textColor, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ',
              style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16)),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: textColor)),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    String value,
    String label,
    Color cardColor,
    Color primaryColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: textColor.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

ThemeData _buildLightTheme() {
  const primary = Color(0xFFFF6B00);
  const background = Color(0xFFFFF8F0);
  const textColor = Color(0xFF2C1810);

  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      background: background,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  return base.copyWith(
    scaffoldBackgroundColor: background,
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: background,
      elevation: 0,
      centerTitle: false,
      foregroundColor: textColor,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      base.textTheme.apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
    ),
    cardColor: Colors.white,
    navigationBarTheme: base.navigationBarTheme.copyWith(
      indicatorColor: primary.withOpacity(0.18),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme:
        base.floatingActionButtonTheme.copyWith(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}

ThemeData _buildDarkTheme() {
  const primary = Color(0xFFFF6B00);
  const background = Color(0xFF110806);

  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      background: background,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );

  return base.copyWith(
    scaffoldBackgroundColor: background,
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: background,
      elevation: 0,
      centerTitle: false,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
    cardColor: const Color(0xFF1C110D),
    navigationBarTheme: base.navigationBarTheme.copyWith(
      backgroundColor: background,
      indicatorColor: primary.withOpacity(0.3),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme:
        base.floatingActionButtonTheme.copyWith(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}