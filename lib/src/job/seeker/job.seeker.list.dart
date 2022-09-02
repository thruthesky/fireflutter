import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';

class JobSeekerList extends StatefulWidget {
  JobSeekerList({
    this.options,
    this.onTap,
    Key? key,
    this.padding,
    this.shrinkWrapList = false,
  }) : super(key: key);

  final JobSeekerListOptionsModel? options;
  // final Function(String)? onTapChat;
  final Function(JobSeekerModel)? onTap;
  final EdgeInsets? padding;
  final bool shrinkWrapList;

  @override
  State<JobSeekerList> createState() => _JobSeekerListState();
}

class _JobSeekerListState extends State<JobSeekerList> {
  Query get _query {
    Query q = Job.jobSeekerCol.where('status', isEqualTo: 'Y');

    JobSeekerListOptionsModel options = widget.options ?? JobSeekerListOptionsModel();

    if (options.siNm.isNotEmpty) {
      q = q.where('siNm', isEqualTo: options.siNm);
    }
    if (options.sggNm.isNotEmpty) {
      q = q.where('sggNm', isEqualTo: options.sggNm);
    }

    /// industry filter.
    if (options.industry.isNotEmpty) {
      q = q.where('industry', isEqualTo: options.industry);
    }

    q = q.orderBy('createdAt', descending: true);

    return q;
  }

  @override
  Widget build(BuildContext context) {
    return FirestoreQueryBuilder(
      query: _query,
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return Center(child: Text('loading...'));
        }

        if (snapshot.hasError) {
          // debugPrint("${snapshot.error}");
          return Center(child: Text('Something went wrong! ${snapshot.error}'));
        }

        if (snapshot.docs.isEmpty) {
          return Center(child: Text('No job seekers found...'));
        }

        return ListView.separated(
          padding: EdgeInsets.all(0),
          itemCount: snapshot.docs.length,
          shrinkWrap: widget.shrinkWrapList,
          separatorBuilder: (context, index) => Divider(height: 32),
          itemBuilder: (context, index) {
            if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
              snapshot.fetchMore();
            }

            JobSeekerModel seeker = JobSeekerModel.fromJson(
              snapshot.docs[index].data() as Map<String, dynamic>,
              snapshot.docs[index].id,
            );

            return GestureDetector(
              key: ValueKey(seeker.id),
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap != null ? () => widget.onTap!(seeker) : null,
              child: Container(
                padding: widget.padding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        if (index == 0) SizedBox(height: 32),
                        UserProfilePhoto(uid: seeker.id, size: 55),
                      ],
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0) SizedBox(height: 32),
                          UserDoc(
                            uid: seeker.id,
                            builder: (u) => Text(
                              '${u.firstName} ${u.middleName.isNotEmpty ? u.middleName : ''} ${u.lastName} - ${u.gender}',
                            ),
                          ),
                          SizedBox(height: 4),
                          Text('Industry: ${Job.categories[seeker.industry]}'),
                          SizedBox(height: 4),
                          Text(
                            'Location: ${seeker.siNm}, ${seeker.sggNm}',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.arrow_right),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
