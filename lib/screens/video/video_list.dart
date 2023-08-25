import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:videoplayer_miniproject/screens/mini_Screens/search.dart';
import 'package:videoplayer_miniproject/screens/video/video_play.dart';
import 'package:videoplayer_miniproject/functions/db_functions/db_functions.dart';
import '../../Model/video_model/video_model.dart';
import 'package:lottie/lottie.dart';
import '../../model/favorite_model/favorite_model.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as video_thumbnail;
import 'package:path/path.dart';

class VideoList extends StatefulWidget {
  const VideoList({super.key});
  @override
  State<VideoList> createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  final TextEditingController _reNameController = TextEditingController();

  // filepicker
  // Future<void> _pickVideo(BuildContext context) async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.video,
  //     allowMultiple: true,
  //   );

  //   if (result != null && result.files.isNotEmpty) {
  //     final videoBox = Hive.box<VideoModel>('videos');
  //     final videosToAdd = result.files.map((file) {
  //       final String videoPath = file.path!;
  //       final String videoName = videoPath.split('/').last;
  //       return VideoModel(name: videoName, videoPath: videoPath);
  //     }).toList();

  //     await videoBox.addAll(videosToAdd);
  //   }
  // }

  Future<void> _pickVideo(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final videoBox = Hive.box<VideoModel>('videos');
      final videosToAdd = await Future.wait(result.files.map((file) async {
        final String videoPath = file.path!;
        final String videoName = videoPath.split('/').last;

        final Directory documentsDir = await getApplicationDocumentsDirectory();
        final String thumbnailPath =
            "${documentsDir.path}/thumbnails/${videoName}.jpg";

        await Directory(dirname(thumbnailPath)).create(recursive: true);

        await video_thumbnail.VideoThumbnail.thumbnailFile(
          video: videoPath,
          thumbnailPath: thumbnailPath,
          imageFormat: video_thumbnail.ImageFormat.JPEG,
          quality: 50,
        );

        return VideoModel(
          name: videoName,
          videoPath: videoPath,
          thumbnailPath: thumbnailPath,
        );
      }));

      await videoBox.addAll(videosToAdd);
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoBox = Hive.box<VideoModel>('videos');
    final favoriteVideoBox = Hive.box<FavoriteVideoModel>('Favorite');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VideoSearchScreen(),
                    ));
              },
              icon: Icon(
                Icons.search_outlined,
                color: Colors.orange.shade700,
                size: 30,
              )),
          const SizedBox(
            width: 10,
          ),
        ],
        title: const Text('Video'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 9),
        child: ValueListenableBuilder(
          valueListenable: videoBox.listenable(),
          builder: (context, Box<VideoModel> box, _) {
            final videos = box.values.toList();
            //lottie based on condition
            if (videos.isEmpty) {
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset('assets/images/data.json',
                      fit: BoxFit.cover, height: 300),
                  const Text(
                    'Video is Empty',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic),
                  )
                ],
              ));
            } else {
              return ListView.separated(
                itemCount: videos.length,
                separatorBuilder: (context, index) {
                  return const Divider(
                    thickness: 1,
                  );
                },
                itemBuilder: (context, index) {
                  final video = videos[index];
                  return Slidable(
                    endActionPane:
                        ActionPane(motion: const DrawerMotion(), children: [
                      SlidableAction(
                        spacing: 5,
                        onPressed: (context) {
                          //to show current name
                          _reNameController.text = video.name;
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Colors.black,
                                title: Text(
                                  'Enter new name for ${video.name}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                content: TextFormField(
                                  style: const TextStyle(color: Colors.black),
                                  controller: _reNameController,
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.orange, width: 3)),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.orange, width: 3)),
                                    hintText: 'New Video Name',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.orange),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      // update code here
                                      final updatedName =
                                          _reNameController.text;
                                      video.name = updatedName;
                                      await videoBox.putAt(index, video);

                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Rename',
                                      style: TextStyle(color: Colors.orange),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: Icons.edit,
                        backgroundColor: Colors.blue,
                        label: 'Edit',
                      ),
                      SlidableAction(
                        spacing: 5,
                        onPressed: (context) {
                          //delete
                          deleteFromDB(context, index);
                        },
                        icon: Icons.delete,
                        backgroundColor: Colors.red,
                        label: 'Delete',
                      ),
                    ]),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10.0),
                      leading: SizedBox(
                          height: double.infinity,
                          width: 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(
                                video.thumbnailPath!,
                              ),
                              fit: BoxFit.cover,
                            ),
                          )),
                      //Favorite icon
                      trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            final isFavorite = favoriteVideoBox.values.any(
                              (favoriteVideo) =>
                                  favoriteVideo.favvideoPath == video.videoPath,
                            );
                            if (isFavorite) {
                              final favoriteVideo =
                                  favoriteVideoBox.values.firstWhere(
                                (favoriteVideo) =>
                                    favoriteVideo.favvideoPath ==
                                    video.videoPath,
                              );
                              favoriteVideoBox.delete(favoriteVideo.key);
                            } else {
                              final favoriteVideo = FavoriteVideoModel(
                                  favname: video.name,
                                  favvideoPath: video.videoPath,
                                  favThumbnailPath: video.thumbnailPath);
                              favoriteVideoBox.add(favoriteVideo);
                            }
                            // Provide haptic feedback
                            HapticFeedback.mediumImpact();
                          });
                        },
                        icon: Icon(
                          favoriteVideoBox.values.any(
                            (favoriteVideo) =>
                                favoriteVideo.favvideoPath == video.videoPath,
                          )
                              ? Icons.favorite
                              : Icons.favorite_border_outlined,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                      title: Text(
                        video.name,
                        style: const TextStyle(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2, // Show only one line
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerWidget(video),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      // to add videos
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickVideo(context),
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}
