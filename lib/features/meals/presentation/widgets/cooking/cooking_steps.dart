List<String> parseCookingSteps(String? instructions) {
  return List<String>.unmodifiable(
    (instructions ?? '')
        .split(RegExp(r'\r\n|\r|\n'))
        .map((step) => step.trim())
        .where((step) => step.isNotEmpty),
  );
}
