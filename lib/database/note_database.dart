import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:loginlogoutbasic/models/note.dart';
import 'package:path_provider/path_provider.dart';

class NoteDatabase extends ChangeNotifier{
  static late Isar isar;

  // Initialize Database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [NoteSchema],
      directory: dir.path,
    );
  }

  // list of notes
  final List<Note> currentNotes = [];

  // Create => create note and save to the database
  Future<void> addNote(String textFromUser) async {
    // create new note object
    final newNote = Note()..text = textFromUser;
    
    // save to database
    await isar.writeTxn(() => isar.notes.put(newNote));

    // re-read from database
    await fetchNotes();
  }

  // Read => reads note from database
  Future<void> fetchNotes() async {
    List<Note> fetchedNotes = await isar.notes.where().findAll();
    currentNotes.clear();
    currentNotes.addAll(fetchedNotes);
    notifyListeners();
  }

  // Update => updates note in database
  Future<void> updateNotes(int id, String newText) async {
    final existingNote = await isar.notes.get(id);
    if(existingNote != null){
      existingNote.text = newText;
      await isar.writeTxn(() => isar.notes.put(existingNote));
      await fetchNotes();
    }
  }

  // Delete => deletes note
  Future<void> deleteNote(int id) async {
    await isar.writeTxn(() => isar.notes.delete(id));

    await fetchNotes();
  }
}