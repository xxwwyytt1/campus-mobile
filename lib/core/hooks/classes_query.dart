import 'package:flutter/cupertino.dart';
import 'package:fquery/fquery.dart';
import '../../app_networking.dart';
import '../models/classes.dart';
import '../models/term.dart';

UseQueryResult<StudentClasses, dynamic> useStudentClassesModel(String accessToken) {
  final academicTerm = useFetchAcademicTermModel(accessToken);
  /// fetch courses
  final GRCourses = useFetchGRCoursesModel(accessToken, academicTerm.data!.termCode!);
  final UNCourses = useFetchUNCoursesModel(accessToken, academicTerm.data!.termCode!);
  return useQuery(['StudentClasses'], () async {
      ClassScheduleModel classScheduleModel = ClassScheduleModel();
      // only use isfetching/iserror
      // circle when reload -> isrefeching
      if (GRCourses.isSuccess) {
        classScheduleModel = GRCourses.data!;
      }
      if (UNCourses.isSuccess) {
        if (classScheduleModel.data != null) {
          classScheduleModel = UNCourses.data!;
        } else {
          classScheduleModel.data!.addAll(UNCourses.data!.data as Iterable<ClassData>);
        }
      }
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
      StudentClasses _studentClasses = StudentClasses(classScheduleModel: classScheduleModel,
          enrolledClasses: _enrolledClasses,
          finals: _finals,
          midterms: _midterms,
          academicTermModel: academicTerm.data!);
      _studentClasses.createMapOfClasses();
      return _studentClasses;
  }, enabled: academicTerm.isSuccess && GRCourses.isSuccess && UNCourses.isSuccess);

}




UseQueryResult<AcademicTermModel, dynamic> useFetchAcademicTermModel(String accessToken)
{
  final String academicTermEndpoint =
      'https://o17lydfach.execute-api.us-west-2.amazonaws.com/qa/v1/term/current';

  return useQuery(['AcademicTerm'], () async {
    String _response = await NetworkHelper().authorizedFetch(academicTermEndpoint, {
      "Authorization": 'Bearer $accessToken'
    });
    /// parse data
    final data = academicTermModelFromJson(_response);
    return data;
  });
}

UseQueryResult<ClassScheduleModel, dynamic> useFetchUNCoursesModel(String accessToken, String term)
{
  final String myAcademicHistoryApiEndpoint =
      'https://api-qa.ucsd.edu:8243/student/my/academic_history/v1/class_list';

  return useQuery(['UNCourses'], () async {
    /// fetch data
    String _response = await NetworkHelper().authorizedFetch(
        myAcademicHistoryApiEndpoint + '?academic_level=UN&term_code=' + term,
        {
          "Authorization": 'Bearer $accessToken'
        });

    debugPrint("UNCoursesModel QUERY HOOK: FETCHING DATA!");

    /// parse data
    final data = classScheduleModelFromJson(_response);
    return data;
  });
}

UseQueryResult<ClassScheduleModel, dynamic> useFetchGRCoursesModel(String accessToken, String term)
{
  final String myAcademicHistoryApiEndpoint =
      'https://api-qa.ucsd.edu:8243/student/my/academic_history/v1/class_list';

  return useQuery(['GRCourses'], () async {
    /// fetch data
    String _response = await NetworkHelper().authorizedFetch(
        myAcademicHistoryApiEndpoint + '?academic_level=GR&term_code=' + term,
        {
          "Authorization": 'Bearer $accessToken'
        });

    debugPrint("GRCoursesModel QUERY HOOK: FETCHING DATA!");

    /// parse data
    final data = classScheduleModelFromJson(_response);
    return data;
  });
}