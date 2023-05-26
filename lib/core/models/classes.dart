// To parse this JSON data, do
//
//     final classScheduleModel = classScheduleModelFromJson(jsonString);

import 'dart:convert';

import 'package:campus_mobile_experimental/core/models/term.dart';
import 'package:intl/intl.dart';

ClassScheduleModel classScheduleModelFromJson(String str) =>
    ClassScheduleModel.fromJson(json.decode(str));

String classScheduleModelToJson(ClassScheduleModel data) =>
    json.encode(data.toJson());

class ClassScheduleModel {
  Metadata? metadata;
  List<ClassData>? data;

  ClassScheduleModel({
    this.metadata,
    this.data,
  });
  factory ClassScheduleModel.fromJson(Map<String, dynamic> json) =>
      ClassScheduleModel(
        metadata: json["metadata"] == null
            ? null
            : Metadata.fromJson(json["metadata"]),
        data: json["data"] == null
            ? null
            : List<ClassData>.from(
                json["data"].map((x) => ClassData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "metadata": metadata == null ? null : metadata!.toJson(),
        "data": data == null
            ? null
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class ClassData {
  String? termCode;
  String? subjectCode;
  String? courseCode;
  double? units;
  String? courseLevel;
  String? gradeOption;
  String? grade;
  String? courseTitle;
  String? enrollmentStatus;
  String? repeatCode;
  List<SectionData>? sectionData;

  ClassData({
    this.termCode,
    this.subjectCode,
    this.courseCode,
    this.units,
    this.courseLevel,
    this.gradeOption,
    this.grade,
    this.courseTitle,
    this.enrollmentStatus,
    this.repeatCode,
    this.sectionData,
  });

  factory ClassData.fromJson(Map<String, dynamic> json) => ClassData(
        termCode: json["term_code"] == null ? null : json["term_code"],
        subjectCode: json["subject_code"] == null ? null : json["subject_code"],
        courseCode: json["course_code"] == null ? null : json["course_code"],
        units: json["units"] == null ? null : json["units"],
        courseLevel: json["course_level"] == null ? null : json["course_level"],
        gradeOption: json["grade_option"] == null ? null : json["grade_option"],
        grade: json["grade"] == null ? null : json["grade"],
        courseTitle: json["course_title"] == null ? null : json["course_title"],
        enrollmentStatus: json["enrollment_status"] == null
            ? null
            : json["enrollment_status"],
        repeatCode: json["repeat_code"] == null ? null : json["repeat_code"],
        sectionData: json["section_data"] == null
            ? null
            : List<SectionData>.from(
                json["section_data"].map((x) => SectionData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "term_code": termCode == null ? null : termCode,
        "subject_code": subjectCode == null ? null : subjectCode,
        "course_code": courseCode == null ? null : courseCode,
        "units": units == null ? null : units,
        "course_level": courseLevel == null ? null : courseLevel,
        "grade_option": gradeOption == null ? null : gradeOption,
        "grade": grade == null ? null : grade,
        "course_title": courseTitle == null ? null : courseTitle,
        "enrollment_status": enrollmentStatus == null ? null : enrollmentStatus,
        "repeat_code": repeatCode == null ? null : repeatCode,
        "section_data": sectionData == null
            ? null
            : List<dynamic>.from(sectionData!.map((x) => x.toJson())),
      };
}

class SectionData {
  String? section;
  String? meetingType;
  String? time;
  String? days;
  String? date;
  String? building;
  String? room;
  String? instructorName;
  String? specialMtgCode;
  String? subjectCode;
  String? courseCode;
  String? courseTitle;
  late String gradeOption;
  String? enrollStatus;

  SectionData({
    this.section,
    this.meetingType,
    this.time,
    this.days,
    this.date,
    this.building,
    this.room,
    this.instructorName,
    this.specialMtgCode,
    this.enrollStatus,
  });

  factory SectionData.fromJson(Map<String, dynamic> json) => SectionData(
        section: json["section"] == null ? null : json["section"],
        meetingType: json["meeting_type"] == null ? null : json["meeting_type"],
        time: json["time"] == null ? null : json["time"],
        days: json["days"] == null ? null : json["days"],
        date: json["date"] == null ? null : json["date"],
        building: json["building"] == null ? "" : json["building"],
        room: json["room"] == null ? "" : json["room"],
        instructorName:
            json["instructor_name"] == null ? "" : json["instructor_name"],
        specialMtgCode:
            json["special_mtg_code"] == null ? null : json["special_mtg_code"],
        enrollStatus:
            json["enrollStatus"] == null ? null : json["enrollStatus"],
      );

  Map<String, dynamic> toJson() => {
        "section": section == null ? null : section,
        "meeting_type": meetingType == null ? null : meetingType,
        "time": time == null ? null : time,
        "days": days == null ? null : days,
        "date": date == null ? null : date,
        "building": building == null ? "" : building,
        "room": room == null ? "" : room,
        "instructor_name": instructorName == null ? "" : instructorName,
        "special_mtg_code": specialMtgCode == null ? null : specialMtgCode,
        "enrollStatus": enrollStatus == null ? null : enrollStatus,
      };
}

class Metadata {
  Metadata();

  factory Metadata.fromJson(Map<String, dynamic>? json) => Metadata();

  Map<String, dynamic> toJson() => {};
}

class StudentClasses {
  String? nextDayWithClass;
  int? selectedCourse;
  ClassScheduleModel classScheduleModel;
  Map<String, List<SectionData>> enrolledClasses;
  Map<String, List<SectionData>> finals;
  Map<String, List<SectionData>> midterms;
  AcademicTermModel academicTermModel;

  StudentClasses({
    this.nextDayWithClass,
    this.selectedCourse,
    required this.classScheduleModel,
    required this.enrolledClasses,
    required this.finals,
    required this.midterms,
    required this.academicTermModel
  });

  void createMapOfClasses() {
    List<ClassData> enrolledCourses = [];

    /// add only enrolled classes because api returns wait-listed and dropped
    /// courses as well
    for (ClassData classData in classScheduleModel!.data!) {
      if (classData.enrollmentStatus == 'EN') {
        enrolledCourses.add(classData);
      }
    }

    // if (enrolledCourses.isEmpty) {
    //   _error = "No enrolled courses found.";
    //   _isLoading = false;
    //   notifyListeners();
    // }
    for (ClassData classData in enrolledCourses) {
      for (SectionData sectionData in classData.sectionData!) {
        /// copy over info from [ClassData] object and put into [SectionData] object
        sectionData.subjectCode = classData.subjectCode;
        sectionData.courseCode = classData.courseCode;
        sectionData.courseTitle = classData.courseTitle;
        sectionData.gradeOption = buildGradeEvaluation(classData.gradeOption);
        String? day = 'OTHER';
        if (sectionData.days != null) {
          day = sectionData.days;
        } else {
          continue;
        }

        if (sectionData.specialMtgCode != 'FI' &&
            sectionData.specialMtgCode != 'MI') {
          enrolledClasses![day!]!.add(sectionData);
        } else if (sectionData.specialMtgCode == 'FI') {
          finals![day!]!.add(sectionData);
        } else if (sectionData.specialMtgCode == 'MI') {
          midterms!['MI']!.add(sectionData);
        }
      }
    }

    /// chronologically sort classes for each day
    for (List<SectionData> listOfClasses in enrolledClasses!.values.toList()) {
      listOfClasses.sort((a, b) => _compare(a, b));
    }
    for (List<SectionData> listOfFinals in finals!.values.toList()) {
      listOfFinals.sort((a, b) => _compare(a, b));
    }
    for (List<SectionData> listOfMidterms in midterms!.values.toList()) {
      listOfMidterms.sort((a, b) => _compare(a, b));
      listOfMidterms.sort((a, b) => _compareMidterms(a, b));
    }
  }

  int _compareMidterms(SectionData a, SectionData b) {
    DateTime dateTimeA = DateFormat('yyyy-M-dd').parse(a.date!);
    DateTime dateTimeB = DateFormat('yyyy-M-dd').parse(b.date!);

    if (dateTimeA.compareTo(dateTimeB) == 0) {
      return 0;
    }
    if (dateTimeA.compareTo(dateTimeB) < 0) {
      return -1;
    }
    return 1;
  }

  /// comparator that sorts according to start time of class
  int _compare(SectionData a, SectionData b) {
    if (a.time == null || b.time == null) {
      return 0;
    }
    DateTime aStartTime = getStartTime(a.time!);
    DateTime bStartTime = getStartTime(b.time!);

    if (aStartTime == bStartTime) {
      return 0;
    }
    if (aStartTime.isBefore(bStartTime)) {
      return -1;
    }
    return 1;
  }

  buildGradeEvaluation(String? gradeEvaluation) {
    switch (gradeEvaluation) {
      case 'L':
        {
          return 'Letter Grade';
        }
      case 'P':
        {
          return 'Pass/No Pass';
        }
      case 'S':
        {
          return 'Sat/Unsat';
        }
      default:
        {
          return 'Other';
        }
    }
  }

  DateTime getStartTime(String time) {
    List<String> times = time.split("-");
    final format = DateFormat.Hm();
    return format.parse(times[0]);
  }

  List<SectionData> get upcomingCourses {
    try {
      /// get weekday and return [List<SectionData>] associated with current weekday
      List<SectionData> listToReturn = [];
      String today = DateFormat('EEEE')
          .format(DateTime.now())
          .toString()
          .toUpperCase()
          .substring(0, 2);
      nextDayWithClass = DateFormat('EEEE').format(DateTime.now()).toString();

      /// if no classes are scheduled for today then find the next day with classes
      int daysToAdd = 1;

      while (enrolledClasses[today]!.isEmpty && daysToAdd <= 7) {
        today = DateFormat('EEEE')
            .format(DateTime.now().add(Duration(days: daysToAdd)))
            .toString()
            .toUpperCase()
            .substring(0, 2);
        nextDayWithClass = DateFormat('EEEE')
            .format(DateTime.now().add(Duration(days: daysToAdd)));
        daysToAdd += 1;
      }

      if (enrolledClasses[today]!.isNotEmpty) {
        listToReturn.addAll(enrolledClasses[today]!);
      } else {
        listToReturn.addAll([]);
      }
      return listToReturn;
    } catch (err) {
      print('classes provider err');
      print(err);
      return [];
    }
  }

}