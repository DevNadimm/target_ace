class TopicEntity {
  final String id;
  final String subjectId;
  final String name;
  final String? description;
  final String? imageUrl;
  final int displayOrder;
  final int totalQuestions;
  final int practicedCount;

  const TopicEntity({
    required this.id,
    required this.subjectId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.displayOrder,
    this.totalQuestions = 0,
    this.practicedCount = 0,
  });
}