import 'package:flutter/material.dart';
import '../../data/models/campaign_model.dart';

class VideoGridSelector extends StatelessWidget {
  final List<SocialVideo> videos;
  final String? selectedUrl;
  final Function(String) onVideoSelect;

  const VideoGridSelector({super.key, required this.videos, required this.selectedUrl, required this.onVideoSelect});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.7,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final v = videos[index];
        final isSel = selectedUrl == v.videoUrl;
        return GestureDetector(
          onTap: () => onVideoSelect(v.videoUrl),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(v.coverUrl, fit: BoxFit.cover),
                if (isSel) Container(color: Colors.black45, child: const Icon(Icons.check_circle, color: Colors.white)),
              ],
            ),
          ),
        );
      },
    );
  }
}