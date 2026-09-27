import 'package:flutter/material.dart';
import 'package:halalsefllearning/models/exercise_model.dart';
import 'package:halalsefllearning/widgets/exercise/exercise_runner_widget.dart';

class ExerciseScreen extends StatelessWidget {
  final bool isPreTest;
  final String skillTitle;
  final List<ExerciseQuestion>? customQuestions;

  const ExerciseScreen({
    super.key,
    this.isPreTest = false,
    this.skillTitle = 'Inheritance & Polymorphism',
    this.customQuestions,
  });

  @override
  Widget build(BuildContext context) {
    // ชุดข้อมูลตัวอย่างสำหรับทดสอบ 
    final sampleQuestions = customQuestions ?? [
      ExerciseQuestion(
        id: 1,
        skillName: 'Inheritance & Polymorphism',
        level: 2,
        questionText:
            'จากโค้ดด้านล่าง หากเราสร้าง instance ของ Bird และเรียกใช้ method fly() ผลลัพธ์จะเป็นอย่างไร',
        codeLanguage: 'PYTHON',
        codeSnippet: '''class Bird:
    def fly(self):
        return "Flying"

class Penguin(Bird):
    def fly(self):
        return "Cannot fly"

my_bird = Penguin()
print(my_bird.fly())''',
        choices: [
          ExerciseChoice(id: '1', label: 'A', text: 'Flying', isCorrect: false),
          ExerciseChoice(id: '2', label: 'B', text: 'Cannot fly', isCorrect: true),
          ExerciseChoice(id: '3', label: 'C', text: 'Error', isCorrect: false),
          ExerciseChoice(id: '4', label: 'D', text: 'None', isCorrect: false),
        ],
      ),
      ExerciseQuestion(
        id: 2,
        skillName: 'Inheritance & Polymorphism',
        level: 2,
        questionText:
            'Keyword ใดในภาษา Python ที่ใช้สำหรับเรียกใช้งาน Constructor หรือ Method ของคลาสแม่ (Parent class)',
        codeLanguage: 'PYTHON',
        codeSnippet: '''class Animal:
    def __init__(self, name):
        self.name = name

class Dog(Animal):
    def __init__(self, name, breed):
        # บรรทัดนี้ควรเรียกใช้งาน constructor ของ Animal อย่างไร?
        super().__init__(name)
        self.breed = breed''',
        choices: [
          ExerciseChoice(id: '5', label: 'A', text: 'parent()', isCorrect: false),
          ExerciseChoice(id: '6', label: 'B', text: 'super()', isCorrect: true),
          ExerciseChoice(id: '7', label: 'C', text: 'base()', isCorrect: false),
          ExerciseChoice(id: '8', label: 'D', text: 'this()', isCorrect: false),
        ],
      ),
      ExerciseQuestion(
        id: 3,
        skillName: 'Inheritance & Polymorphism',
        level: 2,
        questionText:
            'ข้อใดคือความหมายของ Polymorphism ในการเขียนโปรแกรมเชิงวัตถุ (OOP) ได้ถูกต้องที่สุด',
        choices: [
          ExerciseChoice(
            id: '9',
            label: 'A',
            text: 'การที่อ็อบเจกต์ในคลาสลูกสามารถมีฟังก์ชันชื่อเดียวกันแต่ทำงานต่างกันได้ตามบริบท',
            isCorrect: true,
          ),
          ExerciseChoice(
            id: '10',
            label: 'B',
            text: 'การซ่อนข้อมูลภายในคลาสเพื่อป้องกันการเข้าถึงจากภายนอก',
            isCorrect: false,
          ),
          ExerciseChoice(
            id: '11',
            label: 'C',
            text: 'การสืบทอดคุณสมบัติและเมธอดทั้งหมดจากคลาสหลักมายังคลาสย่อย',
            isCorrect: false,
          ),
          ExerciseChoice(
            id: '12',
            label: 'D',
            text: 'การแปลงประเภทข้อมูลตัวแปรจาก String เป็น Integer อัตโนมัติ',
            isCorrect: false,
          ),
        ],
      ),
    ];

    return ExerciseRunnerWidget(
      questions: sampleQuestions,
      skillTitle: skillTitle,
      isPreTest: isPreTest,
      onExit: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      onFinish: (score, total) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
    );
  }
}
