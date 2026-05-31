import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

const Color kPrimary = Color(0xFF525aff);
const Color kPrimaryDark = Color(0xFF4F46E5);
const Color kPrimaryLight = Color(0xFF818CF8);
const Color kSuccess = Color(0xFF10B981);
const Color kDanger = Color(0xFFEF4444);
const Color kWarning = Color(0xFFF59E0B);
const Color kDark = Color(0xFF1E293B);
const Color kGray = Color(0xFF64748B);
const Color kLight = Color(0xFFF8FAFC);
const Color kWhite = Color(0xFFFFFFFF);
const Color kCardBg = Color(0xFFFFFFFF);
const Color kBgGradientStart = Color(0xFFF1F5F9);
const Color kBgGradientEnd = Color(0xFFE2E8F0);

// System License Constants
const String SYSTEM_EXPIRY_DATE = "2026-06-12";
const String LICENSE_KEY = "MOSTAFA-CENTER-2026-PERMANENT";

// License Functions
bool isSystemExpired() {
  final expiryDate = DateTime.parse(SYSTEM_EXPIRY_DATE);
  final now = DateTime.now();
  return now.isAfter(expiryDate);
}

Future<bool> isLicenseActivated() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('license_activated') ?? false;
}

Future<void> activateLicense() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('license_activated', true);
}

// License Dialog Widget
class LicenseDialog extends StatefulWidget {
  const LicenseDialog({Key? key}) : super(key: key);

  @override
  State<LicenseDialog> createState() => _LicenseDialogState();
}

class _LicenseDialogState extends State<LicenseDialog> {
  final TextEditingController _codeController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(colors: [kPrimary, kPrimaryLight]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.vpn_key, color: kWhite),
            ),
            const SizedBox(width: 12),
            const Text('تفعيل النظام',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'انتهت فترة التجربة\nيرجى إدخال كود التفعيل للمتابعة',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: kGray),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                hintText: 'أدخل كود التفعيل',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                errorText: _errorMessage.isEmpty ? null : _errorMessage,
                prefixIcon: const Icon(Icons.key, color: kPrimary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pop();
              });
            },
            child: const Text('إغلاق', style: TextStyle(color: kGray)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_codeController.text.trim() == LICENSE_KEY) {
                await activateLicense();
                if (context.mounted) {
                  Navigator.pop(context);
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const MostafaCenterApp()),
                      (route) => false,
                    );
                  }
                }
              } else {
                setState(() => _errorMessage = 'كود التفعيل غير صحيح');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
            child: const Text('تفعيل'),
          ),
        ],
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    titleBarStyle: TitleBarStyle.hidden,
    center: true,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
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
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [
        Locale('ar', 'EG'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        fontFamily: 'Cairo',
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: kBgGradientStart,
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: kCardBg,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kWhite,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: kGray.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kPrimary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: kWhite,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: kPrimary,
            side: const BorderSide(color: kPrimary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
      ),
      home: KeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKeyEvent: (event) async {
          if (event.logicalKey == LogicalKeyboardKey.f11) {}
        },
        child: const Directionality(
          textDirection: TextDirection.rtl,
          child: MainNavigationScreen(),
        ),
      ),
    );
  }
}

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
  final String name;
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
  final String date;
  final String sessionId;
  final String studentId;
  String status;
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

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  String _currentTab = 'dashboard';
  bool _isLoading = true;
  List<Teacher> _teachers = [];
  List<Student> _students = [];
  List<Session> _sessions = [];
  List<AttendanceRecord> _attendance = [];
  String _teacherSearchQuery = "";
  String _studentSearchQuery = "";
  String? _selectedAttendanceSessionId;
  DateTime _selectedReviewDate = DateTime.now();
  final Set<String> _lockedSessionsToday = {};
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
    _loadStateFromPrefs().then((_) {
      _checkLicenseAndShowDialog();
    });
  }

  Future<void> _checkLicenseAndShowDialog() async {
    final isActivated = await isLicenseActivated();
    if (!isActivated && isSystemExpired()) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const LicenseDialog(),
        );
      }
    }
  }

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

  String _getFormattedDate() {
    final now = DateTime.now();
    const weekdays = [
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت'
    ];
    return "${weekdays[now.weekday % 7]}، ${now.day} ${_getMonthName(now.month)} ${now.year}";
  }

  String _getMonthName(int month) {
    const months = {
      1: 'يناير',
      2: 'فبراير',
      3: 'مارس',
      4: 'أبريل',
      5: 'مايو',
      6: 'يونيو',
      7: 'يوليو',
      8: 'أغسطس',
      9: 'سبتمبر',
      10: 'أكتوبر',
      11: 'نوفمبر',
      12: 'ديسمبر'
    };
    return months[month] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kBgGradientStart, kBgGradientEnd],
          ),
        ),
        child: Row(
          children: [
            _buildSidebar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
                child: _buildCurrentTabContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: kDark,
        boxShadow: [
          BoxShadow(
            color: kDark.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPrimary, kPrimaryLight],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.school, color: kWhite, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'سنتر المصطفى',
                        style: TextStyle(
                            color: kWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      Text(
                        'نظام إدارة متكامل',
                        style: TextStyle(color: kPrimaryLight, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kPrimary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: kPrimaryLight, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getFormattedDate(),
                    style: const TextStyle(
                        color: kWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              children: [
                _buildSidebarItem(
                    id: 'dashboard',
                    title: 'لوحة التحكم',
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard),
                _buildSidebarItem(
                    id: 'teachers',
                    title: 'ملفات المدرسين',
                    icon: Icons.person_outline,
                    activeIcon: Icons.person),
                _buildSidebarItem(
                    id: 'students',
                    title: 'ملفات الطلاب',
                    icon: Icons.people_outline,
                    activeIcon: Icons.people),
                _buildSidebarItem(
                    id: 'sessions',
                    title: 'جدول الحصص الأسبوعي',
                    icon: Icons.calendar_month_outlined,
                    activeIcon: Icons.calendar_month),
                _buildSidebarItem(
                    id: 'attendance',
                    title: 'تسجيل الحضور والغياب',
                    icon: Icons.fact_check_outlined,
                    activeIcon: Icons.fact_check),
                const SizedBox(height: 24),
                const Divider(color: kGray, height: 1),
                const SizedBox(height: 16),
                _buildSidebarItem(
                  id: 'attendance-review',
                  title: 'سجل الحضور السابق',
                  icon: Icons.history_outlined,
                  activeIcon: Icons.history,
                  customColor: kWarning,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required String id,
    required String title,
    required IconData icon,
    required IconData activeIcon,
    Color? customColor,
  }) {
    final isSelected = _currentTab == id;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _currentTab = id;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      kPrimary.withOpacity(0.2),
                      kPrimary.withOpacity(0.05)
                    ],
                  )
                : null,
            color: isSelected ? kPrimary.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: kPrimary.withOpacity(0.3))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? kPrimary : (customColor ?? kGray),
                size: 22,
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? kWhite : (customColor ?? kGray),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatsRow(),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildTodaySessionsCard(),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 1,
                child: _buildQuickActionsCard(),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final List<Map<String, dynamic>> stats = [
      {
        'title': 'إجمالي المدرسين',
        'value': '${_teachers.length}',
        'icon': Icons.person,
        'color': kPrimary
      },
      {
        'title': 'إجمالي الطلاب',
        'value': '${_students.length}',
        'icon': Icons.people,
        'color': kPrimary
      },
      {
        'title': 'إجمالي حصص الأسبوع',
        'value': '${_sessions.length}',
        'icon': Icons.calendar_month,
        'color': kPrimary
      },
      {
        'title': 'إجمالي المديونيات',
        'value': '$totalDebts ج.م',
        'icon': Icons.monetization_on,
        'color': kDanger
      },
    ];
    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: kDark.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stat['title'],
                        style: TextStyle(
                            color: kGray,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    Text(
                      stat['value'],
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: stat['color'],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        stat['color'].withOpacity(0.15),
                        stat['color'].withOpacity(0.05)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(stat['icon'], color: stat['color'], size: 48),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTodaySessionsCard() {
    final String todayEng = _getCurrentDayEnglish();
    final todaySessions = _sessions.where((s) => s.day == todayEng).toList();
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'حصص اليوم المجدولة',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Text(
                    _weekdaysAr[todayEng] ?? 'اليوم',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: kPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (todaySessions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(80),
                  child: Column(
                    children: [
                      Icon(Icons.coffee, size: 80, color: kGray),
                      SizedBox(height: 20),
                      Text('لا توجد حصص مجدولة لهذا اليوم',
                          style: TextStyle(fontSize: 16, color: kGray)),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: todaySessions.length,
                itemBuilder: (context, index) {
                  final session = todaySessions[index];
                  final teacher = _teachers.firstWhere(
                      (t) => t.id == session.teacherId,
                      orElse: () => Teacher(
                          id: '', name: 'مدرس مجهول', subject: '', phone: ''));
                  final enrolledCount = _students
                      .where((s) =>
                          s.grade == session.grade ||
                          s.enrolledSessions.contains(session.id))
                      .length;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: kLight,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: kGray.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    kPrimary.withOpacity(0.15),
                                    kPrimary.withOpacity(0.05)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.cast_for_education,
                                  color: kPrimary, size: 44),
                            ),
                            const SizedBox(width: 24),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(session.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: kPrimary)),
                                const SizedBox(height: 8),
                                Text('${teacher.subject} - ${teacher.name}',
                                    style: const TextStyle(
                                        fontSize: 15, color: kGray)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: kPrimary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(session.time,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: kPrimary)),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.school,
                                        size: 14, color: kGray),
                                    const SizedBox(width: 6),
                                    Text('${session.grade}',
                                        style: const TextStyle(
                                            fontSize: 14, color: kGray)),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.people,
                                        size: 14, color: kGray),
                                    const SizedBox(width: 6),
                                    Text('$enrolledCount طالب',
                                        style: const TextStyle(
                                            fontSize: 14, color: kGray)),
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
                              _loadStudentsForAttendance(session.id);
                            });
                          },
                          icon:
                              const Icon(Icons.check_circle_outline, size: 24),
                          label: const Text('تسجيل الحضور',
                              style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            foregroundColor: kWhite,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('لوحة العمل السريع',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            const SizedBox(height: 20),
            const Text('إضافة وتعديل البيانات بسرعة',
                style: TextStyle(color: kGray, fontSize: 16)),
            const SizedBox(height: 40),
            _buildQuickActionButton(
              icon: Icons.person_add,
              label: 'إضافة طالب جديد',
              onPressed: () => _openAddStudentDialog(),
              color: kPrimary,
            ),
            const SizedBox(height: 24),
            _buildQuickActionButton(
              icon: Icons.add_home_work,
              label: 'إضافة مدرس جديد',
              onPressed: () => _openAddTeacherDialog(),
              color: kPrimary,
              isOutlined: true,
            ),
            const SizedBox(height: 24),
            _buildQuickActionButton(
              icon: Icons.more_time,
              label: 'إضافة حصة جديدة',
              onPressed: () => _openAddSessionDialog(),
              color: kPrimary,
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isOutlined = false,
  }) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 32),
        label: Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color, width: 2.5),
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 32),
      label: Text(
        label,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildTeachersTab() {
    final filtered = _teachers.where((t) {
      final q = _teacherSearchQuery.toLowerCase();
      return t.name.toLowerCase().contains(q) ||
          t.subject.toLowerCase().contains(q);
    }).toList();
    return Column(
      children: [
        _buildPageHeader(
          title: 'إدارة ملفات المدرسين',
          subtitle: 'اضغط على سطر المدرس لفتح حسابه المالي وجدوله',
          buttonText: 'إضافة مدرس جديد',
          buttonIcon: Icons.add,
          onPressed: () => _openAddTeacherDialog(),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                _buildSearchBar(
                  hint: 'ابحث باسم المدرس أو المادة...',
                  query: _teacherSearchQuery,
                  onChanged: (val) => setState(() => _teacherSearchQuery = val),
                  count: filtered.length,
                  label: 'مدرس',
                ),
                _buildTeachersHeader(),
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: kGray.withOpacity(0.1)),
                    itemBuilder: (context, index) {
                      final teacher = filtered[index];
                      final sessCount = _sessions
                          .where((s) => s.teacherId == teacher.id)
                          .length;
                      return InkWell(
                        onTap: () => _openTeacherProfileDialog(teacher),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      kPrimary.withOpacity(0.15),
                                      kPrimary.withOpacity(0.05)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.person,
                                    color: kPrimary, size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 3,
                                child: Text(teacher.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: kDark)),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(teacher.subject,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: kPrimary)),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(teacher.phone,
                                    style: const TextStyle(
                                        fontFamily: 'Courier', fontSize: 12)),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text('$sessCount حصة أسبوعياً',
                                    style: const TextStyle(
                                        fontSize: 12, color: kGray)),
                              ),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: kPrimary, size: 18),
                                      onPressed: () =>
                                          _openAddTeacherDialog(teacher),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: kDanger, size: 18),
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
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeachersHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: const [
          SizedBox(width: 56),
          Expanded(
              flex: 3,
              child: Text('اسم المدرس',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(
              flex: 2,
              child: Text('المادة الدراسية',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(
              flex: 2,
              child: Text('رقم الهاتف',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(
              flex: 2,
              child: Text('عدد الحصص',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(
              flex: 1,
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('خيارات',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12)))),
        ],
      ),
    );
  }

  Widget _buildStudentsTab() {
    final filtered = _students.where((s) {
      final q = _studentSearchQuery.toLowerCase();
      return s.name.toLowerCase().contains(q) ||
          s.grade.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        _buildPageHeader(
          title: 'إدارة ملفات الطلاب والمديونيات',
          subtitle: 'اضغط على سطر الطالب لعرض مديونيته وتفاصيله',
          buttonText: 'إضافة طالب جديد',
          buttonIcon: Icons.add,
          onPressed: () => _openAddStudentDialog(),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                _buildSearchBar(
                  hint: 'ابحث باسم الطالب أو الصف الدراسي...',
                  query: _studentSearchQuery,
                  onChanged: (val) => setState(() => _studentSearchQuery = val),
                  count: filtered.length,
                  label: 'طالب',
                ),
                _buildStudentsHeader(),
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: kGray.withOpacity(0.1)),
                    itemBuilder: (context, index) {
                      final student = filtered[index];
                      final studentDebt = getStudentTotalDebts(student.id);

                      return InkWell(
                        onTap: () => _openStudentProfileDialog(student),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      kPrimary.withOpacity(0.15),
                                      kPrimary.withOpacity(0.05)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.person,
                                    color: kPrimary, size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 3,
                                child: Text(student.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: kDark)),
                              ),
                              Expanded(
                                  flex: 2,
                                  child: Text(student.grade,
                                      style: const TextStyle(fontSize: 12))),
                              Expanded(
                                  flex: 2,
                                  child: Text(student.phone,
                                      style: const TextStyle(
                                          fontFamily: 'Courier',
                                          fontSize: 12))),
                              Expanded(
                                  flex: 2,
                                  child: Text(student.parentPhone,
                                      style: const TextStyle(
                                          fontFamily: 'Courier',
                                          fontSize: 12))),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '$studentDebt ج.م',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: studentDebt > 0 ? kDanger : kGray,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '${student.enrolledSessions.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: kPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      child: IconButton(
                                        icon: const Icon(Icons.class_outlined,
                                            color: kPrimary, size: 18),
                                        onPressed: () {
                                          _manageStudentSessions(student);
                                        },
                                        tooltip: 'إدارة الحصص',
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: kPrimary, size: 18),
                                      onPressed: () =>
                                          _openAddStudentDialog(student),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: kDanger, size: 18),
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
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: const [
          SizedBox(width: 56),
          Expanded(
              flex: 3,
              child: Text('اسم الطالب',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(
              flex: 2,
              child: Text('الصف الدراسي',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(
              flex: 2,
              child: Text('هاتف الطالب',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(
              flex: 2,
              child: Text('هاتف ولي الأمر',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(
              flex: 2,
              child: Text('المديونية',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(
              flex: 1,
              child: Text('الحصص',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(
              flex: 2,
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('الخيارات',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12)))),
        ],
      ),
    );
  }

  Widget _buildSessionsTab() {
    return Column(
      children: [
        _buildPageHeader(
          title: 'جدول الحصص الأسبوعي للسنتر',
          subtitle: 'تنظيم الحصص الأسبوعية وربطها بالمدرسين والصفوف',
          buttonText: 'إضافة حصة جديدة',
          buttonIcon: Icons.add,
          onPressed: () => _openAddSessionDialog(),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _weekdaysEn.map((dayEng) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: kDark.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [kPrimary, kPrimaryLight],
                          ),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20)),
                        ),
                        child: Text(
                          _weekdaysAr[dayEng] ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kWhite,
                            fontSize: 14,
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
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.coffee, size: 32, color: kGray.withOpacity(0.5)),
            const SizedBox(height: 8),
            Text('لا توجد حصص', style: TextStyle(color: kGray, fontSize: 11)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: daySessions.length,
      itemBuilder: (context, index) {
        final session = daySessions[index];
        final teacher = _teachers.firstWhere((t) => t.id == session.teacherId,
            orElse: () =>
                Teacher(id: '', name: 'مدرس', subject: '', phone: ''));

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kGray.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(session.time,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: kPrimary)),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${session.price} ج.م',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: kPrimary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(session.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12, color: kDark)),
              const SizedBox(height: 4),
              Text(teacher.name,
                  style: const TextStyle(fontSize: 10, color: kGray)),
              Text(teacher.subject,
                  style: const TextStyle(fontSize: 9, color: kGray)),
              const SizedBox(height: 4),
              Text(session.grade,
                  style: const TextStyle(fontSize: 9, color: kPrimary)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => _openAddSessionDialog(session),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.edit, size: 14, color: kPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _confirmDeleteSession(session),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: kDanger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete, size: 14, color: kDanger),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  List<AttendanceRecord> _tempAttendanceList = [];
  Widget _buildAttendanceTab() {
    final todayEng = _getCurrentDayEnglish();
    final todaySessions = _sessions.where((s) => s.day == todayEng).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPageHeader(
          title: 'رصد الحضور والغياب والمديونيات',
          subtitle: 'رصد حصص اليوم الحالي (${_weekdaysAr[todayEng]})',
          buttonText: '',
          buttonIcon: Icons.add,
          onPressed: () {},
          showButton: false,
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: kPrimary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedAttendanceSessionId,
                    hint: const Text('اختر حصة للبدء في الرصد...'),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: kWhite,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: kGray.withOpacity(0.2))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: kPrimary, width: 2)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    items: todaySessions.map((s) {
                      final teacher = _teachers.firstWhere(
                          (t) => t.id == s.teacherId,
                          orElse: () => Teacher(
                              id: '', name: 'مدرس', subject: '', phone: ''));
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
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAttendanceSheetHeader(),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _tempAttendanceList.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1, color: kGray.withOpacity(0.1)),
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
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: kPrimary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                          child: Text('${index + 1}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: kPrimary))),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(student.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: _buildStatusBadge(record.status),
                              ),
                              Expanded(
                                flex: 2,
                                child: record.status == 'debt'
                                    ? Row(
                                        children: [
                                          SizedBox(
                                            width: 80,
                                            height: 40,
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
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 8),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (val) {
                                                double debtVal =
                                                    double.tryParse(val) ?? 0.0;
                                                if (debtVal > session.price)
                                                  debtVal = session.price;
                                                setState(() =>
                                                    record.debt = debtVal);
                                                _updateSingleAttendanceRecord(
                                                    record);
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text('من أصل ${session.price} ج.م',
                                              style: const TextStyle(
                                                  fontSize: 10, color: kGray)),
                                        ],
                                      )
                                    : const Text('-',
                                        style: TextStyle(color: kGray)),
                              ),
                              Expanded(
                                flex: 3,
                                child: isLocked
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: kGray.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text('تم قفل الحصة',
                                            style: TextStyle(
                                                color: kGray, fontSize: 11)),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          _buildAttendanceStatusButton(index,
                                              'present', 'حاضر', kSuccess),
                                          const SizedBox(width: 8),
                                          _buildAttendanceStatusButton(
                                              index, 'absent', 'غائب', kDanger),
                                          const SizedBox(width: 8),
                                          _buildAttendanceStatusButton(index,
                                              'debt', 'مديونية', kWarning),
                                        ],
                                      ),
                              )
                            ],
                          ),
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

  Widget _buildAttendanceStatusButton(
      int index, String status, String label, Color color) {
    return InkWell(
      onTap: () {
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }

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

    final targetStudents = _students.where((s) {
      return s.enrolledSessions.contains(session.id);
    }).toList();
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('حصة: ${session.name}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: kPrimary)),
              const SizedBox(height: 4),
              Text('المدرس: ${teacher.name} (${teacher.subject})',
                  style: const TextStyle(fontSize: 12, color: kGray)),
              Text('${session.grade} | سعر الحصة: ${session.price} ج.م',
                  style: const TextStyle(fontSize: 11, color: kGray)),
            ],
          ),
          if (!isLocked)
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      for (var r in _tempAttendanceList) {
                        r.status = 'present';
                        r.debt = 0.0;
                      }
                    });
                    for (var r in _tempAttendanceList)
                      _updateSingleAttendanceRecord(r);
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('تحضير الكل'),
                  style: OutlinedButton.styleFrom(foregroundColor: kSuccess),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      for (var r in _tempAttendanceList) {
                        r.status = 'absent';
                        r.debt = 0.0;
                      }
                    });
                    for (var r in _tempAttendanceList)
                      _updateSingleAttendanceRecord(r);
                  },
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('تغييب الكل'),
                  style: OutlinedButton.styleFrom(foregroundColor: kDanger),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kSuccess.withOpacity(0.1),
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: kSuccess),
                const SizedBox(width: 8),
                const Text('تم تأكيد وحفظ الدفتر وقفل الحصة',
                    style: TextStyle(
                        color: kSuccess, fontWeight: FontWeight.bold)),
              ],
            ),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _lockedSessionsToday.remove(_selectedAttendanceSessionId!);
                  _saveStateToPrefs();
                });
                _showSuccessSnackBar('تم فتح الحصة بنجاح (يمكنك التعديل الآن)');
              },
              icon: const Icon(Icons.lock_open, size: 16),
              label: const Text('إعادة فتح الحصة'),
              style: OutlinedButton.styleFrom(foregroundColor: kWarning),
            )
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              setState(() =>
                  _lockedSessionsToday.add(_selectedAttendanceSessionId!));
              _saveStateToPrefs();
              _showSuccessSnackBar('تم حفظ وتأكيد دفتر الحضور');
            },
            icon: const Icon(Icons.verified),
            label: const Text('حفظ وتأكيد دفتر الحضور (قفل الحصة)'),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceReviewTab() {
    final String dateString =
        "${_selectedReviewDate.year}-${_selectedReviewDate.month.toString().padLeft(2, '0')}-${_selectedReviewDate.day.toString().padLeft(2, '0')}";
    final recordsForDate =
        _attendance.where((a) => a.date == dateString).toList();

    // فصل السجلات إلى حضور ومديونيات عادية ومديونيات مسددة
    final Map<String, List<AttendanceRecord>> grouped = {};
    final Map<String, List<AttendanceRecord>> groupedPaidDebts = {};

    for (var r in recordsForDate) {
      if (r.sessionId == 'custom') {
        // للمديونيات العادية والمسددة
        if (r.status == 'paid') {
          if (!groupedPaidDebts.containsKey(r.sessionId))
            groupedPaidDebts[r.sessionId] = [];
          groupedPaidDebts[r.sessionId]!.add(r);
        } else {
          if (!grouped.containsKey(r.sessionId)) grouped[r.sessionId] = [];
          grouped[r.sessionId]!.add(r);
        }
      } else {
        if (!grouped.containsKey(r.sessionId)) grouped[r.sessionId] = [];
        grouped[r.sessionId]!.add(r);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPageHeader(
          title: 'سجل الحضور والغياب السابقة',
          subtitle: 'مراجعة سجلات الحضور للطلاب في أي تاريخ',
          buttonText: '',
          buttonIcon: Icons.add,
          onPressed: () {},
          showButton: false,
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedReviewDate,
                        firstDate: DateTime(2025),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null)
                        setState(() => _selectedReviewDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: kWhite,
                        border: Border.all(color: kPrimary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(dateString,
                              style: const TextStyle(
                                  fontFamily: 'Courier',
                                  fontWeight: FontWeight.bold,
                                  color: kPrimary)),
                          const Icon(Icons.calendar_month, color: kPrimary),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.refresh),
                  label: const Text('تحديث'),
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView(
            children: [
              // عرض سجلات الحضور والمديونيات العادية
              if (grouped.isNotEmpty) ...[
                const Text('سجلات الحضور والمديونيات',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ...grouped.entries.map((entry) {
                  final String sessId = entry.key;
                  final List<AttendanceRecord> list = entry.value;

                  String title = "مديونيات خارجية";
                  String subtitle = "تسجيل مبيعات ملازم ومراجعات خارجية";

                  if (sessId != 'custom') {
                    final session = _sessions.firstWhere((s) => s.id == sessId,
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
                  final present =
                      list.where((r) => r.status == 'present').length;
                  final absent = list.where((r) => r.status == 'absent').length;
                  final debt = list.where((r) => r.status == 'debt').length;

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ExpansionTile(
                      title: Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: kPrimary)),
                      subtitle: Text(subtitle,
                          style: const TextStyle(color: kGray, fontSize: 11)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildReviewCountBadge('حاضر', present, kSuccess),
                          const SizedBox(width: 4),
                          _buildReviewCountBadge('غائب', absent, kDanger),
                          const SizedBox(width: 4),
                          _buildReviewCountBadge('مديونية', debt, kWarning),
                          const SizedBox(width: 12),
                          const Icon(Icons.arrow_drop_down, color: kGray),
                        ],
                      ),
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: kLight,
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(16)),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: list.length,
                            separatorBuilder: (context, i) => Divider(
                                height: 1, color: kGray.withOpacity(0.1)),
                            itemBuilder: (context, i) {
                              final rec = list[i];
                              final student = _students.firstWhere(
                                  (s) => s.id == rec.studentId,
                                  orElse: () => Student(
                                      id: '',
                                      name: 'طالب محذوف',
                                      grade: '',
                                      phone: '',
                                      parentPhone: '',
                                      enrolledSessions: []));
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 14),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: kPrimary.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                              child: Text('${i + 1}',
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: kPrimary))),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(student.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    _buildStatusBadge(rec.status),
                                    Text(
                                      rec.status == 'debt'
                                          ? '${rec.debt} ج.م'
                                          : '-',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: rec.status == 'debt'
                                              ? kDanger
                                              : kGray),
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
                }),
              ],

              // عرض المديونيات المسددة بشكل منفصل
              if (groupedPaidDebts.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text('المديونيات المسددة',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: kSuccess)),
                const SizedBox(height: 12),
                ...groupedPaidDebts.entries.map((entry) {
                  final List<AttendanceRecord> list = entry.value;

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    color: kSuccess.withOpacity(0.05),
                    child: ExpansionTile(
                      title: const Text('مدفوعات خارجية',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: kSuccess)),
                      subtitle: const Text('مديونيات تم تسديدها بالكامل',
                          style: TextStyle(color: kSuccess, fontSize: 11)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildReviewCountBadge(
                              'مسددة', list.length, kSuccess),
                          const SizedBox(width: 12),
                          const Icon(Icons.arrow_drop_down, color: kGray),
                        ],
                      ),
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: kLight,
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(16)),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: list.length,
                            separatorBuilder: (context, i) => Divider(
                                height: 1, color: kGray.withOpacity(0.1)),
                            itemBuilder: (context, i) {
                              final rec = list[i];
                              final student = _students.firstWhere(
                                  (s) => s.id == rec.studentId,
                                  orElse: () => Student(
                                      id: '',
                                      name: 'طالب محذوف',
                                      grade: '',
                                      phone: '',
                                      parentPhone: '',
                                      enrolledSessions: []));
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 14),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: kSuccess.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                              child: Text('${i + 1}',
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: kSuccess))),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(student.name,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13)),
                                            if (rec.customReason.isNotEmpty)
                                              Text(rec.customReason,
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      color: kGray)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: kSuccess.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.check_circle,
                                              size: 14, color: kSuccess),
                                          const SizedBox(width: 4),
                                          Text('تم السداد',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: kSuccess)),
                                        ],
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
                }),
              ],

              if (grouped.isEmpty && groupedPaidDebts.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.calendar_view_day, size: 64, color: kGray),
                        SizedBox(height: 16),
                        Text('لا توجد سجلات حضور في هذا التاريخ',
                            style: TextStyle(color: kGray)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCountBadge(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('$label: $value',
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = kGray;
    String label = 'غائب';

    if (status == 'present') {
      bg = kSuccess;
      label = 'حاضر';
    } else if (status == 'absent') {
      bg = kDanger;
      label = 'غائب';
    } else if (status == 'debt') {
      bg = kWarning;
      label = 'مديونية';
    } else if (status == 'paid') {
      bg = kSuccess;
      label = 'مسددة';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style:
              TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: bg)),
    );
  }

  Widget _buildPageHeader({
    required String title,
    required String subtitle,
    required String buttonText,
    required IconData buttonIcon,
    required VoidCallback onPressed,
    bool showButton = true,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: kGray, fontSize: 12)),
          ],
        ),
        if (showButton)
          ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(buttonIcon),
            label: Text(buttonText),
          ),
      ],
    );
  }

  Widget _buildSearchBar({
    required String hint,
    required String query,
    required Function(String) onChanged,
    required int count,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: const Icon(Icons.search, color: kGray),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: kWhite,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('المجموع: $count $label',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: kPrimary)),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: kWhite),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: kSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

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
          child: Dialog(
            elevation: 8,
            backgroundColor: Colors.transparent,
            child: Container(
              width: 500,
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: kDark.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [kPrimary, kPrimaryDark]),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: kWhite.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(isEdit ? Icons.edit : Icons.person_add,
                              color: kWhite, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                isEdit ? 'تعديل ملف المدرس' : 'إضافة مدرس جديد',
                                style: const TextStyle(
                                    color: kWhite,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                                isEdit
                                    ? 'قم بتحديث بيانات المدرس'
                                    : 'أدخل بيانات المدرس الجديد',
                                style: TextStyle(
                                    color: kWhite.withOpacity(0.8),
                                    fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                              labelText: 'اسم المدرس ثلاثي',
                              prefixIcon: Icon(Icons.person_outline)),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: subjectController,
                          decoration: const InputDecoration(
                              labelText: 'المادة الدراسية',
                              prefixIcon: Icon(Icons.book_outlined)),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                              labelText: 'رقم الهاتف',
                              prefixIcon: Icon(Icons.phone_outlined)),
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('إلغاء'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (nameController.text.isEmpty ||
                                  subjectController.text.isEmpty ||
                                  phoneController.text.isEmpty) return;
                              setState(() {
                                if (isEdit) {
                                  final idx = _teachers
                                      .indexWhere((t) => t.id == teacher.id);
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
                              _showSuccessSnackBar(isEdit
                                  ? 'تم تعديل بيانات المدرس'
                                  : 'تم إضافة المدرس بنجاح');
                            },
                            child: const Text('حفظ البيانات'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

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
              return Dialog(
                elevation: 8,
                backgroundColor: Colors.transparent,
                child: Container(
                  width: 550,
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: kDark.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [kPrimary, kPrimaryDark]),
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(28),
                              topRight: Radius.circular(28)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: kWhite.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                  isEdit ? Icons.edit : Icons.person_add,
                                  color: kWhite,
                                  size: 28),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    isEdit
                                        ? 'تعديل ملف الطالب'
                                        : 'إضافة طالب جديد',
                                    style: const TextStyle(
                                        color: kWhite,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(
                                    isEdit
                                        ? 'قم بتحديث بيانات الطالب'
                                        : 'أدخل بيانات الطالب الجديد',
                                    style: TextStyle(
                                        color: kWhite.withOpacity(0.8),
                                        fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                  labelText: 'اسم الطالب ثلاثي',
                                  prefixIcon: Icon(Icons.badge_outlined)),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: selectedGrade,
                              decoration: const InputDecoration(
                                  labelText: 'الصف الدراسي',
                                  prefixIcon: Icon(Icons.school_outlined)),
                              items: _grades
                                  .map((g) => DropdownMenuItem(
                                      value: g, child: Text(g)))
                                  .toList(),
                              onChanged: (val) =>
                                  setDialogState(() => selectedGrade = val!),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: phoneController,
                              decoration: const InputDecoration(
                                  labelText: 'رقم هاتف الطالب',
                                  prefixIcon:
                                      Icon(Icons.phone_android_outlined)),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: parentPhoneController,
                              decoration: const InputDecoration(
                                  labelText: 'رقم هاتف ولي الأمر',
                                  prefixIcon: Icon(Icons.phone_outlined)),
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('إلغاء'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimary),
                                onPressed: () {
                                  if (nameController.text.isEmpty ||
                                      phoneController.text.isEmpty ||
                                      parentPhoneController.text.isEmpty)
                                    return;
                                  setState(() {
                                    if (isEdit) {
                                      final idx = _students.indexWhere(
                                          (s) => s.id == student.id);
                                      _students[idx] = Student(
                                        id: student.id,
                                        name: nameController.text,
                                        grade: selectedGrade,
                                        phone: phoneController.text,
                                        parentPhone: parentPhoneController.text,
                                        enrolledSessions:
                                            student.enrolledSessions,
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
                                  _showSuccessSnackBar(isEdit
                                      ? 'تم تعديل بيانات الطالب'
                                      : 'تم إضافة الطالب بنجاح');
                                },
                                child: const Text('حفظ البيانات'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

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
              return Dialog(
                elevation: 8,
                backgroundColor: Colors.transparent,
                child: Container(
                  width: 600,
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: kDark.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [kPrimary, kPrimaryDark]),
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(28),
                              topRight: Radius.circular(28)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: kWhite.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                  isEdit ? Icons.edit : Icons.calendar_month,
                                  color: kWhite,
                                  size: 28),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(isEdit ? 'تعديل الحصة' : 'إضافة حصة جديدة',
                                    style: const TextStyle(
                                        color: kWhite,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(
                                    isEdit
                                        ? 'قم بتعديل تفاصيل الحصة'
                                        : 'أضف حصة جديدة إلى الجدول',
                                    style: TextStyle(
                                        color: kWhite.withOpacity(0.8),
                                        fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: selectedTeacherId,
                              decoration: const InputDecoration(
                                  labelText: 'المدرس',
                                  prefixIcon: Icon(Icons.person_outline)),
                              items: _teachers
                                  .map((t) => DropdownMenuItem(
                                      value: t.id,
                                      child: Text('${t.name} (${t.subject})')))
                                  .toList(),
                              onChanged: (val) => setDialogState(
                                  () => selectedTeacherId = val!),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                  labelText: 'اسم الحصة',
                                  prefixIcon: Icon(Icons.title_outlined)),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: selectedDay,
                                    decoration: const InputDecoration(
                                        labelText: 'اليوم',
                                        prefixIcon: Icon(
                                            Icons.calendar_today_outlined)),
                                    items: _weekdaysEn
                                        .map((d) => DropdownMenuItem(
                                            value: d,
                                            child: Text(_weekdaysAr[d] ?? '')))
                                        .toList(),
                                    onChanged: (val) => setDialogState(
                                        () => selectedDay = val!),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: timeController,
                                    decoration: const InputDecoration(
                                        labelText: 'الوقت',
                                        prefixIcon:
                                            Icon(Icons.access_time_outlined)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: selectedGrade,
                                    decoration: const InputDecoration(
                                        labelText: 'الصف',
                                        prefixIcon:
                                            Icon(Icons.school_outlined)),
                                    items: _grades
                                        .map((g) => DropdownMenuItem(
                                            value: g, child: Text(g)))
                                        .toList(),
                                    onChanged: (val) => setDialogState(
                                        () => selectedGrade = val!),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: priceController,
                                    decoration: const InputDecoration(
                                        labelText: 'السعر (ج.م)',
                                        prefixIcon: Icon(Icons.attach_money)),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('إلغاء'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimary),
                                onPressed: () {
                                  if (selectedTeacherId.isEmpty ||
                                      nameController.text.isEmpty) return;
                                  final double pr =
                                      double.tryParse(priceController.text) ??
                                          50.0;
                                  setState(() {
                                    if (isEdit) {
                                      final idx = _sessions.indexWhere(
                                          (s) => s.id == session.id);
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
                                  _showSuccessSnackBar(isEdit
                                      ? 'تم تعديل الحصة'
                                      : 'تم إضافة الحصة بنجاح');
                                },
                                child: const Text('حفظ الحصة'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _openStudentProfileDialog(Student student) {
    final customDebtReasonController = TextEditingController();
    final customDebtAmountController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setProfileState) {
              final studentTotalDebt = getStudentTotalDebts(student.id);

              // سجلات الحضور العادية
              final attendanceRecords = _attendance
                  .where((a) =>
                      a.studentId == student.id && a.sessionId != 'custom')
                  .toList();

              // المديونيات غير المسددة (من الحصص والمديونيات الخارجية)
              final debtRecords = _attendance
                  .where((a) =>
                      a.studentId == student.id &&
                      a.sessionId != 'custom' &&
                      a.status == 'debt')
                  .toList();

              // المديونيات المسددة
              final paidRecords = _attendance
                  .where((a) =>
                      a.studentId == student.id &&
                      a.sessionId != 'custom' &&
                      a.status == 'paid')
                  .toList();

              // المديونيات الخارجية غير المسددة
              final customDebtRecords = _attendance
                  .where((a) =>
                      a.studentId == student.id &&
                      a.sessionId == 'custom' &&
                      a.status == 'debt')
                  .toList();

              // المديونيات الخارجية المسددة
              final customPaidRecords = _attendance
                  .where((a) =>
                      a.studentId == student.id &&
                      a.sessionId == 'custom' &&
                      a.status == 'paid')
                  .toList();

              return Dialog(
                elevation: 8,
                backgroundColor: Colors.transparent,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double dialogWidth = constraints.maxWidth * 0.95;
                    if (constraints.maxWidth > 1200) {
                      dialogWidth = 1200;
                    }
                    return Container(
                      width: dialogWidth,
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: kDark.withOpacity(0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header Section
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [kPrimary, kPrimaryDark]),
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(28),
                                  topRight: Radius.circular(28)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: kWhite.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Icon(Icons.person,
                                            color: kWhite, size: 36),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(student.name,
                                                style: const TextStyle(
                                                    color: kWhite,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            const SizedBox(height: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: kWhite.withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                  'الصف: ${student.grade}',
                                                  style: const TextStyle(
                                                      color: kWhite,
                                                      fontSize: 12)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: kWhite.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.close,
                                        color: kWhite, size: 22),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  // Info Cards Row
                                  Row(
                                    children: [
                                      _buildProfileCard(
                                          'هاتف الطالب',
                                          student.phone,
                                          Icons.phone_android_outlined,
                                          kPrimary),
                                      const SizedBox(width: 12),
                                      _buildProfileCard(
                                          'هاتف ولي الأمر',
                                          student.parentPhone,
                                          Icons.phone_outlined,
                                          kPrimary),
                                      const SizedBox(width: 12),
                                      _buildProfileCard(
                                          'إجمالي المديونيات',
                                          '$studentTotalDebt ج.م',
                                          Icons.monetization_on,
                                          kDanger),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // ========== قسم السداد الجماعي ==========
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          kSuccess.withOpacity(0.1),
                                          kSuccess.withOpacity(0.05)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: kSuccess.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color:
                                                    kSuccess.withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(Icons.payment,
                                                  color: kSuccess, size: 24),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'سداد المديونيات',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: kSuccess,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'يمكنك تسديد المديونيات المستحقة على الطالب',
                                          style: TextStyle(
                                              fontSize: 12, color: kGray),
                                        ),
                                        const SizedBox(height: 20),

                                        // حقل إدخال المبلغ
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: TextField(
                                                controller:
                                                    customDebtAmountController,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'أدخل المبلغ المراد سداده',
                                                  prefixIcon: Icon(
                                                      Icons.attach_money,
                                                      color: kSuccess),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  filled: true,
                                                  fillColor: kWhite,
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 16),
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () {
                                                  final amount = double.tryParse(
                                                          customDebtAmountController
                                                              .text) ??
                                                      0.0;
                                                  if (amount <= 0) {
                                                    _showSuccessSnackBar(
                                                        'يرجى إدخال مبلغ صحيح');
                                                    return;
                                                  }

                                                  double remainingDebt = amount;

                                                  // سداد المديونيات من الحصص أولاً
                                                  for (var record in debtRecords
                                                      .where((r) =>
                                                          r.status == 'debt')
                                                      .toList()) {
                                                    if (remainingDebt <= 0)
                                                      break;

                                                    if (remainingDebt >=
                                                        record.debt) {
                                                      remainingDebt -=
                                                          record.debt;
                                                      record.debt = 0;
                                                      record.status = 'paid';
                                                    } else {
                                                      record.debt -=
                                                          remainingDebt;
                                                      remainingDebt = 0;
                                                    }
                                                  }

                                                  // ثم سداد المديونيات الخارجية
                                                  for (var record
                                                      in customDebtRecords
                                                          .where((r) =>
                                                              r.status ==
                                                              'debt')
                                                          .toList()) {
                                                    if (remainingDebt <= 0)
                                                      break;

                                                    if (remainingDebt >=
                                                        record.debt) {
                                                      remainingDebt -=
                                                          record.debt;
                                                      record.debt = 0;
                                                      record.status = 'paid';
                                                    } else {
                                                      record.debt -=
                                                          remainingDebt;
                                                      remainingDebt = 0;
                                                    }
                                                  }

                                                  _saveStateToPrefs();
                                                  customDebtAmountController
                                                      .clear();
                                                  setProfileState(() {});
                                                  renderStudents();
                                                  refreshDashboardStats();

                                                  _showSuccessSnackBar(
                                                      'تم تسديد مبلغ ${amount.toStringAsFixed(0)} ج.م بنجاح');
                                                },
                                                icon: const Icon(
                                                    Icons.check_circle,
                                                    size: 20),
                                                label: const Text('تسديد',
                                                    style: TextStyle(
                                                        fontSize: 14)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: kSuccess,
                                                  foregroundColor: kWhite,
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 16),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // قسم الحضور والمديونيات جنب بعض
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // قسم سجل الحضور والغياب
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: kPrimary.withOpacity(0.05),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      decoration: BoxDecoration(
                                                        color: kPrimary
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: const Icon(
                                                          Icons.fact_check,
                                                          color: kPrimary,
                                                          size: 20),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    const Text(
                                                        'سجل الحضور والغياب',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                            color: kDark)),
                                                    const Spacer(),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: kPrimary
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: Text(
                                                          'الإجمالي: ${attendanceRecords.length}',
                                                          style: const TextStyle(
                                                              fontSize: 11,
                                                              color: kPrimary)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxHeight: 350),
                                                child: attendanceRecords.isEmpty
                                                    ? const Center(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  40),
                                                          child: Column(
                                                            children: [
                                                              Icon(Icons.coffee,
                                                                  size: 48,
                                                                  color: kGray),
                                                              SizedBox(
                                                                  height: 12),
                                                              Text(
                                                                  'لا توجد سجلات حضور',
                                                                  style: TextStyle(
                                                                      color:
                                                                          kGray)),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : ListView.separated(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 8),
                                                        itemCount:
                                                            attendanceRecords
                                                                .length,
                                                        separatorBuilder:
                                                            (_, __) => Divider(
                                                                height: 1,
                                                                color: kGray
                                                                    .withOpacity(
                                                                        0.1)),
                                                        itemBuilder:
                                                            (context, idx) {
                                                          final rec =
                                                              attendanceRecords[
                                                                  idx];
                                                          final session = _sessions.firstWhere(
                                                              (s) =>
                                                                  s.id ==
                                                                  rec.sessionId,
                                                              orElse: () => Session(
                                                                  id: '',
                                                                  name:
                                                                      'حصة محذوفة',
                                                                  teacherId: '',
                                                                  day: '',
                                                                  time: '',
                                                                  grade: '',
                                                                  price: 0));
                                                          return Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(12),
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  width: 80,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          6),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: kGray
                                                                        .withOpacity(
                                                                            0.1),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  child: Text(
                                                                      rec.date,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: const TextStyle(
                                                                          fontFamily:
                                                                              'Courier',
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight:
                                                                              FontWeight.w500)),
                                                                ),
                                                                const SizedBox(
                                                                    width: 12),
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                          session
                                                                              .name,
                                                                          style: const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 12),
                                                                          overflow: TextOverflow.ellipsis),
                                                                      const SizedBox(
                                                                          height:
                                                                              2),
                                                                      Text(
                                                                          'الصف: ${session.grade}',
                                                                          style: const TextStyle(
                                                                              fontSize: 10,
                                                                              color: kGray)),
                                                                    ],
                                                                  ),
                                                                ),
                                                                _buildStatusBadge(
                                                                    rec.status),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // قسم المديونيات
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: kWarning.withOpacity(0.05),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                                color:
                                                    kWarning.withOpacity(0.2)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      decoration: BoxDecoration(
                                                        color: kWarning
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: const Icon(
                                                          Icons.monetization_on,
                                                          color: kWarning,
                                                          size: 20),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    const Text('سجل المديونيات',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                            color: kDark)),
                                                    const Spacer(),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: kWarning
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: Text(
                                                          'غير المسددة: ${debtRecords.length + customDebtRecords.length}',
                                                          style: const TextStyle(
                                                              fontSize: 10,
                                                              color: kWarning)),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // عرض المديونيات غير المسددة من الحصص
                                              if (debtRecords.isNotEmpty) ...[
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                                  child: Text('مديونيات الحصص',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                          color: kWarning)),
                                                ),
                                                Container(
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxHeight: 200),
                                                  child: ListView.separated(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8),
                                                    itemCount:
                                                        debtRecords.length,
                                                    separatorBuilder: (_, __) =>
                                                        Divider(
                                                            height: 1,
                                                            color: kGray
                                                                .withOpacity(
                                                                    0.1)),
                                                    itemBuilder:
                                                        (context, idx) {
                                                      final rec =
                                                          debtRecords[idx];
                                                      final session =
                                                          _sessions.firstWhere(
                                                              (s) =>
                                                                  s.id ==
                                                                  rec.sessionId,
                                                              orElse: () => Session(
                                                                  id: '',
                                                                  name:
                                                                      'حصة محذوفة',
                                                                  teacherId: '',
                                                                  day: '',
                                                                  time: '',
                                                                  grade: '',
                                                                  price: 0));
                                                      return Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  width: 80,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          6),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: kGray
                                                                        .withOpacity(
                                                                            0.1),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  child: Text(
                                                                      rec.date,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: const TextStyle(
                                                                          fontFamily:
                                                                              'Courier',
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight:
                                                                              FontWeight.w500)),
                                                                ),
                                                                const SizedBox(
                                                                    width: 12),
                                                                Expanded(
                                                                  child: Text(
                                                                      session
                                                                          .name,
                                                                      style: const TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          fontSize:
                                                                              12),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis),
                                                                ),
                                                                Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          4),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: kWarning
                                                                        .withOpacity(
                                                                            0.1),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                  ),
                                                                  child: Text(
                                                                      '${rec.debt} ج.م',
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              11,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              kWarning)),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],

                                              // عرض المديونيات الخارجية غير المسددة
                                              if (customDebtRecords
                                                  .isNotEmpty) ...[
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                                  child: Text('مديونيات خارجية',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                          color: kWarning)),
                                                ),
                                                Container(
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxHeight: 200),
                                                  child: ListView.separated(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8),
                                                    itemCount: customDebtRecords
                                                        .length,
                                                    separatorBuilder: (_, __) =>
                                                        Divider(
                                                            height: 1,
                                                            color: kGray
                                                                .withOpacity(
                                                                    0.1)),
                                                    itemBuilder:
                                                        (context, idx) {
                                                      final rec =
                                                          customDebtRecords[
                                                              idx];
                                                      return Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              width: 80,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(6),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: kGray
                                                                    .withOpacity(
                                                                        0.1),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              child: Text(rec.date,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: const TextStyle(
                                                                      fontFamily:
                                                                          'Courier',
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500)),
                                                            ),
                                                            const SizedBox(
                                                                width: 12),
                                                            Expanded(
                                                              child: Text(
                                                                  rec.customReason
                                                                          .isEmpty
                                                                      ? 'مديونية بدون بيان'
                                                                      : rec
                                                                          .customReason,
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          12),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis),
                                                            ),
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          4),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: kWarning
                                                                    .withOpacity(
                                                                        0.1),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                              ),
                                                              child: Text(
                                                                  '${rec.debt} ج.م',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          kWarning)),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],

                                              // عرض المديونيات المسددة
                                              if (paidRecords.isNotEmpty ||
                                                  customPaidRecords
                                                      .isNotEmpty) ...[
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                                  child: Text(
                                                      'المديونيات المسددة',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                          color: kSuccess)),
                                                ),
                                                Container(
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxHeight: 200),
                                                  child: ListView.separated(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8),
                                                    itemCount:
                                                        paidRecords.length +
                                                            customPaidRecords
                                                                .length,
                                                    separatorBuilder: (_, __) =>
                                                        Divider(
                                                            height: 1,
                                                            color: kGray
                                                                .withOpacity(
                                                                    0.1)),
                                                    itemBuilder:
                                                        (context, idx) {
                                                      final rec = idx <
                                                              paidRecords.length
                                                          ? paidRecords[idx]
                                                          : customPaidRecords[
                                                              idx -
                                                                  paidRecords
                                                                      .length];
                                                      final session = rec
                                                                  .sessionId !=
                                                              'custom'
                                                          ? _sessions.firstWhere(
                                                              (s) =>
                                                                  s.id ==
                                                                  rec.sessionId,
                                                              orElse: () => Session(
                                                                  id: '',
                                                                  name:
                                                                      'حصة محذوفة',
                                                                  teacherId: '',
                                                                  day: '',
                                                                  time: '',
                                                                  grade: '',
                                                                  price: 0))
                                                          : null;
                                                      return Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              width: 80,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(6),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: kGray
                                                                    .withOpacity(
                                                                        0.1),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              child: Text(rec.date,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: const TextStyle(
                                                                      fontFamily:
                                                                          'Courier',
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500)),
                                                            ),
                                                            const SizedBox(
                                                                width: 12),
                                                            Expanded(
                                                              child: Text(
                                                                rec.sessionId ==
                                                                        'custom'
                                                                    ? (rec.customReason
                                                                            .isEmpty
                                                                        ? 'مديونية خارجية مسددة'
                                                                        : rec
                                                                            .customReason)
                                                                    : (session
                                                                            ?.name ??
                                                                        'حصة مسددة'),
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        12),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          4),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: kSuccess
                                                                    .withOpacity(
                                                                        0.1),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                              ),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: const [
                                                                  Icon(
                                                                      Icons
                                                                          .check_circle,
                                                                      size: 12,
                                                                      color:
                                                                          kSuccess),
                                                                  SizedBox(
                                                                      width: 4),
                                                                  Text('مسددة',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              kSuccess)),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],

                                              if (debtRecords.isEmpty &&
                                                  customDebtRecords.isEmpty &&
                                                  paidRecords.isEmpty &&
                                                  customPaidRecords.isEmpty)
                                                const Center(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(40),
                                                    child: Column(
                                                      children: [
                                                        Icon(Icons.attach_money,
                                                            size: 48,
                                                            color: kGray),
                                                        SizedBox(height: 12),
                                                        Text(
                                                            'لا توجد مديونيات مسجلة',
                                                            style: TextStyle(
                                                                color: kGray)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _manageStudentSessions(Student student) {
    final allSessions =
        _sessions.where((s) => s.grade == student.grade).toList();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Dialog(
                elevation: 8,
                backgroundColor: Colors.transparent,
                child: Container(
                  width: 600,
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: kDark.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [kPrimary, kPrimaryDark]),
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(28),
                              topRight: Radius.circular(28)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: kWhite.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.class_,
                                  color: kWhite, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'إدارة حصص الطالب: ${student.name}',
                                    style: const TextStyle(
                                        color: kWhite,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'اختر الحصص التي يسجل فيها الطالب',
                                    style: TextStyle(
                                        color: kWhite.withOpacity(0.8),
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: kWhite.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.close,
                                    color: kWhite, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: kPrimary.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        color: kPrimary, size: 18),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'الطلاب يظهرون في الحضور فقط للحصص التي تم تسجيلهم فيها',
                                        style: TextStyle(
                                            fontSize: 11, color: kGray),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Row(
                                children: [
                                  Icon(Icons.schedule,
                                      size: 18, color: kPrimary),
                                  SizedBox(width: 6),
                                  Text(
                                    'الحصص المتاحة',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Flexible(
                                child: Container(
                                  constraints:
                                      const BoxConstraints(maxHeight: 350),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: kGray.withOpacity(0.2)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: allSessions.length,
                                    separatorBuilder: (_, __) => Divider(
                                        height: 1,
                                        color: kGray.withOpacity(0.1)),
                                    itemBuilder: (context, index) {
                                      final session = allSessions[index];
                                      final teacher = _teachers.firstWhere(
                                          (t) => t.id == session.teacherId,
                                          orElse: () => Teacher(
                                              id: '',
                                              name: 'مدرس محذوف',
                                              subject: '',
                                              phone: ''));
                                      final isEnrolled = student
                                          .enrolledSessions
                                          .contains(session.id);

                                      return CheckboxListTile(
                                        dense: true,
                                        value: isEnrolled,
                                        onChanged: (checked) {
                                          setState(() {
                                            if (checked == true) {
                                              if (!student.enrolledSessions
                                                  .contains(session.id)) {
                                                student.enrolledSessions
                                                    .add(session.id);
                                              }
                                            } else {
                                              student.enrolledSessions
                                                  .remove(session.id);
                                            }
                                          });
                                          _saveStateToPrefs();
                                          setDialogState(() {});
                                          renderStudents();
                                        },
                                        title: Text(
                                          session.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13),
                                        ),
                                        subtitle: Text(
                                          '${teacher.name} | ${_weekdaysAr[session.day] ?? session.day} | ${session.time}',
                                          style: const TextStyle(
                                              fontSize: 10, color: kGray),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: kLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'المسجل فيها: ${student.enrolledSessions.length} حصة',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: kPrimary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        'صف: ${student.grade}',
                                        style: TextStyle(
                                            fontSize: 10, color: kPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('إغلاق'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showSuccessSnackBar('تم تحديث حصص الطالب');
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: kSuccess),
                                child: const Text('حفظ'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openTeacherProfileDialog(Teacher teacher) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setProfileState) {
              final teacherSessions =
                  _sessions.where((s) => s.teacherId == teacher.id).toList();
              return Dialog(
                elevation: 8,
                backgroundColor: Colors.transparent,
                child: Container(
                  width: 650,
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: kDark.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [kPrimary, kPrimaryDark]),
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(28),
                              topRight: Radius.circular(28)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: kWhite.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(Icons.account_circle,
                                      color: kWhite, size: 40),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(teacher.name,
                                        style: const TextStyle(
                                            color: kWhite,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: kWhite.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                          'مدرس مادة: ${teacher.subject}',
                                          style: const TextStyle(
                                              color: kWhite, fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: kWhite.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.close,
                                    color: kWhite, size: 24),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _buildProfileCard('رقم الهاتف', teacher.phone,
                                    Icons.phone_outlined, kPrimary),
                                const SizedBox(width: 16),
                                _buildProfileCard(
                                    'إجمالي الحصص',
                                    '${teacherSessions.length} حصة',
                                    Icons.calendar_month_outlined,
                                    kPrimary),
                                const SizedBox(width: 16),
                                _buildProfileCard(
                                    'عدد الطلاب',
                                    '${_students.length}',
                                    Icons.people_outline,
                                    kPrimary),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('الحصص الأسبوعية للمدرس',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                TextButton.icon(
                                  onPressed: () {
                                    _openAddSessionDialog(null, teacher.id);
                                    Future.delayed(
                                        const Duration(milliseconds: 300),
                                        () => setProfileState(() {}));
                                  },
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('إضافة حصة',
                                      style: TextStyle(fontSize: 13)),
                                  style: TextButton.styleFrom(
                                      foregroundColor: kPrimary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              height: 280,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: kGray.withOpacity(0.2)),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: teacherSessions.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.schedule,
                                              size: 48,
                                              color: kGray.withOpacity(0.5)),
                                          const SizedBox(height: 12),
                                          Text('لا توجد حصص مجدولة',
                                              style: TextStyle(color: kGray)),
                                        ],
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: teacherSessions.length,
                                      separatorBuilder: (_, __) => Divider(
                                          height: 1,
                                          color: kGray.withOpacity(0.1)),
                                      itemBuilder: (context, idx) {
                                        final sess = teacherSessions[idx];
                                        return Container(
                                          padding: const EdgeInsets.all(14),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: kLight,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color:
                                                      kPrimary.withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Icon(Icons.schedule,
                                                    size: 18, color: kPrimary),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(sess.name,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 13,
                                                            color: kPrimary)),
                                                    Text(
                                                        '${_weekdaysAr[sess.day] ?? sess.day} - ${sess.time}',
                                                        style: const TextStyle(
                                                            fontSize: 11,
                                                            color: kGray)),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color:
                                                      kPrimary.withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text('${sess.price} ج.م',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: kPrimary)),
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                icon: const Icon(Icons.edit,
                                                    size: 18, color: kPrimary),
                                                onPressed: () {
                                                  _openAddSessionDialog(sess);
                                                  Future.delayed(
                                                      const Duration(
                                                          milliseconds: 300),
                                                      () => setProfileState(
                                                          () {}));
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: kGray)),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteTeacher(Teacher teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(Icons.warning_amber_rounded, color: kDanger),
          const SizedBox(width: 8),
          const Text('تأكيد حذف المدرس')
        ]),
        content: Text(
            'هل أنت متأكد من حذف المدرس "${teacher.name}"؟ سيؤدي ذلك لحذف جميع حصصه.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: kGray))),
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
              _showSuccessSnackBar('تم حذف المدرس');
            },
            style: ElevatedButton.styleFrom(backgroundColor: kDanger),
            child: const Text('حذف نهائي'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteStudent(Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(Icons.warning_amber_rounded, color: kDanger),
          const SizedBox(width: 8),
          const Text('تأكيد حذف الطالب')
        ]),
        content: Text('هل أنت متأكد من حذف الطالب "${student.name}" نهائياً؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: kGray))),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _students.removeWhere((s) => s.id == student.id);
                _attendance.removeWhere((a) => a.studentId == student.id);
              });
              _saveStateToPrefs();
              renderStudents();
              Navigator.pop(context);
              _showSuccessSnackBar('تم حذف الطالب');
            },
            style: ElevatedButton.styleFrom(backgroundColor: kDanger),
            child: const Text('حذف نهائي'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSession(Session session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(Icons.warning_amber_rounded, color: kDanger),
          const SizedBox(width: 8),
          const Text('حذف حصة من الجدول')
        ]),
        content: Text('هل تريد إزالة حصة "${session.name}" من جدول الأسبوع؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: kGray))),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _sessions.removeWhere((s) => s.id == session.id);
                _attendance.removeWhere((a) => a.sessionId == session.id);
              });
              _saveStateToPrefs();
              renderSchedule();
              Navigator.pop(context);
              _showSuccessSnackBar('تم حذف الحصة');
            },
            style: ElevatedButton.styleFrom(backgroundColor: kDanger),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void renderTeachers() => setState(() {});
  void renderStudents() => setState(() {});
  void renderSchedule() => setState(() {});
  void refreshDashboardStats() => setState(() {});
}
