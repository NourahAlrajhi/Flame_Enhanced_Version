

import 'package:shared_preferences/shared_preferences.dart';

class SaveData{
  static late    SharedPreferences _sharedPreferences;
   static init() async{
               _sharedPreferences =await SharedPreferences.getInstance();
    }
    static  setData({required dynamic key,required dynamic value})
   async{
      if(value is String ){
    return   await _sharedPreferences.setString(key, value);
      }
      else if(value is bool){
    return  await  _sharedPreferences.setBool(key, value);
      }
      else if (value is double){
    return await   _sharedPreferences.setDouble(key, value);
      }
    }
    static Future removeKey({required String key})async{
  return await      _sharedPreferences.remove(key);
    }
    static dynamic getData({required String key})async{
   return  _sharedPreferences.get(key);
    }
}