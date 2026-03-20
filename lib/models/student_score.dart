class StudentScore {
  final String studentId;
  final String studentName;
  final String studentCode;
  final String subjectName;
  final String score;

  StudentScore({
    required this.studentId,
    required this.studentName,
    required this.studentCode,
    required this.subjectName,
    required this.score,
  });

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'studentName': studentName,
    'studentCode': studentCode,
    'subjectName': subjectName,
    'score': score,
  };

  factory StudentScore.fromJson(Map<String, dynamic> json) => StudentScore(
    studentId: json['studentId'],
    studentName: json['studentName'],
    studentCode: json['studentCode'],
    subjectName: json['subjectName'],
    score: json['score'],
  );
}
