import 'package:flutter/material.dart';

void main() {
  runApp(const Hisaabee());
}

class Hisaabee extends StatelessWidget {
  const Hisaabee({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hisaabee',
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const RoleScreen(),
    );
  }
}

class Firm {
  final String name;
  final String city;
  final String area;
  final List<String> services;
  final String phone;

  const Firm({
    required this.name,
    required this.city,
    required this.area,
    required this.services,
    required this.phone,
  });
}

// Sample data only. Later this list will come from the server.
const List<Firm> firms = [
  Firm(
    name: 'Sharma & Associates',
    city: 'Pune',
    area: 'Kothrud',
    services: ['GST', 'Income Tax', 'Audit'],
    phone: '9000000001',
  ),
  Firm(
    name: 'Patil Tax Consultants',
    city: 'Nashik',
    area: 'College Road',
    services: ['Income Tax', 'Balance Sheets'],
    phone: '9000000002',
  ),
  Firm(
    name: 'Deshmukh Accounting Services',
    city: 'Nagpur',
    area: 'Dharampeth',
    services: ['Accounting', 'GST', 'Payroll'],
    phone: '9000000003',
  ),
  Firm(
    name: 'Kulkarni & Co.',
    city: 'Mumbai',
    area: 'Andheri East',
    services: ['Audit', 'Project Reports', 'GST'],
    phone: '9000000004',
  ),
];

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.account_balance, size: 72, color: primary),
              const SizedBox(height: 16),
              const Text(
                'Hissaabee',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connecting accountants and companies',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _RoleCard(
                icon: Icons.person_outline,
                title: 'I am an Accountant',
                subtitle: 'Find companies near you that need accounting work',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PlaceholderScreen(
                        title: 'Accountant',
                        message: 'Companies near you will appear here.',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: Icons.apartment,
                title: 'I am a Company',
                subtitle: 'Find a full-time or part-time accountant',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PlaceholderScreen(
                        title: 'Company',
                        message: 'Accountants will appear here.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String message;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(message)),
    );
  }
}