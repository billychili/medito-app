import 'package:Medito/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({
    super.key,
    this.streakCount,
  });
  final String? streakCount;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(AssetConstants.icLogo),
          Row(
            children: [
              _streakWidget(context, streakCount: streakCount),
              width16,
              _downloadWidget(context),
              width16,
              SvgPicture.asset(AssetConstants.icMenu),
            ],
          ),
        ],
      ),
    );
  }

  InkWell _downloadWidget(BuildContext context) {
    return InkWell(
      onTap: () => context.push(RouteConstants.collectionPath),
      child: SvgPicture.asset(
        AssetConstants.icDownload,
      ),
    );
  }

  Container _streakWidget(BuildContext context, {String? streakCount}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          width: 1,
          color: ColorConstants.walterWhite,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      child: Row(
        children: [
          SvgPicture.asset(AssetConstants.icStreak),
          width4,
          Text(
            streakCount ?? '0',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
