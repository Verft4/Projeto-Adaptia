// lib/pages/classes_page.dart

import 'package:flutter/material.dart';

class StudentModel {
  String personaName;
  String diagnosis;
  int age;

  StudentModel({
    required this.personaName,
    required this.diagnosis,
    required this.age,
  });
}

class ClassModel {
  String name;
  String institution;
  String grade;
  List<StudentModel> students;

  ClassModel({
    required this.name,
    required this.institution,
    required this.grade,
    this.students = const [],
  });
}

class ClassesPage extends StatefulWidget {
  const ClassesPage({super.key});

  @override
  State<ClassesPage> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  final List<ClassModel> classes = [];

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  void _applySearch() {
    setState(() {
      searchQuery = searchController.text.toLowerCase();
    });
  }

  void _openCreateClassDialog() {
    final nameController = TextEditingController();
    final institutionController = TextEditingController();
    final gradeController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nova turma'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome')),
            TextField(controller: institutionController, decoration: const InputDecoration(labelText: 'Instituição')),
            TextField(controller: gradeController, decoration: const InputDecoration(labelText: 'Ano')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty ||
                  institutionController.text.isEmpty ||
                  gradeController.text.isEmpty) return;

              setState(() {
                classes.add(ClassModel(
                  name: nameController.text,
                  institution: institutionController.text,
                  grade: gradeController.text,
                  students: [],
                ));
              });

              Navigator.pop(dialogContext);
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(ClassModel c, int index) {
    return Card(
      child: ListTile(
        title: Text(c.name),
        subtitle: Text('${c.institution} • ${c.grade}º'),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClassDetailPage(
                classModel: c,
                onDelete: () {
                  setState(() => classes.removeAt(index));
                },
                onUpdate: () => setState(() {}),
              ),
            ),
          );
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredClasses = classes.where((c) {
      if (searchQuery.isEmpty) return true;

      return c.name.toLowerCase().contains(searchQuery) ||
          c.institution.toLowerCase().contains(searchQuery);
    }).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateClassDialog,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Minhas turmas',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar turmas',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _applySearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _applySearch(),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: filteredClasses.isEmpty
                  ? const Center(child: Text('Nenhum resultado encontrado'))
                  : ListView.builder(
                      itemCount: filteredClasses.length,
                      itemBuilder: (_, i) {
                        final c = filteredClasses[i];
                        final index = classes.indexOf(c);
                        return _buildClassCard(c, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClassDetailPage extends StatefulWidget {
  final ClassModel classModel;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const ClassDetailPage({
    super.key,
    required this.classModel,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<ClassDetailPage> createState() => _ClassDetailPageState();
}

class _ClassDetailPageState extends State<ClassDetailPage> {

  void _editClass() {
    final name = TextEditingController(text: widget.classModel.name);
    final inst = TextEditingController(text: widget.classModel.institution);
    final grade = TextEditingController(text: widget.classModel.grade);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar turma'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome')),
            TextField(controller: inst, decoration: const InputDecoration(labelText: 'Instituição')),
            TextField(controller: grade, decoration: const InputDecoration(labelText: 'Ano')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              widget.classModel.name = name.text;
              widget.classModel.institution = inst.text;
              widget.classModel.grade = grade.text;

              widget.onUpdate();
              setState(() {});
              Navigator.pop(dialogContext);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _addStudent() {
    final name = TextEditingController();
    final diagnosis = TextEditingController();
    final age = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Novo aluno'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome da persona')),
            TextField(controller: diagnosis, decoration: const InputDecoration(labelText: 'Diagnóstico')),
            TextField(controller: age, decoration: const InputDecoration(labelText: 'Idade')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              widget.classModel.students.add(
                StudentModel(
                  personaName: name.text,
                  diagnosis: diagnosis.text,
                  age: int.tryParse(age.text) ?? 0,
                ),
              );
              widget.onUpdate();
              setState(() {});
              Navigator.pop(dialogContext);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _editStudent(int index) {
    final student = widget.classModel.students[index];

    final name = TextEditingController(text: student.personaName);
    final diagnosis = TextEditingController(text: student.diagnosis);
    final age = TextEditingController(text: student.age.toString());

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar aluno'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name),
            TextField(controller: diagnosis),
            TextField(controller: age),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              student.personaName = name.text;
              student.diagnosis = diagnosis.text;
              student.age = int.tryParse(age.text) ?? 0;

              widget.onUpdate();
              setState(() {});
              Navigator.pop(dialogContext);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _removeStudent(int index) {
    setState(() {
      widget.classModel.students.removeAt(index);
    });
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.classModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(c.name),
        actions: [
          IconButton(
            onPressed: _editClass,
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              widget.onDelete();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStudent,
        child: const Icon(Icons.person_add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.institution),
            Text('${c.grade}º ano'),
            const SizedBox(height: 16),

            const Text('Alunos', style: TextStyle(fontWeight: FontWeight.bold)),

            Expanded(
              child: ListView.builder(
                itemCount: c.students.length,
                itemBuilder: (_, i) {
                  final s = c.students[i];
                  return ListTile(
                    title: Text(s.personaName),
                    subtitle: Text('${s.diagnosis} • ${s.age} anos'),
                    onTap: () => _editStudent(i),
                    onLongPress: () => _removeStudent(i),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}