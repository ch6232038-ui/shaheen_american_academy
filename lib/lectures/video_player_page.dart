import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoPlayerPage({
    super.key,
    required this.videoUrl,
    this.title = 'Lecture',
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController controller;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    )..initialize().then((_) {
        setState(() {
          isLoading = false;
        });
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          // VIDEO
          AspectRatio(
            aspectRatio: controller.value.isInitialized
                ? controller.value.aspectRatio
                : 16 / 9,
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : VideoPlayer(controller),
          ),

          const SizedBox(height: 20),

          // PLAY / PAUSE
          if (!isLoading)
            IconButton(
              iconSize: 55,
              onPressed: () {
                setState(() {
                  if (controller.value.isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                });
              },
              icon: Icon(
                controller.value.isPlaying
                    ? Icons.pause_circle
                    : Icons.play_circle,
              ),
            ),

          const SizedBox(height: 10),

          // PROGRESS BAR
          if (!isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: VideoProgressIndicator(
                controller,
                allowScrubbing: true,
                padding: const EdgeInsets.all(8),
              ),
            ),
        ],
      ),
    );
  }
}
