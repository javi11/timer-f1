import 'package:flutter/material.dart';

class AlertModal extends StatelessWidget {
  final String subtitle;
  final List<Widget>? buttons;
  final String title;
  final double height;

  const AlertModal(
      {Key? key,
      required this.title,
      required this.subtitle,
      required this.height,
      this.buttons})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(left: 25, right: 25, top: 12, bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[200],
                    child: Center(
                        child: IconButton(
                            color: Colors.black87,
                            iconSize: 20,
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(Icons.close))))
              ],
            ),
            Flexible(
                child: Center(
                    child: Text(
              subtitle,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ))),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: buttons ?? [],
            )
          ],
        ));
  }
}
