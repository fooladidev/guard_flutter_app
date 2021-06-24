import 'package:flutter/material.dart';
import 'text_field_container.dart';
import 'package:project2_app/constants.dart';
class RoundedPasswordField extends StatefulWidget{
  final ValueChanged<String> onChanged;
  const RoundedPasswordField({
    Key? key,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() =>RoundedPasswordFieldState(onChanged);

}

class RoundedPasswordFieldState extends State<RoundedPasswordField> {

  final ValueChanged<String> onChanged;
  bool isObscure = true ;

  RoundedPasswordFieldState(this.onChanged);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        obscureText: isObscure,
        onChanged: onChanged,
        cursorColor: KPrimaryColor,
        decoration: InputDecoration(
          hintText: "رمز عبور شما",
          icon: Icon(
            Icons.lock,
            color: KPrimaryColor,
          ),
          suffixIcon: GestureDetector(
            onTap: (){
              setState(() {
                isObscure=!isObscure ;
              });
            },
            child: Icon(
              Icons.visibility,
              color: KPrimaryColor,
            ),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

}
