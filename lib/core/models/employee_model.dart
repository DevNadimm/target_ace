class EmployeeModel {
  final String name;
  final String designation;
  final String department;
  final bool isActive;
  final bool isOnLeave;
  final String shiftStart;
  final String shiftEnd;
  final int totalLeave;
  final int usedLeave;
  final int graceMinutes;

  EmployeeModel({
    required this.name,
    required this.designation,
    required this.department,
    required this.isActive,
    required this.isOnLeave,
    required this.shiftStart,
    required this.shiftEnd,
    required this.totalLeave,
    required this.usedLeave,
    required this.graceMinutes,
  });

  bool get hasLeaveBalance => totalLeave > usedLeave;

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      name: json['name'] ?? '',
      designation: json['designation'] ?? '',
      department: json['department'] ?? '',
      isActive: json['isActive'] ?? true,
      isOnLeave: json['isOnLeave'] ?? false,
      shiftStart: json['shiftStart'] ?? '09:00 AM',
      shiftEnd: json['shiftEnd'] ?? '05:00 PM',
      totalLeave: json['totalLeave'] ?? 20,
      usedLeave: json['usedLeave'] ?? 0,
      graceMinutes: json['graceMinutes'] ?? 15,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'designation': designation,
      'department': department,
      'isActive': isActive,
      'isOnLeave': isOnLeave,
      'shiftStart': shiftStart,
      'shiftEnd': shiftEnd,
      'totalLeave': totalLeave,
      'usedLeave': usedLeave,
      'graceMinutes': graceMinutes,
    };
  }
}

final List<EmployeeModel> dummyEmployees = [
  EmployeeModel(
    name: 'Nadim Ahmed',
    designation: 'Flutter Developer',
    department: 'IT',
    isActive: true,
    isOnLeave: false,
    shiftStart: '09:00 AM',
    shiftEnd: '06:00 PM',
    totalLeave: 20,
    usedLeave: 5,
    graceMinutes: 15,
  ),
  EmployeeModel(
    name: 'Sarah Khan',
    designation: 'HR Manager',
    department: 'HR',
    isActive: true,
    isOnLeave: false,
    shiftStart: '09:00 AM',
    shiftEnd: '05:00 PM',
    totalLeave: 22,
    usedLeave: 22,
    graceMinutes: 10,
  ),
  EmployeeModel(
    name: 'Tanvir Rahman',
    designation: 'UI/UX Designer',
    department: 'Design',
    isActive: true,
    isOnLeave: true,
    shiftStart: '10:00 AM',
    shiftEnd: '06:00 PM',
    totalLeave: 24,
    usedLeave: 12,
    graceMinutes: 20,
  ),
  EmployeeModel(
    name: 'Mizanur Rahman',
    designation: 'Backend Developer',
    department: 'IT',
    isActive: false,
    isOnLeave: false,
    shiftStart: '09:00 AM',
    shiftEnd: '05:00 PM',
    totalLeave: 20,
    usedLeave: 10,
    graceMinutes: 15,
  ),
  EmployeeModel(
    name: 'Farhana Yasmin',
    designation: 'Sales Executive',
    department: 'Sales',
    isActive: true,
    isOnLeave: false,
    shiftStart: '08:30 AM',
    shiftEnd: '04:30 PM',
    totalLeave: 18,
    usedLeave: 4,
    graceMinutes: 15,
  ),
];

