import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jugaad_fix/data/sample_data.dart';
import 'package:jugaad_fix/models/jugaad_model.dart';

class SubmitScreen extends StatefulWidget {
  const SubmitScreen({super.key});

  @override
  State<SubmitScreen> createState() => _SubmitScreenState();
}

class _SubmitScreenState extends State<SubmitScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedCategoryKey =
      JugaadCategories.categories.first['key']!;
  bool _isSubmitting = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
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
          'Apna Jugaad Bhejo',
          style: GoogleFonts.balooBhai2(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: primary,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Info banner ──
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Text('💡',
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Tera jugaad submit hone ke baad community review karega. 5 upvotes milte hi verified ho jaayega! ✅',
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Title ──
                _buildLabel('Jugaad ka Title *', textColor),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _titleController,
                  hint: 'Short aur catchy rakho...',
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  primary: primary,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title toh zaroori hai 🙂';
                    }
                    if (value.trim().length < 5) {
                      return 'Thoda aur descriptive likho';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ── Category ──
                _buildLabel('Category *', textColor),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: primary.withOpacity(0.25)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategoryKey,
                      isExpanded: true,
                      dropdownColor: cardColor,
                      style: TextStyle(
                          color: textColor, fontSize: 14),
                      items: JugaadCategories.categories
                          .map((c) => DropdownMenuItem(
                                value: c['key'],
                                child: Text(
                                    '${c['emoji']}  ${c['label']}'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(
                              () => _selectedCategoryKey = value);
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Description ──
                _buildLabel('Full Description *', textColor),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _descriptionController,
                  hint:
                      'Step by step batao... kya chahiye, kaise kaam karta hai. Hinglish bilkul chalega 🙂',
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  primary: primary,
                  maxLines: 6,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Thoda detail mein batao na 🙂';
                    }
                    if (value.trim().length < 30) {
                      return 'Thoda aur likho taaki dusre samjhe';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ── Author name ──
                _buildLabel('Tumhara Naam (optional)', textColor),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _nameController,
                  hint: 'Naam likhoge toh credit milega 😄',
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  primary: primary,
                ),

                const SizedBox(height: 32),

                // ── Submit button ──
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(
                        _isSubmitting
                            ? 'Submit ho raha hai...'
                            : 'Jugaad Publish Karo 🚀',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Note ──
                Center(
                  child: Text(
                    'Sirf genuine jugaads submit karo 🙏\nSpam ya fake submissions delete ho jaate hain.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: textColor.withOpacity(0.4),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color textColor) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: textColor.withOpacity(0.8),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required Color primary,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: textColor, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: textColor.withOpacity(0.35)),
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: primary.withOpacity(0.25)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: primary.withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final user = FirebaseAuth.instance.currentUser;
    final category = JugaadCategories.byKey(_selectedCategoryKey);
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final name = _nameController.text.trim().isEmpty
        ? (user?.displayName ?? null)
        : _nameController.text.trim();

    final jugaad = Jugaad(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      categoryKey: category['key']!,
      categoryEmoji: category['emoji']!,
      categoryLabel: category['label']!,
      shortDescription: description.length > 90
          ? '${description.substring(0, 90)}...'
          : description,
      description: description,
      authorName: name,
      isUserCreated: true,
      createdAt: DateTime.now().toIso8601String(),
      createdByUid: user?.uid,   // ← owner's UID stored here
      upvotes: 0,
      isBookmarked: false,
    );

    if (mounted) {
      Navigator.of(context).pop<Jugaad>(jugaad);
    }
  }
}