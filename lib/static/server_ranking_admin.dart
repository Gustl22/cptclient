// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:cptclient/json/competence.dart';
import 'package:cptclient/json/session.dart';
import 'package:cptclient/json/skill.dart';
import 'package:cptclient/json/user.dart';
import 'package:cptclient/static/server.dart' as server;
import 'package:http/http.dart' as http;

Future<List<Competence>> competence_list(
    Session session, User? user, Skill? skill) async {
  final response = await http.get(
    server.uri('/admin/competence_list', {
      if (user != null) 'user_id': user.id.toString(),
      if (skill != null) 'skill_id': skill.id.toString(),
      if (skill != null) 'min': '0',
      if (skill != null) 'max': '0'
    }),
    headers: {
      'Token': session.token,
    },
  );

  if (response.statusCode != 200) return [];

  Iterable l = json.decode(utf8.decode(response.bodyBytes));
  return List<Competence>.from(l.map((model) => Competence.fromJson(model)));
}

Future<bool> competence_create(Session session, Competence ranking) async {
  final response = await http.post(
    server.uri('/admin/competence_create'),
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Token': session.token,
    },
    body: json.encode(ranking),
  );

  return (response.statusCode == 200);
}

Future<bool> competence_edit(Session session, Competence competence) async {
  final response = await http.post(
    server.uri('/admin/competence_edit', {
      'competence_id': competence.id.toString(),
    }),
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Token': session.token,
    },
    body: json.encode(competence),
  );

  return (response.statusCode == 200);
}

Future<bool> competence_delete(Session session, Competence competence) async {
  final response = await http.head(
    server.uri('/admin/competence_delete', {
      'competence_id': competence.id.toString(),
    }),
    headers: {
      'Token': session.token,
    },
  );

  return (response.statusCode == 200);
}
