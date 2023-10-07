import 'package:turn2draw/ui/_state/effect.dart';

class DialogEffect extends Effect {
  DialogEffect(
      {this.title = 'Oh no!',
      this.body = 'Something bad happened. :(',
      this.dismissable = true,
      this.callbackText = 'RETRY'});

  final String title;
  final String body;

  final bool dismissable;
  final String callbackText;
}
