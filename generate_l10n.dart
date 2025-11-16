import 'dart:io';

void main() async {
  // Run flutter tools to generate l10n
  final result = await Process.run(
    'flutter',
    ['pub', 'run', 'flutter_localizations', 'generate'],
    runInShell: true,
  );
  
  print(result.stdout);
  print(result.stderr);
  exit(result.exitCode);
}
