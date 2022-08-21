import 'dart:io';
import 'dart:convert';
import 'package:eopkg/src/package.dart';
import 'package:xml/xml_events.dart';

Future<void> main(List<String> args) async {
  final file = File('files.xml');

	final List<PackageFile> files = [];

  await file
      .openRead()
      .transform(utf8.decoder)
      .toXmlEvents()
      .normalizeEvents()
      .selectSubtreeEvents((event) => event.name == 'File')
      .toXmlNodes()
      .expand((nodes) => nodes)
      .forEach((node) {
    // assert(node.getElement("Path")?.text == node.getElement("Path")?.innerText);
		files.add(PackageFile.fromXml(node));
		print('Permission: ${PackageFile.fromXml(node).mode}');
  });
}
