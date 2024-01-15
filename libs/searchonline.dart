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
  _CompoundsState createState() => _CompoundsState();
}

class _CompoundsState extends State<Compounds> {
  final FlutterTts flutterTts = FlutterTts();
  TextEditingController _textEditingController = TextEditingController();
  List<Map<String, dynamic>> _compounds = [];
  String formulasearch = '';
  Map<int, List<String>> _synonymsMap = {};
  Map<int, List<String>> _first15SynonymsMap = {};

  Future<void> speakCommonName(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(text);
  }

  Future<void> getCompoundNames(int cid) async {
    var url = Uri.parse(
        'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/synonyms/JSON');

    var response = await http.get(url);
//kiểm tra xem danh sách có chất đấy không
    if (response.statusCode == 200) {
      setState(() {
        var data = json.decode(response.body);
        _synonymsMap[cid] =
            data['InformationList']['Information'][0]['Synonym'].cast<String>();
        _first15SynonymsMap[cid] = _synonymsMap[cid]!.take(15).toList();
      });
    } else {
      print(
          'Không thể lấy danh sách tên hợp chất. Mã trạng thái: ${response.statusCode}');
    }
  }

  void _searchCompound() async {
    String formula = _textEditingController.text;
    var compoundDetailsResponse = await _getCompoundDetails('name', formula);
//lấy thông tin formula
    if (compoundDetailsResponse?.statusCode != 200) {
      compoundDetailsResponse =
          await _getCompoundDetails('fastformula', formula);
    }

    if (compoundDetailsResponse?.statusCode == 200) {
      var compoundData = json.decode(compoundDetailsResponse!.body);
      int cid = compoundData['PropertyTable']['Properties'][0]['CID'];

      if (!_synonymsMap.containsKey(cid)) {
        _synonymsMap[cid] = [];
      }
      //cập nhật trạng thái ui
      setState(() {
        formulasearch = formula;
        _compounds = compoundData['PropertyTable']['Properties']
            .cast<Map<String, dynamic>>();
      });

      await getCompoundNames(cid);
    } else {
      setState(() {
        _compounds = [];
      });
    }
  }

  Future<http.Response?> _getCompoundDetails(
      String type, String formula) async {
    var url = Uri.parse(
      //su dung api pubchem lay cac thong tin hop chat len
        'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/$type/$formula/property/IUPACName,MolecularFormula,MolecularWeight,inchi,CanonicalSMILES,IsomericSMILES,title/JSON');

    try {
      return await http.get(url);
    } catch (e) {
      print('Failed to get compound details using $type. Error: $e');
      return null;
    }
  }

  Widget _buildSynonymsList(int cid) {
    List<String> synonymsToShow = _first15SynonymsMap[cid] ?? [];
    return Wrap(
      children: synonymsToShow
          .map((synonym) => Padding(
            //lớp trù tượng
                padding: const EdgeInsets.all(4.0),
                child: TextButton(
                  onPressed: () {
                    speakCommonName(synonym);
                  },
                  child: Text(
                    synonym,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.deepPurple[200]!,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return Scaffold(
          body: Padding(
            //tổ chức giao diện, cung cấp khoảng trắng
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    hintText: languageProvider.isEnglish
                        ? 'Enter formula or compound name. Example: (NH4)2SO4'
                        : 'Nhập công thức hoặc tên hợp chất. Ví dụ: (NH4)2SO4',
                        
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _searchCompound,
                  child: Text(
                    languageProvider.isEnglish ? 'Search' : 'Tìm kiếm',
                  ),
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
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: _compounds.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(
                            languageProvider.isEnglish
                                ? 'Formula : ${formulasearch}' ?? ''
                                : 'Công thức : ${formulasearch}' ?? '',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CID PUBCHEM: ${_compounds[index]['CID']}',
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                languageProvider.isEnglish
                                    ? 'Iupac name: ${_compounds[index]['IUPACName']}' ??
                                        'Iupac name: ${_compounds[index]['Title']}'
                                    : 'Tên IUPAC: ${_compounds[index]['IUPACName']}' ??
                                        'Tên IUPAC: ${_compounds[index]['Title']}',
                              ),
                              SizedBox(height: 5),
                              Text(
                                languageProvider.isEnglish
                                    ? 'Synonyms:'
                                    : 'Đồng nghĩa:',
                              ),
                              _buildSynonymsList(_compounds[index]['CID']),
                            ],
                          ),
                          //nút chuyển màn hình chi tiết
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CompoundDetails(
                                  formula: formulasearch,
                                  compound: _compounds[index],
                                  first15Synonyms: _first15SynonymsMap[
                                          _compounds[index]['CID']] ??
                                      [],
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
