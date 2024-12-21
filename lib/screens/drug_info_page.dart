import 'dart:convert';
import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/widgets/custom_text_fieled.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class DrugInfoSearchPage extends StatefulWidget {
  const DrugInfoSearchPage({super.key});

  @override
  DrugInfoSearchPageState createState() => DrugInfoSearchPageState();
}

class DrugInfoSearchPageState extends State<DrugInfoSearchPage> {
  final TextEditingController _controller = TextEditingController();
  late Future<Map<String, dynamic>>? drugData;

  late List<String> drugSuggestions = [];
  late Timer _debounce;

  @override
  void initState() {
    super.initState();
    drugData = null;
    _debounce = Timer(Duration.zero, () {});
  }

  Future<List<String>> fetchDrugSuggestions(String query) async {
    final response = await http.get(
      Uri.parse('https://api.fda.gov/drug/label.json?search=$query'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['results'] != null && data['results'].isNotEmpty) {
        List<String> suggestions = [];
        for (var drug in data['results']) {
          if (drug['brand_name'] != null) {
            suggestions.add(drug['brand_name'][0] ??
                'هذه المعلومة غير متوفره, ستتوفر قريباً');
          }
        }
        return suggestions;
      } else {
        return [];
      }
    } else {
      throw Exception('فشل تحميل الاقتراحات');
    }
  }

  Future<Map<String, dynamic>> fetchDrugData(String drugName) async {
    final response = await http.get(
      Uri.parse('https://api.fda.gov/drug/label.json?search=$drugName'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['results'] != null && data['results'].isNotEmpty) {
        return data['results'][0];
      } else {
        throw Exception('لا توجد نتائج');
      }
    } else {
      throw Exception('فشل تحميل البيانات');
    }
  }

  void searchDrug() {
    setState(() {
      drugData = fetchDrugData(_controller.text);
    });
  }

  void onSearchChanged(String query) {
    if (_debounce.isActive) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isNotEmpty) {
        final suggestions = await fetchDrugSuggestions(query);
        setState(() {
          drugSuggestions = suggestions;
        });
      } else {
        setState(() {
          drugSuggestions = [];
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "بحث عن دواء",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _controller,
              text: 'أدخل اسم الدواء بشكل صحيح',
              icon: const Icon(Icons.medical_information),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: searchDrug,
                icon: const Icon(Icons.medical_services),
                label: const Text(
                  "بحث",
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (drugSuggestions.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ListView.builder(
                  itemCount: drugSuggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        drugSuggestions[index],
                        style: const TextStyle(color: Colors.black87),
                      ),
                      onTap: () {
                        _controller.text = drugSuggestions[index];
                        setState(() {
                          drugSuggestions = [];
                        });
                        searchDrug();
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: drugData == null
                  ? const Center(
                      child: Text(
                        "ابحث عن دواء لعرض المعلومات.",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    )
                  : FutureBuilder<Map<String, dynamic>>(
                      future: drugData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              " !أدخل اسم الدواء بالإنجليزية بشكل صحيح",
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        } else if (snapshot.hasData) {
                          var drugInfo = snapshot.data!;
                          return Card(
                            elevation: 5,
                            margin: const EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                _buildDrugDetailTile("الاسم العام",
                                    drugInfo['generic_name']?.first),
                                _buildDrugDetailTile("العلامة التجارية",
                                    drugInfo['brand_name']?.first),
                                _buildDrugDetailTile(
                                    "الغرض", drugInfo['purpose']?.first),
                                _buildDrugDetailTile(
                                    "التحذيرات", drugInfo['warnings']?.first),
                                _buildDrugDetailTile(
                                    "الجرعة",
                                    drugInfo['dosage_and_administration']
                                        ?.first),
                              ],
                            ),
                          );
                        }
                        return const Center(
                          child: Text(
                            "لا توجد بيانات",
                            style:
                                TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrugDetailTile(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? 'هذه المعلومة غير متوفره, ستتوفر قريباً',
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
