import 'package:xml/xml.dart';

class PackageFile {
  String path;
  String type;
  int uid;
  int gid;
  int mode;
  String hash;

  PackageFile(this.path, this.type, this.uid, this.gid, this.mode, this.hash);
  PackageFile.fromXml(XmlNode node) :
		path = node.getElement("Path")!.text,
		type = node.getElement("Type")!.text,
		uid = int.parse(node.getElement("Uid")!.text),
		gid = int.parse(node.getElement("Gid")!.text),
		mode = int.parse(node.getElement("Mode")!.text),
		hash = node.getElement("Hash")!.text;
}

class Package {
  static const formats = ['1.0', '1.1', '1.2', '1.3'];
  static const defaultFormat = '1.3';
}
