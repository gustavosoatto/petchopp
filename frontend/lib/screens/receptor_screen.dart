import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../services/api_service.dart';
import '../models/event_entry.dart';
import 'event_entries_screen.dart';

class ReceptorScreen extends StatefulWidget {
  @override
  _ReceptorScreenState createState() => _ReceptorScreenState();
}

class _ReceptorScreenState extends State<ReceptorScreen> with TickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  bool _isNfcAvailable = false;
  bool _isNfcReading = false;
  String? _statusMessage;
  Color? _statusColor;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _checkNfcAvailability();
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _codeController.dispose();
    if (_isNfcReading) {
      NfcManager.instance.stopSession();
    }
    super.dispose();
  }

  Future<void> _checkNfcAvailability() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    setState(() {
      _isNfcAvailable = isAvailable;
    });
  }

  Future<void> _startNfcReading() async {
    if (!_isNfcAvailable) {
      _showMessage('NFC não disponível neste dispositivo', Color(0xFFEF4444));
      return;
    }

    setState(() {
      _isNfcReading = true;
      _statusMessage = 'Aproxime o cartão NFC...';
      _statusColor = Color(0xFF8B5CF6);
    });

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        var nfcId = tag.data['nfca']?['identifier'] ??
                    tag.data['nfcb']?['identifier'] ??
                    tag.data['nfcf']?['identifier'] ??
                    tag.data['nfcv']?['identifier'];

        if (nfcId != null) {
          String tagId = nfcId.map((e) => e.toRadixString(16).padLeft(2, '0')).join('');
          await _processCheckIn(tagId, 'nfc');
        }
      } catch (e) {
        _showMessage('Erro ao ler NFC: $e', Color(0xFFEF4444));
      } finally {
        NfcManager.instance.stopSession();
        setState(() {
          _isNfcReading = false;
        });
      }
    });
  }

  void _stopNfcReading() {
    NfcManager.instance.stopSession();
    setState(() {
      _isNfcReading = false;
      _statusMessage = null;
    });
  }

  Future<void> _scanQRCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRScannerScreen()),
    );

    if (result != null) {
      await _processCheckIn(result, 'qrcode');
    }
  }

  Future<void> _manualCheckIn() async {
    if (_codeController.text.isEmpty) {
      _showMessage('Digite um código válido', Color(0xFFF59E0B));
      return;
    }

    await _processCheckIn(_codeController.text, 'manual');
    _codeController.clear();
  }

  Future<void> _processCheckIn(String code, String method) async {
    try {
      setState(() {
        _statusMessage = 'Processando...';
        _statusColor = Color(0xFF6366F1);
      });

      final entry = await ApiService().checkInByCode(code, method);

      setState(() {
        _statusMessage = 'Check-in realizado com sucesso!';
        _statusColor = Color(0xFF10B981);
      });

      _showSuccessDialog(entry);
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      _showMessage(errorMsg, Color(0xFFEF4444));
    }
  }

  void _showMessage(String message, Color color) {
    setState(() {
      _statusMessage = message;
      _statusColor = color;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Color(0xFF10B981) ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 3),
      ),
    );

    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _statusMessage = null;
          _statusColor = null;
        });
      }
    });
  }

  void _showSuccessDialog(EventEntry entry) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFF10B981).withOpacity(0.05)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF10B981).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 64,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Check-in Realizado!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 24),
              _buildInfoRow('Participante', entry.user?.name ?? 'N/A', Icons.person),
              SizedBox(height: 12),
              _buildInfoRow('Email', entry.user?.email ?? 'N/A', Icons.email),
              SizedBox(height: 12),
              _buildInfoRow(
                'Horário',
                '${entry.entryTime.day.toString().padLeft(2, '0')}/${entry.entryTime.month.toString().padLeft(2, '0')}/${entry.entryTime.year} ${entry.entryTime.hour.toString().padLeft(2, '0')}:${entry.entryTime.minute.toString().padLeft(2, '0')}',
                Icons.access_time,
              ),
              SizedBox(height: 12),
              _buildInfoRow('Método', _getMethodName(entry.entryMethod), _getMethodIcon(entry.entryMethod)),
              SizedBox(height: 32),
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF10B981), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMethodName(String method) {
    switch (method) {
      case 'qrcode':
        return 'QR Code';
      case 'nfc':
        return 'NFC';
      case 'manual':
        return 'Código Manual';
      default:
        return method;
    }
  }

  IconData _getMethodIcon(String method) {
    switch (method) {
      case 'qrcode':
        return Icons.qr_code_2;
      case 'nfc':
        return Icons.nfc;
      case 'manual':
        return Icons.keyboard;
      default:
        return Icons.check;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Receptor'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.list_alt),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventEntriesScreen()),
                );
              },
              tooltip: 'Ver entradas',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.verified_user,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 24),
                Text(
                  'Validar Entrada',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Escolha o método de validação',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 32),
                if (_statusMessage != null)
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _statusColor?.withOpacity(0.3) ?? Colors.transparent,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _statusColor == Color(0xFF10B981) ? Icons.check_circle :
                          _statusColor == Color(0xFFEF4444) ? Icons.error :
                          Icons.info,
                          color: _statusColor,
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _statusMessage!,
                            style: TextStyle(
                              color: _statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                _buildMethodButton(
                  icon: Icons.qr_code_scanner,
                  title: 'Escanear QR Code',
                  subtitle: 'Ler QR Code do participante',
                  gradient: LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
                  onTap: _scanQRCode,
                ),
                SizedBox(height: 16),
                _buildMethodButton(
                  icon: Icons.nfc,
                  title: 'Ler NFC',
                  subtitle: _isNfcAvailable
                      ? (_isNfcReading ? 'Aproxime o cartão...' : 'Aproximar cartão NFC')
                      : 'NFC não disponível',
                  gradient: LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
                  onTap: _isNfcReading ? _stopNfcReading : _startNfcReading,
                  enabled: _isNfcAvailable,
                  isActive: _isNfcReading,
                ),
                SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.keyboard, color: Color(0xFF10B981), size: 24),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Código Manual',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          labelText: 'Código de Entrada',
                          hintText: 'Digite o código',
                          prefixIcon: Icon(Icons.tag, color: Color(0xFF10B981)),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _manualCheckIn(),
                      ),
                      SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _manualCheckIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Validar Código',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
    bool enabled = true,
    bool isActive = false,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(30 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (enabled)
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              decoration: BoxDecoration(
                gradient: enabled ? gradient : LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade400]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, size: 32, color: Colors.white),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isActive)
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                          CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      Navigator.pop(context, scanData.code);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Escanear QR Code'),
        backgroundColor: Colors.black.withOpacity(0.3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Color(0xFF3B82F6),
              borderRadius: 16,
              borderLength: 40,
              borderWidth: 8,
              cutOutSize: 280,
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Posicione o QR Code dentro do quadro',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
