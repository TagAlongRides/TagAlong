import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:tagalong/services/auth_service.dart';
import 'package:tagalong/services/data_service.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/util/ride_filters.dart';

/// The ViewModel for the RideBoardScreen page.
///
/// Holds the rides currently shown on the board and pages more in as the user
/// scrolls (Milestone 2, §10.5 - §10.6).
class RideBoardViewModel extends ChangeNotifier {
  final AuthService authService = AuthService();
  final DatabaseService databaseService = DatabaseService();

  /// How many rides the board shows before the user has to scroll for more.
  static const int pageSize = 10;

  /// How many documents we pull from Firestore per round trip. Larger than
  /// [pageSize] because some of what comes back gets dropped by the filters we
  /// can't express as a Firestore query (full rides, time of day, destination).
  static const int _batchSize = 20;

  /// Safety valve so a board full of unmatched rides can't spin forever.
  static const int _maxBatchesPerPage = 5;

  /// The school whose Ride Board we are showing. Applied to every query and
  /// never surfaced as a user-facing filter (Milestone 2, §11.2.1).
  String? university;

  /// The filters that will be used when querying. This is updated via the
  /// Modal Bottom Sheet for filtering.
  RideFilters filters = const RideFilters();

  final List<RideModel> _rides = [];

  /// The rides currently on the board, oldest departure first.
  List<RideModel> get rides => List.unmodifiable(_rides);

  /// Cursor for the next page.
  DocumentSnapshot? _lastDocument;

  bool _hasMore = true;
  bool _isLoading = false;
  Object? _error;

  /// Whether there may be more rides to page in.
  bool get hasMore => _hasMore;

  /// Whether a fetch is in flight.
  bool get isLoading => _isLoading;

  /// The error from the last fetch, if it failed.
  Object? get error => _error;

  /// Whether we know which school's board to show. Until we do there is
  /// nothing safe to query.
  bool get hasUniversity => university != null && university!.isNotEmpty;

  /// Points the board at a school. Returns true if this changed anything, so
  /// callers know whether a reload is needed.
  bool setUniversity(String? university) {
    if (this.university == university) {
      return false;
    }
    this.university = university;
    return true;
  }

  /// Updates this instance's [filters] and reloads the board from the top.
  ///
  /// Does nothing if the filters are unchanged, so re-opening the filter sheet
  /// and dismissing it does not re-query (Milestone 2, §12.2.1).
  Future<void> updateFilters(RideFilters filters) async {
    if (this.filters == filters) {
      logger.log.fine('RideBoardViewModel - filters unchanged, not re-querying');
      return;
    }
    this.filters = filters;
    await refresh();
  }

  /// Forgets the board entirely, including which school it was showing.
  ///
  /// Used on sign-out so the next user doesn't briefly see the previous
  /// user's board before their own loads.
  void reset() {
    _rides.clear();
    _lastDocument = null;
    _hasMore = true;
    _error = null;
    university = null;
    filters = const RideFilters();
    notifyListeners();
  }

  /// Throws away what's on the board and loads the first page.
  Future<void> refresh() async {
    _rides.clear();
    _lastDocument = null;
    _hasMore = true;
    _error = null;
    notifyListeners();
    await loadMore();
  }

  /// Appends up to [pageSize] more rides to the board.
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) {
      return;
    }
    // Querying without a school would put every school's rides on the board,
    // which the school filter exists to prevent (Milestone 2, §11.2.1). Wait
    // until we know who the user is instead.
    if (!hasUniversity) {
      logger.log.fine('RideBoardViewModel - no school known yet, not querying');
      return;
    }
    _isLoading = true;
    notifyListeners();

    try {
      final startingCount = _rides.length;
      var batches = 0;

      // Firestore can't express "has a free seat" alongside the departure-time
      // range, nor the time-of-day and destination filters, so we over-fetch
      // and sift here — repeating until the page is full or the data runs out.
      while (_hasMore && _rides.length - startingCount < pageSize && batches < _maxBatchesPerPage) {
        batches++;
        final snapshot = await _buildQuery().limit(_batchSize).get();

        if (snapshot.docs.length < _batchSize) {
          _hasMore = false;
        }
        if (snapshot.docs.isEmpty) {
          break;
        }
        _lastDocument = snapshot.docs.last;

        for (final doc in snapshot.docs) {
          final ride = RideModel.fromJson(doc.data() as Map<String, dynamic>);
          if (filters.matches(ride)) {
            _rides.add(ride);
          }
        }
      }
      _error = null;
    } catch (error, stack) {
      logger.log.warning('RideBoardViewModel - failed to load rides: $error', error, stack);
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// The Firestore side of the query: everything we can push to the server.
  ///
  /// Only called once [hasUniversity] is true, so the school filter is always
  /// part of the query.
  Query _buildQuery() {
    Query query = databaseService.rides
        .where('status', isEqualTo: RideStatus.scheduled.name)
        .where('university', isEqualTo: university);

    // Never show rides that have already left.
    var earliest = DateTime.now();
    if (filters.departureDateStart != null && filters.departureDateStart!.isAfter(earliest)) {
      earliest = filters.departureDateStart!;
    }
    query = query.where('departure_date_time', isGreaterThan: Timestamp.fromDate(earliest));

    if (filters.departureDateEnd != null) {
      query = query.where('departure_date_time', isLessThanOrEqualTo: Timestamp.fromDate(filters.departureDateEnd!));
    }

    if (filters.toCampus != null) {
      query = query.where('to_campus', isEqualTo: filters.toCampus);
    }

    query = query.orderBy('departure_date_time');

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }
    return query;
  }

  /// The "City, ST" options to offer for the Point B filter, gathered from the
  /// non-campus end of the rides currently on offer (Milestone 2, §11.2.4).
  ///
  /// When [toCampus] is true the non-campus end is where passengers are picked
  /// up; when false it's where they're dropped off.
  Future<List<String>> getDestinationOptions({required bool toCampus}) async {
    if (!hasUniversity) {
      return [];
    }
    try {
      final Query query = databaseService.rides
          .where('status', isEqualTo: RideStatus.scheduled.name)
          .where('university', isEqualTo: university)
          .where('to_campus', isEqualTo: toCampus)
          .where('departure_date_time', isGreaterThan: Timestamp.fromDate(DateTime.now()));

      final snapshot = await query.orderBy('departure_date_time').limit(200).get();

      final options = <String>{};
      for (final doc in snapshot.docs) {
        final ride = RideModel.fromJson(doc.data() as Map<String, dynamic>);
        if (ride.remainingSeats > 0) {
          options.add(RideFilters.cityStateOf(ride));
        }
      }
      final sorted = options.where((option) => option.isNotEmpty).toList()..sort();
      return sorted;
    } catch (error) {
      logger.log.warning('RideBoardViewModel - failed to load destination options: $error');
      return [];
    }
  }
}
