import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const Hisaabee());
}

class Hisaabee extends StatelessWidget {
  const Hisaabee({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hisaabee',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const WelcomeScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

enum WorkType { fullTime, partTime }

String workTypeLabel(WorkType type) =>
    type == WorkType.fullTime ? 'Full-time' : 'Part-time';

class Accountant {
  final String name;
  final String city;
  final String area;
  final int experienceYears;
  final List<String> skills;
  final List<WorkType> availability;
  final String phone;

  const Accountant({
    required this.name,
    required this.city,
    required this.area,
    required this.experienceYears,
    required this.skills,
    required this.availability,
    required this.phone,
  });
}

class Company {
  final String name;
  final String type;
  final String city;
  final String area;
  final WorkType need;
  final String phone;

  const Company({
    required this.name,
    required this.type,
    required this.city,
    required this.area,
    required this.need,
    required this.phone,
  });
}

// ---------------------------------------------------------------------------
// Sample data (kept in memory; will come from the Django API later).
// These lists are not const, so registration can add new items to them.
// ---------------------------------------------------------------------------

final List<Accountant> accountants = [
  Accountant(
    name: 'Anil Kulkarni',
    city: 'Pune',
    area: 'Kothrud',
    experienceYears: 6,
    skills: ['GST', 'Income Tax'],
    availability: [WorkType.fullTime, WorkType.partTime],
    phone: '9000000001',
  ),
  Accountant(
    name: 'Meera Patil',
    city: 'Nashik',
    area: 'College Road',
    experienceYears: 3,
    skills: ['Accounting', 'Payroll'],
    availability: [WorkType.partTime],
    phone: '9000000002',
  ),
  Accountant(
    name: 'Sunil Deshmukh',
    city: 'Nagpur',
    area: 'Dharampeth',
    experienceYears: 10,
    skills: ['Audit', 'GST', 'Balance Sheets'],
    availability: [WorkType.fullTime],
    phone: '9000000003',
  ),
  Accountant(
    name: 'Pooja Joshi',
    city: 'Mumbai',
    area: 'Andheri East',
    experienceYears: 4,
    skills: ['Income Tax', 'Project Reports'],
    availability: [WorkType.partTime],
    phone: '9000000004',
  ),
  Accountant(
    name: 'Vikas Rane',
    city: 'Nagpur',
    area: 'Sitabuldi',
    experienceYears: 7,
    skills: ['Accounting', 'GST'],
    availability: [WorkType.fullTime, WorkType.partTime],
    phone: '9000000005',
  ),
];

final List<Company> companies = [
  Company(
    name: 'Sahyadri Auto Components',
    type: 'Small manufacturer',
    city: 'Pune',
    area: 'Hadapsar',
    need: WorkType.fullTime,
    phone: '9100000001',
  ),
  Company(
    name: 'Bharat Steel Industries',
    type: 'Large manufacturer',
    city: 'Nashik',
    area: 'Satpur MIDC',
    need: WorkType.fullTime,
    phone: '9100000002',
  ),
  Company(
    name: 'Sample Plaza Mall',
    type: 'Shopping mall',
    city: 'Nagpur',
    area: 'Sitabuldi',
    need: WorkType.fullTime,
    phone: '9100000003',
  ),
  Company(
    name: 'Orange Traders Pvt Ltd',
    type: 'Company',
    city: 'Nagpur',
    area: 'Dharampeth',
    need: WorkType.partTime,
    phone: '9100000004',
  ),
  Company(
    name: 'Konkan Foods',
    type: 'Small manufacturer',
    city: 'Mumbai',
    area: 'Andheri East',
    need: WorkType.partTime,
    phone: '9100000005',
  ),
  Company(
    name: 'Metro Square Mall',
    type: 'Shopping mall',
    city: 'Pune',
    area: 'Camp',
    need: WorkType.partTime,
    phone: '9100000006',
  ),
];

const List<String> skillOptions = [
  'GST',
  'Income Tax',
  'Accounting',
  'Audit',
  'Payroll',
  'Balance Sheets',
  'Project Reports',
];

const List<String> companyTypes = [
  'Small manufacturer',
  'Large manufacturer',
  'Shopping mall',
  'Company',
  'Other',
];

const String allCities = 'All cities';

List<String> cityOptions(Iterable<String> cities) {
  final list = cities.toSet().toList()..sort();
  return [allCities, ...list];
}

// ---------------------------------------------------------------------------
// Small helpers: navigation, phone, search, text cleaning and validators
// ---------------------------------------------------------------------------

// Opens a screen and removes everything before it, so the back button
// cannot return to the login or register screens.
void openHome(BuildContext context, Widget screen) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => screen),
    (route) => false,
  );
}

// Opens the phone's dialer. On devices without one (for example Chrome on a
// computer) it shows the number instead.
Future<void> callPhone(BuildContext context, String phone) async {
  final messenger = ScaffoldMessenger.of(context);
  var launched = false;
  try {
    launched = await launchUrl(Uri(scheme: 'tel', path: phone));
  } catch (_) {
    launched = false;
  }
  if (!launched) {
    messenger.showSnackBar(
      SnackBar(content: Text('Could not open the dialer. Number: $phone')),
    );
  }
}

bool matchesSearch(String query, List<String> fields) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  return fields.any((field) => field.toLowerCase().contains(q));
}

// "pune " -> "Pune", "andheri  east" -> "Andheri East"
String titleCase(String text) => text
    .trim()
    .split(RegExp(r'\s+'))
    .map((w) =>
        w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
    .join(' ');

String? Function(String?) requiredField(String label) {
  return (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $label';
    }
    return null;
  };
}

String? validatePhone(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Please enter a mobile number';
  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(text)) {
    return 'Enter a valid 10-digit mobile number';
  }
  return null;
}

// Used when registering: the number must be valid and not already used.
String? validateNewPhone(String? value) {
  final error = validatePhone(value);
  if (error != null) return error;
  final phone = value!.trim();
  final taken = accountants.any((a) => a.phone == phone) ||
      companies.any((c) => c.phone == phone);
  return taken ? 'This number is already registered. Please login.' : null;
}

String? validateExperience(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Please enter years of experience';
  final years = int.tryParse(text);
  if (years == null || years > 60) return 'Enter a valid number of years';
  return null;
}

// ---------------------------------------------------------------------------
// Welcome (Login or Register)
// ---------------------------------------------------------------------------

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
                'VR Accounting Service',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connecting accountants and companies',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterRoleScreen(),
                    ),
                  );
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Login (mobile number only for now)
// ---------------------------------------------------------------------------

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  void _login() {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    final phone = _phone.text.trim();

    for (final accountant in accountants) {
      if (accountant.phone == phone) {
        openHome(context, CompaniesScreen(userName: accountant.name));
        return;
      }
    }
    for (final company in companies) {
      if (company.phone == phone) {
        openHome(context, AccountantsScreen(userName: company.name));
        return;
      }
    }
    setState(() {
      _error = 'No account found for this number. Please register first.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Welcome back',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Enter the mobile number you registered with.'),
            const SizedBox(height: 24),
            AppTextField(
              controller: _phone,
              label: 'Mobile number',
              prefixText: '+91 ',
              keyboardType: TextInputType.phone,
              capitalization: TextCapitalization.none,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: validatePhone,
            ),
            if (_error != null) FieldError(_error!),
            const SizedBox(height: 16),
            FilledButton(onPressed: _login, child: const Text('Login')),
            const SizedBox(height: 24),
            const Text(
              'Demo only: 9000000001 works as an accountant and 9100000001 '
              'as a company. Real login with a one-time password comes with '
              'the backend.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Register, step one (choose a role)
// ---------------------------------------------------------------------------

class RegisterRoleScreen extends StatelessWidget {
  const RegisterRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Who are you?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _RoleCard(
              icon: Icons.person_outline,
              title: 'I am an Accountant',
              subtitle: 'Find companies near you that need accounting work',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountantRegisterScreen(),
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
                    builder: (context) => const CompanyRegisterScreen(),
                  ),
                );
              },
            ),
          ],
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

// ---------------------------------------------------------------------------
// Home for an accountant: list of companies
// ---------------------------------------------------------------------------

class CompaniesScreen extends StatefulWidget {
  final String userName;
  const CompaniesScreen({super.key, required this.userName});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  final _searchController = TextEditingController();
  String _search = '';
  String _city = allCities;
  WorkType? _type;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _search = '';
      _city = allCities;
      _type = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cities = cityOptions(companies.map((c) => c.city));
    final visible = companies.where((c) {
      final cityOk = _city == allCities || c.city == _city;
      final typeOk = _type == null || c.need == _type;
      final searchOk = matchesSearch(_search, [c.name, c.area]);
      return cityOk && typeOk && searchOk;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Companies near you'),
        actions: [LogoutButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Greeting(widget.userName),
          const SizedBox(height: 12),
          FilterBar(
            searchController: _searchController,
            searchHint: 'Search by company or area',
            cities: cities,
            selectedCity: _city,
            selectedType: _type,
            onSearchChanged: (value) => setState(() => _search = value),
            onCityChanged: (value) => setState(() => _city = value),
            onTypeChanged: (value) => setState(() => _type = value),
          ),
          const SizedBox(height: 12),
          Text(
            '${visible.length} ${visible.length == 1 ? 'company' : 'companies'} found',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          if (visible.isEmpty)
            EmptyState(message: 'No companies found', onClear: _clearFilters)
          else
            for (final company in visible)
              ProfileCard(
                icon: Icons.apartment,
                title: company.name,
                subtitle: company.type,
                location: '${company.area}, ${company.city}',
                tags: ['Needs ${workTypeLabel(company.need)} accountant'],
                phone: company.phone,
                details: {
                  'Company type': company.type,
                  'Looking for': '${workTypeLabel(company.need)} accountant',
                },
              ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Home for a company: list of accountants
// ---------------------------------------------------------------------------

class AccountantsScreen extends StatefulWidget {
  final String userName;
  const AccountantsScreen({super.key, required this.userName});

  @override
  State<AccountantsScreen> createState() => _AccountantsScreenState();
}

class _AccountantsScreenState extends State<AccountantsScreen> {
  final _searchController = TextEditingController();
  String _search = '';
  String _city = allCities;
  WorkType? _type;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _search = '';
      _city = allCities;
      _type = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cities = cityOptions(accountants.map((a) => a.city));
    final visible = accountants.where((a) {
      final cityOk = _city == allCities || a.city == _city;
      final typeOk = _type == null || a.availability.contains(_type);
      final searchOk = matchesSearch(_search, [a.name, a.area]);
      return cityOk && typeOk && searchOk;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find an Accountant'),
        actions: [LogoutButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Greeting(widget.userName),
          const SizedBox(height: 12),
          FilterBar(
            searchController: _searchController,
            searchHint: 'Search by name or area',
            cities: cities,
            selectedCity: _city,
            selectedType: _type,
            onSearchChanged: (value) => setState(() => _search = value),
            onCityChanged: (value) => setState(() => _city = value),
            onTypeChanged: (value) => setState(() => _type = value),
          ),
          const SizedBox(height: 12),
          Text(
            '${visible.length} ${visible.length == 1 ? 'accountant' : 'accountants'} found',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          if (visible.isEmpty)
            EmptyState(message: 'No accountants found', onClear: _clearFilters)
          else
            for (final accountant in visible)
              ProfileCard(
                icon: Icons.person_outline,
                title: accountant.name,
                subtitle: '${accountant.experienceYears} years experience',
                location: '${accountant.area}, ${accountant.city}',
                tags: [
                  ...accountant.skills,
                  ...accountant.availability.map(workTypeLabel),
                ],
                phone: accountant.phone,
                details: {
                  'Experience': '${accountant.experienceYears} years',
                  'Skills': accountant.skills.join(', '),
                  'Available for':
                      accountant.availability.map(workTypeLabel).join(' and '),
                },
              ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile detail (opened by tapping a card)
// ---------------------------------------------------------------------------

class ProfileDetailScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String location;
  final List<String> tags;
  final String phone;
  final Map<String, String> details;

  const ProfileDetailScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.tags,
    required this.phone,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(radius: 36, child: Icon(icon, size: 36)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined, size: 18),
              const SizedBox(width: 4),
              Flexible(child: Text(location)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final tag in tags) Chip(label: Text(tag)),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final entry in details.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            entry.value,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => callPhone(context, phone),
            icon: const Icon(Icons.call),
            label: Text('Call $phone'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await Clipboard.setData(ClipboardData(text: phone));
              messenger.showSnackBar(
                const SnackBar(content: Text('Number copied')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy number'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Accountant registration
// ---------------------------------------------------------------------------

class AccountantRegisterScreen extends StatefulWidget {
  const AccountantRegisterScreen({super.key});

  @override
  State<AccountantRegisterScreen> createState() =>
      _AccountantRegisterScreenState();
}

class _AccountantRegisterScreenState extends State<AccountantRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _area = TextEditingController();
  final _experience = TextEditingController();
  final _phone = TextEditingController();
  final Set<String> _skills = {};
  final Set<WorkType> _availability = {};
  bool _submitted = false;

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _area.dispose();
    _experience.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _submitted = true);
    final formOk = _formKey.currentState!.validate();
    if (!formOk || _skills.isEmpty || _availability.isEmpty) return;

    final name = titleCase(_name.text);
    accountants.add(
      Accountant(
        name: name,
        city: titleCase(_city.text),
        area: titleCase(_area.text),
        experienceYears: int.parse(_experience.text.trim()),
        skills: _skills.toList(),
        availability: _availability.toList(),
        phone: _phone.text.trim(),
      ),
    );
    openHome(context, CompaniesScreen(userName: name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register as Accountant')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(
              controller: _name,
              label: 'Full name',
              validator: requiredField('your name'),
            ),
            AppTextField(
              controller: _city,
              label: 'City',
              validator: requiredField('your city'),
            ),
            AppTextField(
              controller: _area,
              label: 'Area',
              validator: requiredField('your area'),
            ),
            AppTextField(
              controller: _experience,
              label: 'Years of experience',
              keyboardType: TextInputType.number,
              capitalization: TextCapitalization.none,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              validator: validateExperience,
            ),
            const SectionLabel('Skills'),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final skill in skillOptions)
                  FilterChip(
                    label: Text(skill),
                    selected: _skills.contains(skill),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _skills.add(skill);
                        } else {
                          _skills.remove(skill);
                        }
                      });
                    },
                  ),
              ],
            ),
            if (_submitted && _skills.isEmpty)
              const FieldError('Select at least one skill'),
            const SizedBox(height: 16),
            const SectionLabel('Available for'),
            Wrap(
              spacing: 8,
              children: [
                for (final type in WorkType.values)
                  FilterChip(
                    label: Text(workTypeLabel(type)),
                    selected: _availability.contains(type),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _availability.add(type);
                        } else {
                          _availability.remove(type);
                        }
                      });
                    },
                  ),
              ],
            ),
            if (_submitted && _availability.isEmpty)
              const FieldError('Select full-time, part-time or both'),
            const SizedBox(height: 16),
            AppTextField(
              controller: _phone,
              label: 'Mobile number',
              prefixText: '+91 ',
              keyboardType: TextInputType.phone,
              capitalization: TextCapitalization.none,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: validateNewPhone,
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _submit,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Company registration
// ---------------------------------------------------------------------------

class CompanyRegisterScreen extends StatefulWidget {
  const CompanyRegisterScreen({super.key});

  @override
  State<CompanyRegisterScreen> createState() => _CompanyRegisterScreenState();
}

class _CompanyRegisterScreenState extends State<CompanyRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _area = TextEditingController();
  final _phone = TextEditingController();
  String? _type;
  WorkType? _need;
  bool _submitted = false;

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _area.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _submitted = true);
    final formOk = _formKey.currentState!.validate();
    if (!formOk || _need == null) return;

    final name = _name.text.trim();
    companies.add(
      Company(
        name: name,
        type: _type!,
        city: titleCase(_city.text),
        area: titleCase(_area.text),
        need: _need!,
        phone: _phone.text.trim(),
      ),
    );
    openHome(context, AccountantsScreen(userName: name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register your Company')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(
              controller: _name,
              label: 'Company name',
              validator: requiredField('the company name'),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Company type',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final type in companyTypes)
                    DropdownMenuItem(value: type, child: Text(type)),
                ],
                onChanged: (value) => setState(() => _type = value),
                validator: (value) =>
                    value == null ? 'Please select a company type' : null,
              ),
            ),
            AppTextField(
              controller: _city,
              label: 'City',
              validator: requiredField('the city'),
            ),
            AppTextField(
              controller: _area,
              label: 'Area',
              validator: requiredField('the area'),
            ),
            const SectionLabel('We need a'),
            Wrap(
              spacing: 8,
              children: [
                for (final type in WorkType.values)
                  ChoiceChip(
                    label: Text('${workTypeLabel(type)} accountant'),
                    selected: _need == type,
                    onSelected: (_) => setState(() => _need = type),
                  ),
              ],
            ),
            if (_submitted && _need == null)
              const FieldError('Choose full-time or part-time'),
            const SizedBox(height: 16),
            AppTextField(
              controller: _phone,
              label: 'Contact mobile number',
              prefixText: '+91 ',
              keyboardType: TextInputType.phone,
              capitalization: TextCapitalization.none,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: validateNewPhone,
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _submit,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Logout',
      onPressed: () => openHome(context, const WelcomeScreen()),
    );
  }
}

class Greeting extends StatelessWidget {
  final String userName;
  const Greeting(this.userName, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Hello, $userName',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String message;
  final VoidCallback onClear;

  const EmptyState({super.key, required this.message, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 56, color: Colors.grey),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          const Text('Try another city or clear the filters.'),
          const SizedBox(height: 12),
          TextButton(onPressed: onClear, child: const Text('Clear filters')),
        ],
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefixText;
  final TextCapitalization capitalization;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.prefixText,
    this.capitalization = TextCapitalization.words,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: capitalization,
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefixText,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class FieldError extends StatelessWidget {
  final String message;
  const FieldError(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}

class FilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchHint;
  final List<String> cities;
  final String selectedCity;
  final WorkType? selectedType;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<WorkType?> onTypeChanged;

  const FilterBar({
    super.key,
    required this.searchController,
    required this.searchHint,
    required this.cities,
    required this.selectedCity,
    required this.selectedType,
    required this.onSearchChanged,
    required this.onCityChanged,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: searchHint,
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          // The key makes the dropdown rebuild when "Clear filters" resets it.
          key: ValueKey(selectedCity),
          initialValue: selectedCity,
          decoration: const InputDecoration(
            labelText: 'City',
            prefixIcon: Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(),
          ),
          items: [
            for (final city in cities)
              DropdownMenuItem(value: city, child: Text(city)),
          ],
          onChanged: (value) {
            if (value != null) onCityChanged(value);
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: selectedType == null,
              onSelected: (_) => onTypeChanged(null),
            ),
            for (final type in WorkType.values)
              ChoiceChip(
                label: Text(workTypeLabel(type)),
                selected: selectedType == type,
                onSelected: (_) => onTypeChanged(type),
              ),
          ],
        ),
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String location;
  final List<String> tags;
  final String phone;
  final Map<String, String> details;

  const ProfileCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.tags,
    required this.phone,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    final initial = title.isEmpty ? '?' : title[0].toUpperCase();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileDetailScreen(
                icon: icon,
                title: title,
                subtitle: subtitle,
                location: location,
                tags: tags,
                phone: phone,
                details: details,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(child: Text(initial)),
                  const SizedBox(width: 12),
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
                        Text(subtitle),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 18),
                  const SizedBox(width: 4),
                  Expanded(child: Text(location)),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final tag in tags) Chip(label: Text(tag)),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  onPressed: () => callPhone(context, phone),
                  icon: const Icon(Icons.call),
                  label: const Text('Call'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}