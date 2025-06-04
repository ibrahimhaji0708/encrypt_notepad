import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui/bridge_generated.dart/frb_generated.dart';
import 'package:flutter_ui/main.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => await RustLib.init());
  testWidgets('Can call rust function', (WidgetTester tester) async {
    await tester.pumpWidget(const EncryptedNotepadApp());
    expect(find.textContaining('Result: `Hello, Tom!`'), findsOneWidget);
  });
}
