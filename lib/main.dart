import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:faker/faker.dart'; // สำหรับสร้างโน้ตจำลอง
import 'services/pocketbase_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final PocketBaseService pbService = PocketBaseService();
  List<RecordModel> notes = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  // ดึงโน้ตทั้งหมด
  void fetchNotes() async {
    final fetched = await pbService.getNotes();
    setState(() {
      notes = fetched;
    });
  }

  // สร้างโน้ตจากผู้ใช้
  void createNote() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอก title และ content')),
      );
      return;
    }

    final data = {'title': title, 'content': content};
    await pbService.createNote(data);

    titleController.clear();
    contentController.clear();
    fetchNotes();
  }

  // สร้างโน้ตจำลองด้วย Faker **********
  void createFakeNote() async {
    final faker = Faker();
    final data = {
      'title': faker.lorem.sentence(),
      'content': faker.lorem.sentences(3).join(' '),
    };

    await pbService.createNote(data);
    fetchNotes();
  }

  // ลบโน้ต
  void deleteNote(String id) async {
    await pbService.deleteNote(id);
    fetchNotes();
  }

  // แก้ไขโน้ต
  void editNoteDialog(RecordModel note) {
    final editTitleController = TextEditingController(
      text: note.getStringValue('title'),
    );
    final editContentController = TextEditingController(
      text: note.getStringValue('content'),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('แก้ไขโน้ต'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editTitleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: editContentController,
              decoration: const InputDecoration(labelText: 'Content'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newTitle = editTitleController.text.trim();
              final newContent = editContentController.text.trim();
              if (newTitle.isEmpty || newContent.isEmpty) return;

              ///************* */
              await pbService.updateNote(note.id, {
                'title': newTitle,
                'content': newContent,
              });
              Navigator.pop(context);
              fetchNotes();
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Content'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: createNote,
                    child: const Text('สร้างโน้ต'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: createFakeNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('สร้างโน้ตจำลอง'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              //*********** */
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return ListTile(
                    title: Text(note.getStringValue('title') ?? ''),
                    subtitle: Text(note.getStringValue('content') ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => editNoteDialog(note),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteNote(note.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
