import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static final Future<SharedPreferences> _prefs =
      SharedPreferences.getInstance();

  static final StreamController<NoteEvent> _noteEventController =
      StreamController.broadcast();

  static Stream<NoteEvent> get noteEventStream => _noteEventController.stream;

  static Future<bool> setString(String key, String value) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(key);
  }

  static Future<bool> remove(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.remove(key);
  }

  static Future<List> getNoteList() async {
    String? jsonString = await getString('note');
    List<dynamic> noteList = [];
    if (jsonString != null) {
      noteList = jsonDecode(jsonString);
    }
    return noteList;
  }

  static Future<bool> addNote(Map<String, dynamic> noteMap) async {
    List noteList = await getNoteList();
    noteList.add(noteMap);
    String updatedJsonString = json.encode(noteList);
    bool result = await setString('note', updatedJsonString);
    if (result) {
      _noteEventController.add(NoteEvent.added);
    }
    return result;
  }

  static Future<bool> updateNote(
      int index, Map<String, dynamic> updatedNoteMap) async {
    List noteList = await getNoteList();
    if (index >= noteList.length || index < 0) {
      return false;
    }
    noteList[index] = updatedNoteMap;
    String updatedJsonString = json.encode(noteList);
    bool result = await setString('note', updatedJsonString);
    if (result) {
      _noteEventController.add(NoteEvent.updated);
    }
    return result;
  }

  static Future<bool> deleteNote(int index) async {
    List noteList = await getNoteList();
    if (index < 0 || index >= noteList.length) {
      return false;
    }
    noteList.removeAt(index);
    String updatedJsonString = json.encode(noteList);
    bool result = await setString('note', updatedJsonString);
    if (result) {
      _noteEventController.add(NoteEvent.deleted);
    }
    return result;
  }
}

enum NoteEvent { added, updated, deleted }

// final List<dynamic> tt = [
//   {
//     "title": "1222222",
//     "content": "# 青海长云暗雪山👀️\n\n[123](http://baidu.com)\n\n123123\n"
//   },
//   {"title": "123", "content": "# this"}
// ];
