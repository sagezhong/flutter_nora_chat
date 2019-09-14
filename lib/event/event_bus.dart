
import 'package:event_bus/event_bus.dart';



EventBus eventBus = new EventBus();

class FriendEvent {
  String message;
  FriendEvent(this.message);
}

class UpdateNoteNameAndText {
  String noteName;
  String noteText;
  UpdateNoteNameAndText({this.noteName,this.noteText});
}

class UpdateConvasationItem {
  String message;
  UpdateConvasationItem({this.message});
}

class ReceiveMessage {
  String message;
  ReceiveMessage({this.message});
}

class UpdateUserInfo {
  String message;
  UpdateUserInfo({this.message});
}

class UpdateTheme {
  String message;
  UpdateTheme({this.message});
}

class UpdateUserSetting {
  String message;
  UpdateUserSetting({this.message});
}

