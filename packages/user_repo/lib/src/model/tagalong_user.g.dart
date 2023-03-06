// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tagalong_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagAlongUser _$TagAlongUserFromJson(Map<String, dynamic> json) => TagAlongUser(
      id: json['id'] as String,
      providerId: json['providerId'] as String,
      stripeAccountId: json['stripeAccountId'] as String?,
      stripeCustomerId: json['stripeCustomerId'] as String?,
      name: json['name'] as String?,
      institution: json['institution'] as String?,
      emailAddress: json['emailAddress'] as String?,
      password: json['password'] as String?,
      graduationYear: json['graduationYear'] as String?,
    )
      ..isRegistered = json['isRegistered'] as bool
      ..profilePictureUrl = json['profilePictureUrl'] as String?;

Map<String, dynamic> _$TagAlongUserToJson(TagAlongUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'providerId': instance.providerId,
      'isRegistered': instance.isRegistered,
      'stripeAccountId': instance.stripeAccountId,
      'stripeCustomerId': instance.stripeCustomerId,
      'profilePictureUrl': instance.profilePictureUrl,
      'name': instance.name,
      'institution': instance.institution,
      'emailAddress': instance.emailAddress,
      'password': instance.password,
      'graduationYear': instance.graduationYear,
    };
