import 'package:flutter/cupertino.dart';
import 'package:fquery/fquery.dart';
import '../../app_networking.dart';
import '../models/classes.dart';
import '../models/term.dart';

UseQueryResult<StudentClasses, dynamic> useStudentClassesModel(
    String accessToken,
    AcademicTermModel academicTerm,
    UseQueryResult GRCourses,
    UseQueryResult UNCourses) {
  return useQuery(['StudentClasses'], () async {
    debugPrint("StudentClasses QUERY HOOK: FETCHING DATA!");
    ClassScheduleModel classScheduleModel = ClassScheduleModel();
    if (GRCourses.data != null) {
      classScheduleModel = GRCourses.data!;
    }
    // debugPrint("UNCourses is fetching? " + UNCourses.isFetching.toString());
    debugPrint("UNCourses content: " + UNCourses.data!.data.toString());
    if (UNCourses.data!.data != null) {
      debugPrint(UNCourses.data!.data![0].courseTitle);
    }
    debugPrint("condition: " + UNCourses.isSuccess.toString());
    //&& !UNCourses.isFetching
    if (UNCourses.isSuccess) {
      // debugPrint("UNCourses is null? " + (UNCourses.data == null).toString());
      if (classScheduleModel.data == null) {
        classScheduleModel = UNCourses.data!;
      } else {
        classScheduleModel.data!.addAll(UNCourses.data!.data!);
      }
      debugPrint("classScheduleModel content: ");
      debugPrint(classScheduleModel.data!.toString());
    }
    // debugPrint("classScheduleModel is null? " +
    //     (classScheduleModel.data == null).toString());
    Map<String, List<SectionData>> _enrolledClasses = {
      'MO': [],
      'TU': [],
      'WE': [],
      'TH': [],
      'FR': [],
      'SA': [],
      'SU': [],
      'OTHER': [],
    };

    Map<String, List<SectionData>> _finals = {
      'MO': [],
      'TU': [],
      'WE': [],
      'TH': [],
      'FR': [],
      'SA': [],
      'SU': [],
      'OTHER': [],
    };

    Map<String, List<SectionData>> _midterms = {
      'MI': [],
      'OTHER': [],
    };
    StudentClasses _studentClasses = StudentClasses(
        selectedCourse: 0,
        classScheduleModel: classScheduleModel,
        enrolledClasses: _enrolledClasses,
        finals: _finals,
        midterms: _midterms,
        academicTermModel: academicTerm);
    _studentClasses.createMapOfClasses();
    return _studentClasses;
  }, enabled: (UNCourses.isSuccess || GRCourses.isSuccess));
}

UseQueryResult<StudentClasses, dynamic> useFetchClasses(String accessToken) {
  final academicTerm = useFetchAcademicTermModel(accessToken);

  return useQuery(['FetchClasses'], () async {
    debugPrint("academicTerm: " + academicTerm.data!.termCode!);

    /// fetch courses
    final GRCourses =
        useFetchGRCoursesModel(accessToken, academicTerm.data!.termCode!);
    // debugPrint( "GRCourses: " + GRCourses.isSuccess.toString());
    final UNCourses =
        useFetchUNCoursesModel(accessToken, academicTerm.data!.termCode!);
    debugPrint("UNCourses: " + UNCourses.isSuccess.toString());
    final studentClasses = useStudentClassesModel(
        accessToken, academicTerm.data!, GRCourses, UNCourses);
    return studentClasses.data!;
  }, enabled: academicTerm.isSuccess);
}

UseQueryResult<AcademicTermModel, dynamic> useFetchAcademicTermModel(
    String accessToken) {
  final String academicTermEndpoint =
      'https://o17lydfach.execute-api.us-west-2.amazonaws.com/qa/v1/term/current';

  return useQuery(['AcademicTerm'], () async {
    String _response = await NetworkHelper().authorizedFetch(
        academicTermEndpoint, {"Authorization": 'Bearer $accessToken'});
    debugPrint("AcademicTermModel QUERY HOOK: FETCHING DATA!");

    /// parse data
    final data = academicTermModelFromJson(_response);
    return data;
  });
}

UseQueryResult<ClassScheduleModel, dynamic> useFetchUNCoursesModel(
    String accessToken, String term) {
  final String myAcademicHistoryApiEndpoint =
      'https://api-qa.ucsd.edu:8243/student/my/academic_history/v1/class_list';

  return useQuery(['UNCourses'], () async {
    /// fetch data
    String _response = await NetworkHelper().authorizedFetch(
        myAcademicHistoryApiEndpoint + '?academic_level=UN&term_code=' + term,
        {"Authorization": 'Bearer $accessToken'});

    debugPrint("UNCoursesModel QUERY HOOK: FETCHING DATA!");

    /// parse data
    final data = classScheduleModelFromJson(_response);
    return data;
  });
}

UseQueryResult<ClassScheduleModel, dynamic> useFetchGRCoursesModel(
    String accessToken, String term) {
  final String myAcademicHistoryApiEndpoint =
      'https://api-qa.ucsd.edu:8243/student/my/academic_history/v1/class_list';

  return useQuery(['GRCourses'], () async {
    /// fetch data
    String _response = await NetworkHelper().authorizedFetch(
        myAcademicHistoryApiEndpoint + '?academic_level=GR&term_code=' + term,
        {"Authorization": 'Bearer $accessToken'});

    debugPrint("GRCoursesModel QUERY HOOK: FETCHING DATA!");

    /// parse data
    final data = classScheduleModelFromJson(_response);
    return data;
  });
}
