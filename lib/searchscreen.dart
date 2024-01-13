import 'package:flutter/material.dart';
import 'chemical_symbol.dart';
import 'detail_symbol.dart';
import 'package:audioplayers/audioplayers.dart';
import '../language.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Danh sách kết quả tìm kiếm
  List<chemicalsymbol> searchResults = [];
  // Đối tượng AudioPlayer để phát âm thanh
  final player = AudioPlayer();

  // Phương thức tìm kiếm
  void search(String query) {
    setState(() {
      // Lọc danh sách library để lấy kết quả tìm kiếm
      searchResults = libary
          .where((libary) =>
              libary.symbol.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Phương thức chuyển hướng đến màn hình chi tiết
  void navigateToSymbolDetail(chemicalsymbol detailsymbol) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailSymbol(detailsymbol: detailsymbol),
      ),
    );
  }

  // Phương thức đọc tên nguyên tố
  void Read(String name) async {
    await player.play(AssetSource('mp3_elements/${name}.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<LanguageProvider>(
              builder: (context, languageProvider, _) {
                return TextField(
                  onChanged: search,
                  decoration: InputDecoration(
                    labelText: languageProvider.isEnglish
                        ? 'Enter the element symbol'
                        : 'Nhập ký hiệu nguyên tố',
                  ),
                );
              },
            ),
          ),
         Expanded(
            child: Consumer<LanguageProvider>(
              builder: (context, languageProvider, _) {
                return ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      // Hiển thị thông tin về ký hiệu nguyên tố
                      title: Text(
                        languageProvider.isEnglish
                            ? 'Element symbol: ${searchResults[index].symbol}, Name: ${searchResults[index].nomenclature}'
                            : 'Kí hiệu: ${searchResults[index].symbol}, Tên gọi: ${searchResults[index].nomenclature}',
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hiển thị số thứ tự và nguyên tử khối
                          Text(
                            languageProvider.isEnglish
                                ? 'Serial number in the periodic table: ${searchResults[index].chemicalelementnumber}'
                                : "Số thự tự trong bảng tuần hoàn: ${searchResults[index].chemicalelementnumber}",
                          ),
                          Text(
                            languageProvider.isEnglish
                                ? 'Atomic Block: ${searchResults[index].atomicblock}'
                                : "Nguyên tử khối: ${searchResults[index].atomicblock}",
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        // Nút âm thanh để đọc tên nguyên tố
                        icon: Icon(Icons.volume_up),
                        onPressed: () {
                          String name = searchResults[index].nomenclature;
                          Read(name);
                        },
                      ),
                      onTap: () {
                        // Chuyển đến màn hình chi tiết khi nhấp vào
                        navigateToSymbolDetail(searchResults[index]);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
