import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'empty_content.dart';

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class ListItemsBuilder<T> extends StatelessWidget {
  const ListItemsBuilder({
    Key? key,
    required this.data,
    required this.itemBuilder,
    required this.direction,
    // direction,
  }) : super(key: key);
  final AsyncValue<List<T>> data;
  final ItemWidgetBuilder<T> itemBuilder;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    print(direction);
    return data.when(
        data: (items) =>
            items.isNotEmpty ? _buildList(items) : const EmptyContent(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) {
          print(_);
          return const EmptyContent(
            title: 'Something went wrong',
            message: 'Can\'t load items right now',
          );
        });
  }

  Widget _buildList(List<T> items) {
    return ListView.separated(
      // reverse: direction == Axis.horizontal,
      scrollDirection: direction,
      itemCount: items.length + 2,
      separatorBuilder: (context, index) => const Divider(height: 0.5),
      itemBuilder: (context, index) {
        if (index == 0 || index == items.length + 1) {
          return Container(); // zero height: not visible
        }
        return itemBuilder(context, items[index - 1]);
      },
    );
  }
}
