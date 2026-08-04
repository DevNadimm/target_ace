class SubjectEntity {
  final String id;
  final String goalId;
  final String? groupId;
  final String name;
  final String? description;
  final String? imageUrl;
  final int displayOrder;

  const SubjectEntity({
    required this.id,
    required this.goalId,
    this.groupId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.displayOrder,
  });
}
