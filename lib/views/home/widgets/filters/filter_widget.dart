import 'package:Medito/constants/constants.dart';
import 'package:Medito/models/models.dart';
import 'package:Medito/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FilterWidget extends StatelessWidget {
  const FilterWidget({super.key, required this.chips});
  final List<List<HomeChipsItemsModel>> chips;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: chips.map((e) => _filterListView(e)).toList(),
        ),
      ),
    );
  }

  Padding _filterListView(List<HomeChipsItemsModel> items) {
    var boxDecoration = BoxDecoration(
      color: ColorConstants.onyx,
      borderRadius: BorderRadius.circular(12),
    );

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: SizedBox(
        height: 45,
        child: ListView.builder(
          itemCount: items.length,
          scrollDirection: Axis.horizontal,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            var element = items[index];

            return InkWell(
              onTap: () => handleChipPress(context, element),
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  child: Container(
                    decoration: boxDecoration,
                    padding: EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: 10,
                      top: 6,
                    ),
                    child: Text(
                      element.type,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void handleChipPress(
    BuildContext context,
    HomeChipsItemsModel element,
  ) {
    var location = GoRouter.of(context).location;
    if (element.type == TypeConstants.LINK) {
      context.push(
        location + RouteConstants.webviewPath,
        extra: {'url': element.path},
      );
    }
    context.push(getPathFromString(
      element.type,
      [element.id.toString()],
    ));
  }
}
