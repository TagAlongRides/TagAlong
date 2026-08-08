import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tagalong/screens/account/privacy_policy_screen.dart';
import 'package:tagalong/themes/tagalong_theme.dart';
import 'package:tagalong/util/log.dart' as logger;

class SupportScreen extends StatelessWidget {
  static const routeName = '/support-contact-us';
  const SupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQs & Support')),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FAQHeadline('What to do if you\'re new to TagAlong'),
              const FAQQuestion('Complete your profile', [
                TextSpan(
                    text:
                        'Completing your profile gives potential drivers a chance to get to know you more while reviewing your ride request. Be sure to include a profile photo and verify your ID — drivers prefer a complete profile!')
              ]),
              const FAQQuestion('Search for a ride', [
                TextSpan(
                    text:
                        'To find a ride, just say where you\'re heading, where you\'re leaving from and when. Then pick a ride that works for you! If you need more info, you can message drivers before booking or check out their profiles to view their ratings.\n\nCan\'t find a ride? Narrow your results using search filters or set up a ride alert to receive notifications when a ride is available.'),
              ]),
              const FAQQuestion('Book and pay online', [
                TextSpan(
                    text:
                        'Some drivers will let you book instantly, others choose to review every booking requests. Either way—only when your booking is confirmed— your payment method will be charged and you\'ll receive a booking confirmation email. You\'ll be able to find your booking and ride details in Your rides.\n\nIf your ride goes as planned, the driver is automatically paid or can request their money transfer on the TagAlong platform. No matter how far in advance you book, the driver doesn'
                        't receive payment until at least 24 hours after the departure time.\n\nIf a driver sends you a payment link through TagAlong\'s messaging or outside of our platform before a booking is confirmed, please let us know by going to the member'
                        's Profile and selecting Report this member.'),
              ]),
              const FAQHeadline('Offering a ride as a driver'),
              const FAQHeadline('Booking a ride as a passenger'),
              const FAQQuestion(
                'About carpool service fees',
                [
                  TextSpan(
                      text:
                          'To help TagAlong run smoothly and to cover the costs of the services we provide, we charge passengers a service fee when a booking is confirmed. The passenger service fee helps us to:\n    - Provide you with 24/7 customer support\n    - Create a safer platform by verifying our members\n    - Offer you the best experience throughout your entire journey\n\nAs long as a pending booking request hasn\'t been approved by the driver, passengers can cancel their booking request and won\'t be charged for the ride or service fee. If the driver cancels after the booking is confirmed, passengers will be automatically refunded the cost of the booking, including service fees.\n\nAre you a driver? Learn more about how service fees are applied to your publications.'),
                ],
              ),
              const FAQQuestion(
                'When will I pay for my booking?',
                [
                  TextSpan(
                      text:
                          'Some drivers will let you book instantly, others choose to review every booking request.\n    - If the ride has Instant Approvalflash.svg, your payment method is charged immediately.\n    - If you send a booking request, your payment method is charged only after the driver approves your booking request.\n\nOnce your booking is confirmed, you\'ll receive a booking confirmation email and can find your booking and ride details in My Rides.'),
                ],
              ),
              const FAQQuestion(
                'How does my driver get paid?',
                [
                  TextSpan(
                      text:
                          'If your ride goes as planned, the driver is automatically paid or can request their money transfer on the TagAlong platform. No matter how far in advance you book, the driver doesn\'t receive payment until at least 24 hours after departure.\n\nIf a driver sends you a payment link through TagAlong\'s messaging or outside of our platform before a booking is confirmed, please let us know by going to the member\'s Profile and selecting Report this member.'),
                ],
              ),
              FAQQuestion(
                'How do I pay and communicate with my driver?',
                [
                  const TextSpan(
                      text:
                          'Your booking confirmation and payment to the driver are made automatically on the TagAlong platform. Some drivers may suggest chatting or paying through a link on Whatsapp, by text, or somewhere other than the TagAlong platform. But if you do, you lose the protection of our cancellation and refund policies.\n\nPaying your driver\n    - If your ride goes as planned, the driver is automatically paid or can request their money transfer on the TagAlong platform. No matter how far in advance you book, the driver doesn\nt receive payment until at least 24 hours after departure.\n    - If a driver sends you a payment link through TagAlong\'s messaging or outside of our platform before a booking is confirmed, please let us know by going to the member\'s Profile and selecting Report this member.\n\nWe protect our TagAlong members\n    - We work tirelessly to make sure you can enter your payment details and message other community members on TagAlong without any concern. Our site and apps are secure and encrypted, and we review and block any potentially dangerous messages.\n    - Learn more about '),
                  TextSpan(
                    text: 'our Privacy Policy.',
                    style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).pushNamed(PrivacyPolicyScreen.routeName);
                      },
                  )
                ],
              ),
              FAQQuestion(
                'What if my driver cancels or doesn\'t show up?',
                [
                  const TextSpan(
                      text:
                          'If the driver cancels online:\nPassengers will be automatically refunded, including service fees.\n\nIf the driver didn\'t cancel online\nIf the driver didn\'t show up at the meeting point and/or didn\'t cancel the ride online, it\'s important that the passenger lets us know (within 24 hours of when the departure time for the ride) that ride didn\'t go as planned by cancelling their booked ride:\n    - Go to Your rides\n    - Select the booking you want to cancel and then Cancel this booking\n    - Tell us why you\'re cancelling from the drop-down menu (provide as much detail as possible)\n    - Confirm\nThe driver will get 3 days to agree or disagree with you. If the driver disagrees, we\'ll process the refund using the information we receive. Have questions? Check out our '),
                  TextSpan(
                    text: 'Cancellation Policy.',
                    style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()..onTap = () => logger.log.fine('Cancellation policy tapped'),
                  ),
                ],
              ),
              const FAQQuestion(
                'What should I do if the driver asks me to pay outside of TagAlong?',
                [
                  TextSpan(
                      text:
                          'TagAlong will never ask for your login or payment details off-site the TagAlong platform. If you paid for a ride outside of TagAlong (ex: a wire or bank transfer) and the ride doesn\'t appear in Your rides section, you may have paid for a fraudulent booking. To get help, contact us immediately.\n\nReporting requests for offsite payment\n    - If your ride goes as planned, the driver is automatically paid or can request their money transfer on the TagAlong platform. No matter how far in advance you book, the driver doesn\'t receive payment until at least 24 hours after the departure time.\n    - If a driver sends you a payment link through TagAlong\'s messaging or outside of our platform before a booking is confirmed, please let us know by going to the member\'s Profile and selecting Report this member.\n\nReporting suspicious messages\n    - Go to your Inbox and select the conversation with the suspicious message    - From Our guidelines page, Tap Report this thread\n    - Choose the reason you’re reporting the message and follow the onscreen prompts\n\nIdentifying scams\nNever share your contact information (phone number, email) before a booking is confirmed, and always carefully examine links and emails claiming to be from TagAlong.\n    - Phishing scam: You receive an email or link that looks like it\'s from TagAlong or another trusted site. These messages are designed to trick you into providing confidential information such as passwords or other email addresses.\n    - Advance fee scam: A driver offers to pay you or give you something if you pay through a service outside of TagAlong.'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FAQHeadline extends StatelessWidget {
  final String headlineText;
  const FAQHeadline(this.headlineText, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        headlineText,
        style: TagAlongTheme.lightTextTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class FAQQuestion extends StatelessWidget {
  final String questionText;
  final List<InlineSpan> answerText;
  const FAQQuestion(this.questionText, this.answerText, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(questionText),
      initiallyExpanded: false,
      children: [
        FAQAnswer(answerText),
      ],
    );
  }
}

class FAQAnswer extends StatelessWidget {
  final List<InlineSpan> answerText;
  const FAQAnswer(this.answerText, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: RichText(
        text: TextSpan(
          children: answerText,
          style: TagAlongTheme.lightTextTheme.bodyMedium,
        ),
      ),
    );
  }
}
