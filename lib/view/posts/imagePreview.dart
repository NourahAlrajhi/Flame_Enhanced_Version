import 'dart:async';
import 'package:flame/Constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flame/Constants/color.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_place/google_place.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import '../../Constants/theme.dart';
import '../../controller/user_cubit.dart';

class imagePreview extends StatefulWidget {
  @override
  State<imagePreview> createState() => _imagePreviewState();
}

class _imagePreviewState extends State<imagePreview> {
  //pickImage func
  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() {
        postImage = imageTemp;
      });
      return imageTemp;
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('Failed to pick image: $e');
    }
  }

// select image dialog
  _selectImageDialog(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0))),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo',
                    style: TextStyle(
                      fontFamily: font,
                    )),
                onPressed: () {
                  pickImage(ImageSource.camera);
                  UserCubit.get(context).updateImg();
                  Navigator.pop(context);
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from Gallery',
                    style: TextStyle(
                      fontFamily: font,
                    )),
                onPressed: () {
                  pickImage(ImageSource.gallery);
                  UserCubit.get(context).updateImg();
                  Navigator.pop(context);
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text(
                "Cancel",
                style: TextStyle(fontFamily: font, color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return BlocConsumer<UserCubit, UserState>(
        builder: (context, state) {
          return Scaffold(
              appBar: AppBar(
                backgroundColor: background,
                elevation: 0,
                leadingWidth: 65,
                leading: InkWell(
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.black,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    }),
                title: Container(
                  margin: const EdgeInsets.only(left: 60),
                  child: const Text(
                    'Chosen Image',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: BottomAppBar(
                //shape: CircularNotchedRectangle(),
                //notchMargin: 10,
                child: SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          _selectImageDialog(context);
                          setState(() {
                            postImage;
                          });
                          UserCubit.get(context).updateImg();
                        },
                        child: Center(
                          child: Container(
                            margin: EdgeInsets.only(left: 140),
                            child: const Text('Choose another one'),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              backgroundColor: Colors.black,
              body: Stack(children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Image.file(
                    postImage!,
                    width: w,
                    height: h,
                  ),
                ),
              ]));
        },
        listener: (context, state) {});
  }
}
