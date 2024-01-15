import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import '../language.dart';
import 'package:provider/provider.dart';

List<Compounduser> compoundsuser = [];

// Lớp đại diện cho một hợp chất người dùng
class Compounduser {
  final String formula;
  final String iupacName;
  final String commonName;

  Compounduser(this.formula, this.iupacName, this.commonName);

  // Chuyển đối tượng thành dạng JSON
  Map<String, dynamic> toJson() {
    return {
      'formula': formula,
      'iupacName': iupacName,
      'commonName': commonName,
    };
  }

  // Phương thức tạo đối tượng từ JSON
  factory Compounduser.fromJson(Map<String, dynamic> json) {
    return Compounduser(
      json['formula'],
      json['iupacName'],
      json['commonName'],
    );
  }
}

// Widget CompoundList là một StatefulWidget để quản lý danh sách hợp chất người dùng
class CompoundList extends StatefulWidget {
  @override
  _CompoundListState createState() => _CompoundListState();
}

class _CompoundListState extends State<CompoundList> {
  List<Compounduser> searchResultsUser = [];
  final FlutterTts flutterTts = FlutterTts();

  // Phương thức để đọc phát âm tên thông thường của hợp chất
  Future<void> speakCommonName(String text) async {
    await flutterTts.setLanguage("en-GB");
    await flutterTts.speak(text);
  }

  @override
  //khởi tạo khi widget được tạo ra
  void initState() {
    super.initState();
    _loadCompounds();
  }

  // Phương thức để tải danh sách hợp chất từ SharedPreferences
  _loadCompounds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? compoundList = prefs.getStringList('compounds');

    if (compoundList != null) {
      setState(() {
        compoundsuser = compoundList
            .map((json) => Compounduser.fromJson(jsonDecode(json)))
            .toList();
      });
    }
  }

  // Phương thức để lưu danh sách hợp chất vào SharedPreferences
  _saveCompounds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> compoundList =
        compoundsuser.map((compound) => jsonEncode(compound.toJson())).toList();
    prefs.setStringList('compounds', compoundList);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(languageProvider.isEnglish
                ? 'Recently Added Compounds'
                : 'Các hợp chất đã thêm gần đây'),
            centerTitle: true,
            backgroundColor: Colors.deepPurple[200],
          ),
          body: Column(
            children: [
              SizedBox(
                height: 8,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: compoundsuser.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(compoundsuser[index].formula),
                        subtitle: Text(compoundsuser[index].iupacName),
                        trailing: IconButton(
                          onPressed: () {
                            speakCommonName(compoundsuser[index].iupacName);
                          },
                          icon: Icon(Icons.volume_up),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  //hộp thoại thêm chất mới
                  _showAddCompoundDialog(context);
                },
                child: Text(languageProvider.isEnglish
                    ? 'Add Compound'
                    : 'Thêm hợp chất'),
              ),
              //nút
              ElevatedButton(
                onPressed: () {
                  _showDeleteCompoundDialog(context);
                },
                child: Text(languageProvider.isEnglish
                    ? 'Delete Compound'
                    : 'Xóa hợp chất'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Hàm hiển thị thông báo cho người dùng
  void displaymessage(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(message),
            ));
  }

  // Hàm hiển thị hộp thoại thêm hợp chất mới
  Future<void> _showAddCompoundDialog(BuildContext context) async {
    TextEditingController formulaController = TextEditingController();
    TextEditingController iupacNameController = TextEditingController();
    TextEditingController commonNameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return Consumer<LanguageProvider>(
          builder: (context, languageProvider, _) {
            return AlertDialog(
              title: Text(languageProvider.isEnglish
                  ? 'Add New Compound'
                  : 'Thêm hợp chất mới'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(languageProvider.isEnglish ? 'Formula:' : 'Công thức:'),
                  TextField(controller: formulaController),
                  SizedBox(height: 10),
                  Text(languageProvider.isEnglish
                      ? 'IUPAC Name:'
                      : 'Pháp danh:'),
                  TextField(controller: iupacNameController),
                  SizedBox(height: 10),
                  Text(languageProvider.isEnglish
                      ? 'Common Name:'
                      : 'Tên thông thường:'),
                  TextField(controller: commonNameController),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(languageProvider.isEnglish ? 'Cancel' : 'Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Kiểm tra nếu formula và iupacName không rỗng
                    if (formulaController.text.isNotEmpty &&
                        iupacNameController.text.isNotEmpty) {
                      Compounduser newCompound = Compounduser(
                        formulaController.text,
                        iupacNameController.text,
                        commonNameController.text,
                      );
                      setState(() {
                        compoundsuser.add(newCompound);
                        _saveCompounds(); // Lưu trạng thái mới sau khi thêm
                      });
                      Navigator.pop(context);
                    } else {
                      // Hiển thị thông báo lỗi nếu formula hoặc iupacName rỗng
                      displaymessage(languageProvider.isEnglish
                          ? 'Please enter the formula and the IUPAC name'
                          : 'Bạn phải nhập công thức và pháp danh trước');
                    }
                  },
                  child: Text(languageProvider.isEnglish ? 'Add' : 'Thêm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Hàm hiển thị hộp thoại xóa một hợp chất
  Future<void> _showDeleteCompoundDialog(BuildContext context) async {
    TextEditingController formulaController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return Consumer<LanguageProvider>(
          builder: (context, languageProvider, _) {
            return AlertDialog(
              title: Text(languageProvider.isEnglish
                  ? 'Delete Compound'
                  : 'Xóa hợp chất'),
              content: Column(
                children: [
                  Text(languageProvider.isEnglish
                      ? 'Are you sure you want to delete this compound?'
                      : 'Bạn có chắc chắn muốn xóa hợp chất này không?'),
                  SizedBox(
                    height: 8,
                  ),
                  Text(languageProvider.isEnglish ? 'Formula:' : 'Công thức:'),
                  TextField(controller: formulaController),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(languageProvider.isEnglish ? 'Cancel' : 'Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Xác định công thức hợp chất cần xóa
                    String formula = formulaController.text;
                    setState(() {
                      // Loại bỏ hợp chất khỏi danh sách
                      compoundsuser.removeWhere(
                          (compound) => compound.formula == formula);
                      _saveCompounds(); // Lưu trạng thái mới sau khi xóa
                    });
                    Navigator.pop(context);
                    displaymessage(languageProvider.isEnglish
                        ? 'Compound deleted successfully'
                        : 'Hợp chất đã được xóa thành công');
                  },
                  child: Text(languageProvider.isEnglish ? 'Delete' : 'Xóa'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
