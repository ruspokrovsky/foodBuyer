
import 'package:avatar_glow/avatar_glow.dart';
import 'package:circular_motion/circular_motion.dart';
import 'package:flutter/material.dart';
import 'package:ya_bazaar/res/widgets/cached_network_image.dart';
import 'package:ya_bazaar/theme.dart';

class CircularMotionWidget extends StatelessWidget {
  final VoidCallback onPressed1;
  final VoidCallback onPressed2;
  final VoidCallback onPressed3;
  final VoidCallback onPressed4;
  final String imgUrl;
  final String text1;
  final String text2;
  final String text3;
  final String text4;
  final bool? isAvatarGlow;
  const CircularMotionWidget({Key? key,
    required this.onPressed1,
    required this.onPressed2,
    required this.onPressed3,
    required this.onPressed4,
    required this.text1,
    required this.imgUrl,
    required this.text2,
    required this.text3,
    required this.text4,
    this.isAvatarGlow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);
    return CircularMotion(
      //centerWidget: Text('Center'),
      //behavior: HitTestBehavior.deferToChild,
        children: [
          Card(
            color: Colors.transparent,
            elevation: 15.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(31.0),
              //set border radius more than 50% of height and width to make circle
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50.0),
              child: Container(
                height: 50.0,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Theme.of(context)
                        .primaryColorDark,
                  ),
                  borderRadius:
                  BorderRadius.circular(50.0),
                  gradient: LinearGradient(
                    colors: <Color>[
                      Theme.of(context).primaryColorDark,
                      Theme.of(context).primaryColorLight,
                    ],
                  ),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    textStyle:
                    const TextStyle(fontSize: 20),
                  ),
                  onPressed: onPressed1,
                  child: Text(
                    text1,
                    style: styles.motionTextStyle,
                  ),
                ),
              ),
            ),
          ),
          Card(
            color: Colors.transparent,
            elevation: 20.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(31.0),
              //set border radius more than 50% of height and width to make circle
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50.0),
              child: Container(
                height: 50.0,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Theme.of(context)
                        .primaryColorDark,
                  ),
                  borderRadius:
                  BorderRadius.circular(50.0),
                  gradient: LinearGradient(
                    colors: <Color>[
                      //Theme.of(context).primaryColor,
                      Theme.of(context).primaryColorDark,
                      Theme.of(context).primaryColorLight,
                    ],
                  ),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    textStyle: styles.motionTextStyle,
                  ),
                  onPressed: onPressed2,
                  child: Text(
                    text2,
                    style: styles.motionTextStyle,
                  ),
                ),
              ),
            ),
          ),
          // Card(
          //   elevation: 10.0,
          //   color: Colors.transparent,
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(31.0),
          //     //set border radius more than 50% of height and width to make circle
          //   ),
          //   child: ClipRRect(
          //     borderRadius: BorderRadius.circular(50.0),
          //     child: Container(
          //       height: 50.0,
          //       decoration: BoxDecoration(
          //         border: Border.all(
          //           width: 1.0,
          //           color: Theme.of(context)
          //               .primaryColorDark,
          //         ),
          //         borderRadius:
          //         BorderRadius.circular(50.0),
          //         gradient: LinearGradient(
          //           colors: <Color>[
          //             //Theme.of(context).primaryColor,
          //             Theme.of(context).primaryColorDark,
          //             Theme.of(context).primaryColorLight,
          //           ],
          //         ),
          //       ),
          //       child: TextButton(
          //         style: TextButton.styleFrom(
          //           foregroundColor: Colors.white,
          //           textStyle:
          //           const TextStyle(fontSize: 20),
          //         ),
          //         onPressed: onPressed3,
          //         child: Text(
          //           text3,
          //           style: Theme.of(context)
          //               .textTheme
          //               .headlineSmall,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          Card(
            elevation: 10.0,
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(31.0),
              //set border radius more than 50% of height and width to make circle
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50.0),
              child:
              Container(
                height: 50.0,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1.0,
                    color: Theme.of(context)
                        .primaryColorDark,
                  ),
                  borderRadius:
                  BorderRadius.circular(50.0),
                  gradient: LinearGradient(
                    colors: <Color>[
                      //Theme.of(context).primaryColor,
                      Theme.of(context).primaryColorDark,
                      Theme.of(context).primaryColorLight,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          textStyle:
                          styles.motionTextStyle,
                        ),
                        onPressed: onPressed4,
                        child: Text(
                          text4,
                          style: styles.motionTextStyle,
                        ),
                      ),
                      const SizedBox(width: 16,),
                      Container(
                        margin: const EdgeInsets.only(right: 1.5),
                        height: 45,
                        width: 45,
                        child: ClipRRect(
                          borderRadius:
                          BorderRadius.circular(50.0),
                          child: CachedNetworkImg(
                            imageUrl: imgUrl,
                            fit: BoxFit.cover,
                            height: double.infinity,
                            width: double.infinity,
                          ),
                        ),
                      ),




                    ]),
              ),
              // Container(
              //   height: 50.0,
              //   decoration: BoxDecoration(
              //     border: Border.all(
              //       width: 1.0,
              //       color: Theme.of(context)
              //           .primaryColorDark,
              //     ),
              //     borderRadius:
              //     BorderRadius.circular(50.0),
              //     gradient: LinearGradient(
              //       colors: <Color>[
              //         //Theme.of(context).primaryColor,
              //         Theme.of(context).primaryColorDark,
              //         Theme.of(context).primaryColorLight,
              //       ],
              //     ),
              //   ),
              //   child: TextButton(
              //     style: TextButton.styleFrom(
              //       foregroundColor: Colors.white,
              //       textStyle:
              //       const TextStyle(fontSize: 20),
              //     ),
              //     onPressed: onPressed3,
              //     child: Text(
              //       "Личный кабинет",
              //       style: Theme.of(context)
              //           .textTheme
              //           .headlineSmall,
              //     ),
              //   ),
              // ),
            ),
          ),
        ]);
  }
}
