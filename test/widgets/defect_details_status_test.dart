import 'package:cas_house/models/property_short.dart';
import 'package:cas_house/sections/defects/components/defects_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cas_house/providers/defects_provider.dart';
import 'package:cas_house/models/defect.dart';

// Mock providera
class _MockDefectsProvider extends Mock implements DefectsProvider {}

// Pomocniczy builder
Widget _app(Widget child) => MaterialApp(home: child);

// UPROSZCZENIE: dostosuj fabrykę do Twojego modelu Defect, jeśli ma inny konstruktor.
Defect makeDefect({
  String id = 'd1',
  String title = 'Pęknięta rura',
  String description = 'Łazienka',
  String status = 'nowy',
  DateTime? createdAt,
  DateTime? updatedAt,
  String? propertyName,
  String? propertyLocation,
  List<String>? imageFilenames,
}) {
  return Defect(
    id: id,
    title: title,
    description: description,
    status: status,
    createdAt: createdAt ?? DateTime(2025, 11, 10, 14, 30),
    updatedAt: updatedAt ?? DateTime(2025, 11, 11, 9, 00),
    property: propertyName != null || propertyLocation != null
        ? PropertyShort(
            name: propertyName ?? '-',
            location: propertyLocation ?? '-',
            id: 'p1')
        : null,
    imageFilenames: imageFilenames ?? const [],
  );
}

void main() {
  setUpAll(() {
    // jeśli w testach używasz Intl/DateFormat – nic specjalnego nie trzeba robić
    registerFallbackValue(
        ''); // mocktail fallback na wypadek niejawnych matcherów
  });

  testWidgets('pokazuje tytuł i pozwala zmienić status na "W trakcie"',
      (tester) async {
    final mock = _MockDefectsProvider();
    final defect = makeDefect(status: 'nowy', imageFilenames: const []);

    when(() => mock.updateStatus(defect.id!, any())).thenAnswer((_) async {});

    await tester
        .pumpWidget(_app(DefectDetails(defect: defect, defectsProvider: mock)));

    // Renderuje tytuł
    expect(find.text('Pęknięta rura'), findsOneWidget);

    // Otwórz bottom sheet zmiany statusu
    await tester.tap(find.byKey(const Key('defect_status_chip_tap')));
    await tester.pumpAndSettle();

    // Wybierz "W trakcie"
    await tester.tap(find.byKey(const Key('status_option_W trakcie')));
    await tester.pumpAndSettle();

    // Sprawdź, że provider został wywołany z nowym statusem
    verify(() => mock.updateStatus(defect.id!, 'W trakcie')).called(1);

    // SnackBar z potwierdzeniem
    expect(
        find.textContaining('Status zmieniono na: W trakcie'), findsOneWidget);
  });
}
