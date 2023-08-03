import 'dart:convert';

class Employee {
  String id;
  String firstName;
  String lastName;
  String role;
  String email;

  Employee(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.role,
      required this.email});

  Employee.fromJson(Map<String, dynamic> jsonData)
      : id = jsonData['id'],
        firstName = jsonData['firstName'],
        lastName = jsonData['lastName'],
        role = jsonData['role'],
        email = jsonData['email'];

  Map<String, dynamic> toJson(Employee emp) => {
        'id': emp.id,
        'firstName': emp.firstName,
        'lastName': emp.lastName,
        'role': emp.role,
        'email': emp.email
      };

  static Map<String, dynamic> toMap(Employee emp) => {
        'id': emp.id,
        'firstName': emp.firstName,
        'lastName': emp.lastName,
        'role': emp.role,
        'email': emp.email,
      };

  static String encode(List<Employee> emp) => json.encode(
        emp.map<Map<String, dynamic>>((emp) => Employee.toMap(emp)).toList(),
      );

  static List<Employee> decode(String emps) =>
      (json.decode(emps) as List<dynamic>)
          .map<Employee>((item) => Employee.fromJson(item))
          .toList();

  void modifyEmployee(String name, String lastName, String email) {
    this.firstName = name;
    this.lastName = lastName;
    this.email = email;
  }
}
