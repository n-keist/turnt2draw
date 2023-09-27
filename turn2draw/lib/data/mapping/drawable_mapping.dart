import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:turn2draw/config/logger.dart';
import 'package:turn2draw/data/model/paint_drawable.dart';

Map<String, dynamic> mapDrawableToJson(PaintDrawable drawable) {
  return {
    'id': drawable.id,
    'color': '#${drawable.color.value.toRadixString(16)}',
    'path': drawable.offsets.map((o) => [o.dx, o.dy]).join(';'),
    'strokeWidth': drawable.strokeWidth,
  };
}

PaintDrawable mapJsonToDrawable(Map<String, dynamic> value) {
  //final value = jsonDecode(json['drawable_value']);
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
          final pathJson = jsonDecode(path) as List<dynamic>;
          logger.d(pathJson.runtimeType);
          logger.d(pathJson);
          return Offset(
            switch (pathJson[0].runtimeType) {
              int => pathJson[0].toDouble(),
              double => pathJson[0],
              _ => throw UnimplementedError('type not implemented ${pathJson[0].runtimeType}'),
            },
            switch (pathJson[1].runtimeType) {
              int => pathJson[1].toDouble(),
              double => pathJson[1],
              _ => throw UnimplementedError('type not implemented ${pathJson[0].runtimeType}'),
            },
          );
        },
      ).toList(growable: false));
}
