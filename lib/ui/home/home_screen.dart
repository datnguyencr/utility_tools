import 'dart:ffi';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:win32/win32.dart';

import '/util/util.dart';
import '../../identical_checker/identical_checker.dart';
import '../image_view.dart';

class HomeScreen extends StatefulWidget {
  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const HomeScreen());
  }

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _pathController = TextEditingController(text: r'D:\pics');
  Map<String, List<String>> duplicateGroups = {};
  bool isLoading = false;

  Future<void> search({required String path, required List<String> extensions}) async {
    setState(() {
      isLoading = true;
      duplicateGroups = {};
    });

    final tool = IdenticalChecker();
    await tool.checkFiles(path, extensions);

    setState(() {
      duplicateGroups = tool.duplicateGroups;
      isLoading = false;
    });
  }

  static void openFolder({required String path, required String fileName}) {
    final lpOperation = TEXT('open');
    final lpFile = TEXT('explorer.exe');
    final lpParameters = TEXT('/select,"${p.join(path, fileName)}"');

    final lpDirectory = nullptr;
    const nShowCmd = SW_SHOWNORMAL;
    ShellExecute(
      NULL,
      lpOperation,
      lpFile,
      lpParameters,
      lpDirectory,
      nShowCmd,
    );
  }

  bool isImage(String filePath) {
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].any((item) => filePath.endsWith('.$item'));
  }

  Widget imageAction({Color? color, required String text, void Function()? onPressed}) {
    return InkWell(
        onTap: onPressed,
        child: Container(
            width: 90,
            padding: const EdgeInsets.symmetric(
                vertical: Dimens.spacingMini, horizontal: Dimens.spacingLarge),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            )));
  }

  void onOpenPressed(String filePath) {
    final folder = p.dirname(filePath);
    final fileName = p.basename(filePath);
    openFolder(path: folder, fileName: fileName);
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(duration: const Duration(milliseconds: 2000), content: Text(message)),
    );
  }

  Future<void> onDeletePressed(String filePath) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this file?\n\n$filePath'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();

          setState(() {
            final groupKey = duplicateGroups.keys.firstWhere(
              (key) => duplicateGroups[key]!.contains(filePath),
              orElse: () => '',
            );

            if (groupKey.isNotEmpty) {
              duplicateGroups[groupKey]!.remove(filePath);

              if (duplicateGroups[groupKey]!.isEmpty) {
                duplicateGroups.remove(groupKey);
              }
            }
          });

          showSnackBar('File deleted successfully');
        }
      } catch (e) {
        showSnackBar('Failed to delete: $e');
      }
    }
  }

  Widget itemView(String filePath) {
    return SizedBox(
        width: 270,
        child: Container(
          padding: const EdgeInsets.all(Dimens.spacingNormal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  width: 260,
                  height: 260,
                  child: isImage(filePath)
                      ? ImageView(
                          filePath: filePath,
                          fit: BoxFit.cover,
                        )
                      : const Icon(
                          Icons.insert_drive_file,
                          size: 30,
                        )),
              Text(
                filePath,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              const SizedBox(
                height: Dimens.spacingMini,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  imageAction(
                      color: Colors.red[700],
                      text: 'delete',
                      onPressed: () {
                        onDeletePressed(filePath);
                      }),
                  imageAction(
                      color: Colors.blue[700],
                      text: 'open',
                      onPressed: () {
                        onOpenPressed(filePath);
                      }),
                ],
              )
            ],
          ),
        ));
  }

  Widget groupList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (duplicateGroups.isEmpty) {
      return const Center(child: Text('No duplicates found'));
    }

    return Expanded(
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: duplicateGroups.keys.length,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final groupKey = duplicateGroups.keys.elementAt(index);
            final files = duplicateGroups[groupKey]!;
            return SizedBox(
                height: 360,
                child: ListView(
                    scrollDirection: Axis.horizontal, children: files.map(itemView).toList()));
          },
        ),
      ),
    );
  }

  Widget inputText() {
    return Expanded(
      child: TextField(
        controller: _pathController,
        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          labelText: 'Folder Path',
        ),
      ),
    );
  }

  Widget buttonSearch() {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(2),
    );
    return Material(
      color: Colors.blue[700],
      shape: shape,
      child: InkWell(
          customBorder: shape,
          onTap: () {
            search(
              path: _pathController.text,
              extensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'],
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                vertical: Dimens.spacingSmall, horizontal: Dimens.spacingLarge),
            child: const Text(
              'Search',
              style: TextStyle(color: Colors.white),
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Dimens.spacingMedium,
            horizontal: Dimens.spacingMedium,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(Dimens.spacingNormal),
                child: Row(
                  children: [
                    inputText(),
                    const SizedBox(width: Dimens.spacingNormal),
                    buttonSearch()
                  ],
                ),
              ),
              Container(child: groupList())
            ],
          ),
        ),
      ),
    );
  }
}
