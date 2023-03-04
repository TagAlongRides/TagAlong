// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tagalong_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagAlongUser _$TagAlongUserFromJson(Map<String, dynamic> json) => TagAlongUser(
      id: json['id'] as String,
      isEmailVerified: json['isEmailVerified'] as bool,
      providerId: json['providerId'] as String,
      name: json['name'] as String?,
      institution: json['institution'] as String?,
      signUpTime: json['signUpTime'] as int?,
      emailAddress: json['emailAddress'] as String?,
      password: json['password'] as String?,
      graduationYear: json['graduationYear'] as String?,
    )..isRegistered = json['isRegistered'] as bool;

Map<String, dynamic> _$TagAlongUserToJson(TagAlongUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'providerId': instance.providerId,
      'isEmailVerified': instance.isEmailVerified,
      'isRegistered': instance.isRegistered,
      'name': instance.name,
      'institution': instance.institution,
      'emailAddress': instance.emailAddress,
      'password': instance.password,
      'signUpTime': instance.signUpTime,
      'graduationYear': instance.graduationYear,
    };
