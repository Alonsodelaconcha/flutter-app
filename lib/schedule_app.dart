import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://wzzsdgseysfrchtgprbk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind6enNkZ3NleXNmcmNodGdwcmJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg2NzU5NTksImV4cCI6MjA5NDI1MTk1OX0.uv7xE4gtGvDeO9gHhoA4cqth2gfz5yGF6owgZ4ukk1E',
  );
  runApp(const ScheduleApp());
}

final supabase = Supabase.instance.client;

const List<String> kDays = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
];

const List<Color> kClassColors = [
  Color(0xFF4F46E5), // indigo
  Color(0xFF0891B2), // cyan
  Color(0xFF059669), // emerald
  Color(0xFFD97706), // amber
  Color(0xFFDC2626), // red
  Color(0xFF7C3AED), // violet
  Color(0xFFDB2777), // pink
  Color(0xFF65A30D), // lime
];

Color colorForClass(String name) {
  return kClassColors[name.hashCode.abs() % kClassColors.length];
}

class ScheduleApp extends StatelessWidget {
  const ScheduleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Class Schedule',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

// ─── AUTH GATE ────────────────────────────────────────────────────────────────

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.session != null) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

// ─── LOGIN ────────────────────────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true;
  String? _error;

  Future<void> _submit() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      if (_isLogin) {
        await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.school, size: 64, color: Color(0xFF4F46E5)),
                    const SizedBox(height: 12),
                    const Text('Class Schedule',
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_isLogin ? 'Sign in to continue' : 'Create your account',
                        style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(_error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(_isLogin ? 'Login' : 'Register',
                                style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      child: Text(_isLogin
                          ? "Don't have an account? Register"
                          : 'Already have an account? Login'),
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

// ─── HOME SCREEN (tabs) ───────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    final data = await supabase
        .from('classes')
        .select()
        .eq('user_id', supabase.auth.currentUser!.id)
        .order('time', ascending: true);
    setState(() {
      _classes = List<Map<String, dynamic>>.from(data);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      WeeklyGridView(classes: _classes, isLoading: _isLoading, onRefresh: _loadClasses),
      DashboardView(classes: _classes),
      WeeklyTimetableView(classes: _classes),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Schedule'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ClassFormScreen()));
              await _loadClasses();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => supabase.auth.signOut(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calendar_view_week), label: 'Schedule'),
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.grid_view), label: 'Timetable'),
        ],
      ),
    );
  }
}

// ─── WEEKLY GRID ──────────────────────────────────────────────────────────────

class WeeklyGridView extends StatefulWidget {
  final List<Map<String, dynamic>> classes;
  final bool isLoading;
  final VoidCallback onRefresh;

  const WeeklyGridView({
    super.key,
    required this.classes,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  State<WeeklyGridView> createState() => _WeeklyGridViewState();
}

class _WeeklyGridViewState extends State<WeeklyGridView> {
  int _selectedDay = DateTime.now().weekday - 1;

  List<Map<String, dynamic>> get _classesForDay {
    return widget.classes
        .where((c) => c['day_of_week'] == kDays[_selectedDay])
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Day selector
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (i) {
              final selected = i == _selectedDay;
              final dayName = kDays[i].substring(0, 3);
              return GestureDetector(
                onTap: () => setState(() => _selectedDay = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF4F46E5) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      dayName,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black54,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const Divider(height: 1),
        // Classes list
        Expanded(
          child: _classesForDay.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_available, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text('No classes on ${kDays[_selectedDay]}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ClassFormScreen(
                                initialDay: kDays[_selectedDay],
                              ),
                            ),
                          );
                          widget.onRefresh();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add class'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _classesForDay.length,
                  itemBuilder: (context, index) {
                    final c = _classesForDay[index];
                    final color = colorForClass(c['name']);
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClassDetailScreen(classData: c),
                          ),
                        );
                        widget.onRefresh();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border(
                            left: BorderSide(color: color, width: 5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  Text(
                                    c['time'].toString().substring(0, 5),
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c['name'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.room, size: 14,
                                            color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(c['room'],
                                            style: const TextStyle(
                                                color: Colors.grey)),
                                      ],
                                    ),
                                    if ((c['notes'] as String).isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        c['notes'],
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ─── DASHBOARD ────────────────────────────────────────────────────────────────

class DashboardView extends StatelessWidget {
  final List<Map<String, dynamic>> classes;

  const DashboardView({super.key, required this.classes});

  Map<String, dynamic>? get _nextClass {
    final now = TimeOfDay.now();
    final todayName = kDays[DateTime.now().weekday - 1];
    final todayClasses = classes
        .where((c) => c['day_of_week'] == todayName)
        .toList();
    for (final c in todayClasses) {
      final parts = c['time'].toString().split(':');
      final classTime =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      if (classTime.hour > now.hour ||
          (classTime.hour == now.hour && classTime.minute > now.minute)) {
        return c;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextClass;
    final totalClasses = classes.length;
    final uniqueSubjects = classes.map((c) => c['name']).toSet().length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Next class banner
          if (next != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorForClass(next['name']),
                    colorForClass(next['name']).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.alarm, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text('Next class today',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(next['name'],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                      '${next['time'].toString().substring(0, 5)} · Room ${next['room']}',
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 12),
                  Text('No more classes today!',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          const SizedBox(height: 20),
          // Stats
          const Text('This week',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatCard(
                icon: Icons.event_note,
                label: 'Total classes',
                value: '$totalClasses',
                color: const Color(0xFF4F46E5),
              ),
              const SizedBox(width: 12),
              _StatCard(
                icon: Icons.book,
                label: 'Subjects',
                value: '$uniqueSubjects',
                color: const Color(0xFF059669),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Classes by day summary
          const Text('Classes per day',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...kDays.map((day) {
            final count =
                classes.where((c) => c['day_of_week'] == day).length;
            if (count == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(day,
                        style: const TextStyle(color: Colors.grey)),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: count / 6,
                        minHeight: 10,
                        backgroundColor: Colors.grey[200],
                        color: const Color(0xFF4F46E5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('$count',
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(label,
                style: TextStyle(color: color.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}

// ─── CLASS DETAIL ─────────────────────────────────────────────────────────────

class ClassDetailScreen extends StatefulWidget {
  final Map<String, dynamic> classData;

  const ClassDetailScreen({super.key, required this.classData});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  late TextEditingController _notesController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _notesController =
        TextEditingController(text: widget.classData['notes'] ?? '');
  }

  Future<void> _saveNotes() async {
    setState(() => _saving = true);
    await supabase
        .from('classes')
        .update({'notes': _notesController.text.trim()})
        .eq('id', widget.classData['id']);
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notes saved!')),
      );
    }
  }

  Future<void> _delete() async {
    await supabase
        .from('classes')
        .delete()
        .eq('id', widget.classData['id']);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.classData;
    final color = colorForClass(c['name']);

    return Scaffold(
      appBar: AppBar(
        title: Text(c['name']),
        backgroundColor: color,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClassFormScreen(classData: c),
                ),
              );
              if (mounted) Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _delete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _InfoRow(Icons.calendar_today, 'Day', c['day_of_week']),
                  const SizedBox(height: 12),
                  _InfoRow(Icons.access_time, 'Time',
                      c['time'].toString().substring(0, 5)),
                  const SizedBox(height: 12),
                  _InfoRow(Icons.room, 'Room', c['room']),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Reminder banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active,
                      color: Colors.amber),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '⏰ Reminder set: 15 minutes before ${c['name']} at ${c['time'].toString().substring(0, 5)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Notes
            const Text('Notes',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Write your notes for this class...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _saveNotes,
                icon: const Icon(Icons.save),
                label:
                    Text(_saving ? 'Saving...' : 'Save Notes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text('$label: ',
            style: TextStyle(color: Colors.grey[600])),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ─── CLASS FORM ───────────────────────────────────────────────────────────────

class ClassFormScreen extends StatefulWidget {
  final Map<String, dynamic>? classData;
  final String? initialDay;

  const ClassFormScreen({super.key, this.classData, this.initialDay});

  @override
  State<ClassFormScreen> createState() => _ClassFormScreenState();
}

class _ClassFormScreenState extends State<ClassFormScreen> {
  final _nameController = TextEditingController();
  final _roomController = TextEditingController();
  final _notesController = TextEditingController();
  late String _selectedDay;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDay ?? kDays[0];
    if (widget.classData != null) {
      final c = widget.classData!;
      _nameController.text = c['name'];
      _roomController.text = c['room'];
      _notesController.text = c['notes'] ?? '';
      _selectedDay = c['day_of_week'];
      final parts = c['time'].toString().split(':');
      _selectedTime = TimeOfDay(
          hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
  }

  Future<void> _pickTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty ||
        _roomController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    final timeStr =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00';
    final data = {
      'name': _nameController.text.trim(),
      'room': _roomController.text.trim(),
      'day_of_week': _selectedDay,
      'time': timeStr,
      'notes': _notesController.text.trim(),
      'user_id': supabase.auth.currentUser!.id,
    };
    if (widget.classData == null) {
      await supabase.from('classes').insert(data);
    } else {
      await supabase
          .from('classes')
          .update(data)
          .eq('id', widget.classData!['id']);
    }
    setState(() => _isLoading = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.classData == null ? 'Add Class' : 'Edit Class'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Class name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _roomController,
              decoration: const InputDecoration(
                labelText: 'Room',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.room),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDay,
              decoration: const InputDecoration(
                labelText: 'Day of week',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              items: kDays
                  .map((d) =>
                      DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedDay = v!),
            ),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Colors.grey[400]!),
              ),
              leading: const Icon(Icons.access_time),
              title: Text(
                  'Time: ${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.edit),
              onTap: _pickTime,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        widget.classData == null
                            ? 'Add Class'
                            : 'Save Changes',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 

// ─── WEEKLY TIMETABLE ─────────────────────────────────────────────────────────

class WeeklyTimetableView extends StatelessWidget {
  final List<Map<String, dynamic>> classes;

  const WeeklyTimetableView({super.key, required this.classes});

  static const int _startHour = 7;
  static const int _endHour = 20;
  static const double _hourHeight = 60.0;
  static const double _timeWidth = 50.0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _timeWidth + (kDays.length * 90),
          child: Column(
            children: [
              // Header row with day names
              Row(
                children: [
                  SizedBox(width: _timeWidth),
                  ...kDays.map((day) => Container(
                        width: 90,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.indigo[50],
                        child: Center(
                          child: Text(
                            day.substring(0, 3),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ),
                      )),
                ],
              ),
              const Divider(height: 1),
              // Grid
              SizedBox(
                height: (_endHour - _startHour) * _hourHeight,
                child: Stack(
                  children: [
                    // Hour lines
                    Column(
                      children: List.generate(_endHour - _startHour, (i) {
                        final hour = _startHour + i;
                        return SizedBox(
                          height: _hourHeight,
                          child: Row(
                            children: [
                              SizedBox(
                                width: _timeWidth,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    '${hour.toString().padLeft(2, '0')}:00',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                          color: Colors.grey[200]!),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    // Vertical day dividers
                    Row(
                      children: [
                        SizedBox(width: _timeWidth),
                        ...kDays.map((day) => Container(
                              width: 90,
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(color: Colors.grey[200]!),
                                ),
                              ),
                            )),
                      ],
                    ),
                    // Class blocks
                    ...classes.map((c) {
                      final dayIndex = kDays.indexOf(c['day_of_week']);
                      if (dayIndex == -1) return const SizedBox.shrink();
                      final parts = c['time'].toString().split(':');
                      final hour = int.parse(parts[0]);
                      final minute = int.parse(parts[1]);
                      if (hour < _startHour || hour >= _endHour) {
                        return const SizedBox.shrink();
                      }
                      final top = ((hour - _startHour) + minute / 60) *
                          _hourHeight;
                      final color = colorForClass(c['name']);
                      return Positioned(
                        top: top,
                        left: _timeWidth + (dayIndex * 90) + 2,
                        width: 86,
                        height: _hourHeight - 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: color, width: 1.5),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c['name'],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                c['room'],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: color.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}