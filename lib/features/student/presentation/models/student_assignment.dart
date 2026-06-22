class StudentAssignment {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String dueDate;
  final String status;
  final String? submissionStatus;
  final int? marks;
  final String? feedback;

  const StudentAssignment({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.dueDate,
    this.status = 'Open',
    this.submissionStatus,
    this.marks,
    this.feedback,
  });
}
