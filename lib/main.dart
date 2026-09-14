import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'persona.dart';

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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    if (_counter > 0) {
      setState(() {
        _counter--;
      });
    }
  }

  List<Persona> _personas = [];
  bool _cargando = false;

  Future<void> _obtenerPersonas() async {
    setState(() {
      _cargando = true;
    });

    final url = Uri.parse('http://localhost:5045/personas');
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

  @override
  void initState() {
    super.initState();
    _obtenerPersonas();
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
    );
  }
}
