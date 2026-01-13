class Validator {
  bool validateDirective(
      Map<String, dynamic> config, String value, List<String> errors) {
    final val = config['validation'];
    if (val == null) return true;
    if (val['type'] == 'string') {
      if (val['pattern'] != null) {
        final pattern = val['pattern'] as String;
        if (!RegExp(pattern).hasMatch(value)) {
          errors.add(
              'Invalid value for ${config['name']}: $value (${val['description']})');
          return false;
        }
      }
    } else if (val['type'] == 'integer') {
      final intVal = int.tryParse(value);
      if (intVal == null ||
          intVal < val['minimum'] ||
          intVal > val['maximum']) {
        errors.add(
            'Invalid integer for ${config['name']}: $value (${val['description']})');
        return false;
      }
    }
    return true;
  }

  bool validateAttribute(
      Map<String, dynamic> val, String value, List<String> errors) {
    if (val['type'] == 'string') {
      if (val['pattern'] != null) {
        final pattern = val['pattern'] as String;
        if (!RegExp(pattern).hasMatch(value)) {
          errors.add('Invalid attribute value: $value (${val['description']})');
          return false;
        }
      }
    } else if (val['type'] == 'integer') {
      final intVal = int.tryParse(value);
      if (intVal == null ||
          intVal < val['minimum'] ||
          intVal > val['maximum']) {
        errors.add('Invalid attribute integer: $value (${val['description']})');
        return false;
      }
    }
    return true;
  }

  bool validateChord(String chordName, RegExp pattern, List<String> errors) {
    if (!pattern.hasMatch(chordName)) {
      errors.add('Invalid chord: $chordName');
      return false;
    }
    return true;
  }
}
