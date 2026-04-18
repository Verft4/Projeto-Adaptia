import 'package:flutter/material.dart';

class StudentModel {
  String personaName;
  String diagnosis;
  String observations;
  int age;

  StudentModel({
    required this.personaName,
    required this.diagnosis,
    required this.observations,
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
    final name = TextEditingController();
    final inst = TextEditingController();
    final grade = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova turma'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome da turma')),
            TextField(controller: inst, decoration: const InputDecoration(labelText: 'Instituição')),
            TextField(controller: grade, decoration: const InputDecoration(labelText: 'Ano')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (name.text.trim().isEmpty ||
                  inst.text.trim().isEmpty ||
                  grade.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preencha todos os campos')),
                );
                return;
              }

              setState(() {
                classes.add(ClassModel(
                  name: name.text,
                  institution: inst.text,
                  grade: grade.text,
                  students: [],
                ));
              });
              Navigator.pop(ctx);
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(ClassModel c, int index) {
    return GestureDetector(
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF3F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(c.institution),
            Text('${c.grade}º do fundamental'),
            Text('${c.students.length} alunos'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = classes.where((c) {
      if (searchQuery.isEmpty) return true;
      return c.name.toLowerCase().contains(searchQuery) ||
          c.institution.toLowerCase().contains(searchQuery);
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 50, left: 16, bottom: 16),
                color: Colors.blue,
                child: const Text(
                  'Minhas turmas',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar turmas',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: _applySearch,
                          ),
                        ),
                        onSubmitted: (_) => _applySearch(),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final c = filtered[i];
                            final index = classes.indexOf(c);
                            return _buildCard(c, index);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              onPressed: _openCreateClassDialog,
              child: const Icon(Icons.add),
            ),
          )
        ],
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
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  void _applySearch() {
    setState(() {
      searchQuery = searchController.text.toLowerCase();
    });
  }

  void _addStudent() {
    final name = TextEditingController();
    final age = TextEditingController();
    final otherDiagnosis = TextEditingController();
    final observations = TextEditingController();

    final options = ['TDAH', 'TEA', 'Dislexia', 'Discalculia', 'Altas habilidades', 'Outro'];
    final Map<String, bool> selected = {for (var o in options) o: false};

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Novo aluno'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome da persona')),
                const SizedBox(height: 12),
                const Align(alignment: Alignment.centerLeft, child: Text('Diagnóstico')),
                ...options.map((o) => CheckboxListTile(
                      title: Text(o),
                      value: selected[o],
                      onChanged: (v) {
                        setStateDialog(() {
                          selected[o] = v!;
                        });
                      },
                    )),
                if (selected['Outro'] == true)
                  TextField(controller: otherDiagnosis, decoration: const InputDecoration(labelText: 'Outro diagnóstico')),
                TextField(controller: age, decoration: const InputDecoration(labelText: 'Idade')),
                TextField(controller: observations, maxLines: 4, decoration: const InputDecoration(labelText: 'Observações')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (name.text.trim().isEmpty ||
                    age.text.trim().isEmpty ||
                    !selected.containsValue(true)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
                  );
                  return;
                }

                if (selected['Outro'] == true && otherDiagnosis.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Informe o diagnóstico em "Outro"')),
                  );
                  return;
                }

                final selectedList = selected.entries
                    .where((e) => e.value && e.key != 'Outro')
                    .map((e) => e.key)
                    .toList();

                if (selected['Outro'] == true) {
                  selectedList.add(otherDiagnosis.text);
                }

                widget.classModel.students.add(
                  StudentModel(
                    personaName: name.text,
                    diagnosis: selectedList.join(', '),
                    observations: observations.text,
                    age: int.tryParse(age.text) ?? 0,
                  ),
                );

                widget.onUpdate();
                setState(() {});
                Navigator.pop(ctx);
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  void _editStudent(int index) {
    final student = widget.classModel.students[index];

    final name = TextEditingController(text: student.personaName);
    final age = TextEditingController(text: student.age.toString());
    final observations = TextEditingController(text: student.observations);
    final otherDiagnosis = TextEditingController();

    final options = ['TDAH', 'TEA', 'Dislexia', 'Discalculia', 'Altas habilidades', 'Outro'];
    final selected = {for (var o in options) o: false};

    final currentDiagnoses = student.diagnosis.split(', ');

    for (var d in currentDiagnoses) {
      if (options.contains(d)) {
        selected[d] = true;
      } else {
        selected['Outro'] = true;
        otherDiagnosis.text = d;
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Editar aluno'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome da persona')),
                const SizedBox(height: 12),
                const Align(alignment: Alignment.centerLeft, child: Text('Diagnóstico')),
                ...options.map((o) => CheckboxListTile(
                      title: Text(o),
                      value: selected[o],
                      onChanged: (v) {
                        setStateDialog(() {
                          selected[o] = v!;
                        });
                      },
                    )),
                if (selected['Outro'] == true)
                  TextField(controller: otherDiagnosis, decoration: const InputDecoration(labelText: 'Outro diagnóstico')),
                TextField(controller: age, decoration: const InputDecoration(labelText: 'Idade')),
                TextField(controller: observations, maxLines: 4, decoration: const InputDecoration(labelText: 'Observações')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (name.text.trim().isEmpty ||
                    age.text.trim().isEmpty ||
                    !selected.containsValue(true)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
                  );
                  return;
                }

                if (selected['Outro'] == true && otherDiagnosis.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Informe o diagnóstico em "Outro"')),
                  );
                  return;
                }

                final selectedList = selected.entries
                    .where((e) => e.value && e.key != 'Outro')
                    .map((e) => e.key)
                    .toList();

                if (selected['Outro'] == true) {
                  selectedList.add(otherDiagnosis.text);
                }

                student.personaName = name.text;
                student.diagnosis = selectedList.join(', ');
                student.observations = observations.text;
                student.age = int.tryParse(age.text) ?? 0;

                widget.onUpdate();
                setState(() {});
                Navigator.pop(ctx);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _studentCard(StudentModel s, int index) {
    return GestureDetector(
      onTap: () => _editStudent(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF3F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.personaName, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(s.diagnosis),
            Text('${s.age} anos'),
            if (s.observations.isNotEmpty) Text('Obs: ${s.observations}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.classModel;

    final filtered = c.students.where((s) {
      if (searchQuery.isEmpty) return true;
      return s.personaName.toLowerCase().contains(searchQuery) ||
          s.diagnosis.toLowerCase().contains(searchQuery);
    }).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addStudent,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back, size: 18),
                    SizedBox(width: 6),
                    Text('Voltar', style: TextStyle(color: Colors.blue)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Detalhes da Turma', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(),
              Text(c.institution),
              Text('${c.grade}º do fundamental'),
              const SizedBox(height: 16),
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar alunos',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _applySearch,
                  ),
                ),
                onSubmitted: (_) => _applySearch(),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final originalIndex = c.students.indexOf(filtered[i]);
                    return _studentCard(filtered[i], originalIndex);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}