import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/models/note.dart';
import 'package:lesson_tracker/providers/note_provider.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

class NoteAudioPlayer extends StatefulWidget {
  final Note note;
  final bool isDark;

  const NoteAudioPlayer({super.key, required this.note, required this.isDark});

  @override
  State<NoteAudioPlayer> createState() => _NoteAudioPlayerState();
}

class _NoteAudioPlayerState extends State<NoteAudioPlayer> {
  bool _isPlaying = false;
  Duration _duration = Duration.zero;

  late final StreamSubscription _stateSub;
  late final StreamSubscription _completeSub;

  @override
  void initState() {
    super.initState();
    _duration = Duration(seconds: widget.note.audioDuration ?? 0);

    _stateSub = context.read<NoteProvider>().onPlayerStateChanged.listen((
      state,
    ) {
      if (mounted) {
        setState(() {
          _isPlaying = state.toString().contains('playing');
        });
      }
    });

    _completeSub = context.read<NoteProvider>().onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _stateSub.cancel();
    _completeSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),
                color: AppColors.primary,
                iconSize: 32,
                onPressed: () {
                  final provider = context.read<NoteProvider>();
                  if (_isPlaying) {
                    provider.pauseAudio();
                    setState(() => _isPlaying = false);
                  } else {
                    if (widget.note.filePath != null) {
                      provider.playAudio(widget.note.filePath!);
                      setState(() => _isPlaying = true);
                    }
                  }
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.voiceMemo,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: widget.isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    StreamBuilder<Duration>(
                      stream: context.read<NoteProvider>().onPositionChanged,
                      builder: (context, snapshot) {
                        final pos = snapshot.data ?? Duration.zero;
                        return Text(
                          '${_formatDuration(pos)} / ${widget.note.formattedDuration}',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<Duration>(
            stream: context.read<NoteProvider>().onPositionChanged,
            builder: (context, snapshot) {
              final pos = snapshot.data ?? Duration.zero;
              final max = _duration.inMilliseconds.toDouble();
              final value = pos.inMilliseconds.toDouble().clamp(0.0, max);

              return Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12,
                      ),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: value,
                      max: max > 0 ? max : 1.0,
                      activeColor: AppColors.primary,
                      inactiveColor: widget.isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                      onChanged: (val) {
                        context.read<NoteProvider>().seekAudio(
                          Duration(milliseconds: val.toInt()),
                        );
                      },
                    ),
                  ),
                  if (widget.note.bookmarks.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: widget.note.bookmarks.asMap().entries.map((
                        entry,
                      ) {
                        final index = entry.key;
                        final bm = entry.value;
                        return ActionChip(
                          label: Text(
                            '#${index + 1} ${_formatDuration(bm)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          avatar: const Icon(
                            Icons.flag,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          onPressed: () {
                            context.read<NoteProvider>().seekAudio(bm);
                          },
                          backgroundColor: widget.isDark
                              ? Colors.grey.shade700
                              : AppColors.surfaceLight,
                          side: BorderSide(color: widget.isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                        );
                      }).toList(),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}