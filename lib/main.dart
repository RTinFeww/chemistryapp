//https://blog.logrocket.com/flutter-tabbar-a-complete-tutorial-with-examples/
import 'package:chemistryapp/searchnamecp.dart';
import 'package:flutter/material.dart';
import 'library.dart';
import 'searchscreen.dart';
import 'setting.dart';
import 'searchonline.dart';
import 'language.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider<LanguageProvider>(
      create: (context) => LanguageProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: DefaultTabController(
            length: 5,
            child: Scaffold(
              appBar: AppBar(
                title:
                    Text(languageProvider.isEnglish ? 'MENU' : 'Các chức năng'),
                centerTitle: true,
                backgroundColor: Colors.deepPurple[200],
                bottom: TabBar(
                  indicatorWeight: 20,  //dưới icon
                  tabs: [
                    Tab(
                      icon: Image.asset(
                        'assets/giaodien/nguyento.png',
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                      //text: languageProvider.isEnglish ? 'Element' : 'Nguyên tố',
                    ),
                    Tab(
                      icon: Image.asset(
                        'assets/giaodien/hopchat.png',
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                      //text: languageProvider.isEnglish ? 'Compound' : 'Hợp chất',
                    ),
                    Tab(
                      icon: Image.asset(
                        'assets/giaodien/timkiem.png',
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
                      //text: languageProvider.isEnglish ? 'Searching' : 'Tìm kiếm',
                    ),
                    Tab(
                      icon: Image.asset(
                        'assets/giaodien/lib.png',
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                      //text: languageProvider.isEnglish ? 'Library' : 'Mục lục',
                    ),
                    Tab(
                      icon: Image.asset(
                        'assets/giaodien/setting.png',
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                      //text: languageProvider.isEnglish ? 'Setting' : 'Cài đặt',
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  SearchScreen(),
                  searchNamecp(),
                  Compounds(),
                  Contents(),
                  Setting(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
