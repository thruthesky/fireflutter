import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class MeetupCustomize {
  Widget Function(Meetup)? meetupDetails;
  
  Widget Function(Meetup)? meetupDetailsPhoto;

  MeetupCustomize({
    this.meetupDetails,
    this.meetupDetailsPhoto
  });
}
