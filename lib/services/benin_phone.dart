/// Normalise une saisie béninoise sans conserver sa forme d'origine.
/// Les numéros à 8 chiffres restent acceptés pour les codes USSD historiques.
class BeninPhone {
  static String? normalize(String input, String format) {
    var digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('00229')) digits = digits.substring(5);
    if (digits.startsWith('229')) digits = digits.substring(3);
    if (digits.length == 10 && digits.startsWith('01')) {
      digits = digits.substring(2);
    }
    if (!RegExp(r'^\d{8}$').hasMatch(digits)) return null;
    return switch (format) {
      '8' => digits,
      '10' => '01$digits',
      '229+8' => '229$digits',
      _ => null,
    };
  }
}
