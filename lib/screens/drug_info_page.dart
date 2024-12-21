import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:async';

import '../constants/colors_page.dart';
import '../constants/theme_dark_mode.dart';
import '../widgets/custom_text_fieled.dart';

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
            suggestions.add(drug['brand_name'][0] ?? '203'.tr);
          }
        }
        return suggestions;
      } else {
        return [];
      }
    } else {
      throw Exception('204'.tr);
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
        throw Exception('205'.tr);
      }
    } else {
      throw Exception('206'.tr);
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '207'.tr,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: themeProvider.isDarkMode
                  ? [Colors.blueGrey, Colors.blueGrey.shade700]
                  : [AppColors.primaryColor, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _controller,
              text: '208'.tr,
              icon: const Icon(Icons.medical_information),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: searchDrug,
                icon: const Icon(Icons.medical_services),
                label: Text(
                  '209'.tr,
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDarkMode ? Colors.teal : const Color(0xFF1E88E5),
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
                  color: isDarkMode ? Colors.grey[800] : Colors.grey.shade200,
                  border: Border.all(
                      color: isDarkMode ? Colors.grey[700]! : Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ListView.builder(
                  itemCount: drugSuggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        drugSuggestions[index],
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
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
                  ? Center(
                      child: Text(
                        '210'.tr,
                        style: const TextStyle(fontSize: 16),
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
                          return Center(
                            child: Text(
                              '211'.tr,
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        } else if (snapshot.hasData) {
                          var drugInfo = snapshot.data!;
                          return Card(
                            elevation: 5,
                            color: isDarkMode ? Colors.grey[850] : Colors.white,
                            margin: const EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                _buildDrugDetailTile(
                                    '212'.tr,
                                    drugInfo['generic_name']?.first,
                                    isDarkMode),
                                _buildDrugDetailTile('213'.tr,
                                    drugInfo['brand_name']?.first, isDarkMode),
                                _buildDrugDetailTile('214'.tr,
                                    drugInfo['purpose']?.first, isDarkMode),
                                _buildDrugDetailTile('215'.tr,
                                    drugInfo['warnings']?.first, isDarkMode),
                                _buildDrugDetailTile(
                                    '216'.tr,
                                    drugInfo['dosage_and_administration']
                                        ?.first,
                                    isDarkMode),
                              ],
                            ),
                          );
                        }
                        return Center(
                          child: Text(
                            '217'.tr,
                            style: const TextStyle(fontSize: 16),
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

  Widget _buildDrugDetailTile(String title, String? value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDarkMode ? Colors.tealAccent : AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? '218'.tr,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
