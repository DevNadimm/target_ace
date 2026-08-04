class TopicEntity {
  final String id;
  final String subjectId;
  final String name;
  final String? description;
  final int displayOrder;

  const TopicEntity({
    required this.id,
    required this.subjectId,
    required this.name,
    this.description,
    required this.displayOrder,
  });
}
