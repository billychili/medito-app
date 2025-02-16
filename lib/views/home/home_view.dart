import 'package:Medito/constants/constants.dart';
import 'package:Medito/models/home/home_model.dart';
import 'package:Medito/widgets/shimmers/home_shimmer_widget.dart';
import 'package:Medito/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/filters/filter_widget.dart';
import 'widgets/header/home_header_widget.dart';
import 'widgets/search/search_widget.dart';
import 'widgets/meditation_cards/card_list_widget.dart';
import 'package:Medito/providers/providers.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var homeRes = ref.watch(homeProvider);

    return Scaffold(
      body: homeRes.when(
        skipLoadingOnRefresh: false,
        skipLoadingOnReload: false,
        data: (data) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              height8,
              HomeHeaderWidget(),
              height16,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SearchWidget(),
                      FilterWidget(
                        chips: data.chips,
                      ),
                      _cardListWidget(data),
                      height16,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        error: (err, stack) => MeditoErrorWidget(
          message: err.toString(),
          onTap: () => ref.refresh(homeProvider),
          isLoading: homeRes.isLoading,
        ),
        loading: () => const HomeShimmerWidget(),
      ),
    );
  }

  Column _cardListWidget(HomeModel data) {
    return Column(
      children: data.rows
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CardListWidget(
                row: e,
              ),
            ),
          )
          .toList(),
    );
  }
}
