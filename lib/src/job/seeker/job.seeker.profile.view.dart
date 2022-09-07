import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class JobSeekerProfileView extends StatefulWidget {
  JobSeekerProfileView({
    Key? key,
    required this.seeker,
    required this.onChat,
    this.onTapProfilePhoto,
  }) : super(key: key);

  final JobSeekerModel seeker;
  final Function(String) onChat;
  final Function(String)? onTapProfilePhoto;

  @override
  State<JobSeekerProfileView> createState() => _JobSeekerProfileViewState();
}

class _JobSeekerProfileViewState extends State<JobSeekerProfileView> {
  final labelStyle = TextStyle(fontSize: 10, color: Colors.blueGrey);

  @override
  Widget build(BuildContext context) {
    return UserDoc(
      uid: widget.seeker.id,
      builder: (user) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20),
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTapProfilePhoto != null
                  ? () => widget.onTapProfilePhoto!(user.uid)
                  : null,
              child: ProfilePhoto(
                user: user,
                size: 100,
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text('First Name', style: labelStyle),
                  SizedBox(height: 5),
                  Text('${user.firstName}'),
                ],
              ),
              SizedBox(width: 16),
              Column(
                children: [
                  Text('Last Name', style: labelStyle),
                  SizedBox(height: 5),
                  Text('${user.lastName}'),
                ],
              ),
            ],
          ),
          Divider(height: 30),
          Text('Gender', style: labelStyle),
          Text(user.gender == 'F' ? 'Female' : 'Male'),
          SizedBox(height: 18),
          Text('Proficiency', style: labelStyle),
          Text(widget.seeker.proficiency),
          SizedBox(height: 18),
          Text('Years of experience', style: labelStyle),
          Text(widget.seeker.experiences),
          SizedBox(height: 18),
          Text('Location', style: labelStyle),
          Text('${widget.seeker.siNm}, ${widget.seeker.sggNm}'),
          SizedBox(height: 18),
          Text('Industry', style: labelStyle),
          Text('${Job.categories[widget.seeker.industry]}'),
          SizedBox(height: 18),
          Text('Comment', style: labelStyle),
          Text('${widget.seeker.comment}'),
          SizedBox(height: 32),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => widget.onChat(user.uid),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 243, 150, 0),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.maps_ugc_outlined,
                    size: 28,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Send message to ${user.firstName}',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
