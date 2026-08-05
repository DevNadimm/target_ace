import 'package:target_ace/features/practice/domain/entities/topic_entity.dart';

class SubjectEntity {
  final String id;
  final String groupId;
  final String name;
  final String? description;
  final String? imageUrl;
  final int displayOrder;
  final int totalQuestions;
  final int practicedCount;
  final List<TopicEntity> topics;

  const SubjectEntity({
    required this.id,
    required this.groupId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.displayOrder,
    this.totalQuestions = 0,
    this.practicedCount = 0,
    this.topics = const [],
  });
}