import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:teams/models/call.dart';
import 'package:teams/models/user.dart';
import 'package:teams/provider/user_provider.dart';
import 'package:teams/utils/call_methods.dart';
import 'package:teams/utils/utils.dart';

import '../chat_screen.dart';

/// Call screen widget for one to one video call and chats

class CallScreen extends StatefulWidget {
  final Call call;
  final UserModel receiver;

  CallScreen({
    @required this.call,
    this.receiver,
  });

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallMethods callMethods = CallMethods();

  UserProvider userProvider;
  StreamSubscription callStreamSubscription;

  final users = <int>[];
  final infoStrings = <String>[];
  bool muted = false;
  RtcEngine engine;

  @override
  void initState() {
    super.initState();
    addPostFrameCallback();
    initialize();
  }

  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      setState(() {
        infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await engine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(1920, 1080);
    await engine.setVideoEncoderConfiguration(configuration);
    await engine.joinChannel(null, widget.call.channelId, null, 0);
  }

  addPostFrameCallback() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      userProvider = Provider.of<UserProvider>(context, listen: false);

      callStreamSubscription = callMethods
          .callStream(uid: userProvider.getUser.uid)
          .listen((DocumentSnapshot ds) {
        // defining the logic
        switch (ds.data) {
          case null:
            // snapshot is null which means that call is hanged and documents are deleted
            Navigator.pop(context);
            break;

          default:
            break;
        }
      });
    });
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    engine = await RtcEngine.create(APP_ID);
    await engine.enableVideo();
    // await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    // await _engine.setClientRole(widget.role);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'onError: $code';
        infoStrings.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        infoStrings.add(info);
      });
    }, leaveChannel: (stats) {
      setState(() {
        infoStrings.add('onLeaveChannel');
        users.clear();
      });
    }, userJoined: (uid, elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        infoStrings.add(info);
        users.add(uid);
      });
    }, userOffline: (uid, elapsed) {
      callMethods.endCall(call: widget.call);
      setState(() {
        final info = 'userOffline: $uid';
        infoStrings.add(info);
        users.remove(uid);
      });
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        infoStrings.add(info);
      });
    }));
  }

  /// Helper function to get list of native views
  List<Widget> getRenderViews() {
    final List<StatefulWidget> list = [];
    users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    list.add(RtcLocalView.SurfaceView());
    print(list);
    return list;
  }

  /// Video view wrapper
  Widget videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget viewRows() {
    final views = getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            expandedVideoRow([views[0]]),
            expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            expandedVideoRow(views.sublist(0, 2)),
            expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            expandedVideoRow(views.sublist(0, 2)),
            expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    engine.switchCamera();
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic : Icons.mic_off,
              color: muted ? Colors.white : Colors.orange,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.orange : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () {
              callMethods.endCall(
                call: widget.call,
              );
              Navigator.pop(context);
            },
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.orange,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    receiver: widget.receiver,
                    no: 1,
                  ),
                )),
            child: Icon(
              Icons.chat,
              color: Colors.orange,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // clear users
    users.clear();
    // destroy sdk
    engine.leaveChannel();
    engine.destroy();
    callStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          widget.receiver.name,
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Arial",
            fontSize: 24,
          ),
        ),
      ),
      body: Center(
        child: Stack(
          children: <Widget>[
            viewRows(),
            _toolbar(),
          ],
        ),
      ),
    );
  }
}
