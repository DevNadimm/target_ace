import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/features/practice/domain/entities/topic_entity.dart';
import 'package:target_ace/features/practice/domain/repository/practice_repository.dart';

part 'practice_topics_state.dart';

class PracticeTopicsCubit extends Cubit<PracticeTopicsState> {
  final PracticeRepository _repository;

  PracticeTopicsCubit({required PracticeRepository repository})
      : _repository = repository,
        super(PracticeTopicsInitial());

  Future<void> fetchTopics(String subjectId) async {
    emit(PracticeTopicsLoading());
    final result = await _repository.getTopics(subjectId);
    result.fold(
      (failure) => emit(PracticeTopicsError(failure.message)),
      (topics) => emit(PracticeTopicsLoaded(topics)),
    );
  }
}
