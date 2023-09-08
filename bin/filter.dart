import 'dart:collection';
import 'dart:io';
import 'dart:convert';
import 'package:xml/xml_events.dart';

const good = [
  // Haskell stack
  "ghc",
  "haskell-async",
  "haskell-base16-bytestring",
  "haskell-base64-bytestring",
  "haskell-cabal-install",
  "haskell-cabal-syntax",
  "haskell-cryptohash-sha256",
  "haskell-data-array-byte",
  "haskell-echo",
  "haskell-ed25519",
  "haskell-edit-distance",
  "haskell-hackage-security",
  "haskell-hashable",
  "haskell-http",
  "haskell-lukko",
  "haskell-network",
  "haskell-network-uri",
  "haskell-random",
  "haskell-regex-base",
  "haskell-regex-posix",
  "haskell-resolv",
  "haskell-splitmix",
  "haskell-tar",
  "haskell-th-compat",
  "haskell-zlib",
  // XMonad
  "haskell-data-default-class",
  "haskell-setlocale",
  "haskell-utf8-string",
  "haskell-x11",
  "haskell-x11-xft",
  "xmonad",
  "xmonad-contrib",
];

Set<String> packages = Set();

void main(List<String> args) async {
  final file = File(args[0]);

  List<String> deprecations = [];

  await file
      .openRead()
      .transform(utf8.decoder)
      .toXmlEvents()
      .normalizeEvents()
      .selectSubtreeEvents((event) => event.name == 'Package')
      .toXmlNodes()
      .expand((nodes) => nodes)
      .forEach((node) {
    if (node.getElement('Name') == null) {
      return;
    }

    String name = node.getElement('Name')!.innerText;
    packages.add(name);
    String? partOf = node.getElement('PartOf')?.innerText;

    if (partOf == "programming.haskell" && !good.contains(name)) {
      deprecations.add(name);
    }
  });

  List<String> full = [];

  for (final name in deprecations) {
    full.add(name);
    if (packages.lookup("$name-devel") != null) {
      full.add("$name-devel");
    }
  }

  full.sort();
  for (final name in full) {
    print("\t\t<Package>$name</Package>");
  }

  // print(deprecations.length);
  // print(full.length);
}
