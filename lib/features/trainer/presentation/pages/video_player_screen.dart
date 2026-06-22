import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:google_fonts/google_fonts.dart';

/// Full-screen HLS video player screen.
/// Pass the .m3u8 URL and video title when navigating to this page.
///
/// Usage:
///   Navigator.push(context, MaterialPageRoute(
///     builder: (_) => VideoPlayerScreen(
///       hlsUrl: video.videoUrl,   // the .m3u8 URL from DB
///       title: video.title,
///     ),
///   ));
class VideoPlayerScreen extends StatefulWidget {
  final String hlsUrl;
  final String title;

  const VideoPlayerScreen({
    super.key,
    required this.hlsUrl,
    required this.title,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool _isFullScreen = false;
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();

    // Lock to landscape when entering player
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.hlsUrl,
      // Tells the player this is an HLS (adaptive bitrate) stream so it
      // picks up the available quality variants from the master playlist.
      videoFormat: BetterPlayerVideoFormat.hls,
    );

    final configuration = BetterPlayerConfiguration(
      autoPlay: true,
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
      controlsConfiguration: const BetterPlayerControlsConfiguration(
        enableMute: true,
        enableFullscreen: true,
        enableProgressBar: true,
        enablePlayPause: true,
        enableQualities: true, // shows quality-switch option for HLS
      ),
      fullScreenByDefault: false,
      deviceOrientationsOnFullScreen: const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    );

    _betterPlayerController = BetterPlayerController(
      configuration,
      betterPlayerDataSource: dataSource,
    );

    // Keep our own fullscreen flag in sync with the player's, so we can
    // hide/show the AppBar and info panel below the video.
    _betterPlayerController.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.openFullscreen) {
        setState(() => _isFullScreen = true);
      } else if (event.betterPlayerEventType ==
          BetterPlayerEventType.hideFullscreen) {
        setState(() => _isFullScreen = false);
      }
    });
  }

  @override
  void dispose() {
    // Restore portrait when leaving
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullScreen
          ? null
          : AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              title: Text(
                widget.title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              elevation: 0,
            ),
      body: SafeArea(
        child: Column(
          children: [
            // ── HLS Player ────────────────────────────────────────────────
            AspectRatio(
              aspectRatio: 16 / 9,
              child: BetterPlayer(controller: _betterPlayerController),
            ),

            // ── Video info below player ───────────────────────────────────
            if (!_isFullScreen)
              Expanded(
                child: Container(
                  color: const Color(0xFF0D0D0D),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22B07D).withAlpha(30),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.hd_rounded,
                                  size: 14,
                                  color: Color(0xFF22B07D),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'HLS Streaming',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF22B07D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(10),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Adaptive Quality',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.white60,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
