import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vancouver Reference Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ReferenceGenerator(),
    );
  }
}

class ReferenceGenerator extends StatefulWidget {
  const ReferenceGenerator({super.key});

  @override
  _ReferenceGeneratorState createState() => _ReferenceGeneratorState();
}

class _ReferenceGeneratorState extends State<ReferenceGenerator> {
  String _selectedType = 'Bog';
  final Map<String, List<String>> _fields = {
    'Bog': ['Titel', 'Udgave', 'Udgivelsesby', 'Forlagsnavn', 'Udgivelsesår'],
    'E-bog': ['Titel', 'Udgave', 'Udgivelsesby', 'Forlagsnavn', 'Udgivelsesår', 'Henvisnings-dato', 'Link'],
    'Artikel': ['Titel', 'Tidsskriftets navn', 'Udgivelsesdato', 'Volume', 'Issue', 'Sidetal'],
    'Hjemmeside': ['Titel', 'Sidens navn', 'Udgivelsesdato', 'Henvisnings-dato', 'Link'],
  };

  final Map<String, TextEditingController> _controllers = {};
  List<Map<String, TextEditingController>> _authors = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _addAuthor(); // Initialize with one author field
  }

  void _initializeControllers() {
    _fields.forEach((key, value) {
      for (var field in value) {
        _controllers[field] = TextEditingController();
      }
    });
  }

  void _addAuthor() {
    setState(() {
      _authors.add({
        'Efternavn': TextEditingController(),
        'Forbogstav': TextEditingController(),
      });
    });
  }

  void _removeAuthor(int index) {
    setState(() {
      _authors.removeAt(index);
    });
  }

  String _generateReference() {
    List<String> requiredFields = _fields[_selectedType]!;
    Map<String, String> data = {};
    for (var field in requiredFields) {
      data[field] = _controllers[field]!.text;
    }

    String authors = _authors.map((author) {
      return '${author['Efternavn']!.text} ${author['Forbogstav']!.text}.';
    }).join(', ');

    switch (_selectedType) {
      case 'Bog':
        return '$authors ${data['Titel']}. ${data['Udgave']}. udg. ${data['Udgivelsesby']}: ${data['Forlagsnavn']}; ${data['Udgivelsesår']}.';
      case 'E-bog':
        return '$authors ${data['Titel']} [e-bog]. ${data['Udgave']}. udg. ${data['Udgivelsesby']}: ${data['Forlagsnavn']}; ${data['Udgivelsesår']}. [Online]. [Henvist ${data['Henvisnings-dato']}]. Tilgængelig fra: ${data['Link']}';
      case 'Artikel':
        return '$authors ${data['Titel']}. ${data['Tidsskriftets navn']}. ${data['Udgivelsesdato']};${data['Volume']}(${data['Issue']}):${data['Sidetal']}';
      case 'Hjemmeside':
        return '${data['Titel']}. ${data['Sidens navn']} [Internet]. ${data['Udgivelsesdato']} [Henvist ${data['Henvisnings-dato']}]. Tilgængelig fra: ${data['Link']}.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vancouver Reference Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedType,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedType = newValue!;
                });
              },
              items: _fields.keys.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Expanded(
              child: ListView(
                children: [
                  ..._authors.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, TextEditingController> author = entry.value;
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: author['Efternavn'],
                                decoration: const InputDecoration(
                                  labelText: 'Efternavn',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: author['Forbogstav'],
                                decoration: const InputDecoration(
                                  labelText: 'Forbogstav',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle),
                              onPressed: () {
                                _removeAuthor(index);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  }).toList(),
                  ElevatedButton(
                    onPressed: _addAuthor,
                    child: const Text('Tilføj forfatter'),
                  ),
                  const SizedBox(height: 16),
                  ..._fields[_selectedType]!
                      .map((field) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextField(
                              controller: _controllers[field],
                              decoration: InputDecoration(
                                labelText: field,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ))
                      .toList(),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                String reference = _generateReference();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Generated Reference'),
                      content: Text(reference),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Generate Reference'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) {
      controller.dispose();
    });
    for (var author in _authors) {
      author.forEach((key, controller) {
        controller.dispose();
      });
    }
    super.dispose();
  }
}
