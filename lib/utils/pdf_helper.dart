import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;

class PdfHelper {
  static Future<Uint8List> generateRapor({
    required String nama,
    required String nis,
    required List<Map<String, dynamic>> nilai,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("RAPOR SISWA",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Nama: $nama"),
              pw.Text("NIS: $nis"),
              pw.SizedBox(height: 20),

              // Tabel nilai
              pw.Table.fromTextArray(
                headers: ["Mata Pelajaran", "Tugas", "UTS", "UAS", "Akhir", "Predikat"],
                data: nilai.map((n) {
                  return [
                    n['subject'],
                    n['tugas'].toString(),
                    n['uts'].toString(),
                    n['uas'].toString(),
                    n['final'].toStringAsFixed(2),
                    n['predikat'],
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
