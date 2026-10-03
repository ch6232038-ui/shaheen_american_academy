import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'video_player_page.dart';

class LectureListPage extends StatefulWidget {
  const LectureListPage({super.key});

  @override
  State<LectureListPage> createState() => _LectureListPageState();
}

class _LectureListPageState extends State<LectureListPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> lectures = [];

  bool isLoading = true;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    loadLectures();
  }

  // ============================
  // LOAD LECTURES
  // ============================

  Future<void> loadLectures() async {
    try {
      setState(() {
        isLoading = true;
      });

      final data = await supabase
          .from('lectures')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        lectures = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lectures load nahi ho sakin: $e'),
        ),
      );
    }
  }

  // ============================
  // ADD NEW LECTURE
  // ============================

  Future<void> addLecture() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final notesController = TextEditingController();

    XFile? selectedVideo;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Lecture'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // TITLE
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Lecture Title',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // DESCRIPTION
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // NOTES
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // VIDEO PICKER
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();

                          final video = await picker.pickVideo(
                            source: ImageSource.gallery,
                          );

                          if (video != null) {
                            setDialogState(() {
                              selectedVideo = video;
                            });
                          }
                        },
                        icon: const Icon(Icons.video_library),
                        label: Text(
                          selectedVideo == null
                              ? 'Select Video From Gallery'
                              : 'Video Selected ✓',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                // CANCEL
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),

                // SAVE
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lecture title likhein'),
                        ),
                      );
                      return;
                    }

                    if (selectedVideo == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pehle video select karein'),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);

                    await uploadLecture(
                      selectedVideo!,
                      titleController.text.trim(),
                      descriptionController.text.trim(),
                      notesController.text.trim(),
                    );
                  },
                  child: const Text('Save Lecture'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
    notesController.dispose();
  }

  // ============================
  // UPLOAD VIDEO TO SUPABASE
  // ============================

  Future<void> uploadLecture(
    XFile video,
    String title,
    String description,
    String notes,
  ) async {
    try {
      setState(() {
        isUploading = true;
      });

      final bytes = await video.readAsBytes();

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${video.name}';

      final filePath = 'lectures/$fileName';

      // Upload video to Supabase Storage
      await supabase.storage.from('video').uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'video/mp4',
              upsert: false,
            ),
          );

      // Get public URL
      final videoUrl = supabase.storage.from('video').getPublicUrl(filePath);

      // Save lecture information in database
      await supabase.from('lectures').insert({
        'title': title,
        'description': description,
        'notes': notes,
        'video_url': videoUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      setState(() {
        isUploading = false;
      });

      await loadLectures();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lecture successfully add ho gaya ✓'),
        ),
      );
    } catch (e) {
      setState(() {
        isUploading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload error: $e'),
        ),
      );
    }
  }

  // ============================
  // UI
  // ============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lectures'),
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : lectures.isEmpty
              ? const Center(
                  child: Text(
                    'Abhi koi lecture available nahi hai.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadLectures,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: lectures.length,
                    itemBuilder: (context, index) {
                      final lecture = lectures[index];

                      final title = lecture['title'] ?? 'Untitled Lecture';

                      final description = lecture['description'] ?? '';

                      final notes = lecture['notes'] ?? '';

                      final videoUrl = lecture['video_url'] ?? '';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // TITLE
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // DESCRIPTION
                              if (description.isNotEmpty)
                                Text(
                                  description,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),

                              // NOTES
                              if (notes.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Notes: $notes',
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ],

                              const SizedBox(height: 12),

                              // PLAY BUTTON
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: videoUrl.isEmpty
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  VideoPlayerPage(
                                                videoUrl: videoUrl,
                                                title: title,
                                              ),
                                            ),
                                          );
                                        },
                                  icon: const Icon(
                                    Icons.play_arrow,
                                  ),
                                  label: const Text(
                                    'Play Lecture',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

      // ADD LECTURE BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isUploading ? null : addLecture,
        icon: isUploading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add),
        label: Text(
          isUploading ? 'Uploading...' : 'Add Lecture',
        ),
      ),
    );
  }
}
