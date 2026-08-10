part of '../home_active_exam_section.dart';

class _CountdownStub extends StatefulWidget {
  final DateTime startTime;
  final int durationMinutes;
  final bool isLive;

  const _CountdownStub({
    required this.startTime,
    required this.durationMinutes,
    required this.isLive,
  });

  @override
  State<_CountdownStub> createState() => _CountdownStubState();
}

class _CountdownStubState extends State<_CountdownStub> {
  Timer? _timer;
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  String _label = '';

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _update() {
    final now = DateTime.now();
    final endTime =
        widget.startTime.add(Duration(minutes: widget.durationMinutes));
    Duration d;
    String lbl;

    if (now.isAfter(widget.startTime) && now.isBefore(endTime)) {
      d = endTime.difference(now);
      lbl = 'LEFT';
    } else if (now.isBefore(widget.startTime)) {
      d = widget.startTime.difference(now);
      lbl = 'UNTIL';
    } else {
      d = Duration.zero;
      lbl = '';
    }

    if (mounted) {
      setState(() {
        _hours = d.inHours;
        _minutes = d.inMinutes % 60;
        _seconds = d.inSeconds % 60;
        _label = lbl;
      });
    }
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  Widget _unit(String val, String lbl) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          val,
          style: AppFonts.heading(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            height: 1.0,
          ).copyWith(
            fontFeatures: const [ui.FontFeature.tabularFigures()],
          ),
        ),
        Text(
          lbl,
          style: AppFonts.body(
            fontSize: 7,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.6),
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _unit(_pad(_hours), 'HR'),
          const SizedBox(height: 8),
          _unit(_pad(_minutes), 'MIN'),
          const SizedBox(height: 8),
          _unit(_pad(_seconds), 'SEC'),
          if (_label.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              _label,
              style: AppFonts.body(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.5),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
