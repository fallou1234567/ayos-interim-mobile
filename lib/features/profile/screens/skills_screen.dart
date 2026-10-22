import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  static const _storageKey = 'ayos_profile_skills';

  final TextEditingController _skillController = TextEditingController();

  final List<String> _suggestions = [
    'Accueil et réception',
    'Gestion des réservations',
    'Service client',
    'Gestion administrative',
    'Gestion de caisse',
    'Restauration',
    'Service en salle',
    'Gestion des stocks',
    'Microsoft Office',
    'Communication',
    'Travail en équipe',
    'Gestion du temps',
  ];

  final Set<String> _skills = {};
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _skills.addAll(prefs.getStringList(_storageKey) ?? []);
      _loading = false;
    });
  }

  Future<void> _addSkill([String? suggestedSkill]) async {
    final skill = (suggestedSkill ?? _skillController.text).trim();

    if (skill.isEmpty) return;

    if (_skills.any(
      (existing) => existing.toLowerCase() == skill.toLowerCase(),
    )) {
      _skillController.clear();
      return;
    }

    setState(() {
      _skills.add(skill);
      _skillController.clear();
    });

    await _saveSkills(showMessage: false);
  }

  Future<void> _removeSkill(String skill) async {
    setState(() => _skills.remove(skill));
    await _saveSkills(showMessage: false);
  }

  Future<void> _saveSkills({bool showMessage = true}) async {
    setState(() => _saving = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setStringList(_storageKey, _skills.toList()..sort());

      if (!mounted) return;

      if (showMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compétences enregistrées sur cet appareil.'),
            backgroundColor: AppColors.navy,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’enregistrer les compétences.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableSuggestions = _suggestions
        .where(
          (skill) => !_skills.any(
            (existing) => existing.toLowerCase() == skill.toLowerCase(),
          ),
        )
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Mes métiers et compétences',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              children: [
                _introCard(),
                const SizedBox(height: 22),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Mes compétences',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${_skills.length} ajoutée(s)',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _skillsCard(),
                const SizedBox(height: 22),
                const Text(
                  'Ajouter une compétence',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _skillController,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _addSkill(),
                        decoration: InputDecoration(
                          hintText: 'Ex. Gestion de caisse',
                          filled: true,
                          fillColor: AppColors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 49,
                      width: 49,
                      child: ElevatedButton(
                        onPressed: _saving ? null : () => _addSkill(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const Text(
                  'Suggestions',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableSuggestions.map((skill) {
                    return ActionChip(
                      avatar: const Icon(
                        Icons.add,
                        size: 15,
                        color: AppColors.navy,
                      ),
                      label: Text(skill),
                      onPressed: _saving ? null : () => _addSkill(skill),
                      backgroundColor: AppColors.white,
                      side: const BorderSide(color: AppColors.border),
                      labelStyle: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textPrimary,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 49,
                  child: OutlinedButton.icon(
                    onPressed: _saving ? null : () => _saveSkills(),
                    icon: _saving
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_saving ? 'Enregistrement...' : 'Enregistrer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      side: const BorderSide(color: AppColors.navy),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _introCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            color: AppColors.orange,
            size: 26,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Mettez en valeur vos savoir-faire pour mieux '
              'présenter votre profil professionnel.',
              style: TextStyle(color: Colors.white, fontSize: 11, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skillsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: _skills.isEmpty
          ? const Text(
              'Aucune compétence ajoutée. Choisissez une suggestion '
              'ou saisissez une compétence ci-dessous.',
              style: TextStyle(
                fontSize: 11,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills.map((skill) {
                return Chip(
                  label: Text(skill, style: const TextStyle(fontSize: 10)),
                  deleteIcon: const Icon(Icons.close, size: 15),
                  onDeleted: _saving ? null : () => _removeSkill(skill),
                  backgroundColor: AppColors.lightBlue,
                  side: BorderSide.none,
                  deleteIconColor: AppColors.navy,
                );
              }).toList(),
            ),
    );
  }
}
