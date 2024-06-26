// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:cptclient/json/location.dart';
import 'package:cptclient/json/session.dart';
import 'package:cptclient/static/server.dart' as server;
import 'package:http/http.dart' as http;

Future<List<Location>> location_list(Session session) async {
  final response = await http.get(
    server.uri('/admin/location_list'),
    headers: {
      'Token': session.token,
    },
  );

  if (response.statusCode != 200) return [];

  Iterable l = json.decode(utf8.decode(response.bodyBytes));
  return List<Location>.from(l.map((model) => Location.fromJson(model)));
}

Future<bool> location_create(Session session, Location location) async {
  final response = await http.post(
    server.uri('/admin/location_create'),
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Token': session.token,
    },
    body: json.encode(location),
  );

  return (response.statusCode == 200);
}

Future<bool> location_edit(Session session, Location location) async {
  final response = await http.post(
    server.uri('/admin/location_edit'),
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Token': session.token,
    },
    body: json.encode(location),
  );

  return (response.statusCode == 200);
}

Future<bool> location_delete(Session session, Location location) async {
  final response = await http.head(
    server.uri('/admin/location_delete', {'location': location.id.toString()}),
    headers: {
      'Token': session.token,
    },
  );

  return (response.statusCode == 200);
}
