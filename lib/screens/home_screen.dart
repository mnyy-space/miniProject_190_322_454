import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:halalsefllearning/widgets/skills_card.dart';
import 'package:halalsefllearning/api/app_api.dart';
import 'package:halalsefllearning/models/skills_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState(); 
  
}

class _HomeScreenState extends State<HomeScreen>{
  List<SkillsModel> skillModelStore = [];
  bool isLoading = true;
  void _fetchSkill() async{
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
  void initState(){
    _fetchSkill();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),

      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : skillModelStore.isEmpty
            ? const Center(child: Text("data is not found"))
            : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1
              ),
              itemCount: skillModelStore.length,
              itemBuilder: (contextm, index){
                final skill = skillModelStore[index];
                return SkillsCard(skill : skill);
              },
            )
      // body: const Center(
      //   child: Text(
      //     'Home Screen', 
      //     style: TextStyle(
      //       fontSize: 24, 
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      // ),
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF156EA7),

//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: const Color(0xFF79FFF3),
//         centerTitle: true,
//         title: const Text(
//           'HALAL Self Learning',
//           style: TextStyle(
//             color: Colors.black87,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Programming Basics',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 8),

//             const Text(
//               'เลือกเลเวลที่ต้องการเรียน',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Color.fromARGB(255, 250, 244, 255),
//               ),
//             ),

//             const SizedBox(height: 24),

//             Expanded(
//               child: GridView.count(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 children: const [
//                   LevelCard(
//                     title: 'Level 1',
//                     subtitle: 'Basic',
//                     icon: Icons.code,
//                   ),
//                   LevelCard(
//                     title: 'Level 2',
//                     subtitle: 'Variables',
//                     icon: Icons.data_object,
//                   ),
//                   LevelCard(
//                     title: 'Level 3',
//                     subtitle: 'Conditions',
//                     icon: Icons.account_tree,
//                   ),
//                   LevelCard(
//                     title: 'Level 4',
//                     subtitle: 'Loops',
//                     icon: Icons.loop,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),

//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: 0,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Account',
//           ),
//         ],
//       ),
//     );
//   }
// }

// class LevelCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final IconData icon;

//   const LevelCard({
//     super.key,
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {},
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               size: 50,
//               color: Colors.green,
//             ),
//             SizedBox(height: 12),
//             Text(
//               title,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 4),
//             Text(
//               subtitle,
//               style: TextStyle(
//                 color: Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: const Color.fromARGB(255, 0, 0, 0),

  //     appBar: AppBar(
  //       title: const Text('Home'),
  //     ),
  //     body: const Center(
  //       child: Text(
  //         'Home Screen', 
  //         style: TextStyle(
  //           fontSize: 24, 
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //     ),
  //   );
  // }
