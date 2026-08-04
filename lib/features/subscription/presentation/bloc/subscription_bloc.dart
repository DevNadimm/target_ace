import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/core/utils/enums/error_type.dart';
import 'package:target_ace/features/subscription/domain/entities/subscription_entity.dart';
import 'package:target_ace/features/subscription/domain/usecases/get_subscription_status.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final GetSubscriptionStatus _getSubscriptionStatus;

  SubscriptionBloc({
    required GetSubscriptionStatus getSubscriptionStatus,
  })  : _getSubscriptionStatus = getSubscriptionStatus,
        super(SubscriptionInitial()) {
    on<FetchSubscriptionStatus>(_onFetchSubscriptionStatus);
  }

  Future<void> _onFetchSubscriptionStatus(
    FetchSubscriptionStatus event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    final res = await _getSubscriptionStatus(const NoParams());

    await res.fold(
      (failure) async {
        emit(SubscriptionError(
          ErrorType.unknown,
          failure.message,
        ));
      },
      (sub) async {
        // Persist the fresh subscription data
        await UserLocalDataSource.updateFields({
          'subscription_plan_name': sub.planName ?? '',
          'subscription_status': sub.status,
          'subscription_expiry_date': sub.endDate ?? '',
        });

        emit(SubscriptionLoaded(sub, isManualCheck: event.isManualCheck));
      },
    );
  }
}
