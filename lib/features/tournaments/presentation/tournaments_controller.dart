import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/tournament_repository.dart';

part 'tournaments_controller.g.dart';

/// State for the Tournaments hub screen.
class TournamentsState {
  final int activeTab; // 0 = My Leagues, 1 = Discover
  final bool isRefreshing;

  const TournamentsState({this.activeTab = 0, this.isRefreshing = false});

  TournamentsState copyWith({int? activeTab, bool? isRefreshing}) {
    return TournamentsState(
      activeTab: activeTab ?? this.activeTab,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

/// Controller managing the Tournaments tab selection and data refreshes.
@riverpod
class TournamentsController extends _$TournamentsController {
  @override
  TournamentsState build() {
    return const TournamentsState(activeTab: 0);
  }

  void setTab(int index) {
    state = state.copyWith(activeTab: index);
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true);
    ref.invalidate(publicTournamentsProvider);
    ref.invalidate(enrolledTournamentsProvider);
    ref.invalidate(userPrivateLeaguesProvider);
    state = state.copyWith(isRefreshing: false);
  }
}
