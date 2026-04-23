import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class ActivoFormScreen extends StatefulWidget {
  final int ubicacionId;
  final String ubicacionNombre;

  const ActivoFormScreen({super.key, required this.ubicacionId, required this.ubicacionNombre});

  @override
  State<ActivoFormScreen> createState() => _ActivoFormScreenState();
}

class _ActivoFormScreenState extends State<ActivoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  
  File? _image;
  DateTime? _fechaVerificacion;
  final String _estado = 'OPERATIVO';
  bool _enviando = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);

    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.black,
              surface: const Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _fechaVerificacion = picked);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enviando = true);

    String? fechaStr = _fechaVerificacion != null 
        ? DateFormat('yyyy-MM-dd').format(_fechaVerificacion!) 
        : null;

    bool ok = await ApiService.crearActivo(
      nombre: _nombreController.text,
      descripcion: _descController.text,
      ubicacionId: widget.ubicacionId,
      estado: _estado,
      imagen: _image,
      fechaProximaVerificacion: fechaStr,
    );

    setState(() => _enviando = false);

    if (ok) {
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text("✅ ACTIVO REGISTRADO"), backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha:0.8)));
    }
  }

  // Estilo común para los inputs
  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.white24, size: 20),
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFF1E293B),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha:0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha:0.5)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text("REGISTRO DE ACTIVO")),
      body: _enviando 
        ? Center(child: CircularProgressIndicator(color: accentColor))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "UBICACIÓN DESTINO: ${widget.ubicacionNombre.toUpperCase()}", 
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: accentColor, letterSpacing: 1.5)
                  ),
                  const SizedBox(height: 25),
                  
                  // ÁREA DE FOTO TIPO "DROPZONE"
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _image == null ? Colors.white.withValues(alpha:0.1) : accentColor.withValues(alpha:0.5),
                          width: 2,
                          style: _image == null ? BorderStyle.solid : BorderStyle.solid,
                        ),
                      ),
                      child: _image == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined, size: 40, color: accentColor),
                                const SizedBox(height: 12),
                                const Text("CAPTURAR IMAGEN DEL ACTIVO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54)),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.file(_image!, fit: BoxFit.cover),
                            ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  TextFormField(
                    controller: _nombreController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputStyle("Nombre del Activo", Icons.inventory_2_outlined),
                    validator: (v) => v!.isEmpty ? "Este campo es obligatorio" : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _descController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: _inputStyle("Descripción técnica o notas", Icons.description_outlined),
                  ),
                  const SizedBox(height: 16),
                  
                  // SELECTOR FECHA
                  InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha:0.05)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, color: accentColor, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            _fechaVerificacion == null 
                                ? "PROGRAMAR VERIFICACIÓN" 
                                : "PRÓXIMA REVISIÓN: ${DateFormat('dd/MM/yyyy').format(_fechaVerificacion!)}",
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _guardar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text("FINALIZAR REGISTRO", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}