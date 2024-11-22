import 'package:flutter/material.dart';

class PostButton extends StatefulWidget {
  const PostButton({super.key});

  @override
  State<PostButton> createState() => _PostButtonState();
}

class _PostButtonState extends State<PostButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: (){}, child: Text("Post"),
      style: ButtonStyle(
        // backgroundBuilder: Widgets
      )
    );
  }
}
