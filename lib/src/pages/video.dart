import 'package:agora_flutter_quickstart/src/services/database.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
void main() => runApp(VideoApp());

class VideoApp extends StatefulWidget {
  final String channelName;// = '123';
  const VideoApp({Key key, this.channelName}) : super(key: key);
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller;
  Stream ktvRoomStream;
  DatabaseMethods databaseMethods = DatabaseMethods();
  Future<void> _initializeVideoPlayerFuture;
  
  void getKTVRoomList() async {
    await databaseMethods.getKtvRoom(widget.channelName).then((value){
      setState(() {
        ktvRoomStream = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getKTVRoomList();
    // final file = File();
    databaseMethods.createOrUpdateKtvRoomVideoState(widget.channelName, 'pause');
    _controller = VideoPlayerController.network('https://tzw0.github.io/videos/perfect.mp4');
    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _controller.initialize();

    // Use the controller to loop the video.
    _controller.setLooping(true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Video Demo',
      home: Scaffold(
        body: StreamBuilder(
          stream: ktvRoomStream,
          builder: (context, snapshot) {
            // print(snapshot.data['videostate']);
            // if (snapshot.hasData && snapshot.data['videostate'] == 'play') {
            //   _controller.play();
            // } else if (snapshot.hasData && snapshot.data['videostate'] == 'pause') {
            //   _controller.pause();
            // }
            var state;
            try {
              state = snapshot.data['videostate'];
            } catch (e) {
              state = 'pause';
            }
            print(state);
            if (snapshot.hasData && state == 'play') {
              _controller.play();
            } else if (snapshot.hasData && state == 'pause') {
              _controller.pause();
            }
            return Center(
              child: _controller.value.initialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : Container(),
            );
          }
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              if (_controller.value.isPlaying) {
                databaseMethods.createOrUpdateKtvRoomVideoState(widget.channelName, 'pause'); //when these 2 commented somehow ok
                _controller.pause();
              } else {
                databaseMethods.createOrUpdateKtvRoomVideoState(widget.channelName, 'play'); //when these 2 commented somehow ok
                _controller.play();
              }
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}