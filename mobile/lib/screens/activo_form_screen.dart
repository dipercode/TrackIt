import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class ActivoFormScreen extends StatefulWidget {
  final int ubicacionId;
  final String ubicacionNombre;
  final Map<String, dynamic>? activoParaEditar; 

  const ActivoFormScreen({
    super.key, 
    required this.ubicacionId, 
    required this.ubicacionNombre,
    this.activoParaEditar, 
  });

  @override
  State<ActivoFormScreen> createState() => _ActivoFormScreenState();
}

class _ActivoFormScreenState extends State<ActivoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nombreController;
  late TextEditingController _descController;
  late TextEditingController _qrController; 
  
  File? _image;
  File? _docImage; // NUEVO: Para la foto del documento/certificado
  DateTime? _fechaVerificacion;
  String _estado = 'OPERATIVO';
  bool _requiereCalibracion = false;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    final activo = widget.activoParaEditar;
    
    _nombreController = TextEditingController(text: activo != null ? activo['nombre'] : "");
    _descController = TextEditingController(text: activo != null ? activo['descripcion'] : "");
    _qrController = TextEditingController(text: activo != null ? activo['codigo_qr'] : "");
    
    if (activo != null) {
      _estado = activo['estado'] ?? 'OPERATIVO';
      _requiereCalibracion = activo['requiere_calibracion'] ?? false;
      if (activo['fecha_proxima_verificacion'] != null) {
        _fechaVerificacion = DateTime.parse(activo['fecha_proxima_verificacion']);
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descController.dispose();
    _qrController.dispose();
    super.dispose();
  }

  // MODIFICADO: Ahora acepta un parámetro para saber qué imagen capturar
  Future<void> _pickImage(bool isDocument) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        if (isDocument) {
          _docImage = File(pickedFile.path);
        } else {
          _image = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaVerificacion ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _fechaVerificacion = picked);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enviando = true);

    String? fechaStr = _fechaVerificacion != null 
        ? DateFormat('yyyy-MM-dd').format(_fechaVerificacion!) 
        : null;

    bool ok;
    if (widget.activoParaEditar != null) {
      ok = await ApiService.actualizarActivo(
        id: widget.activoParaEditar!['id'],
        nombre: _nombreController.text,
        descripcion: _descController.text,
        ubicacionId: widget.ubicacionId,
        estado: _estado,
        fechaProximaVerificacion: fechaStr,
        requiereCalibracion: _requiereCalibracion,
        codigoQr: _qrController.text,
        imagenCalibracion: _docImage, // Se envía si se capturó una nueva
      );
    } else {
      ok = await ApiService.crearActivo(
        nombre: _nombreController.text,
        descripcion: _descController.text,
        ubicacionId: widget.ubicacionId,
        estado: _estado,
        imagen: _image,
        imagenCalibracion: _docImage, // También disponible en creación
        fechaProximaVerificacion: fechaStr,
      );
    }

    if (!mounted) return;
    setState(() => _enviando = false);

    if (ok) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.activoParaEditar != null ? "✅ DATOS ACTUALIZADOS" : "✅ ACTIVO REGISTRADO"), 
          backgroundColor: const Color(0xFF2C74A4)
        )
      );
    }
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      alignLabelWithHint: true,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      prefixIcon: Icon(icon, color: const Color(0xFF546E7A).withValues(alpha: 0.5), size: 20),
      labelStyle: const TextStyle(color: Color(0xFF546E7A), fontSize: 16, fontWeight: FontWeight.bold),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.03)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF2C74A4); 
    const backgroundColor = Color(0xFFD4E3EB); 
    final esEdicion = widget.activoParaEditar != null;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF263238)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          esEdicion ? "GESTIONAR ACTIVO" : "NUEVO ACTIVO",
          style: const TextStyle(color: Color(0xFF263238), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _enviando 
        ? const Center(child: CircularProgressIndicator(color: accentColor))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "UBICACIÓN DESTINO: ${widget.ubicacionNombre.toUpperCase()}", 
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: accentColor, letterSpacing: 1.2)
                  ),
                  const SizedBox(height: 25),
                  
                  // FOTO PRINCIPAL DEL ACTIVO
                  if (!esEdicion) ...[
                    _buildFotoSelector(
                      file: _image, 
                      label: "FOTO DEL ACTIVO", 
                      icon: Icons.camera_alt_rounded,
                      onTap: () => _pickImage(false)
                    ),
                    const SizedBox(height: 30),
                  ],

                  _buildShadowWrapper(
                    TextFormField(
                      controller: _nombreController,
                      style: const TextStyle(color: Color(0xFF263238), fontWeight: FontWeight.w600),
                      decoration: _inputStyle("Nombre del Activo", Icons.inventory_2_outlined),
                      validator: (v) => v!.isEmpty ? "Este campo es obligatorio" : null,
                    ),
                  ),
                  const SizedBox(height: 25),

                  _buildShadowWrapper(
                    TextFormField(
                      controller: _descController,
                      style: const TextStyle(color: Color(0xFF263238)),
                      maxLines: 3,
                      decoration: _inputStyle("Descripción técnica", Icons.description_outlined),
                    ),
                  ),
                  const SizedBox(height: 25),

                  if (esEdicion) ...[
                    _buildShadowWrapper(
                      TextFormField(
                        controller: _qrController,
                        style: const TextStyle(color: Color(0xFF263238), fontWeight: FontWeight.bold),
                        decoration: _inputStyle("Código QR / Identificador", Icons.qr_code_2_rounded),
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],

                  // SECCIÓN DE CALIBRACIÓN
                  _buildShadowWrapper(
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: SwitchListTile(
                        title: const Text("¿Requiere Calibración?", 
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF263238))),
                        subtitle: Text("Activa para programar alertas de revisión", 
                          style: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.4))),
                        value: _requiereCalibracion,
                        activeThumbColor: accentColor,
                        onChanged: (val) => setState(() => _requiereCalibracion = val),
                      ),
                    ),
                  ),

                  if (_requiereCalibracion) ...[
                    const SizedBox(height: 15),
                    // Selector de fecha
                    _buildShadowWrapper(
                      InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded, color: accentColor, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("FECHA PRÓXIMA REVISIÓN", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                    Text(
                                      _fechaVerificacion == null ? "Seleccionar fecha..." : DateFormat('dd/MM/yyyy').format(_fechaVerificacion!),
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.edit_calendar, size: 20, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // NUEVO: Selector de foto del documento de calibración
                    const Text("COMPROBANTE DE CALIBRACIÓN (FOTO)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: accentColor)),
                    const SizedBox(height: 8),
                    _buildFotoSelector(
                      file: _docImage, 
                      label: "TOMAR FOTO DEL DOCUMENTO", 
                      icon: Icons.file_present_rounded,
                      height: 120,
                      onTap: () => _pickImage(true)
                    ),
                  ],

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _guardar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      child: Text(
                        esEdicion ? "ACTUALIZAR ACTIVO" : "FINALIZAR REGISTRO", 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
    );
  }

  // Widget auxiliar para los selectores de fotos
  Widget _buildFotoSelector({required File? file, required String label, required IconData icon, double height = 160, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: file == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 30, color: Colors.grey.withValues(alpha: 0.5)),
                  const SizedBox(height: 8),
                  Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(file, fit: BoxFit.cover),
              ),
      ),
    );
  }

  Widget _buildShadowWrapper(Widget child) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))
        ],
      ),
      child: child,
    );
  }
}