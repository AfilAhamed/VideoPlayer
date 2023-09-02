import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:videoplayer_miniproject/model/chart_model/chart_model.dart';
import 'package:videoplayer_miniproject/screens/mini_Screens/search.dart';
import 'package:videoplayer_miniproject/screens/video/video_play.dart';
import 'package:videoplayer_miniproject/functions/db_functions/db_functions.dart';
import '../../Model/video_model/video_model.dart';
import 'package:lottie/lottie.dart';
import '../../model/favorite_model/favorite_model.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as video_thumbnail;
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

class VideoList extends StatefulWidget {
  const VideoList({super.key});
  @override
  State<VideoList> createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  final TextEditingController _reNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // filepicker function along with thumbnail
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
            "${documentsDir.path}/thumbnails/$videoName.jpg";

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

      // Show a success snackbar if video geted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          padding:
              const EdgeInsets.only(bottom: 10, top: 10, left: 10, right: 10),
          content: Center(
              child: Text(
            'Video added successfully',
            style: TextStyle(
                color: Colors.orange.shade700, fontWeight: FontWeight.bold),
          )),
          backgroundColor: Colors.black,
          duration: const Duration(seconds: 1),
        ),
      );

      //-------------
      // chart calculation of video added
      final now = DateTime.now();
      final statisticsBox = Hive.box<VideoStatistics>('statistics');

      final periods =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final existingStatistics = statisticsBox.get(periods);
      if (existingStatistics != null) {
        existingStatistics.addedCount += videosToAdd.length;
        statisticsBox.put(periods, existingStatistics);
      } else {
        final statistics = VideoStatistics(
          period: periods,
          addedCount: videosToAdd.length,
          deletedCount: 0,
        );
        statisticsBox.put(periods, statistics);
      }
    } else {
      // Show an error snackbar if video didnt get
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          padding: EdgeInsets.only(bottom: 10, top: 10, left: 10, right: 10),
          content:
              Center(child: Text('Video didn\'t get added. Please try again.')),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Set<int> selectedVideos = Set<int>();
  bool _isSelecting = false;

  // Function to handle deleting selected videos and multiple
  void _deleteSelectedVideos() {
    final videoBox = Hive.box<VideoModel>('videos');
    final List<int> selectedIndices = selectedVideos.toList();
    selectedIndices.sort((a, b) =>
        b.compareTo(a)); // Sort in reverse order to avoid index issues
    for (int index in selectedIndices) {
      final video = videoBox.getAt(index);
      if (video != null) {
        videoBox.deleteAt(index);
      }
    }
    setState(() {
      _isSelecting = false;
      selectedVideos.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoBox = Hive.box<VideoModel>('videos');
    final favoriteVideoBox = Hive.box<FavoriteVideoModel>('Favorite');
    final multipledelete = videoBox.values.toList();
    return GestureDetector(
      onTap: () {
        //to disable the selction to delete multipl videos
        if (_isSelecting) {
          setState(() {
            _isSelecting = false;
            selectedVideos.clear();
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _isSelecting
            ? AppBar(
                backgroundColor: Colors.black,
                title: Text('${selectedVideos.length} selected'),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.select_all),
                    onPressed: () {
                      setState(() {
                        if (selectedVideos.length == multipledelete.length) {
                          selectedVideos.clear();
                        } else {
                          selectedVideos = Set<int>.from(List<int>.generate(
                              multipledelete.length, (i) => i));
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: selectedVideos.isNotEmpty
                        ? () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Delete Selected Videos'),
                                  content: const Text(
                                    'Are you sure you want to delete the selected videos?',
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Delete'),
                                      onPressed: () {
                                        _deleteSelectedVideos();
                                        Navigator.of(context).pop();
                                        final statisticsBox =
                                            Hive.box<VideoStatistics>(
                                                'statistics');
                                        final now = DateTime.now();
                                        final period =
                                            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

                                        final existingStatistics =
                                            statisticsBox.get(period);
                                        if (existingStatistics != null) {
                                          existingStatistics.deletedCount += 1;
                                          statisticsBox.put(
                                              period, existingStatistics);
                                        } else {
                                          final statistics = VideoStatistics(
                                            period: period,
                                            addedCount: 0,
                                            deletedCount: 1,
                                          );
                                          statisticsBox.put(period, statistics);
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        : null,
                  ),
                ],
              )
            : AppBar(
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
                    final isSelected = selectedVideos.contains(index);
                    return GestureDetector(
                      onTap: () {
                        if (_isSelecting) {
                          setState(() {
                            if (isSelected) {
                              selectedVideos.remove(index);
                            } else {
                              selectedVideos.add(index);
                            }
                          });
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoPlayerWidget(video),
                            ),
                          );
                        }
                      },
                      onLongPress: () {
                        setState(() {
                          _isSelecting = true;
                          if (isSelected) {
                            selectedVideos.remove(index);
                          } else {
                            selectedVideos.add(index);
                          }
                        });
                      },
                      child: Slidable(
                        endActionPane:
                            ActionPane(motion: const DrawerMotion(), children: [
                          SlidableAction(
                            spacing: 5,
                            onPressed: (context) {
                              _reNameController.text =
                                  video.name; //to show current name when update
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.black,
                                    title: Text(
                                      'Enter new name for ${video.name}',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    content: Form(
                                      key: _formKey,
                                      child: TextFormField(
                                        style: const TextStyle(
                                            color: Colors.black),
                                        controller: _reNameController,
                                        decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            focusedBorder:
                                                const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.orange,
                                                        width: 3)),
                                            enabledBorder:
                                                const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.orange,
                                                        width: 3)),
                                            hintText: 'New Video Name',
                                            suffixIcon: IconButton(
                                                onPressed: () {
                                                  _reNameController.clear();
                                                },
                                                icon: const Icon(
                                                  Icons.clear,
                                                  color: Colors.orange,
                                                ))),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a valid video name';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'Cancel',
                                          style:
                                              TextStyle(color: Colors.orange),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            // update function
                                            final updatedName =
                                                _reNameController.text;
                                            final oldName = video.name;
                                            video.name = updatedName;
                                            await videoBox.putAt(index, video);
                                            Navigator.pop(context);

                                            // Show a snackbar for the successful update
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Center(
                                                  child: Text(
                                                      'Video name updated from "$oldName" to "$updatedName"'),
                                                ),
                                                duration:
                                                    const Duration(seconds: 2),
                                                backgroundColor: Colors.blue,
                                              ),
                                            );
                                          }
                                        },
                                        child: const Text(
                                          'Rename',
                                          style:
                                              TextStyle(color: Colors.orange),
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
                              deleteFromDB(context, index); //delete from hive
                            },
                            icon: Icons.delete,
                            backgroundColor: Colors.red,
                            label: 'Delete',
                          ),
                        ]),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10.0),
                          leading: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              SizedBox(
                                height: double.infinity,
                                width: 80,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(video.thumbnailPath!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          //  SizedBox(
                          //     height: double.infinity,
                          //     width: 80,
                          //     child: ClipRRect(
                          //       borderRadius: BorderRadius.circular(8),
                          //       child: Image.file(
                          //         File(
                          //           video.thumbnailPath!,
                          //         ),
                          //         fit: BoxFit.cover,
                          //       ),
                          //     )),
                          trailing: IconButton(
                            onPressed: () {
                              setState(() {
                                final isFavorite = favoriteVideoBox.values.any(
                                  (favoriteVideo) =>
                                      favoriteVideo.favvideoPath ==
                                      video.videoPath,
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

                                HapticFeedback
                                    .mediumImpact(); // Provide haptic feedback
                              });
                            },
                            icon: Icon(
                              favoriteVideoBox.values.any(
                                (favoriteVideo) =>
                                    favoriteVideo.favvideoPath ==
                                    video.videoPath,
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
                            maxLines: 2,
                          ),
                          // onTap: () {
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => VideoPlayerWidget(video),
                          //     ),
                          //   );
                          // },
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
        //add button to add videos
        floatingActionButton: FloatingActionButton(
          onPressed: () => _pickVideo(context),
          backgroundColor: Colors.black,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
