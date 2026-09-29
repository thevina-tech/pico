import 'package:flutter/material.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/shared/components/pico_pitch_background.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Reusable in-app web browser that wraps external URLs inside the app
/// with a native gamified AppBar, loading indicator, and dark stadium aesthetic.
class InAppWebBrowserScreen extends StatefulWidget {
  const InAppWebBrowserScreen({
    super.key,
    required this.title,
    required this.url,
  });

  final String title;
  final String url;

  @override
  State<InAppWebBrowserScreen> createState() => _InAppWebBrowserScreenState();
}

class _InAppWebBrowserScreenState extends State<InAppWebBrowserScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  int _loadingProgress = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    try {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFF07150F))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              if (mounted) {
                setState(() {
                  _loadingProgress = progress;
                });
              }
            },
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              if (mounted) {
                setState(() {
                  _errorMessage = error.description;
                  _isLoading = false;
                });
              }
            },
          ),
        );

      if (widget.url.isNotEmpty) {
        controller.loadRequest(Uri.parse(widget.url));
      }
      _controller = controller;
    } catch (e) {
      // In headless widget test environments or unsupported platforms,
      // gracefully fallback to webview simulation container.
      debugPrint('[InAppWebBrowser] Platform controller init: $e');
      _errorMessage = null;
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PicoPitchBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: const Color(0xFF081C14),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            widget.title,
            style: PicoTypography.headlineMd.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 17.0,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.0),
            child: _isLoading
                ? LinearProgressIndicator(
                    value: _loadingProgress > 0 ? _loadingProgress / 100.0 : null,
                    backgroundColor: const Color(0xFF0D281E),
                    color: PicoColors.primary,
                    minHeight: 2.5,
                  )
                : Container(
                    height: 1.0,
                    color: const Color(0x3310B981),
                  ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                color: Color(0xFF94A3B8),
                size: 20.0,
              ),
              onPressed: () {
                if (_controller != null) {
                  _controller!.reload();
                } else if (widget.url.isNotEmpty) {
                  setState(() {
                    _isLoading = true;
                  });
                  Future.delayed(const Duration(milliseconds: 400), () {
                    if (mounted) setState(() => _isLoading = false);
                  });
                }
              },
            ),
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: PicoColors.error,
                size: 48.0,
              ),
              const SizedBox(height: 12.0),
              Text(
                'Failed to load webpage',
                style: PicoTypography.headlineMd.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 6.0),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: PicoTypography.bodySm.copyWith(color: PicoColors.textWhiteMuted),
              ),
              const SizedBox(height: 16.0),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _isLoading = true;
                  });
                  _controller?.reload();
                },
                icon: const Icon(Icons.refresh_rounded, color: PicoColors.primary),
                label: const Text(
                  'Try Again',
                  style: TextStyle(color: PicoColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller != null) {
      return Stack(
        children: [
          WebViewWidget(controller: _controller!),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: PicoColors.primary,
              ),
            ),
        ],
      );
    }

    // Fallback display for test runners or environments where WebViewWidget is unavailable
    return Container(
      key: const Key('in_app_browser_fallback'),
      color: const Color(0xFF07150F),
      padding: const EdgeInsets.all(20.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF0E271F),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0x3310B981)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.language_rounded,
                  color: PicoColors.primary,
                  size: 44.0,
                ),
                const SizedBox(height: 12.0),
                Text(
                  widget.title,
                  style: PicoTypography.headlineMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  widget.url,
                  textAlign: TextAlign.center,
                  style: PicoTypography.bodySm.copyWith(
                    color: const Color(0xFF6EE7B7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
