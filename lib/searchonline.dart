import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'detailcp.dart';
import '../language.dart';
import 'package:provider/provider.dart';

class Compounds extends StatefulWidget {
  const Compounds({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CompoundsState createState() => _CompoundsState();
}

class _CompoundsState extends State<Compounds> {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController _textEditingController = TextEditingController();
  List<Map<String, dynamic>> _compounds = [];
  String formulasearch = '';
  List<String> _synonyms = [];
  List<String> _first15Synonyms = [];
  final _synonymsList = <List<String>>[];
  final _synonymsMap = <int, List<String>>{};
  //Hàm đọc pháp danh
  Future<void> speakCommonName(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(text);
  }

// Hàm để lấy danh sách synonyms của một hợp chất dựa trên CID (Compound ID)
  Future<void> getCompoundNames(int cid) async {
    // Xây dựng URL để gửi yêu cầu API đến PubChem với CID và yêu cầu dữ liệu synonyms dưới dạng JSON
    var url = Uri.parse(
        'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/synonyms/JSON');

    // Gửi yêu cầu HTTP GET và đợi phản hồi từ server
    var response = await http.get(url);

    // Kiểm tra xem phản hồi có thành công không (statusCode 200)
    if (response.statusCode == 200) {
      // Xử lý dữ liệu JSON từ phản hồi
      setState(() {
        var data = json.decode(response.body);

        // Lấy danh sách synonyms từ dữ liệu và cập nhật các biến trạng thái của widget
        _synonyms =
            data['InformationList']['Information'][0]['Synonym'].cast<String>();
        _synonymsMap[cid] = _synonyms;
        _synonymsList.add(_synonyms);
        _first15Synonyms = _synonyms.take(15).toList();
      });
    } else {
      // In ra thông báo nếu không thành công
    }
  }

// Hàm tìm kiếm thông tin của hợp chất dựa trên công thức
  void _searchCompound() async {
    // Lấy công thức từ trường nhập liệu (TextField)
    String formula = _textEditingController.text;

    // Xây dựng URL để gửi yêu cầu API đến PubChem với công thức và yêu cầu dữ liệu chi tiết dưới dạng JSON
    var compoundDetailsUrl = Uri.parse(
        'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/$formula/property/IUPACName,MolecularFormula,MolecularWeight,inchi,CanonicalSMILES,IsomericSMILES,title/JSON');

    // Gửi yêu cầu HTTP GET và đợi phản hồi từ server
    var compoundDetailsResponse = await http.get(compoundDetailsUrl);

    // Kiểm tra xem phản hồi có thành công không (statusCode 200)
    if (compoundDetailsResponse.statusCode == 200) {
      // Xử lý dữ liệu JSON từ phản hồi
      var compoundData = json.decode(compoundDetailsResponse.body);

      // Cập nhật trạng thái của widget với các thông tin của hợp chất được trả về
      setState(() {
        formulasearch = formula;
        _compounds = compoundData['PropertyTable']['Properties']
            .cast<Map<String, dynamic>>();
      });

      // Lấy CID từ dữ liệu compoundDetailsResponse
      int cid = compoundData['PropertyTable']['Properties'][0]['CID'];

      // Gọi hàm getCompoundNames để lấy tên đồng nghĩa của hợp chất
      await getCompoundNames(cid);
    } else {
      // Nếu không thành công, cập nhật trạng thái của widget để không có kết quả
      setState(() {
        _compounds = [];
      });
    }
  }

  //Xây dựng 1 widget con để hiển thị các synonyms của hợp chất
  Widget _buildSynonymsList(int cid) {
    return Wrap(
      children: _synonymsMap[cid]
              ?.take(15)
              .map((synonym) => Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextButton(
                      onPressed: () {
                        // Gọi hàm phát âm khi bấm vào nút
                        speakCommonName(synonym);
                      },
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.deepPurple[200]!,
                        ),
                      ),
                      child: Text(
                        synonym,
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight:
                                FontWeight.bold // Thay đổi màu sắc tại đây
                            ),
                      ),
                    ),
                  ))
              .toList() ??
          [],
    );
  }

//Giao diện hiển thị người dùng
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        // Scaffold là cấu trúc cơ bản của trang
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // TextField để nhập công thức hoặc tên hợp chất
                TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    hintText: languageProvider.isEnglish
                        ? 'Enter formula or compound name. Example: (NH4)2SO4'
                        : 'Nhập công thức hoặc tên hợp chất. Ví dụ: (NH4)2SO4',
                  ),
                ),
                const SizedBox(height: 10),
                // Nút "Search" để thực hiện tìm kiếm
                ElevatedButton(
                  onPressed: _searchCompound,
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.deepPurple[200]!,
                    ),
                  ),
                  child: Text(
                    languageProvider.isEnglish ? 'Search' : 'Tìm kiếm',
                  ),
                ),
                const SizedBox(height: 20),
                // Danh sách kết quả tìm kiếm
                Expanded(
                  child: ListView.builder(
                    itemCount: _compounds.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          // Hiển thị thông tin về hợp chất
                          title: Text(
                            languageProvider.isEnglish
                                ? 'Formula : $formulasearch'
                                : 'Công thức : $formulasearch',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CID PUBCHEM: ${_compounds[index]['CID']}',
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                languageProvider.isEnglish
                                    ? 'Iupac name: ${_compounds[index]['IUPACName']}'
                                    : 'Tên IUPAC: ${_compounds[index]['IUPACName']}',
                              ),
                              const SizedBox(height: 5),
                              Text(
                                languageProvider.isEnglish
                                    ? 'Synonyms:'
                                    : 'Đồng nghĩa:',
                              ),
                              // Hiển thị danh sách đồng nghĩa bằng ListView.builder
                              _buildSynonymsList(_compounds[index]['CID']),
                            ],
                          ),
                          onTap: () {
                            // Chuyển đến màn hình chi tiết khi một hợp chất được chọn
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CompoundDetails(
                                  formula: formulasearch,
                                  compound: _compounds[index],
                                  first15Synonyms: _first15Synonyms,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
