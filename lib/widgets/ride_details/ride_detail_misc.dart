import 'package:flutter/material.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:tagalong/widgets/common/tagalong_components.dart';

/// Car, luggage allowance and (when the driver asked for it) COVID
/// precautions, as a row of fact pills.
class RideDetailMisc extends StatelessWidget {
  const RideDetailMisc({
    Key? key,
    required this.ride,
  }) : super(key: key);

  final RideModel ride;

  @override
  Widget build(BuildContext context) {
    final car = [ride.vehicle.color, ride.vehicle.make, ride.vehicle.model].where((s) => s.isNotEmpty).join(' ');
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (car.isNotEmpty) TagAlongFactPill(icon: Icons.directions_car_outlined, label: car),
        TagAlongFactPill(
          icon: Icons.luggage_outlined,
          label: '${ride.noBags} ${ride.noBags == 1 ? 'bag' : 'bags'} each',
        ),
        if (ride.vaccinationCard)
          TagAlongFactPill(
            icon: Icons.masks_outlined,
            label: 'COVID precautions',
            onTap: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('COVID Protocols Enforced'),
                content: const Text(
                    'This Driver has indicated proof of vaccination or wearing a mask is required. Please ensure you bring your vaccination card and a mask to wear. Failure to do so, Drivers reserve the right to refuse providing a ride.'),
                actions: <Widget>[TextButton(child: const Text('OK'), onPressed: () => Navigator.pop(context))],
              ),
            ),
          ),
      ],
    );
  }
}
