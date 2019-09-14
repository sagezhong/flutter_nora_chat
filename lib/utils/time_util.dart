
import 'package:nora_chat/utils/date_util.dart';


class TimeUtil {

  //时间之差是否超过五分钟
  static bool forMoreThanFiveMinutes(int time, int previousTime) {
    if ( (time - previousTime).abs() > 
      3 * 60 * 1000 ) {
        return true;
      } else {
        return false;
      }
  }
  
  static bool forMoreThanWeek(int time) {
    if ( (time - DateUtil.getNowDateMs()).abs() >
     7 * 24 * 60 * 60 * 1000) {
       return true;
     } else {
       return false;
     }
  }

  static bool isToday(int time) {
    int day = DateUtil.getDayOfYearByMillis(time);
    int today = DateUtil.getDayOfYear(DateTime.now());
    if (day == today) {
      return true;
    } else {
      return false;
    }
    
  }

  static String getMessageTime(int time) {
    int nowDate = DateUtil.getNowDateMs();
    DateTime dateTime = DateUtil.getDateTimeByMs(time);
    //判断是否是今年
    if (DateUtil.yearIsEqualByMillis(time, nowDate)) {
      //判断是否在一周之内
      //超过了一周 但是在今年
      if (forMoreThanWeek(time)) {
        // x月 x,hour:minute
        return '${dateTime.month}月 ${dateTime.day},${dateTime.hour.toString().padLeft(2,'0')}:${dateTime.minute.toString().padLeft(2,'0')}';

      } else {
        //是否是昨天
        if (DateUtil.isYesterdayByMillis(time, nowDate)) {
          return '昨天 ${dateTime.hour.toString().padLeft(2,'0')}:${dateTime.minute.toString().padLeft(2,'0')}';
        } else if(isToday(time)) {
          return '${dateTime.hour.toString().padLeft(2,'0')}:${dateTime.minute.toString().padLeft(2,'0')}';
        } else {
          String weekDay = DateUtil.getZHWeekDayByMs(time);
           return '$weekDay ${dateTime.hour.toString().padLeft(2,'0')}:${dateTime.minute.toString().padLeft(2,'0')}';
        }
      }
    } else {
      return '${dateTime.month}月 ${dateTime.day},${dateTime.year} ${dateTime.hour.toString().padLeft(2,'0')}:${dateTime.minute.toString().padLeft(2,'0')}';
    }
  }
}