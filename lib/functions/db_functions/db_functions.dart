import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../Model/video_model/video_model.dart';

//delete from db with a confirmation show dailog..

Future<void> deleteFromDB(BuildContext context, int id) async {
  final videoDB = await Hive.openBox<VideoModel>('videos');

  // ignore: use_build_context_synchronously
  bool confirmDelete = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          "Confirm Deletion",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to delete this video?",
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              "No",
              style: TextStyle(color: Colors.orange.shade700),
            ),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: Text(
              "Yes",
              style: TextStyle(color: Colors.orange.shade700),
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );

  if (confirmDelete == true) {
    await videoDB.deleteAt(id);
  }
}
