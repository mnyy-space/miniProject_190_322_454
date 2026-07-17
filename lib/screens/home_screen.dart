import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:halalsefllearning/api/app_api.dart';
import 'package:halalsefllearning/models/skills_model.dart';
import 'package:halalsefllearning/widgets/home_block_widget.dart';
import 'package:halalsefllearning/widgets/skills_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SkillsModel> skillModelStore = [];
  bool isLoading = true;

  void _fetchSkill() async {
    try {
      var response = await AppApi.get("skill");
      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);
        SkillsResponse skillsResponse = SkillsResponse.fromJson(json);

        setState(() {
          skillModelStore = skillsResponse.data;
          isLoading = false;
        });
      } else {
        print("Failed to load skills, status: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching skills: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    _fetchSkill();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วน Header ด้านบน และ Card "Especially For You" ใน Widget ใหม่
            const HomeBlockWidget(),

            const SizedBox(height: 24),

            // หัวข้อ "Topics"
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Topics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ตาราง Grid 2 คอลัมน์แสดงหัวข้อ (Topics/Skills)
            isLoading
                ? const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2894D7),
                      ),
                    ),
                  )
                : skillModelStore.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.folder_open_rounded,
                                size: 54,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "data is not found",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.95,
                        ),
                        itemCount: skillModelStore.length,
                        itemBuilder: (context, index) {
                          final skill = skillModelStore[index];
                          return SkillsCard(skill: skill, index: index);
                        },
                      ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
