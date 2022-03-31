import 'package:flutter/material.dart';

class DrawerItem extends StatelessWidget {
  final Widget leading;
  final void Function()? onTap;
  final String title;
  final Widget? trailing;
  final Color? textColor;

  const DrawerItem(
      {Key? key,
      required this.title,
      required this.leading,
      this.trailing,
      this.onTap,
      this.textColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var color = textColor ?? Colors.blue[100]!;
    return ListTile(
      minLeadingWidth: 10,
      iconColor: color,
      textColor: color,
      leading: leading,
      title: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      trailing: trailing,
    );
  }
}
