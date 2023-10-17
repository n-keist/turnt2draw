import 'package:firebase_core/firebase_core.dart';
import 'package:turn2draw/data/service/firebase_service.dart';
import 'package:turn2draw/firebase_options.dart';

class FirebaseServiceImpl extends FirebaseService {
  @override
  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
