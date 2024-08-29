import 'dart:async';
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

void main() {
  final controller = Controller()..init();
  runApp(EmbeddedIFrameExample(controller));
}

class EmbeddedIFrameExample extends StatelessWidget {
  const EmbeddedIFrameExample(this.controller, {Key? key}) : super(key: key);

  final Controller controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Embedded iFrame Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Embedded iFrame Example'),
        ),
        body: EmbeddedIFrame(controller),
      ),
    );
  }
}

class EmbeddedIFrame extends StatefulWidget {
  const EmbeddedIFrame(this.controller, {Key? key}) : super(key: key);

  final Controller controller;

  @override
  State<EmbeddedIFrame> createState() => _EmbeddedIFrameState();
}

class _EmbeddedIFrameState extends State<EmbeddedIFrame> {
  @override
  void initState() {
    super.initState();
    // Handle messages from the embedded iFrame that are sent via
    // 'window.postMessage'
    html.window.addEventListener('message', widget.controller.handleMessage);
  }

  @override
  void dispose() {
    html.window.removeEventListener('message', widget.controller.handleMessage);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          const Positioned.fill(
            child: HtmlElementView(
              viewType: Controller.viewId,
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: ElevatedButton(
              onPressed: _ping,
              child: const Text('Post Message'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _ping() async {
    widget.controller.postMessage('PING');
  }
}

class Controller {
  static const viewId = 'my-view-id';

  /// This is a random test web app. The embedded web app will need to have an
  /// event listener (e.g. window.addEventListener('message', _someHandler)) to
  /// receive the post message events we send from [Controller.postMessage]. The
  /// embedded web app can then send events back to this flutter web app by
  /// calling [window.postMessage]. For example, in _someHandler:
  ///
  ///    const windowSource = messageEvent.source as Window;
  ///    windowSource.postMessage('PONG', messageEvent.origin);
  ///
  /// Messages sent from the embedded web app will be handled by
  /// [Controller.handleMessage], provided [Controller.handleMessage] is added
  /// as an event listener to this window (see [_EmbeddedIFrameState.initState]
  /// above).
  static const url = 'https://www.youtube.com/embed/032ePISToJs';

  html.IFrameElement get iFrame => _iFrame;

  late final html.IFrameElement _iFrame;

  // This method should only be called once, registering a view with the same
  // name multiple times may cause issues.
  void init() {
    _iFrame = html.IFrameElement()..src = url;
    _iFrame.style
      ..border = 'none'
      ..height = '100%'
      ..width = '100%';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => _iFrame,
    );
  }

  void postMessage(dynamic message) {
    iFrame.contentWindow!.postMessage(message, url);
  }

  void handleMessage(html.Event e) {
    if (e is html.MessageEvent) {
      print('MessageEvent: ${e.data}');
    }
  }
}
