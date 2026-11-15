import 'package:flutter/material.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:tagalong/themes/tagalong_theme.dart';

class RideDetailMisc extends StatelessWidget {
  const RideDetailMisc({
    Key? key,
    required this.context,
    required this.ride,
  }) : super(key: key);

  final BuildContext context;
  final RideModel ride;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Column(children: [
          Row(children: [
            const Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.directions_car_outlined)),
            Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ride.vehicle.make} ${ride.vehicle.model}',
                    style: TagAlongTheme.lightTextTheme.bodyMedium!,
                  ),
                  Text(ride.vehicle.color),
                ]),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            const Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.backpack_outlined)),
            Text('${ride.noBags} bags per person'),
          ]),
          // IF covid precautions were required, introduce INFO (i) button
          if (ride.vaccinationCard) const SizedBox(height: 16),
          if (ride.vaccinationCard)
            Row(children: [
              const Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.masks)),
              const Text('COVID safety precautions required'),
              const SizedBox(width: 16),
              IconButton(
                  padding: const EdgeInsets.all(0),
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.info_outline),
                  onPressed: () async {
                    return showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                              title: const Text('COVID Protocols Enforced'),
                              content: const Text(
                                  'This Driver has indicated proof of vaccination or wearing a mask is required. Please ensure you bring your vaccination card and a mask to wear. Failure to do so, Drivers reserve the right to refuse providing a ride.'),
                              actions: <Widget>[
                                TextButton(child: const Text('OK'), onPressed: () => Navigator.pop(context))
                              ]);
                        });
                  })
            ])
        ]));
  }
}
