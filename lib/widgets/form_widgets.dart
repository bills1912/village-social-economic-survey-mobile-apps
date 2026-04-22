// lib/widgets/form_widgets.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FormInput
// ─────────────────────────────────────────────────────────────────────────────

class FormInput extends StatelessWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int? maxLines;
  final bool readOnly;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const FormInput({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.keyboardType,
    this.maxLength,
    this.maxLines = 1,
    this.readOnly = false,
    this.onChanged,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          readOnly: readOnly,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            counterText: maxLength != null ? null : '',
            suffixIcon: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomSelectField  — StatefulWidget agar FormField selalu sync dengan value
// ─────────────────────────────────────────────────────────────────────────────

class CustomSelectField extends StatefulWidget {
  final String label;
  final String? value;
  final List<Map<String, String>> options;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final bool isRequired;

  const CustomSelectField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.validator,
    this.isRequired = false,
  });

  @override
  State<CustomSelectField> createState() => _CustomSelectFieldState();
}

class _CustomSelectFieldState extends State<CustomSelectField> {
  final _fieldKey = GlobalKey<FormFieldState<String>>();

  @override
  void didUpdateWidget(CustomSelectField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Saat value berubah dari luar (mis. cascade WilayahPicker reset),
    // sync ke FormField internal agar validator selalu pakai nilai terkini.
    if (oldWidget.value != widget.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_fieldKey.currentState != null) {
          _fieldKey.currentState!.didChange(widget.value);
        }
      });
    }
  }

  String? get _selectedLabel {
    if (widget.value == null) return null;
    return widget.options
        .cast<Map<String, String>?>()
        .firstWhere(
          (o) => o?['value'] == widget.value,
      orElse: () => null,
    )?['label'];
  }

  void _open(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SelectSheet(
        title: widget.label.replaceAll(' *', ''),
        options: widget.options,
        selectedValue: widget.value,
        onSelected: (val) {
          Navigator.pop(context);
          // Sync FormField dulu, lalu notify parent
          _fieldKey.currentState?.didChange(val);
          widget.onChanged(val);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedLabel;

    return FormField<String>(
      key: _fieldKey,
      initialValue: widget.value,
      validator: widget.validator,
      builder: (state) {
        final showError = state.errorText != null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Label ─────────────────────────────────────────────────────
            RichText(
              text: TextSpan(
                text: widget.label.replaceAll(' *', ''),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppTheme.textPrimary,
                ),
                children: [
                  if (widget.isRequired)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppTheme.accentRed),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // ── Trigger field ──────────────────────────────────────────────
            GestureDetector(
              onTap: () => _open(context),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: showError
                        ? AppTheme.accentRed
                        : selected != null
                        ? AppTheme.primaryBlue
                        : Colors.grey[300]!,
                    width: selected != null && !showError ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selected ??
                            'Pilih ${widget.label.replaceAll(' *', '')}',
                        style: TextStyle(
                          fontSize: 13,
                          color: selected != null
                              ? AppTheme.textPrimary
                              : Colors.grey[400],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: selected != null
                            ? AppTheme.primaryBlue
                            : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Error text ─────────────────────────────────────────────────
            if (showError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.accentRed,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SelectSheet  — bottom sheet content
// ─────────────────────────────────────────────────────────────────────────────

class _SelectSheet extends StatefulWidget {
  final String title;
  final List<Map<String, String>> options;
  final String? selectedValue;
  final ValueChanged<String?> onSelected;

  const _SelectSheet({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  State<_SelectSheet> createState() => _SelectSheetState();
}

class _SelectSheetState extends State<_SelectSheet>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scaleAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filtered {
    if (_query.isEmpty) return widget.options;
    final q = _query.toLowerCase();
    return widget.options
        .where((o) => (o['label'] ?? '').toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final mq = MediaQuery.of(context);
    final sheetHeight = mq.size.height * 0.75;

    return ScaleTransition(
      scale: _scaleAnim,
      alignment: Alignment.bottomCenter,
      child: Container(
        height: sheetHeight,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // ── Handle ───────────────────────────────────────────────────
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),

            // ── Title row ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pilih ${widget.title}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 16, color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Search bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchCtrl,
                autofocus: widget.options.length > 6,
                onChanged: (v) => setState(() => _query = v),
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText:
                  'Cari ${widget.title.toLowerCase()}...',
                  hintStyle: TextStyle(
                      fontSize: 13, color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search,
                      size: 18, color: AppTheme.primaryBlue),
                  suffixIcon: _query.isNotEmpty
                      ? GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      setState(() => _query = '');
                    },
                    child: const Icon(Icons.clear,
                        size: 16,
                        color: AppTheme.textSecondary),
                  )
                      : null,
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    BorderSide(color: Colors.grey[200]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    BorderSide(color: Colors.grey[200]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppTheme.primaryBlue, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ── Divider ───────────────────────────────────────────────────
            Divider(height: 1, color: Colors.grey[100]),

            // ── Options list ──────────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off,
                        size: 40, color: Colors.grey[300]),
                    const SizedBox(height: 10),
                    Text(
                      'Tidak ada hasil untuk "$_query"',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[400]),
                    ),
                  ],
                ),
              )
                  : ListView.separated(
                padding: EdgeInsets.only(
                  top: 4,
                  bottom: mq.padding.bottom + 16,
                ),
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey[100]),
                itemBuilder: (_, i) {
                  final opt = filtered[i];
                  final isSelected =
                      opt['value'] == widget.selectedValue;
                  return _OptionTile(
                    label: opt['label'] ?? '',
                    isSelected: isSelected,
                    onTap: () =>
                        widget.onSelected(opt['value']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _OptionTile
// ─────────────────────────────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        color: isSelected
            ? AppTheme.primaryBlue.withOpacity(0.06)
            : Colors.transparent,
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppTheme.primaryBlue
                    : Colors.grey[300]!,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: isSelected
                      ? AppTheme.primaryBlue
                      : AppTheme.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check,
                    size: 13, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FormDropdown  — backward compat, delegates ke CustomSelectField
// ─────────────────────────────────────────────────────────────────────────────

class FormDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<Map<String, String>> options;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;
  final bool isRequired;

  const FormDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.validator,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSelectField(
      label: label,
      value: value,
      options: options,
      onChanged: onChanged,
      validator: validator,
      isRequired: isRequired,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FormRadioGroup
// ─────────────────────────────────────────────────────────────────────────────

class FormRadioGroup extends StatelessWidget {
  final String label;
  final String? value;
  final List<Map<String, String>> options;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;

  const FormRadioGroup({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        FormField<String>(
          initialValue: value,
          validator: validator,
          builder: (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...options.map(
                    (opt) => RadioListTile<String>(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(opt['label']!,
                      style: const TextStyle(fontSize: 13)),
                  value: opt['value']!,
                  groupValue: value,
                  activeColor: AppTheme.primaryBlue,
                  onChanged: (v) {
                    state.didChange(v);
                    onChanged(v);
                  },
                ),
              ),
              if (state.errorText != null)
                Text(state.errorText!,
                    style: const TextStyle(
                        color: Colors.red, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// InfoTile
// ─────────────────────────────────────────────────────────────────────────────

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const InfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color:
              (iconColor ?? AppTheme.primaryBlue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon,
                size: 16,
                color: iconColor ?? AppTheme.primaryBlue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}