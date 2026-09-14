class Persona {
  final int id;
  final String nombre;
  final int edad;

  Persona({required this.id, required this.nombre, required this.edad});

  factory Persona.fromJson(Map<String, dynamic> json) {
    return Persona(id: json['id'], nombre: json['nombre'], edad: json['edad']);
  }
}
