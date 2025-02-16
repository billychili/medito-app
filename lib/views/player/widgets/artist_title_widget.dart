import 'package:Medito/providers/providers.dart';
import 'package:Medito/widgets/widgets.dart';
import 'package:Medito/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ArtistTitleWidget extends ConsumerWidget {
  const ArtistTitleWidget({
    super.key,
    required this.meditationTitle,
    this.artistName,
    this.artistUrlPath,
    this.meditationTitleFontSize = 24,
    this.artistNameFontSize = 16,
    this.artistUrlPathFontSize = 13,
    this.isPlayerScreen = false,
  });
  final String meditationTitle;
  final String? artistName, artistUrlPath;
  final double meditationTitleFontSize;
  final double artistNameFontSize;
  final double artistUrlPathFontSize;
  final bool isPlayerScreen;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(context),
        _subtitle(context, ref),
      ],
    );
  }

  Text _title(BuildContext context) {
    return Text(
      meditationTitle,
      style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
            fontFamily: ClashDisplay,
            color: ColorConstants.walterWhite,
            fontSize: meditationTitleFontSize,
            letterSpacing: 1,
          ),
    );
  }

  Padding _subtitle(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: MarkdownWidget(
        textAlign: WrapAlignment.start,
        body: '${artistName ?? ''} ${artistUrlPath ?? ''}',
        pFontSize: artistNameFontSize,
        aFontSize: artistUrlPathFontSize,
        onTapLink: (text, href, title) {
          var getCurrentLocation = GoRouter.of(context);
          if (isPlayerScreen) {
            ref.read(pageviewNotifierProvider).gotoPreviousPage();
          }
          var location = getCurrentLocation.location;
          if (location.contains(RouteConstants.webviewPath)) {
            context.pop();
          }
          location = getCurrentLocation.location;
          context
              .go(location + RouteConstants.webviewPath, extra: {'url': href});
        },
      ),
    );
  }
}
