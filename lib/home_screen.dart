import 'dart:io';
import 'dart:typed_data';

import 'package:before_after/before_after.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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

  Future<void> downloadImage(BuildContext context) async {
    var perm = await Permission.photos.request();
    String fileName = "${DateTime.now().microsecondsSinceEpoch}";
    if (perm.isGranted) {
      await screenshotController.capture(delay: const Duration(milliseconds: 10)).then((Uint8List? image) async {
        if (image != null) {
          final directory = await getApplicationDocumentsDirectory();
          final imagePath = await File('${directory.path}/image.png').create();
          await imagePath.writeAsBytes(image);
          final result = await ImageGallerySaver.saveImage(image, name: fileName);
          if (!context.mounted) return;
          if(result['isSuccess']){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Download image success!'),
              backgroundColor: Colors.green,
            ));
          }else{
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('An error occurred!'),
              backgroundColor: Colors.red,
            ));
          }
        }
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                await downloadImage(context);
              },
              icon: const Icon(Icons.download, color: Colors.white,))
        ],
        leading: const Icon(Icons.sort_rounded, color: Colors.white),
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'AI Background Remover',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
      body: Center(
        child: removeBg
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BeforeAfter(
                    value: value,
                    after: Image.file(File(imagePath)),
                    before: Screenshot(
                      controller: screenshotController,
                      child: Image.memory(image!),
                    ),
                    onValueChanged: (value) {
                      setState(() => this.value = value);
                    },
                  ),
                ),
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
