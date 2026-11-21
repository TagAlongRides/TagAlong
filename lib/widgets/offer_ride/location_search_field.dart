import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tagalong/data/globals.dart';
import 'package:tagalong/services/places_service.dart';
import 'package:tagalong/themes/tagalong_tokens.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/widgets/common/tagalong_components.dart';

/// One search box for an off-campus address, backed by Google Maps.
///
/// Suggestions appear as the driver types. Picking one resolves it to a full
/// address. If they type an address and carry on without picking, the screen
/// calls [LocationSearchFieldState.resolve], which checks it with Google and
/// either accepts it, asks "did you mean", or says what's wrong.
class LocationSearchField extends StatefulWidget {
  const LocationSearchField({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.accent,
    this.placesService,
  }) : super(key: key);

  /// The place chosen so far, if any.
  final ResolvedPlace? value;

  /// Called with the resolved place, or null when the driver clears it.
  final ValueChanged<ResolvedPlace?> onChanged;

  /// Tint for the pin, matching the ride's direction.
  final Color accent;

  /// Overridable for tests.
  final PlacesService? placesService;

  @override
  State<LocationSearchField> createState() => LocationSearchFieldState();
}

class LocationSearchFieldState extends State<LocationSearchField> {
  static const _debounce = Duration(milliseconds: 300);
  static const _minChars = 3;

  late final PlacesService _places = widget.placesService ?? PlacesService();
  final _controller = TextEditingController();
  final _focus = FocusNode();

  Timer? _timer;
  List<PlaceSuggestion> _suggestions = const [];
  bool _searching = false;
  bool _resolving = false;
  String? _error;

  /// Shown above a match Google had to guess at.
  String? _confirmNote;

  /// Groups keystrokes and the details lookup that ends them into one billed
  /// Places session. A new one starts after each pick.
  String _sessionToken = uuid.v4();

  /// Drops answers to searches the driver has already typed past.
  int _searchSeq = 0;

  bool get busy => _resolving;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    _timer?.cancel();
    setState(() => _error = null);
    final query = text.trim();
    if (query.length < _minChars) {
      _searchSeq++;
      setState(() {
        _suggestions = const [];
        _searching = false;
      });
      return;
    }
    _timer = Timer(_debounce, () => _search(query));
  }

  Future<void> _search(String query) async {
    final seq = ++_searchSeq;
    setState(() => _searching = true);
    try {
      final results = await _places.autocomplete(query, sessionToken: _sessionToken);
      if (!mounted || seq != _searchSeq) return;
      setState(() => _suggestions = results);
    } catch (error) {
      logger.log.warning('Address autocomplete failed: $error');
      if (!mounted || seq != _searchSeq) return;
      // Not fatal: the driver can still type a full address and continue.
      setState(() => _suggestions = const []);
    } finally {
      if (mounted && seq == _searchSeq) setState(() => _searching = false);
    }
  }

  Future<void> _pick(PlaceSuggestion suggestion) async {
    _timer?.cancel();
    _searchSeq++;
    _focus.unfocus();
    setState(() {
      _resolving = true;
      _suggestions = const [];
      _error = null;
    });
    try {
      final place = await _places.details(suggestion.placeId, sessionToken: _sessionToken);
      if (!mounted) return;
      if (!place.precise) {
        setState(() => _error = _vagueMessage(place));
        return;
      }
      _accept(place);
    } catch (error) {
      logger.log.warning('Place details failed: $error');
      if (mounted) setState(() => _error = 'Couldn’t load that place. Check your connection and try again.');
    } finally {
      _sessionToken = uuid.v4();
      if (mounted) setState(() => _resolving = false);
    }
  }

  void _accept(ResolvedPlace place, {String? note}) {
    setState(() {
      _confirmNote = note;
      _error = null;
    });
    widget.onChanged(place);
  }

  void _change() {
    _controller.text = widget.value?.formattedAddress ?? _controller.text;
    _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
    setState(() => _confirmNote = null);
    widget.onChanged(null);
    _focus.requestFocus();
  }

  String _vagueMessage(ResolvedPlace place) =>
      '“${place.formattedAddress}” is a whole area. Add a street address or pick a specific place.';

  /// Makes sure there is a real place before the driver moves on.
  ///
  /// Returns true when [LocationSearchField.value] holds a place Google
  /// found exactly. Otherwise shows why not and returns false; a close match
  /// is filled in for the driver to confirm with a second tap.
  Future<bool> resolve() async {
    if (widget.value != null) return true;
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Search for an address or place');
      return false;
    }

    _timer?.cancel();
    _searchSeq++;
    setState(() {
      _resolving = true;
      _suggestions = const [];
      _error = null;
    });
    try {
      final result = await _places.geocode(text);
      if (!mounted) return false;
      switch (result.status) {
        case GeocodeStatus.found:
          if (result.partial) {
            _accept(result.place!, note: 'Is this the right place? We couldn’t match “$text” exactly.');
            return false;
          }
          _accept(result.place!);
          return true;
        case GeocodeStatus.tooVague:
          setState(() => _error = _vagueMessage(result.place!));
          return false;
        case GeocodeStatus.notFound:
          setState(() => _error = 'We couldn’t find that address. Check the spelling, or pick a suggestion.');
          return false;
      }
    } catch (error) {
      logger.log.warning('Address check failed: $error');
      if (mounted) setState(() => _error = 'Couldn’t check that address. Check your connection and try again.');
      return false;
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (place != null) ...[
          if (_confirmNote != null) _Note(text: _confirmNote!),
          _SelectedPlace(place: place, accent: widget.accent, onChange: _change),
        ] else ...[
          TextField(
            controller: _controller,
            focusNode: _focus,
            autofocus: true,
            keyboardType: TextInputType.streetAddress,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.search,
            enabled: !_resolving,
            onChanged: _onTextChanged,
            onSubmitted: (_) => resolve(),
            decoration: InputDecoration(
              hintText: 'Search an address or place',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searching || _resolving
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : _controller.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _controller.clear();
                            _onTextChanged('');
                          },
                        ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(TagAlongSpace.s1, TagAlongSpace.s2, TagAlongSpace.s1, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 16, color: TagAlongColors.errorInk),
                  const SizedBox(width: TagAlongSpace.s2),
                  Expanded(
                    child: Text(_error!, style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.errorInk)),
                  ),
                ],
              ),
            ),
          if (_suggestions.isNotEmpty) ...[
            const SizedBox(height: TagAlongSpace.s3),
            TagAlongCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < _suggestions.length; i++) ...[
                    if (i > 0) const Divider(height: 1, indent: 56, color: TagAlongColors.border),
                    _SuggestionRow(suggestion: _suggestions[i], onTap: () => _pick(_suggestions[i])),
                  ],
                  // Google requires attribution wherever its results are
                  // listed without a map.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        TagAlongSpace.s4, TagAlongSpace.s2, TagAlongSpace.s4, TagAlongSpace.s3),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('Google Maps',
                          style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textTertiary)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.suggestion, required this.onTap});

  final PlaceSuggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: TagAlongSpace.s4, vertical: TagAlongSpace.s3),
        child: Row(
          children: [
            const Icon(Icons.place_outlined, size: 22, color: TagAlongColors.textTertiary),
            const SizedBox(width: TagAlongSpace.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(suggestion.mainText,
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: TagAlongText.labelLarge),
                  if (suggestion.secondaryText.isNotEmpty)
                    Text(suggestion.secondaryText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedPlace extends StatelessWidget {
  const _SelectedPlace({required this.place, required this.accent, required this.onChange});

  final ResolvedPlace place;
  final Color accent;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return TagAlongCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            child: const Icon(Icons.place_rounded, color: TagAlongColors.textPrimary),
          ),
          const SizedBox(width: TagAlongSpace.s4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place.title, style: TagAlongText.titleSmall),
                const SizedBox(height: 2),
                Text(place.formattedAddress,
                    style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textSecondary)),
              ],
            ),
          ),
          TextButton(onPressed: onChange, child: const Text('Change')),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: TagAlongSpace.s3),
      padding: const EdgeInsets.all(TagAlongSpace.s3),
      decoration: BoxDecoration(color: TagAlongPalette.butter100, borderRadius: TagAlongRadius.mdAll),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.help_outline_rounded, size: 18, color: TagAlongColors.warningInk),
          const SizedBox(width: TagAlongSpace.s2),
          Expanded(child: Text(text, style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.warningInk))),
        ],
      ),
    );
  }
}
