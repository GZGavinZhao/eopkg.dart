import 'dart:typed_data';
import 'dart:convert';
import 'package:eopkg/src/package.dart';
import 'package:xml/xml_events.dart';

import 'package:archive/archive_io.dart';

Future<void> main(List<String> args) async {
  // final inputStream = InputFileStream('blob/nano-6.3-142-1-x86_64.eopkg');
  final inputStream = InputFileStream(args[0]);
  final nano1 = ZipDecoder().decodeBuffer(inputStream);

  final ArchiveFile metadata = nano1.findFile('files.xml')!;
  final List<PackageFile> files = [];

  assert(metadata.content is Uint8List);
  await Stream.fromIterable((metadata.content as Uint8List).map((e) => [e]))
      .transform(utf8.decoder)
      .toXmlEvents()
      .normalizeEvents()
      .selectSubtreeEvents((event) => event.name == 'File')
      .toXmlNodes()
      .expand((nodes) => nodes)
      .forEach((node) {
    // print(node.getElement('Path')!.text);
    files.add(PackageFile.fromXml(node));
    // print(files);
    // print('Permission: ${files.last.mode}');
  });
  print('Total files: ${files.length}');
}
