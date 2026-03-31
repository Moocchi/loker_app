import 'package:flutter/material.dart';

import 'models/locker_status.dart';
import 'services/locker_api_service.dart';

void main() {
  runApp(const LokerApp());
}

class LokerApp extends StatelessWidget {
  const LokerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Loker',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF2F6F9),
      ),
      home: const LokerPage(),
    );
  }
}

class LokerPage extends StatelessWidget {
  const LokerPage({super.key});

  // Android emulator: http://10.0.2.2:5000
  // HP fisik: ganti ke IP laptop kamu, contoh http://192.168.1.20:5000
  static const String _backendBaseUrl = 'http://192.168.60.126:5000';

  @override
  Widget build(BuildContext context) {
    final LockerApiService apiService =
        LockerApiService(baseUrl: _backendBaseUrl);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Loker',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E2C40),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: FutureBuilder<List<LockerStatus>>(
                  future: apiService.fetchLockers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Gagal konek ke backend',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E2C40),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              snapshot.error.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 10),
                            FilledButton(
                              onPressed: () {
                                (context as Element).markNeedsBuild();
                              },
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      );
                    }

                    final List<LockerStatus> lockers =
                        _normalizeTo12(snapshot.data ?? const []);

                    return RefreshIndicator(
                      onRefresh: () async {
                        (context as Element).markNeedsBuild();
                        await apiService.fetchLockers();
                      },
                      child: GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: lockers.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1,
                            ),
                        itemBuilder: (context, index) {
                          final LockerStatus locker = lockers[index];
                          return _LokerTile(
                            number: locker.id,
                            isOpen: locker.isOpen,
                          );
                        },
                      ),
                    );
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

class _LokerTile extends StatelessWidget {
  const _LokerTile({required this.number, required this.isOpen});

  final int number;
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$number',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E2C40),
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOpen
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              isOpen ? 'Terbuka' : 'Tertutup',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isOpen
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFDC2626),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<LockerStatus> _normalizeTo12(List<LockerStatus> source) {
  final Map<int, LockerStatus> mapById = <int, LockerStatus>{
    for (final LockerStatus item in source) item.id: item,
  };

  return List<LockerStatus>.generate(12, (index) {
    final int id = index + 1;
    return mapById[id] ?? LockerStatus(id: id, isLocked: true);
  });
}
