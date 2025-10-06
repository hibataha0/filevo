import 'package:flutter/material.dart';

class ProfilePic extends StatelessWidget {
  const ProfilePic({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 115,
      width: 115,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          const CircleAvatar(
            backgroundImage: NetworkImage(
              "https://i.postimg.cc/0jqKB6mS/Profile-Image.png",
            ),
          ),
          Positioned(
            right: -8,
            bottom: 0,
            child: SizedBox(
              height: 35,
              width: 35,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: const BorderSide(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFFF5F6F9),
                ),
                onPressed: () {
                  // 📸 هنا الكود اللي بفتح الكاميرا أو المعرض
                },
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
