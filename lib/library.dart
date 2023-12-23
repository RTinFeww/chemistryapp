import 'package:flutter/material.dart';
import 'chemical_symbol.dart';
import 'detail_symbol.dart';
import 'package:flutter/material.dart';

// Widget Contents để hiển thị nội dung của ứng dụng
class Contents extends StatelessWidget {
  const Contents({Key? key});

  // Phương thức chuyển hướng đến màn hình chi tiết khi nhấp vào một phần tử
  void navigateToSymbolDetail(
      BuildContext context, chemicalsymbol detailsymbol) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailSymbol(detailsymbol: detailsymbol),
      ),
    );
  }

  // Phương thức trả về màu sắc của Card dựa trên phân loại của nguyên tố
  Color getColorCard(String classify) {
    switch (classify) {
      case 'Á kim':
        return Color(0xFFF0E68C); // Màu Khaki
      case 'Khí hiếm':
        return Color(0xFFF08080); // Đỏ
      case 'Phi kim':
        return Color(0xFFD3D3D3); // Xám
      case 'Kim loại kiềm':
        return Color(0xFFD3A0D3); // Màu Violet
      case 'Kim loại kiềm thổ':
        return Color(0xFF87CEFA); // Màu Light Sky Blue
      case 'Kim loại chuyển tiếp':
        return Color(0xFFABD1B5); // Màu Green Pale
      case 'Kim loại yếu':
        return Color(0xFFCDE2B8); // Màu Tea Green
      case 'Halogen':
        return Color(0xFFFF6347); // Màu Tomato
      case 'Lanthanide':
        return Color(0xFF20B2AA); // Màu Light Sea Green
      default:
        return Color(0xFFFFFF); // Màu mặc định
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        // Sử dụng SliverGridDelegate để quy định số cột trong lưới
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: libary.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            elevation: 2.0,
            margin: EdgeInsets.all(10.0),
            color: getColorCard(
                libary[index].classify), // Lấy màu sắc từ phân loại
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: GestureDetector(
              onTap: () {
                // Chuyển hướng đến màn hình chi tiết khi nhấp vào Card
                navigateToSymbolDetail(context, libary[index]);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Hiển thị số thứ tự và ký hiệu nguyên tố
                  Text(
                    '${libary[index].chemicalelementnumber} ${libary[index].symbol}',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  // Hiển thị tên gọi nguyên tố
                  Text(
                    '${libary[index].nomenclature}',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  // Hiển thị khối nguyên tử
                  Text(
                    '${libary[index].atomicblock}',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  // Hiển thị trạng thái nguyên tố
                  Text(
                    '${libary[index].state}',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
