part of video_cast;

/// Callback method for when the button is ready to be used.
///
/// Pass to [ChromeCastButton.onButtonCreated] to receive a [ChromeCastController]
/// when the button is created.
typedef OnButtonCreated = void Function(ChromeCastController controller);

/// Callback method for when a request has failed.
typedef OnRequestFailed = void Function(String? error);

///Callback when a cast session is starting to end.
typedef OnSessionEnding = void Function(int? position);

/// Widget that displays the ChromeCast button.
class ChromeCastButton extends StatefulWidget {
  /// Creates a widget displaying a ChromeCast button.
  ChromeCastButton({
    Key? key,
    this.size,
    this.color,
    this.onButtonCreated,
    this.onSessionStarted,
    this.onSessionEnded,
    this.onRequestCompleted,
    this.onRequestFailed,
    this.onSessionEnding,
  })  : assert(defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android,
            '$defaultTargetPlatform is not supported by this plugin'),
        super(key: key);

  /// The size of the button.
  final double? size;

  final Color? color;

  /// Callback method for when the button is ready to be used.
  ///
  /// Used to receive a [ChromeCastController] for this [ChromeCastButton].
  final OnButtonCreated? onButtonCreated;

  /// Called when a cast session has started.
  final VoidCallback? onSessionStarted;

  /// Called when a cast session has ended.
  final VoidCallback? onSessionEnded;

  /// Called when a cast request has successfully completed.
  final VoidCallback? onRequestCompleted;

  /// Called when a cast request has failed.
  final OnRequestFailed? onRequestFailed;

  ///Called when a cast session is starting to end.
  final OnSessionEnding? onSessionEnding;

  @override
  State<ChromeCastButton> createState() => _ChromeCastButtonState();
}

class _ChromeCastButtonState extends State<ChromeCastButton> {
  StreamSubscription<SessionStartedEvent>? _subscriptionSessionStarted;
  StreamSubscription<SessionEndedEvent>? _subscriptionSessionEnded;
  StreamSubscription<RequestDidCompleteEvent>? _subscriptionRequestCompleted;
  StreamSubscription<RequestDidFailEvent>? _subscriptionRequestFailed;
  StreamSubscription<SessionEndingEvent>? _subscriptionSessionEnding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final Map<String, dynamic> args = {
      'red': widget.color?.red ?? colorScheme.primary.red,
      'green': widget.color?.green ?? colorScheme.primary.green,
      'blue': widget.color?.blue ?? colorScheme.primary.blue,
      'alpha': widget.color?.alpha ?? colorScheme.primary.alpha,
    };

    return SizedBox(
      width: theme.iconTheme.size ?? widget.size,
      height: theme.iconTheme.size ?? widget.size,
      child: _chromeCastPlatform.buildView(args, _onPlatformViewCreated),
    );
  }

  Future<void> _onPlatformViewCreated(int id) async {
    final ChromeCastController controller = await ChromeCastController.init(id);
    if (widget.onButtonCreated != null) {
      widget.onButtonCreated?.call(controller);
    }
    if (widget.onSessionStarted != null) {
      _subscriptionSessionStarted = _chromeCastPlatform.onSessionStarted(id: id).listen((_) => widget.onSessionStarted?.call());
    }
    if (widget.onSessionEnded != null) {
      _subscriptionSessionEnded = _chromeCastPlatform.onSessionEnded(id: id).listen((_) => widget.onSessionEnded?.call());
    }
    if (widget.onRequestCompleted != null) {
      _subscriptionRequestCompleted = _chromeCastPlatform.onRequestCompleted(id: id).listen((_) => widget.onRequestCompleted?.call());
    }
    if (widget.onRequestFailed != null) {
      _subscriptionRequestFailed = _chromeCastPlatform.onRequestFailed(id: id).listen((event) => widget.onRequestFailed?.call(event.error));
    }
    if (widget.onSessionEnding != null) {
      _subscriptionSessionEnding = _chromeCastPlatform.onSessionEnding(id: id).listen((event) => widget.onSessionEnding?.call(event.lastPosition));
    }
  }

  @override
  void dispose() {
    _subscriptionSessionStarted?.cancel();
    _subscriptionSessionEnded?.cancel();
    _subscriptionRequestCompleted?.cancel();
    _subscriptionRequestFailed?.cancel();
    _subscriptionSessionEnding?.cancel();
    super.dispose();
  }
}
