import 'package:campus_mobile_experimental/core/models/classes.dart';
// import 'package:campus_mobile_experimental/core/providers/classes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/hooks/classes_query.dart';
import '../../core/providers/user.dart';

class UpcomingCoursesList extends HookWidget {
  late final UseQueryResult<StudentClasses, dynamic> classes;
  late final queryClient;
  @override
  Widget build(BuildContext context) {
    final userDataProvider = useMemoized(() {
      debugPrint("Memoized UserDataProvider!");
      return Provider.of<UserDataProvider>(context);
    }, [context]);
    final accessToken = userDataProvider.authenticationModel!.accessToken!;
    classes = useFetchClasses(accessToken);
    queryClient = useQueryClient();

    List<SectionData> data = classes.data!.upcomingCourses;
    final selectedCourseIndex = classes.data!.selectedCourse;
    return buildListOfCourses(data, selectedCourseIndex, context);
  }

  Widget buildListOfCourses(
      List<SectionData> data, int selectedCourse, BuildContext context) {
    List<Widget> listOfCourses = List.generate(data.length, (int index) {
      return buildTile(index, selectedCourse, data[index], context);
    });
    return Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3),
        child: ListView(
          children: listOfCourses,
          shrinkWrap: true,
        ));
  }

  void setSelectedCourse(int index) {
    queryClient.setQueryData<StudentClasses>(['FetchClasses'], (previous) {
      return previous?.selectCourse(index);
    });
  }

  Widget buildTile(
      int index, int selectedCourse, SectionData data, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, right: 8.0),
      child: Container(
        constraints: BoxConstraints.tightFor(height: 65),
        decoration: createBorder(),
        child: ListTile(
          dense: true,
          onTap: () => setSelectedCourse(index),
          title: buildClassTitle(data),
          subtitle: buildClassTimeText(data, context),
          selected: index == selectedCourse,
          enabled: true,
        ),
      ),
    );
  }

  BoxDecoration createBorder() {
    return BoxDecoration(
      border: Border.all(width: 1),
    );
  }

  Widget buildClassTimeText(SectionData sectionData, BuildContext context) {
    return Text(
      sectionData.days! + ' @ ' + getStartTime(sectionData.time!, context),
    );
  }

  Widget buildClassTitle(SectionData sectionData) {
    return Text(
      sectionData.subjectCode! + ' ' + sectionData.courseCode!,
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  String getStartTime(String time, BuildContext context) {
    List<String> times = time.split("-");
    return stringToTimeOfDay(times[0]).format(context);
  }

  TimeOfDay stringToTimeOfDay(String tod) {
    final format = DateFormat.Hm();
    return TimeOfDay.fromDateTime(format.parse(tod));
  }
}
