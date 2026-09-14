import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'persona.dart';

const String _baseUrl = 'http://localhost:5045';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // int _counter = 0;
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();

  // void _incrementCounter() {
  //   setState(() {
  //     _counter++;
  //   });
  // }

  // void _decrementCounter() {
  //   if (_counter > 0) {
  //     setState(() {
  //       _counter--;
  //     });
  //   }
  // }

  List<Persona> _personas = [];
  bool _cargando = false;

  Future<void> _obtenerPersonas() async {
    setState(() {
      _cargando = true;
    });

    final url = Uri.parse('$_baseUrl/personas');
    final respuesta = await http.get(url);

    if (respuesta.statusCode == 200) {
      final List<dynamic> datosJson = jsonDecode(respuesta.body);
      setState(() {
        _personas = datosJson.map((json) => Persona.fromJson(json)).toList();
        _cargando = false;
      });
    } else {
      setState(() {
        _cargando = false;
      });
      throw Exception('Error al obtener las personas: ${respuesta.statusCode}');
    }
  }

  Future<void> _crearPersona(String nombre, int edad) async {
    final url = Uri.parse('$_baseUrl/personas');
    final nuevoId = _personas.isEmpty
        ? 1
        : _personas.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;

    try {
      final respuesta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': nuevoId, 'nombre': nombre, 'edad': edad}),
      );

      if (respuesta.statusCode == 201) {
        _obtenerPersonas();
      } else {
        print('Error al crear: ${respuesta.statusCode}');
        print('Detalle: ${respuesta.body}');
      }
    } catch (e) {
      print('Error al conectar $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _obtenerPersonas();
  }

  void _mostrarFormularioCrear() {
    _nombreController.clear();
    _edadController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nueva Persona'),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _edadController,
                decoration: const InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final nombre = _nombreController.text;
                final edad = int.tryParse(_edadController.text) ?? 0;

                if (nombre.isNotEmpty && edad > 0) {
                  _crearPersona(nombre, edad);
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _personas.length,
              itemBuilder: (context, index) {
                final persona = _personas[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(persona.nombre),
                  subtitle: Text('Edad: ${persona.edad}'),
                );
              },
            ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FloatingActionButton(
            onPressed: _mostrarFormularioCrear,
            tooltip: 'Agregar Persona',
            backgroundColor: Colors.green,
            child: const Icon(Icons.person_add),
          ),
        ],
      ),
    );
  }
}
