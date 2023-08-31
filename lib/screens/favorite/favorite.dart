import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:videoplayer_miniproject/functions/favorite_functions/favorite_functions.dart';
import 'package:videoplayer_miniproject/screens/favorite/player_favorite.dart';
import '../../model/favorite_model/favorite_model.dart';

class FavoriteVideoList extends StatelessWidget {
  const FavoriteVideoList({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteVideoBox = Hive.box<FavoriteVideoModel>('Favorite');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: const Text('Favorite'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 9),
        child: ValueListenableBuilder(
          valueListenable: favoriteVideoBox.listenable(),
          builder: (context, Box<FavoriteVideoModel> box, _) {
            final favoriteVideos = box.values.toList();

            if (favoriteVideos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Lottie.asset('assets/images/favorite.json',
                        fit: BoxFit.cover, height: 300),
                    const Text(
                      'No favorite videos',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              );
            } else {
              return ListView.separated(
                itemCount: favoriteVideos.length,
                separatorBuilder: (context, index) {
                  return const Divider(
                    thickness: 1,
                  );
                },
                itemBuilder: (context, index) {
                  final favoriteVideo = favoriteVideos[index];

                  return Slidable(
                    endActionPane:
                        ActionPane(motion: const DrawerMotion(), children: [
                      SlidableAction(
                        onPressed: (context) {
                          deleteFavfromDB(context, index);
                        },
                        icon: Icons.delete,
                        label: 'Delete',
                        backgroundColor: Colors.red,
                      )
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
                              favoriteVideo.favThumbnailPath!,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        favoriteVideo.favname,
                        style: const TextStyle(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      onTap: () {
                        // Navigate to the video player
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FavoritePlayer(favoriteVideo),
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
    );
  }
}
