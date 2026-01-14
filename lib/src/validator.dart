/// Validates ICLF directives, attributes, and chords against specification rules.
///
/// Used internally by [IclfParser] to validate parsed elements against
/// the rules defined in the directives.json configuration.
class Validator {
  /// Validates a directive value against its configuration rules.
  ///
  /// The [config] contains the directive specification from directives.json,
  /// including validation rules (type, pattern, min/max for integers).
  /// The [value] is the directive value to validate.
  /// Any validation errors are added to [errors].
  ///
  /// Returns true if valid, false otherwise.
  bool validateDirective(
      Map<String, dynamic> config, String value, List<String> errors) {
    final valDynamic = config['validation'];
    if (valDynamic == null) return true;
    final val = valDynamic as Map<String, dynamic>;
    final type = val['type'] as String?;
    if (type == 'string') {
      final pattern = val['pattern'] as String?;
      if (pattern != null) {
        if (!RegExp(pattern).hasMatch(value)) {
          final description = val['description'] as String? ?? '';
          errors.add(
              'Invalid value for ${config['name']}: $value ($description)');
          return false;
        }
      }
    } else if (type == 'integer') {
      final intVal = int.tryParse(value);
      final minimum = (val['minimum'] as num).toInt();
      final maximum = (val['maximum'] as num).toInt();
      final description = val['description'] as String? ?? '';
      if (intVal == null || intVal < minimum || intVal > maximum) {
        errors.add(
            'Invalid integer for ${config['name']}: $value ($description)');
        return false;
      }
    }
    return true;
  }

  /// Validates a chord attribute value against its configuration rules.
  ///
  /// The [val] contains the attribute validation rules (type, pattern, min/max).
  /// The [value] is the attribute value to validate.
  /// Any validation errors are added to [errors].
  ///
  /// Returns true if valid, false otherwise.
  bool validateAttribute(
      Map<String, dynamic> val, String value, List<String> errors) {
    final type = val['type'] as String?;
    final description = val['description'] as String? ?? '';
    if (type == 'string') {
      final pattern = val['pattern'] as String?;
      if (pattern != null) {
        if (!RegExp(pattern).hasMatch(value)) {
          errors.add('Invalid attribute value: $value ($description)');
          return false;
        }
      }
    } else if (type == 'integer') {
      final intVal = int.tryParse(value);
      final minimum = (val['minimum'] as num).toInt();
      final maximum = (val['maximum'] as num).toInt();
      if (intVal == null || intVal < minimum || intVal > maximum) {
        errors.add('Invalid attribute integer: $value ($description)');
        return false;
      }
    }
    return true;
  }

  /// Validates a chord name against the chord pattern.
  ///
  /// The [chordName] is validated against [pattern] (e.g., matches
  /// standard chord notation like "Am", "G7", "Cmaj7").
  /// Any validation errors are added to [errors].
  ///
  /// Returns true if valid, false otherwise.
  bool validateChord(String chordName, RegExp pattern, List<String> errors) {
    if (!pattern.hasMatch(chordName)) {
      errors.add('Invalid chord: $chordName');
      return false;
    }
    return true;
  }
}
