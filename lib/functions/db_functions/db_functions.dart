import 'package:hive/hive.dart';
import '../../Model/video_model/video_model.dart';

//video_model db function-----------

//delete from db
Future<void> deletefromDB(int id) async {
  final videoDB = await Hive.openBox<VideoModel>('videos');
  await videoDB.deleteAt(id);
}
