import 'package:chemistryapp/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../language.dart';
import 'package:provider/provider.dart';

class CompoundDetails extends StatefulWidget {
  //Khai báo biến
  final String formula;
  final Map<String, dynamic> compound;
  final List<String> first15Synonyms;
  //Biến compound để lưu trữ thông tin hợp chất
  //Biến first15Synonyms là để lưu trữ 15 giá trị đầu tiên của synonyms hợp chất người dùng tìm kiếm

  CompoundDetails(
      {Key? key,
      required this.formula,
      required this.compound,
      required this.first15Synonyms})
      : super(key: key);

  @override
  State<CompoundDetails> createState() => _CompoundDetailsState();
}

class _CompoundDetailsState extends State<CompoundDetails> {
  final FlutterTts flutterTts = FlutterTts();

  //Hàm đọc pháp danh hợp chất bằng tiếng Anh-Mĩ
  Future<void> speakCommonName(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(text);
  }

  Widget _buildSynonymsList() {
    return Wrap(
      children: widget.first15Synonyms
          .map((synonym) => Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextButton(
                  onPressed: () {
                    // Gọi hàm phát âm khi bấm vào nút
                    speakCommonName(synonym);
                  },
                  child: Text(
                    synonym,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold // Thay đổi màu sắc tại đây
                        ),
                  ),
                  // Thay dổi nút bấm
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      //Colors.deepPurple[200]!,
                      Color.fromARGB(255, 250, 178, 189)!,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  } // Phần màn hình hiển thị thông tin chi tiết về hợp chất cho người dùng

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return Scaffold(
          appBar: AppBar(
            // Thanh tiêu đề của ứng dụng
            title: Text(
              languageProvider.isEnglish
                  ? 'Information compound'
                  : 'Thông tin hợp chất',
            ),
            centerTitle: true,
            backgroundColor: Colors.deepPurple[200],
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Container(
                margin: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width * 1,
                // Box để chứa nội dung với viền, màu nền và hình dạng được xác định
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: Colors.grey[200],
                  border: Border.all(
                    color: Colors.black,
                    width: 3.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Hiển thị CID và công thức của hợp chất
                      Text(
                        'PUBChem CID: ${widget.compound['CID']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        widget.formula,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Colors.black54,
                        ),
                      ),
                      // Nút để phát âm IUPAC Name hoặc Title của hợp chất
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.black),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        onPressed: () {
                          speakCommonName(widget.compound['IUPACName'] ??
                              widget.compound['Title']);
                        },
                        child: Icon(
                          Icons.volume_up,
                          size: 30,
                        ),
                      ),
                      // Hiển thị IUPAC Name hoặc Tên IUPAC của hợp chất
                      Text(
                        languageProvider.isEnglish
                            ? 'IUPAC Name: ${widget.compound['IUPACName'] ?? 'Unknown'}'
                            : 'Tên IUPAC: ${widget.compound['IUPACName'] ?? 'Không xác định'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 5),
                      // Hiển thị Công thức phân tử của hợp chất
                      Text(
                        languageProvider.isEnglish
                            ? 'Molecular Formula: ${widget.compound['MolecularFormula'] ?? 'Unknown'}'
                            : 'Công thức phân tử: ${widget.compound['MolecularFormula'] ?? 'Không xác định'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 5),
                      // Hiển thị Trọng lượng phân tử của hợp chất
                      Text(
                        languageProvider.isEnglish
                            ? 'Molecular Weight: ${widget.compound['MolecularWeight'] ?? 'Unknown'}'
                            : 'Trọng lượng phân tử: ${widget.compound['MolecularWeight'] ?? 'Không xác định'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      // Hiển thị InChI của hợp chất
                      SizedBox(height: 5),
                      Text(
                        'InChI: ${widget.compound['InChI'] ?? 'Unknown'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      // Hiển thị CanonicalSMILES của hợp chất
                      SizedBox(height: 5),
                      Text(
                        'CanonicalSMILES: ${widget.compound['CanonicalSMILES'] ?? 'Unknown'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      // Hiển thị IsomericSMILES của hợp chất
                      SizedBox(height: 5),
                      Text(
                        'IsomericSMILES: ${widget.compound['IsomericSMILES'] ?? 'Unknown'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      // Hiển thị Title của hợp chất
                      SizedBox(height: 5),
                      Text(
                        'Title: ${widget.compound['Title'] ?? 'Unknown'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      // Hiển thị IUPAC Name và danh sách đồng nghĩa
                      Text(
                        languageProvider.isEnglish
                            ? 'IUPAC Name and Synonyms:'
                            : 'Pháp danh và đồng nghĩa:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      _buildSynonymsList(),
                      SizedBox(height: 10),
                      // Nút quay lại menu chính
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.deepPurple),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MyApp()),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            languageProvider.isEnglish
                                ? 'Back to menu'
                                : 'Quay lại menu',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
