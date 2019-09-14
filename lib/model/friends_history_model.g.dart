part of 'friends_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendsHistoryModel _$FriendsHistoryModelFromJson(Map<String, dynamic> json) {
  return FriendsHistoryModel(
      owner: json['owner'] as String,
      nickname: json['nickname'] as String,
      avatarPath: json['avatarPath'] as String,
      introduce: json['introduce'] as String,
      isAccepted: json['isAccepted'] as String,
      id: json['_id'] as String,
      username: json['username'] as String)
      ;
}

Map<String, dynamic> _$FriendsHistoryModelToJson(
        FriendsHistoryModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'nickname': instance.nickname,
      'avatarPath': instance.avatarPath,
      'introduce': instance.introduce,
      'isAccepted': instance.isAccepted,
      'username': instance.username,
      'owner':instance.owner,
    };
