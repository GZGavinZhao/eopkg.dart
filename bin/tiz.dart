import 'dart:io';
import 'dart:convert';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:tar/tar.dart';

Future<void> main(List<String> args) async {
  File target = File(args[0]);
	File result = File('result.tar.gz');

  TarEncoder tarEncoder = TarEncoder();

  ArchiveFile archiveFile = ArchiveFile.stream(
    p.basename(target.path),
    target.lengthSync(),
    InputFileStream(target.path),
  );

	Archive archive = Archive();
	archive.addFile(archiveFile);

	result.writeAsBytes(tarEncoder.encode(archive));
}
