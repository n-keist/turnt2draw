import 'package:turn2draw/ui/_state/effect.dart';

class DialogEffect extends Effect {
  DialogEffect({this.title = 'Oh no!', this.body = 'Something bad happened. :('});

  final String title;
  final String body;
}
