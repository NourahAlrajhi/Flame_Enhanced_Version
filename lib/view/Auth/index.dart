import 'package:flame/view/Auth/Signin.dart';
import 'package:flame/view/Auth/Signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});
  static String id = "IndexScreen";

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Image.asset('assets/Header.png'),
          Image.asset('assets/filledLogo.png', width: 118, height: 111,),
          Text('Flame', 
          style: TextStyle(fontFamily: 'Tajawal',fontSize: 70, fontWeight: FontWeight.bold, color: Color(0xff3F3D43))),
          Text('keep your circle\nwarm',
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.normal, height: 2, color: Color(0xff3F3D43)), textAlign: TextAlign.center,),

          Container(
            margin: const EdgeInsets.only(top: 60.0),
            child: InkWell(
              onTap: () { showCupertinoModalBottomSheet(
                context: context, 
                expand: true,
                isDismissible: true,
                topRadius: Radius.circular(20),
                builder: (context) => SignupScreen(),
                backgroundColor: Colors.transparent,
                 ); },
              highlightColor: Color(0xffFF7F1D),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xffFF7F1D)), 
                    borderRadius: BorderRadius.circular(10)),
                width: 331,
                height: 54,
                child: Center(
                  child: Text('Sign up',
                         style:TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.w700)),
                      ),),
            ),
          ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  child: Divider(thickness: 2, color: Color(0xffDADADA), height: 50 ,)
                  ),
                Text('  OR  ', style:TextStyle(fontFamily: 'Tajawal',fontSize: 14)),
                Container(
                  width: 140,
                  child: Divider(thickness: 2, color: Color(0xffDADADA), height: 50 ,)
                  )
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account?',
                style:TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.normal, color:Color(0xff3F3D43))),
                
                InkWell(
                  onTap: () { showCupertinoModalBottomSheet(
                    context: context, 
                    expand: true,
                    isDismissible: true,
                    topRadius: Radius.circular(20),
                    builder: (context) => SigninScreen(),
                    backgroundColor: Colors.transparent,
                    ); },
                  child: Text(' Sign in',
                  style:TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.normal, color: Color(0xffFF7F1D))),
                ),
              ],
            ),
        ],
      ),
    );
  }
}