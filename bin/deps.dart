import 'dart:collection';
import 'dart:io';
import 'dart:convert';
import 'package:xml/xml_events.dart';

class Package {
  List<Package> _deps = [];
  int _dc = 0;
  final List<Package> _revdeps = [];
  int _rc = 0;
  final String name;

  void addDep(Package dep) {
    _dc++;
  }

  void addRevDep(Package revDep) {
    _rc++;
    _revdeps.add(revDep);
  }

  void removeDep(Package dep) {
    _dc--;
  }

  List<Package> get revdeps => _revdeps;

  List<Package> get deps => _deps;
  set deps(List<Package> dependencies) {
    _dc = dependencies.length;
    _deps = dependencies;
  }

  int get dc => _dc;
  int get rc => _rc;

  Package(this.name);

  @override
  String toString() => name;
}

Future<Map<String, Package>> createGraph(
  String indexPath, {
  bool noDevel = true,
  bool noDocs = true,
  bool noDbgInfo = true,
}) async {
  final file = File(indexPath);

  Map<String, Package> pkgs = {};

  await file
      .openRead()
      .transform(utf8.decoder)
      .toXmlEvents()
      .normalizeEvents()
      .selectSubtreeEvents((event) => event.name == 'Package')
      .toXmlNodes()
      .expand((nodes) => nodes)
      .forEach((node) {
    String? name = node.getElement('Name')?.innerText;

    // Some simple boolean algebra to simplify condition.
    if (name != null &&
        !(noDevel && name.endsWith('-devel')) &&
        !(noDocs && name.endsWith('-docs')) &&
        !(noDbgInfo && name.endsWith('-dbginfo'))) {
      Iterable<String>? deps = node
          .getElement("RuntimeDependencies")
          ?.childElements
          .map((p0) => p0.innerText);

      // Some special cases where dependencies were specified incorrectly.
      if (name == 'haskell-cabal-install') {
        deps = [
          'haskell-async',
          'haskell-echo',
          'haskell-edit-distance',
          'haskell-hackage-security',
          'haskell-HTTP',
          'haskell-resolv',
          'haskell-zip-archive',
        ];
      } else if (name == 'haskell-nats') {
        deps = ['ghc'];
      } else if (name == 'haskell-fail') {
        deps = ['ghc'];
      }

      if (pkgs[name] == null) {
        pkgs[name] = Package(name);
      }

      Package pkg = pkgs[name]!;

      if (deps != null) {
        for (final dep in deps) {
          (pkgs[dep] ??= Package(dep)).addRevDep(pkg);
        }
        pkg.deps = deps.map((e) => pkgs[e]!).toList(growable: false);
      }
    }
  });

  return pkgs;
}

void dfs(
  Package package,
  Map<String, int> from,
  Map<String, Package> original,
) {
  assert(from.containsKey(package.name));

  if (from[package.name]! > 1) {
    return;
  }

  for (final revdep in original[package.name]!.revdeps) {
    if (!from.containsKey(revdep.name)) {
      from[revdep.name] = 0;
    }

    from[revdep.name] = from[revdep.name]! + 1;

    dfs(revdep, from, original);
  }
}

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print(
        "deps.dart <package-name> <location-of-eopkg-index.xml (default: eopkg-index.xml)>");
    return;
  }
  final String target = args[0];

  Map<String, Package> original =
      await createGraph(args.length > 1 ? args[1] : 'eopkg-index.xml');
  print(
      "Construct dependency graph complete, total packages: ${original.length}");

  if (original[target] == null) {
    stderr.writeln(
        "Unfortunately, package $target doesn't exist in the index...");
    return;
  }

  Map<String, int> from = {target: 0};
  dfs(original[target]!, from, original);
  print(
      "Successfully isolated subgraph for package $target. Now calculating safe order for rebuild...");

  Queue<String> queue = Queue.of([target]);
  while (queue.isNotEmpty) {
    String victim = queue.removeFirst();
    print(victim);

    for (final revdep in original[victim]!.revdeps) {
      from[revdep.name] = from[revdep.name]! - 1;
      if (from[revdep.name] == 0) {
        queue.add(revdep.name);
      }
    }
  }
}


      // if ((name == 'ghc' ||
      //         name.startsWith('haskell') ||
      //         (deps?.contains('ghc') ?? false)) &&
      //     !name.endsWith('-devel') &&
      //     !name.endsWith('-dbginfo')) {
        // Add package node to graph is doesn't exist yet.
        // if (pkgs[name] == null) {
        //   pkgs[name] = Package(name);
        // }

        // Package pkg = pkgs[name]!;

        // if (deps != null) {
        //   for (final dep in deps) {
        //     (pkgs[dep] ??= Package(dep)).addRevDep(pkg);
        //   }

        //   pkg.deps = deps.map((e) => pkgs[e]!).toList(growable: false);
        // }
      // }

// HASKELL STACK REBUILD ORDER
//
// final queue = Queue<Package>();

// for (final entry in pkgs.entries) {
//   if (entry.value.pc == 0) {
//     queue.add(entry.value);
//   }
// }

// print("Startable: ${queue.length}");

// print("Here's the rebuild order: ");

// while (queue.isNotEmpty) {
//   Package pkg = queue.removeFirst();

//   print(pkg);

//   for (final revdep in pkg.revDependencies) {
//     revdep.removeDep(pkg);

//     assert(revdep.pc != 0);
//     assert(revdep.rc != 0);

//     if (revdep.pc == 0) {
//       queue.add(revdep);
//     }
//   }
// }
