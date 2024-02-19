import 'package:flutter/material.dart';
import 'package:gemini_assistant/services/file_picker_service.dart';

class ImageInProcessWidget extends StatelessWidget {
  const ImageInProcessWidget({
    super.key,
    required this.filesInProcess,
    required this.imageLoading,
  });

  final List<FileData>? filesInProcess;
  final bool imageLoading;

  @override
  Widget build(BuildContext context) {
    if (filesInProcess != null && filesInProcess!.isNotEmpty || imageLoading) {
      if (imageLoading) {
        return const Text(
          'Loading images...',
          style: TextStyle(fontSize: 20),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.3,
            ),
            itemCount: filesInProcess!.length > 3 ? 3 : filesInProcess!.length,
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Image.memory(
                      filesInProcess![index].bytes,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (filesInProcess!.length > 3 && index == 2)
                    Container(
                      width: 150,
                      height: 200,
                      color: Colors.black54,
                      child: Center(
                        child: Text(
                          '+${filesInProcess!.length - 3} ',
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }
}
