import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/exceptions/api_exception.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/core/utils/enums/error_type.dart';
import 'package:target_ace/features/subscription/data/models/subscription_model.dart';
import 'package:target_ace/features/subscription/data/repos/subscription_repo.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  SubscriptionBloc() : super(SubscriptionInitial()) {
    on<FetchSubscriptionStatus>(_onFetchSubscriptionStatus);
  }

  Future<void> _onFetchSubscriptionStatus(
    FetchSubscriptionStatus event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final sub = await SubscriptionRepo.fetchMySubscription();
      if (sub == null) {
        emit(SubscriptionError(
          ErrorType.unknown,
          'Could not reach the server. Please check your internet connection and try again.',
        ));
        return;
      }

      // Persist the fresh subscription data
      await AppPreferences.saveSubscription(
        planId: int.tryParse(sub.planId ?? '0') ?? 0,
        planName: sub.planName ?? '',
        startDate: sub.startDate ?? '',
        expiryDate: sub.endDate ?? '',
        status: sub.status,
      );

      emit(SubscriptionLoaded(sub, isManualCheck: event.isManualCheck));
    } on ApiException catch (e) {
      emit(SubscriptionError(e.type, e.message));
    } catch (e) {
      emit(SubscriptionError(
        ErrorType.unknown,
        'An unexpected error occurred. Please try again.',
      ));
    }
  }
}

