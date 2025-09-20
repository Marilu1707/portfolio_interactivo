// Conditional import wrapper for popup sounds
import 'sound_stub.dart'
    if (dart.library.html) 'sound_web.dart' as impl;

void playPopupSound({bool success = true}) => impl.playPopupSound(success: success);

