import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/themes/tagalong_theme.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/viewmodels/ride_board_view_model.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/widgets/rideboard/rideboard_card.dart';

/// The list of rides available to the signed-in user's school.
///
/// Shows the first page of rides and pages in more as the user reaches the
/// bottom of the list (Milestone 2, §10.5 - §10.6).
class RideBoard extends StatefulWidget {
  const RideBoard({Key? key}) : super(key: key);

  @override
  State<RideBoard> createState() => _RideBoardState();
}

class _RideBoardState extends State<RideBoard> {
  final ScrollController _scrollController = ScrollController();
  bool _bannerDismissed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    // Start the next page a little before the user hits the very bottom.
    if (position.pixels >= position.maxScrollExtent - 200) {
      Provider.of<RideBoardViewModel>(context, listen: false).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.log.fine('RideBoardList Build');

    // Watching the user view model as well, because the board can't query
    // until it knows which school to show (Milestone 2, §11.2.1) and the user
    // record may still be loading on the first frame.
    return Consumer2<TagAlongUserViewModel, RideBoardViewModel>(
      builder: (context, userViewModel, rideBoardViewModel, child) {
        if (rideBoardViewModel.setUniversity(userViewModel.tagAlongUser?.institution)) {
          // The school just became known, or changed. Reload after this frame
          // so we aren't mutating the view model mid-build.
          WidgetsBinding.instance.addPostFrameCallback((_) => rideBoardViewModel.refresh());
        }

        return Column(
          children: [
            if (!userViewModel.isEmailVerified() && !_bannerDismissed) _emailBanner(userViewModel),
            Expanded(
              child: RefreshIndicator(
                onRefresh: rideBoardViewModel.refresh,
                child: _rideList(rideBoardViewModel),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _rideList(RideBoardViewModel viewModel) {
    final rides = viewModel.rides;

    // Still waiting to find out which school's board this is.
    if (!viewModel.hasUniversity) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.isLoading && rides.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null && rides.isEmpty) {
      return _message('Something went wrong loading rides. Pull down to try again.');
    }

    if (rides.isEmpty) {
      return _message('No rides match your filters right now. Pull down to refresh.');
    }

    return ListView.builder(
      controller: _scrollController,
      // One extra row for the "loading more" spinner at the tail.
      itemCount: rides.length + (viewModel.hasMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= rides.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return RideBoardCard(ride: rides[i]);
      },
    );
  }

  /// Empty and error states still need to scroll so pull-to-refresh works.
  Widget _message(String text) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(text, textAlign: TextAlign.center),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Persistent prompt to confirm the user's .edu address (Milestone 2, §15).
  Widget _emailBanner(TagAlongUserViewModel userViewModel) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.up,
      onDismissed: (_) {
        setState(() {
          _bannerDismissed = true;
        });
      },
      child: MaterialBanner(
        content: const Text(
            'Heads up! In order to book a ride you’ll need to confirm your email. Click here to resend confirmation email'),
        backgroundColor: TagAlongTheme.colorError,
        actions: [
          TextButton(
            onPressed: () {
              userViewModel.sendEmailVerificationToUser();
              setState(() {
                _bannerDismissed = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Verification email sent to ${userViewModel.tagAlongUser?.emailAddress}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
            child: const Text('RESEND'),
          )
        ],
      ),
    );
  }
}
