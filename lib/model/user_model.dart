
class User {
  String username;
  int friendsUnReadCount;
  String friendsHistoryList;

  User({this.username,this.friendsUnReadCount,this.friendsHistoryList});
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] as String,
      friendsHistoryList: json['friendsHistoryList'] as String,
      friendsUnReadCount: json['friendsUnReadCount'] as int,
    );
  }

  Map<String, dynamic> toJson(User instance) => 
    <String, dynamic>{
      'username': instance.username,
      'friendsHistoryList': instance.friendsHistoryList,
      'friendsUnReadCount': instance.friendsUnReadCount,
    };
}