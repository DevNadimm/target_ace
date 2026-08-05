import 'package:flutter/material.dart' hide BackButton;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/components/custom_icon_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/shared/widgets/empty_state_widget.dart';
import 'package:target_ace/core/shared/widgets/error_state_widget.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/shared/widgets/app_confirmation_dialog.dart';
import 'package:target_ace/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:target_ace/features/notification/presentation/pages/notification_detail_page.dart';
import 'package:target_ace/features/notification/presentation/widgets/notification_card.dart';
import 'package:target_ace/features/notification/presentation/widgets/notification_options_bottom_sheet.dart';

class NotificationPage extends StatefulWidget {
  static Route route() => MaterialPageRoute(builder: (_) => const NotificationPage());

  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchNotifications();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll <= 200) {
      context.read<NotificationBloc>().add(FetchMoreNotificationsEvent());
    }
  }

  void _fetchNotifications({bool isRefresh = false}) {
    context.read<NotificationBloc>().add(FetchNotificationsEvent(isRefresh: isRefresh));
  }

  void _showDeleteAllConfirmation() {
    AppConfirmationDialog.show(
      context,
      title: 'Clear All Notifications',
      message: 'Are you sure you want to delete all notifications? This action cannot be undone.',
      confirmText: 'Clear All',
      cancelText: 'Cancel',
      isDestructive: true,
      onConfirm: () {
        context.read<NotificationBloc>().add(DeleteAllEvent());
      },
    );
  }

  void _showOptionsSheet() {
    NotificationOptionsBottomSheet.show(
      context,
      onDeleteAll: () {
        _showDeleteAllConfirmation();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: const BackButton(),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CustomIconButton(
              backgroundColor: AppColors.card,
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedMoreVertical,
                color: AppColors.textPrimary,
              ),
              tooltip: 'Options',
              onTap: _showOptionsSheet,
            ),
          ),
        ],
      ),
      body: GradientBackground(
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: Loader());
            }

            if (state is NotificationError) {
              return ErrorStateWidget();
            }

            if (state is NotificationLoaded) {
              final list = state.notifications;
              if (list.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () async {
                    _fetchNotifications(isRefresh: true);
                  },
                  color: AppColors.primary,
                  backgroundColor: AppColors.card,
                  child: const CustomScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: EmptyStateWidget(),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  _fetchNotifications(isRefresh: true);
                },
                color: AppColors.primary,
                backgroundColor: AppColors.card,
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                  itemCount: list.length + (state.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == list.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Loader(
                          isShowContainer: false,
                        ),
                      );
                    }

                    final item = list[index];

                    return NotificationCard(
                      item: item,
                      onTap: () {
                        if (!item.isRead) {
                          context.read<NotificationBloc>().add(
                            MarkReadEvent(item.id),
                          );
                        }
                        Navigator.push(
                          context,
                          NotificationDetailPage.route(item),
                        );
                      },
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}