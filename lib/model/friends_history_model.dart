
part 'friends_history_model.g.dart';



class FriendsHistoryModel {
  String id;
  String nickname;
  String avatarPath;
  String introduce;
  String isAccepted;
  String username;
  String owner;


  FriendsHistoryModel({this.nickname, this.avatarPath, this.introduce, this.isAccepted, this.id,this.username,this.owner});

  factory FriendsHistoryModel.fromJson(Map<String, dynamic> json) => _$FriendsHistoryModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$FriendsHistoryModelToJson(this);
}