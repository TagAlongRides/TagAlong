// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tagalong_user_new.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagAlongUserNew _$TagAlongUserNewFromJson(Map<String, dynamic> json) =>
    TagAlongUserNew(
      id: json['id'] as String,
      name: json['name'] as String,
      signUpMethod: json['signUpMethod'] as String,
      institution: json['institution'] as String,
      signUpTime: json['signUpTime'] as int,
      emailAddress: json['emailAddress'] as String,
      password: json['password'] as String?,
      graduationYear: json['graduationYear'] as String?,
      driverData: json['driverData'] == null
          ? null
          : Driver.fromJson(json['driverData'] as Map<String, dynamic>),
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
    );

Map<String, dynamic> _$TagAlongUserNewToJson(TagAlongUserNew instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'signUpMethod': instance.signUpMethod,
      'institution': instance.institution,
      'emailAddress': instance.emailAddress,
      'signUpTime': instance.signUpTime,
      'isEmailVerified': instance.isEmailVerified,
      'password': instance.password,
      'graduationYear': instance.graduationYear,
      'driverData': instance.driverData,
    };
