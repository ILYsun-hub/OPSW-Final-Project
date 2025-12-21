class Medicine {
  final String name;
  final String emoji;
  final List<String> times;
  final String description; // 효능 추가

  const Medicine({
    required this.name,
    required this.emoji,
    required this.times,
    this.description = '처방된 약입니다.',
  });
}
