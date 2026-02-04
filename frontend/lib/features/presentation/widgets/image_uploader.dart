import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';

class ImageUploader extends StatefulWidget {
  const ImageUploader({super.key});

  @override
  State<ImageUploader> createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  Uint8List? imageBytes;
  bool isDragging = false;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        imageBytes = result.files.single.bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (_) => setState(() => isDragging = true),
      onDragExited: (_) => setState(() => isDragging = false),
      onDragDone: (details) async {
        final file = details.files.first;
        final bytes = await file.readAsBytes();
        setState(() {
          imageBytes = bytes;
          isDragging = false;
        });
      },
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        dashPattern: const [6, 3],
        color: isDragging ? Colors.deepPurple : Colors.grey,
        child: Container(
          width: 320,
          height: 160,
          padding: const EdgeInsets.all(12),
          alignment: Alignment.center,
          child: imageBytes == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Drag & Drop Image Here",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text("Upload Image"),
                    ),
                  ],
                )
              : Image.memory(
                  imageBytes!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
        ),
      ),
    );
  }
}

