import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language.dart';

// Widget Setting được sử dụng để chuyển đổi ngôn ngữ trong ứng dụng
class Setting extends StatelessWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Thanh tiêu đề của trang cài đặt
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          Provider.of<LanguageProvider>(context).isEnglish
              ? 'Change Language'
              : 'Chuyển đổi ngôn ngữ',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Hiển thị văn bản hướng dẫn về chuyển đổi ngôn ngữ
                  Text(
                    Provider.of<LanguageProvider>(context).isEnglish
                        ? 'Change to Vietnamese'
                        : 'Chuyển sang Tiếng Anh',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 20),
                  // Nút để thực hiện chuyển đổi ngôn ngữ
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.deepPurple),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      // Gọi phương thức toggleLanguage để chuyển đổi ngôn ngữ
                      Provider.of<LanguageProvider>(context, listen: false)
                          .toggleLanguage();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      // Hiển thị văn bản trên nút dựa vào ngôn ngữ hiện tại
                      child: Text(
                        Provider.of<LanguageProvider>(context).isEnglish
                            ? 'Chuyển sang Tiếng Việt'
                            : 'Change to English',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
