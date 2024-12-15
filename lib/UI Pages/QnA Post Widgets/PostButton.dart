import 'package:flutter/material.dart';

class PostButton extends StatefulWidget {
  const PostButton({super.key});

  @override
  State<PostButton> createState() => _PostButtonState();
}

class _PostButtonState extends State<PostButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: (){}, child: Text("Post", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(Colors.tealAccent.shade400),

      )


    );
  }
}
