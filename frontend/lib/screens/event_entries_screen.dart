import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/event_entry.dart';
import '../models/event.dart';

class EventEntriesScreen extends StatefulWidget {
  @override
  _EventEntriesScreenState createState() => _EventEntriesScreenState();
}

class _EventEntriesScreenState extends State<EventEntriesScreen> {
  late Future<Event> _activeEvent;
  late Future<List<EventEntry>> _entries;
  bool _isLoadingEntries = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _activeEvent = ApiService().getActiveEvent();

    _activeEvent.then((event) {
      setState(() {
        _entries = ApiService().getEventEntries(event.id);
        _isLoadingEntries = false;
      });
    }).catchError((error) {
      setState(() {
        _isLoadingEntries = false;
      });
    });
  }

  void _refreshData() {
    setState(() {
      _isLoadingEntries = true;
      _loadData();
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getMethodIcon(String method) {
    switch (method) {
      case 'qrcode':
        return '📱';
      case 'nfc':
        return '📡';
      case 'manual':
        return '⌨️';
      default:
        return '✓';
    }
  }

  String _getMethodName(String method) {
    switch (method) {
      case 'qrcode':
        return 'QR Code';
      case 'nfc':
        return 'NFC';
      case 'manual':
        return 'Manual';
      default:
        return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entradas do Evento'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: FutureBuilder<Event>(
        future: _activeEvent,
        builder: (context, eventSnapshot) {
          if (eventSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (eventSnapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Erro ao carregar evento',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    eventSnapshot.error.toString().replaceAll('Exception: ', ''),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          final event = eventSnapshot.data!;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade700, Colors.orange.shade900],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (event.description != null) ...[
                      SizedBox(height: 8),
                      Text(
                        event.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.white70),
                        SizedBox(width: 8),
                        Text(
                          _formatDateTime(event.startDate),
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    if (event.location != null) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.white70),
                          SizedBox(width: 8),
                          Text(
                            event.location!,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: _isLoadingEntries
                    ? Center(child: CircularProgressIndicator())
                    : FutureBuilder<List<EventEntry>>(
                        future: _entries,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                                  SizedBox(height: 16),
                                  Text(
                                    'Erro ao carregar entradas',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            );
                          }

                          final entries = snapshot.data!;

                          if (entries.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Nenhuma entrada registrada',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                color: Colors.grey.shade100,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total de Entradas:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        entries.length.toString(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: entries.length,
                                  padding: EdgeInsets.all(8),
                                  itemBuilder: (context, index) {
                                    final entry = entries[index];
                                    return Card(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      elevation: 2,
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.orange.shade100,
                                          child: Text(
                                            entry.user?.name.substring(0, 1).toUpperCase() ?? '?',
                                            style: TextStyle(
                                              color: Colors.orange.shade900,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          entry.user?.name ?? 'Desconhecido',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 4),
                                            Text(entry.user?.email ?? ''),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  size: 14,
                                                  color: Colors.grey.shade600,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  _formatDateTime(entry.entryTime),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        trailing: Tooltip(
                                          message: _getMethodName(entry.entryMethod),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getMethodColor(entry.entryMethod)
                                                  .withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: _getMethodColor(entry.entryMethod),
                                              ),
                                            ),
                                            child: Text(
                                              _getMethodIcon(entry.entryMethod),
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ),
                                        ),
                                        isThreeLine: true,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getMethodColor(String method) {
    switch (method) {
      case 'qrcode':
        return Colors.blue;
      case 'nfc':
        return Colors.purple;
      case 'manual':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
