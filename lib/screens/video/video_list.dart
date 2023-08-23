import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:videoplayer_miniproject/screens/mini_Screens/search.dart';
import 'package:videoplayer_miniproject/screens/video/video_play.dart';
import 'package:videoplayer_miniproject/functions/db_functions/db_functions.dart';
import '../../Model/video_model/video_model.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart'; // Import HapticFeedback
import '../../model/favorite_model/favorite_model.dart';

class VideoList extends StatefulWidget {
  const VideoList({super.key});

  @override
  State<VideoList> createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  final TextEditingController _reNameController = TextEditingController();

  // Maintain favorite videos list
  Future<void> _pickVideo(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null && result.files.isNotEmpty) {
      final String videoPath = result.files.first.path!;
      final String videoName = videoPath.split('/').last;
      final VideoModel videoModel =
          VideoModel(name: videoName, videoPath: videoPath);

      await Hive.box<VideoModel>('videos').add(videoModel);
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
        padding: const EdgeInsets.only(top: 10, left: 5),
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
                      leading: SizedBox(
                        height: 50,
                        width: 50,
                        child: Image.asset('assets/images/play.png'),
                      ),
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
                              );
                              favoriteVideoBox.add(favoriteVideo);
                            }
                            // Provide haptic feedback
                            //HapticFeedback.heavyImpact();
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
                        style: const TextStyle(fontSize: 20),
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
