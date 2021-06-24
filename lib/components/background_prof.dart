import 'package:flutter/material.dart';

class BackgroundProf extends StatelessWidget {
  final Widget child;
  const BackgroundProf({
    Key? key,
    required this.child,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
              bottom: 0,
              right: 0,
              child: Image.asset("assets/images/login_bottom.png",
                width: size.width*0.3,)
          ),
          child,


        ],
      ),

    );
  }
}
