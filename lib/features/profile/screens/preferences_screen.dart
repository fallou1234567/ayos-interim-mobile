import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  static const _storageKeyTypes = 'ayos_preferences_types';
  static const _storageKeyDays = 'ayos_preferences_days';
  static const _storageKeyHours = 'ayos_preferences_hours';

  final Set<String> _selectedTypes = {};
  final Set<String> _selectedDays = {};
  String _hours = 'Journée';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _selectedTypes.addAll(prefs.getStringList(_storageKeyTypes) ?? []);
      _selectedDays.addAll(prefs.getStringList(_storageKeyDays) ?? []);
      _hours = prefs.getString(_storageKeyHours) ?? 'Journée';
      _loading = false;
    });
  }

  Future<void> _savePreferences() async {
    setState(() => _saving = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setStringList(_storageKeyTypes, _selectedTypes.toList());
      await prefs.setStringList(_storageKeyDays, _selectedDays.toList());
      await prefs.setString(_storageKeyHours, _hours);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Préférences enregistrées sur cet appareil.'),
          backgroundColor: AppColors.navy,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’enregistrer les préférences.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Préférences de missions',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
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
                _sectionTitle('Types de missions'),
                const SizedBox(height: 10),

                _whiteCard(
                  child: RadioGroup<String>(
                    groupValue: _hours,
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() => _hours = value);
                      }
                    },
                    child: Column(
                      children: ['Matin', 'Journée', 'Soir', 'Nuit', 'Flexible']
                          .map((hours) {
                            return RadioListTile<String>(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              activeColor: AppColors.navy,
                              title: Text(
                                hours,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              value: hours,
                            );
                          })
                          .toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 22),
                _sectionTitle('Plage horaire préférée'),
                const SizedBox(height: 10),
                _whiteCard(
                  child: RadioGroup<String>(
                    groupValue: _hours,
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() => _hours = value);
                      }
                    },
                    child: Column(
                      children: ['Matin', 'Journée', 'Soir', 'Nuit', 'Flexible']
                          .map((hours) {
                            return RadioListTile<String>(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              activeColor: AppColors.navy,
                              title: Text(
                                hours,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              value: hours,
                            );
                          })
                          .toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 22),
                _sectionTitle('Plage horaire préférée'),
                const SizedBox(height: 10),

                _whiteCard(
                  child: RadioGroup<String>(
                    groupValue: _hours,
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() => _hours = value);
                      }
                    },
                    child: Column(
                      children: ['Matin', 'Journée', 'Soir', 'Nuit', 'Flexible']
                          .map((hours) {
                            return RadioListTile<String>(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              activeColor: AppColors.navy,
                              title: Text(
                                hours,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              value: hours,
                            );
                          })
                          .toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  height: 49,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _savePreferences,
                    icon: _saving
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_saving ? 'Enregistrement...' : 'Enregistrer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
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
          Icon(Icons.tune, color: AppColors.orange, size: 25),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Personnalisez vos disponibilités et les missions '
              'que vous souhaitez recevoir.',
              style: TextStyle(color: Colors.white, fontSize: 11, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _whiteCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
