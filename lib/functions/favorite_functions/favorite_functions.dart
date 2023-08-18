import 'package:hive/hive.dart';
import 'package:videoplayer_miniproject/model/favorite_model/favorite_model.dart';

//delete from db
Future<void> deleteFavfromDB(int id) async {
  final favoriteDB = await Hive.openBox<FavoriteVideoModel>('Favorite');
  await favoriteDB.deleteAt(id);
}
