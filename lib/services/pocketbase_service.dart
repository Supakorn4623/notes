import 'package:pocketbase/pocketbase.dart';

class PocketBaseService {
  final pb = PocketBase('http://127.0.0.1:8090'); // URL PocketBase

  // superuser credentials
  final String adminEmail = 'admin@ubu.ac.th';
  final String adminPassword = '123456789a';

  PocketBaseService() {
    _loginSuperuser();
  }

  // login superuser
  Future<void> _loginSuperuser() async {
    try {
      await pb.admins.authWithPassword(adminEmail, adminPassword);
      print('Superuser logged in successfully');
    } catch (e) {
      print('Superuser login failed: $e');
    }
  }

  // ดึงโน้ตทั้งหมด
  Future<List<RecordModel>> getNotes() async {
    await _loginSuperuser();
    return await pb.collection('notes').getFullList();
  }

  // สร้างโน้ตใหม่
  Future<void> createNote(Map<String, dynamic> data) async {
    await _loginSuperuser();
    await pb.collection('notes').create(body: data);
  }

  // อัปเดตโน้ต
  Future<void> updateNote(String id, Map<String, dynamic> data) async {
    await _loginSuperuser();
    await pb.collection('notes').update(id, body: data);
  }

  // ลบโน้ต
  Future<void> deleteNote(String id) async {
    await _loginSuperuser();
    await pb.collection('notes').delete(id);
  }
}
