import 'package:flutter/widgets.dart';
import 'package:turn2draw/data/model/paint_drawable.dart';

Map<String, dynamic> mapDrawableToJson(PaintDrawable drawable) {
  return {
    'id': drawable.id,
    'color': '#${drawable.color.value.toRadixString(16)}',
    'path': drawable.offsets.map((o) => '${o.dx}:${o.dy}').join(';'),
    'strokeWidth': drawable.strokeWidth,
  };
}

PaintDrawable mapJsonToDrawable(Map<String, dynamic> value) {
  return PaintDrawable(
    id: value['id'],
    color: Color(
      int.parse(
        value['color'].replaceAll('#', '0x'),
      ),
    ),
    strokeWidth: switch (value['strokeWidth'].runtimeType) {
      int => value['strokeWidth'].toDouble(),
      double => value['strokeWidth'],
      _ => throw StateError('strokeWidth is neither a int or a double'),
    },
    offsets: ((value['path'] ?? '').split(';') as List<dynamic>).map(
      (path) {
        final pathSegments = path.split(':');
        if (pathSegments.length != 2) throw 'incorrect path segment count';
        return Offset(
          switch (pathSegments[0].runtimeType) {
            int => pathSegments[0].toDouble(),
            double => pathSegments[0],
            String => double.tryParse(pathSegments[0]),
            _ => throw UnimplementedError('type not implemented ${pathSegments[0].runtimeType}'),
          },
          switch (pathSegments[1].runtimeType) {
            int => pathSegments[1].toDouble(),
            double => pathSegments[1],
            String => double.tryParse(pathSegments[1]),
            _ => throw UnimplementedError('type not implemented ${pathSegments[0].runtimeType}'),
          },
        );
      },
    ).toList(growable: false),
  );
}
