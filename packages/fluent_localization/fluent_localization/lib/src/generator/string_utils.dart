/// Utilities for string manipulation in the generator.
class StringUtils {
  /// Converts a snake_case or dot.notation string to camelCase.
  static String toCamelCase(String text) {
    final expression = RegExp('[._-]([a-z])');
    final camelCase = text.replaceAllMapped(expression, (match) {
      return match.group(1)!.toUpperCase();
    });
    return camelCase[0].toLowerCase() + camelCase.substring(1);
  }
}
