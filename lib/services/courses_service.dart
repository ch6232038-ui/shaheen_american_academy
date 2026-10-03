import 'package:supabase_flutter/supabase_flutter.dart';

class CourseService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      final response = await supabase
          .from('courses')
          .select()
          .eq('status', 'Active')
          .order('id', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Course load error: $e');
      return [];
    }
  }
}
