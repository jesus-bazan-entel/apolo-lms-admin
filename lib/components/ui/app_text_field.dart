import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lms_admin/configs/design_tokens.dart';

/// Campo de texto profesional con soporte para:
/// - Icono de prefijo/sufijo
/// - Contador de caracteres
/// - Texto de ayuda
/// - Validación visual
/// - Estados de carga
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.suffix,
    this.prefix,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showCounter = false,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.isRequired = false,
    this.isLoading = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? suffix;
  final Widget? prefix;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final bool showCounter;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final bool isRequired;
  final bool isLoading;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.isRequired)
                Text(
                  ' *',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          DesignTokens.vSpaceSm,
        ],

        // Text Field
        TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            decoration: InputDecoration(
              hintText: widget.hint,
              errorText: widget.errorText,
              prefixIcon: widget.prefix ??
                  (widget.prefixIcon != null
                      ? Icon(widget.prefixIcon, size: DesignTokens.iconSm)
                      : null),
              suffixIcon: _buildSuffix(),
              counterText: widget.showCounter ? null : '',
              filled: true,
            ),
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            obscureText: _obscureText,
            enabled: widget.enabled,
            readOnly: widget.readOnly || widget.isLoading,
            autofocus: widget.autofocus,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            inputFormatters: widget.inputFormatters,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            onTap: widget.onTap,
            textCapitalization: widget.textCapitalization,
        ),

        // Helper text
        if (widget.helperText != null && widget.errorText == null) ...[
          DesignTokens.vSpaceXs,
          Text(
            widget.helperText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffix() {
    if (widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(DesignTokens.spaceMd),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: DesignTokens.iconSm,
        ),
        onPressed: () => setState(() => _obscureText = !_obscureText),
      );
    }

    if (widget.suffix != null) return widget.suffix;

    if (widget.suffixIcon != null) {
      return Icon(widget.suffixIcon, size: DesignTokens.iconSm);
    }

    return null;
  }
}

/// Campo de búsqueda profesional
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    this.controller,
    this.hint = 'Buscar...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String hint;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final bool enabled;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_updateHasText);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_updateHasText);
    }
    super.dispose();
  }

  void _updateHasText() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _clear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search, size: DesignTokens.iconSm),
        suffixIcon: _hasText
            ? IconButton(
                icon: const Icon(Icons.close, size: DesignTokens.iconSm),
                onPressed: _clear,
              )
            : null,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceLg,
          vertical: DesignTokens.spaceMd,
        ),
      ),
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      textInputAction: TextInputAction.search,
    );
  }
}

/// Campo de selección con dropdown estilizado
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.enabled = true,
    this.isRequired = false,
    this.validator,
  });

  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final T? value;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final bool enabled;
  final bool isRequired;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          DesignTokens.vSpaceSm,
        ],

        // Dropdown
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: DesignTokens.iconSm)
                : null,
            filled: true,
          ),
          validator: validator,
          isExpanded: true,
        ),

        // Helper text
        if (helperText != null && errorText == null) ...[
          DesignTokens.vSpaceXs,
          Text(
            helperText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }
}

/// Campo de fecha con picker
class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.onChanged,
    this.value,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.isRequired = false,
  });

  final void Function(DateTime?) onChanged;
  final DateTime? value;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          DesignTokens.vSpaceSm,
        ],

        // Date picker button
        InkWell(
          onTap: enabled ? () => _showDatePicker(context) : null,
          borderRadius: DesignTokens.borderRadiusSm,
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: hint ?? 'Seleccionar fecha',
              errorText: errorText,
              prefixIcon: const Icon(
                Icons.calendar_today_outlined,
                size: DesignTokens.iconSm,
              ),
              suffixIcon: value != null
                  ? IconButton(
                      icon: const Icon(Icons.close, size: DesignTokens.iconSm),
                      onPressed: () => onChanged(null),
                    )
                  : null,
              filled: true,
            ),
            child: Text(
              value != null ? _formatDate(value!) : (hint ?? 'Seleccionar fecha'),
              style: value != null
                  ? theme.textTheme.bodyLarge
                  : theme.textTheme.bodyLarge?.copyWith(
                      color: theme.hintColor,
                    ),
            ),
          ),
        ),

        // Helper text
        if (helperText != null && errorText == null) ...[
          DesignTokens.vSpaceXs,
          Text(
            helperText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
    );
    if (result != null) {
      onChanged(result);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
