import 'dart:io';
import 'dart:typed_data';

import 'package:before_after/before_after.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:remove_bg_ai/api.dart';
import 'package:remove_bg_ai/dashed_border.dart';
import 'package:screenshot/screenshot.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var value = 0.5;
  bool loaded = false;
  bool removeBg = false;
  bool isLoading = false;
  Uint8List? image;
  String imagePath = '';
  ScreenshotController screenshotController = ScreenshotController();

  pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (img != null) {
      imagePath = img.path;
      loaded = true;
      setState(() {});
    } else {}
  }

  downloadImage() async {
    var perm = await Permission.storage.request();
    String fileName = "${DateTime.now().microsecondsSinceEpoch}";
    if (perm.isGranted) {
      final directory = Directory("storage/emulated/0/");
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      await screenshotController.captureAndSave(
        directory.path,
        delay: const Duration(microseconds: 100),
        fileName: fileName,
        pixelRatio: 1.0,
      );
      print("Download to ${directory.path}");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Download to ${directory.path}")));
    }else{

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async{
                await downloadImage();
              },
              icon: const Icon(Icons.download))
        ],
        leading: const Icon(Icons.sort_rounded),
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'AI Background Remover',
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: Center(
        child: removeBg
            ? BeforeAfter(
                after: Image.file(File(imagePath)),
                before: Screenshot(
                  controller: screenshotController,
                  child: Image.memory(image!),
                ),
                onValueChanged: (value) {
                  setState(() => this.value = value);
                },
              )
            : loaded
                ? GestureDetector(
                    onTap: () {
                      pickImage();
                    },
                    child: Image.file(
                      File(imagePath),
                    ),
                  )
                : DashedBorder(
                    padding: const EdgeInsets.all(40),
                    color: Colors.grey,
                    radius: 12,
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () {
                          pickImage();
                        },
                        child: const Text(
                          "Pick Image",
                        ),
                      ),
                    ),
                  ),
      ),
      bottomNavigationBar: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: loaded
              ? () async {
                  setState(() {
                    isLoading = true;
                  });
                  image = await Api.removeBg(imagePath);
                  print(image);
                  if (image != null) {
                    removeBg = true;
                    isLoading = false;
                    setState(() {});
                  }
                }
              : null,
          child: isLoading
              ? const Center(
                  child: CupertinoActivityIndicator(),
                )
              : const Text(
                  "Remove Background",
                ),
        ),
      ),
    );
  }
}
