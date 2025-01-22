import 'package:flutter/material.dart';

class PostButton extends StatefulWidget {
  const PostButton({super.key});

  @override
  State<PostButton> createState() => _PostButtonState();
}

class _PostButtonState extends State<PostButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: (){},
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(Colors.teal.shade700),

      ), child: const Text("Post", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),)


    );
  }
}
