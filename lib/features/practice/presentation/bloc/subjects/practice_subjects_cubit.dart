import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/features/practice/domain/entities/subject_entity.dart';
import 'package:target_ace/features/practice/domain/usecases/get_subjects.dart';

part 'practice_subjects_state.dart';

class PracticeSubjectsCubit extends Cubit<PracticeSubjectsState> {
  final GetSubjects _getSubjects;

  PracticeSubjectsCubit({
    required GetSubjects getSubjects,
  })  : _getSubjects = getSubjects,
        super(const PracticeSubjectsInitial());

  Future<void> fetchSubjects(String goalId) async {
    emit(const PracticeSubjectsLoading());
    final res = await _getSubjects(goalId);

    res.fold(
      (failure) => emit(PracticeSubjectsFailure(failure.message)),
      (subjects) => emit(PracticeSubjectsLoaded(subjects)),
    );
  }
}
