import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// تعريف الألوان الأساسية للسنتر بدقة لتجنب أخطاء الألوان غير المعرفة
const Color kSlate = Color(0xFF64748B);
const Color kEmerald = Color(0xFF10B981);
const Color kRose = Color(0xFFF43F5E);
const Color kIndigo = Color.fromARGB(255, 255, 255, 255);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    titleBarStyle: TitleBarStyle.hidden,
    center: true,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    // يفتح Fullscreen تلقائي
    await windowManager.setFullScreen(true);

    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MostafaCenterApp());
}

class MostafaCenterApp extends StatelessWidget {
  const MostafaCenterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سنتر المصطفى التعليمي',
      debugShowCheckedModeBanner: false,
      // تهيئة اللغة العربية لتكون اللغة الأساسية لضبط الاتجاهات والترتيب لليمين تلقائياً
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [
        Locale('ar', 'EG'),
      ],
      // توفير مفسرات التعريب لحل مشكلة RawChip وحل خطأ No MaterialLocalizations found
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        fontFamily: 'Cairo',
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
      ),
      // تغليف التطبيق بـ Directionality لضمان اتجاه الواجهات بالكامل من اليمين إلى اليسار (RTL)
      home: KeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKeyEvent: (event) async {
          if (event.logicalKey == LogicalKeyboardKey.f11) {
            final isFull = await windowManager.isFullScreen();

            await windowManager.setFullScreen(!isFull);
          }
        },
        child: const Directionality(
          textDirection: TextDirection.rtl,
          child: MainNavigationScreen(),
        ),
      ),
    );
  }
}

// =========================================================================
// --- DATA MODELS ---
// =========================================================================

class Teacher {
  final String id;
  final String name;
  final String subject;
  final String phone;

  Teacher(
      {required this.id,
      required this.name,
      required this.subject,
      required this.phone});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subject': subject,
        'phone': phone,
      };

  factory Teacher.fromJson(Map<String, dynamic> json) => Teacher(
        id: json['id'],
        name: json['name'],
        subject: json['subject'],
        phone: json['phone'],
      );
}

class Student {
  final String id;
  final String name;
  final String grade;
  final String phone;
  final String parentPhone;
  final List<String> enrolledSessions;

  Student({
    required this.id,
    required this.name,
    required this.grade,
    required this.phone,
    required this.parentPhone,
    required this.enrolledSessions,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'grade': grade,
        'phone': phone,
        'parentPhone': parentPhone,
        'enrolledSessions': enrolledSessions,
      };

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'],
        name: json['name'],
        grade: json['grade'],
        phone: json['phone'],
        parentPhone: json['parentPhone'],
        enrolledSessions: List<String>.from(json['enrolledSessions'] ?? []),
      );
}

class Session {
  final String id;
  final String teacherId;
  final String name; // اسم الحصة (تم إضافته لربط تفاصيل المدرس وموضوع الحصة)
  final String day;
  final String time;
  final String grade;
  final double price;

  Session({
    required this.id,
    required this.teacherId,
    required this.name,
    required this.day,
    required this.time,
    required this.grade,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'teacherId': teacherId,
        'name': name,
        'day': day,
        'time': time,
        'grade': grade,
        'price': price,
      };

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json['id'],
        teacherId: json['teacherId'],
        name: json['name'] ?? 'حصة عامة',
        day: json['day'],
        time: json['time'],
        grade: json['grade'],
        price: (json['price'] as num).toDouble(),
      );
}

class AttendanceRecord {
  final String date; // YYYY-MM-DD
  final String sessionId; // "custom" or Session ID
  final String studentId;
  String status; // present, absent, debt
  double debt;
  final String customReason;

  AttendanceRecord({
    required this.date,
    required this.sessionId,
    required this.studentId,
    required this.status,
    required this.debt,
    this.customReason = '',
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'sessionId': sessionId,
        'studentId': studentId,
        'status': status,
        'debt': debt,
        'customReason': customReason,
      };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        date: json['date'],
        sessionId: json['sessionId'],
        studentId: json['studentId'],
        status: json['status'],
        debt: (json['debt'] as num).toDouble(),
        customReason: json['customReason'] ?? '',
      );
}

// =========================================================================
// --- STATE MANAGEMENT ---
// =========================================================================

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  String _currentTab = 'dashboard';
  bool _isLoading = true;

  // Global State Arrays
  List<Teacher> _teachers = [];
  List<Student> _students = [];
  List<Session> _sessions = [];
  List<AttendanceRecord> _attendance = [];

  // Search queries
  String _teacherSearchQuery = "";
  String _studentSearchQuery = "";

  // Selected Session for today's attendance taking
  String? _selectedAttendanceSessionId;

  // Date for historical review
  DateTime _selectedReviewDate = DateTime.now();

  // تجميد رصد الحضور للحصة بشكل مؤقت بعد التأكيد النهائي
  final Set<String> _lockedSessionsToday = {};

  // قائمة الصفوف المحددة بدقة من الصف الرابع الابتدائي حتى الثالث الثانوي
  final List<String> _grades = [
    "الرابع الابتدائي",
    "الخامس الابتدائي",
    "السادس الابتدائي",
    "الأول الإعدادي",
    "الثاني الإعدادي",
    "الثالث الإعدادي",
    "الأول الثانوي",
    "الثاني الثانوي",
    "الثالث الثانوي"
  ];

  final Map<String, String> _weekdaysAr = {
    'Saturday': 'السبت',
    'Sunday': 'الأحد',
    'Monday': 'الاثنين',
    'Tuesday': 'الثلاثاء',
    'Wednesday': 'الأربعاء',
    'Thursday': 'الخميس',
    'Friday': 'الجمعة',
  };

  final List<String> _weekdaysEn = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday'
  ];

  @override
  void initState() {
    super.initState();
    _loadStateFromPrefs();
  }

  // Save state helper
  Future<void> _saveStateToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'teachers', jsonEncode(_teachers.map((e) => e.toJson()).toList()));
    await prefs.setString(
        'students', jsonEncode(_students.map((e) => e.toJson()).toList()));
    await prefs.setString(
        'sessions', jsonEncode(_sessions.map((e) => e.toJson()).toList()));
    await prefs.setString(
        'attendance', jsonEncode(_attendance.map((e) => e.toJson()).toList()));
    await prefs.setString(
        'locked_sessions', jsonEncode(_lockedSessionsToday.toList()));
  }

  // Load state helper
  Future<void> _loadStateFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final String? teachersRaw = prefs.getString('teachers');
    final String? studentsRaw = prefs.getString('students');
    final String? sessionsRaw = prefs.getString('sessions');
    final String? attendanceRaw = prefs.getString('attendance');
    final String? lockedRaw = prefs.getString('locked_sessions');

    setState(() {
      if (teachersRaw != null) {
        _teachers = (jsonDecode(teachersRaw) as List)
            .map((e) => Teacher.fromJson(e))
            .toList();
      } else {
        _teachers = [];
      }

      if (studentsRaw != null) {
        _students = (jsonDecode(studentsRaw) as List)
            .map((e) => Student.fromJson(e))
            .toList();
      } else {
        _students = [];
      }

      if (sessionsRaw != null) {
        _sessions = (jsonDecode(sessionsRaw) as List)
            .map((e) => Session.fromJson(e))
            .toList();
      } else {
        _sessions = [];
      }

      if (attendanceRaw != null) {
        _attendance = (jsonDecode(attendanceRaw) as List)
            .map((e) => AttendanceRecord.fromJson(e))
            .toList();
      } else {
        _attendance = [];
      }

      if (lockedRaw != null) {
        final decoded = jsonDecode(lockedRaw) as List;
        _lockedSessionsToday.clear();
        _lockedSessionsToday.addAll(decoded.cast<String>());
      }

      _isLoading = false;
    });
  }

  // تصفير كل داتا التطبيق وإعادتها لقاعدة بيانات فارغة
  void _confirmExitApp() {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.close_rounded, color: kRose, size: 28),
                SizedBox(width: 8),
                Text(
                  'إغلاق التطبيق',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: const Text(
              'هل تريد إغلاق التطبيق الآن؟',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(color: kSlate),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);

                  // إغلاق التطبيق
                  SystemNavigator.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kRose,
                ),
                child: const Text(
                  'إغلاق التطبيق',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // حساب المديونيات الإجمالية لكل الطلاب
  double get totalDebts {
    return _attendance.fold(0.0, (sum, item) {
      if (item.status == 'debt') {
        return sum + item.debt;
      }
      return sum;
    });
  }

  double getStudentTotalDebts(String studentId) {
    return _attendance.fold(0.0, (sum, item) {
      if (item.studentId == studentId && item.status == 'debt') {
        return sum + item.debt;
      }
      return sum;
    });
  }

  String _getCurrentDayEnglish() {
    final Map<int, String> conversion = {
      DateTime.monday: 'Monday',
      DateTime.tuesday: 'Tuesday',
      DateTime.wednesday: 'Wednesday',
      DateTime.thursday: 'Thursday',
      DateTime.friday: 'Friday',
      DateTime.saturday: 'Saturday',
      DateTime.sunday: 'Sunday',
    };
    return conversion[DateTime.now().weekday] ?? 'Saturday';
  }

  String _getTodayDateOnlyString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  // =========================================================================
  // --- UI BUILDING ---
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Container(
              color: const Color(0xFFF1F5F9),
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: _buildCurrentTabContent(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      color: const Color(0xFF0F172A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      const Icon(Icons.school, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'سنتر المصطفى',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      Text(
                        'لوحة الإدارة الذكية',
                        style:
                            TextStyle(color: Colors.blueAccent, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF1E293B), height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              children: [
                _buildSidebarItem(
                    id: 'dashboard',
                    title: 'لوحة التحكم',
                    icon: Icons.dashboard),
                _buildSidebarItem(
                    id: 'teachers',
                    title: 'ملفات المدرسين',
                    icon: Icons.person),
                _buildSidebarItem(
                    id: 'students', title: 'ملفات الطلاب', icon: Icons.people),
                _buildSidebarItem(
                    id: 'sessions',
                    title: 'جدول الحصص الأسبوعي',
                    icon: Icons.calendar_month),
                _buildSidebarItem(
                    id: 'attendance',
                    title: 'تسجيل الحضور والغياب',
                    icon: Icons.fact_check),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFF1E293B)),
                _buildSidebarItem(
                  id: 'attendance-review',
                  title: 'سجل الحضور السابق',
                  icon: Icons.history,
                  customColor: Colors.amber.shade400,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF020617),
            child: Column(
              children: [
                const Text(
                  'سنتر المصطفى التعليمي - الإصدار الذهبي',
                  style: TextStyle(color: kSlate, fontSize: 11),
                ),
                const SizedBox(height: 4),
                ElevatedButton.icon(
                  onPressed: _confirmExitApp,
                  icon: const Icon(Icons.exit_to_app, size: 14),
                  label: const Text('إغلاق التطبيق',
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.2),
                    foregroundColor: Colors.red,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
      {required String id,
      required String title,
      required IconData icon,
      Color? customColor}) {
    final isSelected = _currentTab == id;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _currentTab = id;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.indigo.shade600 : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: isSelected ? Colors.white : (customColor ?? kSlate),
                  size: 20),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : (customColor ?? kSlate),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final DateTime now = DateTime.now();
    final String dateString =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final String currentDayAr =
        _weekdaysAr[_getCurrentDayEnglish()] ?? 'غير محدد';

    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.indigo, size: 20),
              const SizedBox(width: 8),
              Text(
                'تاريخ اليوم: $dateString ($currentDayAr)',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, color: kSlate),
              ),
            ],
          ),
          Row(
            children: [
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('أدمن السنتر',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('المدير العام المالي',
                      style: TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                backgroundColor: Colors.indigo.shade50,
                child: const Text('م',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.indigo)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTabContent() {
    switch (_currentTab) {
      case 'dashboard':
        return _buildDashboardTab();
      case 'teachers':
        return _buildTeachersTab();
      case 'students':
        return _buildStudentsTab();
      case 'sessions':
        return _buildSessionsTab();
      case 'attendance':
        return _buildAttendanceTab();
      case 'attendance-review':
        return _buildAttendanceReviewTab();
      default:
        return const Center(child: Text('غير موجود'));
    }
  }

  // =========================================================================
  // TAB 1: DASHBOARD
  // =========================================================================

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3F51B5), Color(0xFF1A237E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'لوحة تحكم سنتر المصطفى التعليمي 👋',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  'تحضير الطلاب الفوري، الحفظ التلقائي عند التعديل، تتبع مديونيات الكافيتريا والمذكرات مع إمكانية تعديل اسم الحصة وتصفير البيانات بالكامل.',
                  style: TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildMetricCard('إجمالي المدرسين', '${_teachers.length}',
                  Icons.person, Colors.blue),
              const SizedBox(width: 16),
              _buildMetricCard('إجمالي الطلاب', '${_students.length}',
                  Icons.people, kEmerald),
              const SizedBox(width: 16),
              _buildMetricCard('إجمالي حصص الأسبوع', '${_sessions.length}',
                  Icons.calendar_month, Colors.amber),
              const SizedBox(width: 16),
              _buildMetricCard('إجمالي المديونيات المستحقة', '$totalDebts ج.م',
                  Icons.monetization_on, kRose),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'حصص اليوم المجدولة للرصد السريع والتغيير المباشر',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Chip(
                              label: Text(
                                _weekdaysAr[_getCurrentDayEnglish()] ?? 'اليوم',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                              backgroundColor: Colors.blue.shade50,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTodaySessionsList(),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('لوحة العمل السريع',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 8),
                        const Text(
                          'تعديل وإضافة الطلاب والمدرسين والمواعيد لقاعدة البيانات المحلية مباشرة.',
                          style: TextStyle(color: Colors.grey, fontSize: 11.5),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _openAddStudentDialog(),
                          icon: const Icon(Icons.person_add_alt),
                          label: const Text('إضافة طالب جديد'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _openAddTeacherDialog(),
                          icon: const Icon(Icons.add_home_work),
                          label: const Text('إضافة مدرس جديد'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.indigo,
                            side: const BorderSide(color: Colors.indigo),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _openAddSessionDialog(),
                          icon: const Icon(Icons.more_time),
                          label: const Text('إضافة حصة جديدة للجدول'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.indigo,
                            side: const BorderSide(color: Colors.indigo),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color == kRose ? kRose : Colors.black87),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaySessionsList() {
    final String todayEng = _getCurrentDayEnglish();
    final todaySessions = _sessions.where((s) => s.day == todayEng).toList();

    if (todaySessions.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.coffee, size: 40, color: Colors.grey),
            SizedBox(height: 12),
            Text('لا توجد حصص مجدولة لهذا اليوم في قاعدة البيانات.',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: todaySessions.length,
      itemBuilder: (context, index) {
        final session = todaySessions[index];
        final teacher = _teachers.firstWhere((t) => t.id == session.teacherId,
            orElse: () =>
                Teacher(id: '', name: 'مدرس مجهول', subject: '', phone: ''));
        final int enrolledCount = _students
            .where((s) =>
                s.grade == session.grade ||
                s.enrolledSessions.contains(session.id))
            .length;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.indigo.shade50,
                    child: const Icon(Icons.cast_for_education,
                        color: Colors.indigo),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              color: Colors.indigo)),
                      const SizedBox(height: 4),
                      Text('${teacher.subject} - ${teacher.name}',
                          style: const TextStyle(fontSize: 12, color: kSlate)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(session.time,
                                style: const TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Text(session.grade,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                          const SizedBox(width: 8),
                          Text('• $enrolledCount طالب مسجل',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.indigo)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentTab = 'attendance';
                    _selectedAttendanceSessionId = session.id;
                  });
                },
                icon: const Icon(Icons.check_circle_outline, size: 14),
                label:
                    const Text('الغياب السريع', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================================
  // TAB 2: TEACHERS
  // =========================================================================

  Widget _buildTeachersTab() {
    final filtered = _teachers.where((t) {
      final q = _teacherSearchQuery.toLowerCase();
      return t.name.toLowerCase().contains(q) ||
          t.subject.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('إدارة ملفات وحسابات المدرسين',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(
                    'اضغط على سطر المدرس لفتح حسابه المالي وجدوله وإضافة حصص له مباشرة.',
                    style: TextStyle(color: Colors.grey, fontSize: 11.5)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _openAddTeacherDialog(),
              icon: const Icon(Icons.add),
              label: const Text('إضافة مدرس جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'ابحث باسم المدرس أو المادة...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 0),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _teacherSearchQuery = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('المجموع: ${filtered.length} مدرس',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo)),
                    ],
                  ),
                ),
                Container(
                  color: Colors.grey.shade50,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  child: Row(
                    children: const [
                      Expanded(
                          flex: 3,
                          child: Text('اسم المدرس',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5))),
                      Expanded(
                          flex: 2,
                          child: Text('المادة الدراسية',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5))),
                      Expanded(
                          flex: 2,
                          child: Text('رقم الهاتف',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5))),
                      Expanded(
                          flex: 2,
                          child: Text('عدد الحصص الأسبوعية',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5))),
                      Expanded(
                          flex: 1,
                          child: Align(
                              alignment: Alignment.center,
                              child: Text('خيارات',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5)))),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final teacher = filtered[index];
                      final sessCount = _sessions
                          .where((s) => s.teacherId == teacher.id)
                          .length;

                      return InkWell(
                        onTap: () => _openTeacherProfileDialog(teacher),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Text(teacher.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigo))),
                              Expanded(
                                flex: 2,
                                child: UnconstrainedBox(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Text(teacher.subject,
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade800)),
                                  ),
                                ),
                              ),
                              Expanded(
                                  flex: 2,
                                  child: Text(teacher.phone,
                                      style: const TextStyle(
                                          fontFamily: 'Courier'))),
                              Expanded(
                                  flex: 2,
                                  child: Text('$sessCount حصة أسبوعياً')),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.indigo, size: 18),
                                      onPressed: () =>
                                          _openAddTeacherDialog(teacher),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: kRose, size: 18),
                                      onPressed: () =>
                                          _confirmDeleteTeacher(teacher),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // TAB 3: STUDENTS
  // =========================================================================

  Widget _buildStudentsTab() {
    final filtered = _students.where((s) {
      final q = _studentSearchQuery.toLowerCase();
      return s.name.toLowerCase().contains(q) ||
          s.grade.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('إدارة ملفات الطلاب والمديونيات',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(
                    'اضغط على سطر الطالب لعرض مديونيته بالتفصيل وسدادها يدوياً أو إضافة مبيعات الملازم الخارجية.',
                    style: TextStyle(color: Colors.grey, fontSize: 11.5)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _openAddStudentDialog(),
              icon: const Icon(Icons.add),
              label: const Text('إضافة طالب جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'ابحث باسم الطالب أو الصف الدراسي...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 0),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _studentSearchQuery = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('المجموع: ${filtered.length} طالب',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo)),
                    ],
                  ),
                ),
                Container(
                  color: Colors.grey.shade50,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  child: Row(
                    children: const [
                      Expanded(
                          flex: 3,
                          child: Text('اسم الطالب',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5))),
                      Expanded(
                          flex: 2,
                          child: Text('الصف الدراسي',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5))),
                      Expanded(
                          flex: 2,
                          child: Text('رقم هاتف الطالب',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5))),
                      Expanded(
                          flex: 2,
                          child: Text('رقم هاتف ولي الأمر',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5))),
                      Expanded(
                          flex: 2,
                          child: Text('المديونية المستحقة',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5))),
                      Expanded(
                          flex: 1,
                          child: Align(
                              alignment: Alignment.center,
                              child: Text('خيارات',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5)))),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final student = filtered[index];
                      final double studentDebt =
                          getStudentTotalDebts(student.id);

                      return InkWell(
                        onTap: () => _openStudentProfileDialog(student),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Text(student.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigo))),
                              Expanded(flex: 2, child: Text(student.grade)),
                              Expanded(
                                  flex: 2,
                                  child: Text(student.phone,
                                      style: const TextStyle(
                                          fontFamily: 'Courier'))),
                              Expanded(
                                  flex: 2,
                                  child: Text(student.parentPhone,
                                      style: const TextStyle(
                                          fontFamily: 'Courier'))),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '$studentDebt ج.م',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Courier',
                                    color: studentDebt > 0 ? kRose : kSlate,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.indigo, size: 18),
                                      onPressed: () =>
                                          _openAddStudentDialog(student),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: kRose, size: 18),
                                      onPressed: () =>
                                          _confirmDeleteStudent(student),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  // =========================================================================
  // TAB 4: SESSIONS SCHEDULE
  // =========================================================================

  Widget _buildSessionsTab() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('جدول الحصص الأسبوعي للسنتر',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(
                    'تنظيم الحصص الأسبوعية المفتوحة وربطها بالمدرسين والصفوف بدقة وإسناد اسم خاص بكل حصة.',
                    style: TextStyle(color: Colors.grey, fontSize: 11.5)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _openAddSessionDialog(),
              icon: const Icon(Icons.add),
              label: const Text('إضافة حصة جديدة للجدول'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _weekdaysEn.map((dayEng) {
              return Expanded(
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: dayEng == 'Friday'
                              ? const Color.fromARGB(255, 255, 255, 255)
                              : const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                        ),
                        child: Text(
                          _weekdaysAr[dayEng] ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: dayEng == 'Friday'
                                ? const Color.fromARGB(255, 0, 0, 0)
                                : const Color.fromARGB(255, 0, 0, 0),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildDaySessionsSchedule(dayEng),
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        )
      ],
    );
  }

  Widget _buildDaySessionsSchedule(String day) {
    final daySessions = _sessions.where((s) => s.day == day).toList();

    if (daySessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.coffee, size: 24, color: Colors.grey),
            SizedBox(height: 6),
            Text('لا توجد حصص',
                style: TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: daySessions.length,
      itemBuilder: (context, index) {
        final session = daySessions[index];
        final teacher = _teachers.firstWhere((t) => t.id == session.teacherId,
            orElse: () =>
                Teacher(id: '', name: 'مدرس', subject: '', phone: ''));

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(session.time,
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo)),
                  ),
                  Text('${session.price} ج.م',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: kEmerald)),
                ],
              ),
              const SizedBox(height: 6),
              Text(session.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Colors.indigo),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(teacher.name,
                  style: const TextStyle(fontSize: 10, color: Colors.black87),
                  overflow: TextOverflow.ellipsis),
              Text(teacher.subject,
                  style: const TextStyle(fontSize: 9, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(session.grade,
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => _openAddSessionDialog(session),
                    child: const Icon(Icons.edit, size: 14, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _confirmDeleteSession(session),
                    child: const Icon(Icons.delete, size: 14, color: kRose),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  // =========================================================================
  // TAB 5: ATTENDANCE (TAKING ATTENDANCE)
  // =========================================================================

  List<AttendanceRecord> _tempAttendanceList = [];

  Widget _buildAttendanceTab() {
    // جلب الحصص المجدولة لليوم الحالي للجهاز فقط
    final todayEng = _getCurrentDayEnglish();
    final todaySessions = _sessions.where((s) => s.day == todayEng).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('رصد الحضور والغياب والمديونيات',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(
          'رصد حصص اليوم الحالي للسنتر تلقائياً (${_weekdaysAr[todayEng]}):',
          style: const TextStyle(color: Colors.grey, fontSize: 11.5),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('اختر الحصة لليوم الحالي',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedAttendanceSessionId,
                        hint: const Text('اختر حصة للبدء في الرصد...'),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        items: todaySessions.map((s) {
                          final teacher = _teachers.firstWhere(
                              (t) => t.id == s.teacherId,
                              orElse: () => Teacher(
                                  id: '',
                                  name: 'مدرس',
                                  subject: '',
                                  phone: ''));
                          return DropdownMenuItem<String>(
                            value: s.id,
                            child: Text(
                                '${s.name} - ${teacher.subject} - ${teacher.name} (${s.grade})'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedAttendanceSessionId = val;
                            _tempAttendanceList = [];
                          });
                          if (val != null) {
                            _loadStudentsForAttendance(val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (_selectedAttendanceSessionId != null &&
            _tempAttendanceList.isNotEmpty)
          Expanded(
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAttendanceSheetHeader(),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _tempAttendanceList.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final record = _tempAttendanceList[index];
                        final student = _students.firstWhere(
                            (s) => s.id == record.studentId,
                            orElse: () => Student(
                                id: '',
                                name: 'مجهول',
                                grade: '',
                                phone: '',
                                parentPhone: '',
                                enrolledSessions: []));
                        final session = _sessions.firstWhere(
                            (s) => s.id == _selectedAttendanceSessionId);
                        final isLocked = _lockedSessionsToday
                            .contains(_selectedAttendanceSessionId);

                        return Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(student.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  _buildStatusBadge(record.status),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: record.status == 'debt'
                                  ? Row(
                                      children: [
                                        SizedBox(
                                          width: 80,
                                          height: 36,
                                          child: TextField(
                                            controller: TextEditingController(
                                                text: record.debt
                                                    .toStringAsFixed(0))
                                              ..selection =
                                                  TextSelection.collapsed(
                                                      offset: record.debt
                                                          .toStringAsFixed(0)
                                                          .length),
                                            enabled: !isLocked,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 0),
                                            ),
                                            keyboardType: TextInputType.number,
                                            onChanged: (val) {
                                              double debtVal =
                                                  double.tryParse(val) ?? 0.0;
                                              if (debtVal > session.price) {
                                                debtVal = session.price;
                                              }
                                              setState(() {
                                                record.debt = debtVal;
                                              });
                                              _updateSingleAttendanceRecord(
                                                  record);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text('من أصل ${session.price} ج.م',
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey)),
                                      ],
                                    )
                                  : const Text('-'),
                            ),
                            Expanded(
                              flex: 3,
                              child: isLocked
                                  ? const Center(
                                      child: Text('تم تثبيت الدفتر وقفل الحصة',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold)))
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        _buildRowStatusButton(
                                            index, 'present', 'حاضر', kEmerald),
                                        const SizedBox(width: 6),
                                        _buildRowStatusButton(
                                            index, 'absent', 'غائب', kRose),
                                        const SizedBox(width: 6),
                                        _buildRowStatusButton(index, 'debt',
                                            'مديونية', Colors.amber),
                                      ],
                                    ),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                  _buildAttendanceSheetFooter(),
                ],
              ),
            ),
          )
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = Colors.grey;
    Color text = Colors.white;
    String label = 'غائب';

    if (status == 'present') {
      bg = kEmerald.withOpacity(0.1);
      text = kEmerald;
      label = 'حاضر';
    } else if (status == 'absent') {
      bg = kRose.withOpacity(0.1);
      text = kRose;
      label = 'غائب';
    } else if (status == 'debt') {
      bg = Colors.amber.shade50;
      text = Colors.amber.shade800;
      label = 'مديونية';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: text)),
    );
  }

  Widget _buildRowStatusButton(
      int index, String status, String label, Color color) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _tempAttendanceList[index].status = status;
          if (status == 'debt') {
            final session = _sessions
                .firstWhere((s) => s.id == _selectedAttendanceSessionId);
            _tempAttendanceList[index].debt = session.price;
          } else {
            _tempAttendanceList[index].debt = 0.0;
          }
        });
        _updateSingleAttendanceRecord(_tempAttendanceList[index]);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.08),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  // مزامنة التعديل الحالي فوراً وحفظه بالـ SharedPreferences
  void _updateSingleAttendanceRecord(AttendanceRecord rec) {
    final todayStr = _getTodayDateOnlyString();
    _attendance.removeWhere((a) =>
        a.studentId == rec.studentId &&
        a.sessionId == rec.sessionId &&
        a.date == todayStr);
    _attendance.add(rec);
    _saveStateToPrefs();
  }

  void _loadStudentsForAttendance(String sessionId) {
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    final todayStr = _getTodayDateOnlyString();

    final targetStudents = _students
        .where((s) =>
            s.grade == session.grade || s.enrolledSessions.contains(session.id))
        .toList();

    final existingRecords = _attendance
        .where((a) => a.sessionId == session.id && a.date == todayStr)
        .toList();

    setState(() {
      _tempAttendanceList = targetStudents.map((student) {
        final existing = existingRecords.firstWhere(
            (a) => a.studentId == student.id,
            orElse: () => AttendanceRecord(
                date: '', sessionId: '', studentId: '', status: '', debt: 0));

        return AttendanceRecord(
          date: todayStr,
          sessionId: session.id,
          studentId: student.id,
          // افتراضياً غائب لحين التغيير يدوياً
          status: existing.status.isNotEmpty ? existing.status : 'absent',
          debt: existing.status.isNotEmpty ? existing.debt : 0.0,
        );
      }).toList();
    });
  }

  Widget _buildAttendanceSheetHeader() {
    final session =
        _sessions.firstWhere((s) => s.id == _selectedAttendanceSessionId);
    final teacher = _teachers.firstWhere((t) => t.id == session.teacherId,
        orElse: () => Teacher(id: '', name: 'مدرس', subject: '', phone: ''));
    final isLocked =
        _lockedSessionsToday.contains(_selectedAttendanceSessionId);

    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('حصة: ${session.name}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.indigo)),
              const SizedBox(height: 4),
              Text('المدرس: ${teacher.name} (${teacher.subject})',
                  style: const TextStyle(fontSize: 12, color: kSlate)),
              const SizedBox(height: 2),
              Text('${session.grade} | سعر الحصة: ${session.price} ج.م',
                  style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          if (!isLocked)
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      for (var r in _tempAttendanceList) {
                        r.status = 'present';
                        r.debt = 0.0;
                      }
                    });
                    // مزامنة الكل دفعة واحدة
                    for (var r in _tempAttendanceList) {
                      _updateSingleAttendanceRecord(r);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kEmerald.withOpacity(0.1),
                      foregroundColor: kEmerald),
                  child: const Text('تحضير الكل'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      for (var r in _tempAttendanceList) {
                        r.status = 'absent';
                        r.debt = 0.0;
                      }
                    });
                    for (var r in _tempAttendanceList) {
                      _updateSingleAttendanceRecord(r);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kRose.withOpacity(0.1),
                      foregroundColor: kRose),
                  child: const Text('تغييب الكل'),
                ),
              ],
            )
        ],
      ),
    );
  }

  Widget _buildAttendanceSheetFooter() {
    final isLocked =
        _lockedSessionsToday.contains(_selectedAttendanceSessionId);

    if (isLocked) {
      return Container(
        color: kEmerald.withOpacity(0.1),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: kEmerald),
                const SizedBox(width: 8),
                Text(
                  'تم تأكيد وحفظ الدفتر لهذه الحصة لليوم، وتم قفله بالكامل ضد التعديل.',
                  style: TextStyle(
                      color: const Color(0xFF065F46),
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _lockedSessionsToday.remove(_selectedAttendanceSessionId!);
                });
                _saveStateToPrefs();
              },
              icon: const Icon(Icons.lock_open, size: 16),
              label: const Text('إعادة فتح الحصة للتعديل',
                  style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
              ),
            )
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _lockedSessionsToday.add(_selectedAttendanceSessionId!);
              });
              _saveStateToPrefs();
            },
            icon: const Icon(Icons.verified),
            label: const Text('حفظ وتأكيد دفتر الحضور والغياب (قفل الحصة)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kEmerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 6: HISTORICAL ATTENDANCE REVIEW
  // =========================================================================

  Widget _buildAttendanceReviewTab() {
    final String dateString =
        "${_selectedReviewDate.year}-${_selectedReviewDate.month.toString().padLeft(2, '0')}-${_selectedReviewDate.day.toString().padLeft(2, '0')}";
    final recordsForDate =
        _attendance.where((a) => a.date == dateString).toList();

    // تجميع الحصص في هذا اليوم
    final Map<String, List<AttendanceRecord>> grouped = {};
    for (var r in recordsForDate) {
      if (!grouped.containsKey(r.sessionId)) {
        grouped[r.sessionId] = [];
      }
      grouped[r.sessionId]!.add(r);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('سجل الحضور والغياب والمستندات السابقة',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Text(
            'أدخل تاريخ اليوم المطلوب لمشاهدة جميع الحصص التي تم تحضيرها والطلاب المسجلين مع تفصيل المديونيات.',
            style: TextStyle(color: Colors.grey, fontSize: 11.5)),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('اختر تاريخ اليوم المراد مراجعته',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedReviewDate,
                            firstDate: DateTime(2025),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedReviewDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(dateString,
                                  style: const TextStyle(
                                      fontFamily: 'Courier',
                                      fontWeight: FontWeight.bold)),
                              const Icon(Icons.calendar_month,
                                  color: Colors.indigo),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => setState(() {}),
                      icon: const Icon(Icons.refresh),
                      label: const Text('تحديث البيانات'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: grouped.isEmpty
              ? Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_view_day,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text('لم يتم رصد أي حضور في هذا التاريخ: $dateString',
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView(
                  children: grouped.entries.map((entry) {
                    final String sessId = entry.key;
                    final List<AttendanceRecord> list = entry.value;

                    String title = "مديونيات خارجية ومستلزمات مكتبية";
                    String subtitle = "تسجيل مبيعات ملازم ومراجعات خارجية";

                    if (sessId != 'custom') {
                      final session = _sessions.firstWhere(
                          (s) => s.id == sessId,
                          orElse: () => Session(
                              id: '',
                              name: 'حصة محذوفة',
                              teacherId: '',
                              day: '',
                              time: '',
                              grade: '',
                              price: 0));
                      final teacher = _teachers.firstWhere(
                          (t) => t.id == session.teacherId,
                          orElse: () => Teacher(
                              id: '',
                              name: 'مدرس مجهول',
                              subject: '',
                              phone: ''));
                      title = "حصة: ${session.name}";
                      subtitle =
                          "${teacher.subject} - ${teacher.name} | الصف: ${session.grade} | الموعد: ${session.time}";
                    }

                    final int present =
                        list.where((r) => r.status == 'present').length;
                    final int absent =
                        list.where((r) => r.status == 'absent').length;
                    final int debt =
                        list.where((r) => r.status == 'debt').length;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        title: Text(title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.indigo)),
                        subtitle: Text(subtitle,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 11)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildMiniCount('حاضر', present, kEmerald),
                            const SizedBox(width: 4),
                            _buildMiniCount('غائب', absent, kRose),
                            const SizedBox(width: 4),
                            _buildMiniCount('مديونية', debt, Colors.amber),
                            const SizedBox(width: 12),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                        children: [
                          Container(
                            color: Colors.grey.shade50,
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: list.length,
                              separatorBuilder: (context, i) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, i) {
                                final rec = list[i];
                                final student = _students.firstWhere(
                                    (s) => s.id == rec.studentId,
                                    orElse: () => Student(
                                        id: '',
                                        name: 'طالب مجهول',
                                        grade: '',
                                        phone: '',
                                        parentPhone: '',
                                        enrolledSessions: []));

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(student.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      _buildStatusBadge(rec.status),
                                      Text(
                                        rec.status == 'debt'
                                            ? '${rec.debt} ج.م'
                                            : '-',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: rec.status == 'debt'
                                              ? kRose
                                              : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),
        )
      ],
    );
  }

  Widget _buildMiniCount(String label, int val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6)),
      child: Text('$label: $val',
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  // =========================================================================
  // MODALS AND DIALOGS
  // =========================================================================

  // إضافة وتعديل ملف مدرس
  void _openAddTeacherDialog([Teacher? teacher]) {
    final isEdit = teacher != null;
    final nameController = TextEditingController(text: teacher?.name ?? '');
    final subjectController =
        TextEditingController(text: teacher?.subject ?? '');
    final phoneController = TextEditingController(text: teacher?.phone ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(isEdit ? 'تعديل ملف المدرس' : 'إضافة مدرس جديد'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'اسم المدرس ثلاثي *'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: subjectController,
                    decoration: const InputDecoration(
                        labelText: 'المادة الدراسية *',
                        hintText: 'مثال: كيمياء، لغة عربية'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    decoration:
                        const InputDecoration(labelText: 'رقم الهاتف *'),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isEmpty ||
                      subjectController.text.isEmpty ||
                      phoneController.text.isEmpty) return;

                  setState(() {
                    if (isEdit) {
                      final idx =
                          _teachers.indexWhere((t) => t.id == teacher.id);
                      _teachers[idx] = Teacher(
                          id: teacher.id,
                          name: nameController.text,
                          subject: subjectController.text,
                          phone: phoneController.text);
                    } else {
                      _teachers.add(Teacher(
                          id: 't-${DateTime.now().millisecondsSinceEpoch}',
                          name: nameController.text,
                          subject: subjectController.text,
                          phone: phoneController.text));
                    }
                  });
                  _saveStateToPrefs();
                  renderTeachers();
                  Navigator.pop(context);
                },
                child: const Text('حفظ البيانات'),
              ),
            ],
          ),
        );
      },
    );
  }

  // إضافة وتعديل ملف طالب
  void _openAddStudentDialog([Student? student]) {
    final isEdit = student != null;
    final nameController = TextEditingController(text: student?.name ?? '');
    String selectedGrade = student?.grade ?? _grades[0];
    final phoneController = TextEditingController(text: student?.phone ?? '');
    final parentPhoneController =
        TextEditingController(text: student?.parentPhone ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(isEdit ? 'تعديل ملف الطالب' : 'إضافة طالب جديد'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                            labelText: 'اسم الطالب رباعي *'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedGrade,
                        decoration:
                            const InputDecoration(labelText: 'الصف الدراسي *'),
                        items: _grades
                            .map((g) =>
                                DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedGrade = val!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                            labelText: 'رقم هاتف الطالب *'),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: parentPhoneController,
                        decoration: const InputDecoration(
                            labelText: 'رقم هاتف ولي الأمر *'),
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء')),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isEmpty ||
                          phoneController.text.isEmpty ||
                          parentPhoneController.text.isEmpty) return;

                      setState(() {
                        if (isEdit) {
                          final idx =
                              _students.indexWhere((s) => s.id == student.id);
                          _students[idx] = Student(
                            id: student.id,
                            name: nameController.text,
                            grade: selectedGrade,
                            phone: phoneController.text,
                            parentPhone: parentPhoneController.text,
                            enrolledSessions: student.enrolledSessions,
                          );
                        } else {
                          _students.add(Student(
                            id: 's-${DateTime.now().millisecondsSinceEpoch}',
                            name: nameController.text,
                            grade: selectedGrade,
                            phone: phoneController.text,
                            parentPhone: parentPhoneController.text,
                            enrolledSessions: [],
                          ));
                        }
                      });
                      _saveStateToPrefs();
                      renderStudents();
                      Navigator.pop(context);
                    },
                    child: const Text('حفظ البيانات'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // إضافة وتعديل حصة مجدولة
  void _openAddSessionDialog([Session? session, String? preferredTeacherId]) {
    final isEdit = session != null;
    String selectedTeacherId = preferredTeacherId ??
        session?.teacherId ??
        (_teachers.isNotEmpty ? _teachers[0].id : '');
    final nameController = TextEditingController(text: session?.name ?? '');
    String selectedDay = session?.day ?? 'Saturday';
    final timeController =
        TextEditingController(text: session?.time ?? '10:00');
    String selectedGrade = session?.grade ?? _grades[0];
    final priceController = TextEditingController(
        text: session != null ? session.price.toStringAsFixed(0) : '50');

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(
                    isEdit ? 'تعديل تفاصيل الحصة' : 'إضافة حصة لجدول الأسبوع'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedTeacherId.isEmpty
                            ? null
                            : selectedTeacherId,
                        decoration: const InputDecoration(
                            labelText: 'اختر المدرس المالك للحصة *'),
                        items: _teachers
                            .map((t) => DropdownMenuItem(
                                value: t.id,
                                child: Text('${t.name} (${t.subject})')))
                            .toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedTeacherId = val!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'اسم أو موضوع الحصة *',
                          hintText:
                              'مثال: محاضرة الكيمياء العضوية الشاملة، مراجعة المصفوفات',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedDay,
                              decoration: const InputDecoration(
                                  labelText: 'يوم الحصة *'),
                              items: _weekdaysEn
                                  .map((d) => DropdownMenuItem(
                                      value: d,
                                      child: Text(_weekdaysAr[d] ?? '')))
                                  .toList(),
                              onChanged: (val) {
                                setDialogState(() {
                                  selectedDay = val!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: timeController,
                              decoration: const InputDecoration(
                                  labelText: 'الوقت (HH:mm) *'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedGrade,
                              decoration: const InputDecoration(
                                  labelText: 'الصف الدراسي المستهدف *'),
                              items: _grades
                                  .map((g) => DropdownMenuItem(
                                      value: g, child: Text(g)))
                                  .toList(),
                              onChanged: (val) {
                                setDialogState(() {
                                  selectedGrade = val!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: priceController,
                              decoration: const InputDecoration(
                                  labelText: 'سعر الحصة (ج.م) *'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء')),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedTeacherId.isEmpty ||
                          nameController.text.isEmpty) return;

                      final double pr =
                          double.tryParse(priceController.text) ?? 50.0;

                      setState(() {
                        if (isEdit) {
                          final idx =
                              _sessions.indexWhere((s) => s.id == session.id);
                          _sessions[idx] = Session(
                            id: session.id,
                            teacherId: selectedTeacherId,
                            name: nameController.text,
                            day: selectedDay,
                            time: timeController.text,
                            grade: selectedGrade,
                            price: pr,
                          );
                        } else {
                          _sessions.add(Session(
                            id: 'sess-${DateTime.now().millisecondsSinceEpoch}',
                            teacherId: selectedTeacherId,
                            name: nameController.text,
                            day: selectedDay,
                            time: timeController.text,
                            grade: selectedGrade,
                            price: pr,
                          ));
                        }
                      });
                      _saveStateToPrefs();
                      renderSchedule();
                      Navigator.pop(context);
                    },
                    child: const Text('حفظ الحصة'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // --- POPUP PROFILES ---

  // الملف المالي للمدرس والجدول الخاص به
  void _openTeacherProfileDialog(Teacher teacher) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setProfileState) {
              final teacherSessions =
                  _sessions.where((s) => s.teacherId == teacher.id).toList();

              return AlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_box,
                            color: Colors.indigo, size: 28),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(teacher.name,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('مدرس مادة: ${teacher.subject}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close)),
                  ],
                ),
                content: SizedBox(
                  width: 600,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('رقم الهاتف',
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.grey)),
                                  Text(teacher.phone,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Courier')),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('إجمالي الحصص بالأسبوع',
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.grey)),
                                  Text('${teacherSessions.length}',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                              'المواعيد والحصص الأسبوعية المحددة للمدرس:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          TextButton.icon(
                            onPressed: () {
                              _openAddSessionDialog(null, teacher.id);
                              Future.delayed(const Duration(milliseconds: 300),
                                  () {
                                setProfileState(() {});
                              });
                            },
                            icon: const Icon(Icons.add, size: 14),
                            label: const Text('إضافة حصة للمدرس',
                                style: TextStyle(fontSize: 11)),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(8)),
                        child: teacherSessions.isEmpty
                            ? const Center(
                                child: Text(
                                    'لا توجد حصص مجدولة للمدرس في جدول الأسبوع.',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 11)))
                            : ListView.separated(
                                itemCount: teacherSessions.length,
                                separatorBuilder: (context, idx) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, idx) {
                                  final sess = teacherSessions[idx];
                                  return Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(sess.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.indigo)),
                                        Text(_weekdaysAr[sess.day] ?? sess.day,
                                            style:
                                                const TextStyle(fontSize: 11)),
                                        Text(sess.time,
                                            style: const TextStyle(
                                                fontFamily: 'Courier',
                                                fontSize: 11)),
                                        Text(sess.grade,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey)),
                                        Text('${sess.price} ج.م',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: kEmerald,
                                                fontSize: 11)),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      )
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kSlate, foregroundColor: Colors.white),
                    child: const Text('إغلاق الحساب المالي للمدرس'),
                  )
                ],
              );
            },
          ),
        );
      },
    );
  }

  // بطاقة الطالب متكاملة (سداد جزئي، إضافة مديونية، ربط الحصص لسنه فقط)
  void _openStudentProfileDialog(Student student) {
    final customDebtReasonController = TextEditingController();
    final customDebtAmountController = TextEditingController();
    final quickSettleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setProfileState) {
              final double studentTotalDebt = getStudentTotalDebts(student.id);
              final studentAttendanceRecords =
                  _attendance.where((a) => a.studentId == student.id).toList();

              // تصفية الحصص لتظهر حصص سنه فقط كما هو مطلوب
              final eligibleSessionsForEnrollment = _sessions
                  .where((sess) => sess.grade == student.grade)
                  .toList();

              return AlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person,
                            color: Colors.indigo, size: 28),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(student.name,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(student.grade,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close)),
                  ],
                ),
                content: SizedBox(
                  width: 750,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildProfileInfoItem('هاتف الطالب', student.phone),
                            const SizedBox(width: 12),
                            _buildProfileInfoItem(
                                'هاتف ولي الأمر', student.parentPhone),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: kRose.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: kRose.withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('الديون المعلقة',
                                            style: TextStyle(
                                                fontSize: 10, color: kRose)),
                                        Text('$studentTotalDebt ج.م',
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: kRose)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 60,
                                          height: 36,
                                          child: TextField(
                                            controller: quickSettleController,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              contentPadding: EdgeInsets.all(6),
                                              fillColor: Colors.white,
                                              filled: true,
                                            ),
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        ElevatedButton(
                                          onPressed: () {
                                            final double payVal =
                                                double.tryParse(
                                                        quickSettleController
                                                            .text) ??
                                                    0.0;
                                            if (payVal <= 0) return;

                                            setState(() {
                                              double runningPayment = payVal;
                                              final studentDebts = _attendance
                                                  .where((a) =>
                                                      a.studentId ==
                                                          student.id &&
                                                      a.status == 'debt')
                                                  .toList();

                                              for (var debtRec
                                                  in studentDebts) {
                                                if (runningPayment <= 0) break;
                                                if (runningPayment >=
                                                    debtRec.debt) {
                                                  runningPayment -=
                                                      debtRec.debt;
                                                  debtRec.debt = 0.0;
                                                  debtRec.status = 'present';
                                                } else {
                                                  debtRec.debt -=
                                                      runningPayment;
                                                  runningPayment = 0.0;
                                                }
                                              }
                                            });

                                            _saveStateToPrefs();
                                            quickSettleController.clear();
                                            setProfileState(() {});
                                            renderStudents();
                                            refreshDashboardStats();
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: kEmerald,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8)),
                                          child: const Text('سداد'),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                        'تسجيل مديونية أخرى (ملزمة / مذكرة / كافيتريا)',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11)),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: customDebtReasonController,
                                      decoration: const InputDecoration(
                                          labelText: 'بيان المديونية',
                                          contentPadding: EdgeInsets.all(8),
                                          border: OutlineInputBorder()),
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller:
                                                customDebtAmountController,
                                            decoration: const InputDecoration(
                                                labelText: 'المبلغ المستحق',
                                                contentPadding:
                                                    EdgeInsets.all(8),
                                                border: OutlineInputBorder()),
                                            keyboardType: TextInputType.number,
                                            style:
                                                const TextStyle(fontSize: 11),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            final String reason =
                                                customDebtReasonController.text
                                                    .trim();
                                            final double amount = double.tryParse(
                                                    customDebtAmountController
                                                        .text) ??
                                                0.0;

                                            if (reason.isEmpty || amount <= 0)
                                              return;

                                            final String todayStr =
                                                _getTodayDateOnlyString();

                                            setState(() {
                                              _attendance.add(AttendanceRecord(
                                                date: todayStr,
                                                sessionId: 'custom',
                                                studentId: student.id,
                                                status: 'debt',
                                                debt: amount,
                                                customReason: reason,
                                              ));
                                            });

                                            _saveStateToPrefs();
                                            customDebtReasonController.clear();
                                            customDebtAmountController.clear();
                                            setProfileState(() {});
                                            renderStudents();
                                            refreshDashboardStats();
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: kRose,
                                              foregroundColor: Colors.white),
                                          child: const Text('إضافة الدين'),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                        'تسجيل الطالب في حصة معينة بالسنتر',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11)),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.all(8)),
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.black),
                                      hint: const Text('اختر الحصة...'),
                                      items: eligibleSessionsForEnrollment
                                          .map((sess) {
                                        final teacher = _teachers.firstWhere(
                                            (t) => t.id == sess.teacherId,
                                            orElse: () => Teacher(
                                                id: '',
                                                name: 'مدرس',
                                                subject: '',
                                                phone: ''));
                                        final bool isEnrolled = student
                                            .enrolledSessions
                                            .contains(sess.id);
                                        return DropdownMenuItem<String>(
                                          value: sess.id,
                                          child: Text(
                                              '${sess.name} - ${teacher.name} (${sess.day}) ${isEnrolled ? "[مسجل]" : ""}'),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val == null) return;
                                        if (!student.enrolledSessions
                                            .contains(val)) {
                                          setState(() {
                                            student.enrolledSessions.add(val);
                                          });
                                          _saveStateToPrefs();
                                          setProfileState(() {});
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                        '* تظهر الحصص المتوافقة مع صف الطالب فقط.',
                                        style: TextStyle(
                                            fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text('تفاصيل حضور ومديونيات الطالب التاريخية:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 8),
                        Container(
                          height: 220,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(8)),
                          child: studentAttendanceRecords.isEmpty
                              ? const Center(
                                  child: Text(
                                      'لا توجد سجلات حضور سابقة للطالب.',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 11)))
                              : ListView.separated(
                                  itemCount: studentAttendanceRecords.length,
                                  separatorBuilder: (context, idx) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, idx) {
                                    final rec = studentAttendanceRecords[idx];
                                    String detailName = "";

                                    if (rec.sessionId == 'custom') {
                                      detailName =
                                          "مديونية خارجية: ${rec.customReason}";
                                    } else {
                                      final session = _sessions.firstWhere(
                                          (s) => s.id == rec.sessionId,
                                          orElse: () => Session(
                                              id: '',
                                              name: 'مدرس',
                                              teacherId: '',
                                              day: '',
                                              time: '',
                                              grade: '',
                                              price: 0));
                                      detailName = "حصة: ${session.name}";
                                    }

                                    final partialPayController =
                                        TextEditingController();

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(rec.date,
                                              style: const TextStyle(
                                                  fontFamily: 'Courier',
                                                  fontSize: 11)),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12.0),
                                              child: Text(detailName,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 11.5),
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ),
                                          ),
                                          _buildStatusBadge(rec.status),
                                          const SizedBox(width: 8),
                                          if (rec.status == 'debt')
                                            Row(
                                              children: [
                                                Text('${rec.debt} ج.م',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: kRose,
                                                        fontSize: 11.5)),
                                                const SizedBox(width: 8),
                                                SizedBox(
                                                  width: 50,
                                                  height: 32,
                                                  child: TextField(
                                                    controller:
                                                        partialPayController,
                                                    decoration:
                                                        const InputDecoration(
                                                            border:
                                                                OutlineInputBorder(),
                                                            contentPadding:
                                                                EdgeInsets.all(
                                                                    4),
                                                            labelText: 'سداد'),
                                                    keyboardType:
                                                        TextInputType.number,
                                                    style: const TextStyle(
                                                        fontSize: 10),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    final double amt =
                                                        double.tryParse(
                                                                partialPayController
                                                                    .text) ??
                                                            0.0;
                                                    if (amt <= 0) return;

                                                    setState(() {
                                                      if (amt >= rec.debt) {
                                                        rec.debt = 0.0;
                                                        rec.status = 'present';
                                                      } else {
                                                        rec.debt -= amt;
                                                      }
                                                    });
                                                    _saveStateToPrefs();
                                                    setProfileState(() {});
                                                    renderStudents();
                                                    refreshDashboardStats();
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.indigo,
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 6)),
                                                  child: const Text('تخصيص',
                                                      style: TextStyle(
                                                          fontSize: 9)),
                                                ),
                                                const SizedBox(width: 4),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      rec.debt = 0.0;
                                                      rec.status = 'present';
                                                    });
                                                    _saveStateToPrefs();
                                                    setProfileState(() {});
                                                    renderStudents();
                                                    refreshDashboardStats();
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              kEmerald,
                                                          foregroundColor: Colors
                                                              .white,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      6)),
                                                  child: const Text('سداد كامل',
                                                      style: TextStyle(
                                                          fontSize: 9)),
                                                )
                                              ],
                                            )
                                          else
                                            const Text('-'),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        )
                      ],
                    ),
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kSlate, foregroundColor: Colors.white),
                    child: const Text('إغلاق الملف الشخصي'),
                  )
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProfileInfoItem(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(value,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier')),
          ],
        ),
      ),
    );
  }

  // --- DELETE CONFIRMATION HANDLERS (STYLIZED MATERIAL DIALOGS - NO JS-ALERTS) ---

  void _confirmDeleteTeacher(Teacher teacher) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تأكيد حذف المدرس'),
            content: Text(
                'هل أنت متأكد من حذف المدرس "${teacher.name}"؟ سيؤدي ذلك لحذف جميع حصصه المجدولة وجدول مواعيده الأسبوعي نهائياً!'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _teachers.removeWhere((t) => t.id == teacher.id);
                    _sessions.removeWhere((s) => s.teacherId == teacher.id);
                  });
                  _saveStateToPrefs();
                  renderTeachers();
                  renderSchedule();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: kRose),
                child: const Text('حذف نهائي',
                    style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteStudent(Student student) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تأكيد حذف الطالب'),
            content: Text(
                'هل أنت متأكد من حذف الطالب "${student.name}" نهائياً من سجلات حضور ومديونيات السنتر؟'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _students.removeWhere((s) => s.id == student.id);
                    _attendance.removeWhere((a) => a.studentId == student.id);
                  });
                  _saveStateToPrefs();
                  renderStudents();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: kRose),
                child: const Text('حذف نهائي',
                    style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteSession(Session session) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('حذف حصة من الجدول'),
            content: Text(
                'هل تريد إزالة حصة "${session.name}" تماماً من جدول الأسبوع وحذف سجل غيابها؟'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _sessions.removeWhere((s) => s.id == session.id);
                    _attendance.removeWhere((a) => a.sessionId == session.id);
                  });
                  _saveStateToPrefs();
                  renderSchedule();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: kRose),
                child: const Text('إزالة من الجدول الأسبوعي',
                    style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        );
      },
    );
  }

  void renderTeachers() => setState(() {});
  void renderStudents() => setState(() {});
  void renderSchedule() => setState(() {});
  void refreshDashboardStats() => setState(() {});
}
