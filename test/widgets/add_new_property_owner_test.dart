import 'dart:io';

import 'package:cas_house/main_global.dart' as globals;
import 'package:cas_house/models/properties.dart';
import 'package:cas_house/models/user.dart'
    as app_user; // dopasuj ścieżkę, jeśli inną masz w projekcie
import 'package:cas_house/providers/properties_provider.dart';
import 'package:cas_house/widgets/image_picker.dart';
import 'package:cas_house/sections/properties/add_new_property_owner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

// --- mocki ---
class _MockPropertiesProvider extends Mock implements PropertiesProvider {}

class _MockNavigatorObserver extends Mock implements NavigatorObserver {}

class _FakeRoute extends Fake implements Route<dynamic> {}

// Wrapper z Providerem i Scaffoldem
Widget _wrap(Widget child, PropertiesProvider provider,
    {NavigatorObserver? obs}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<PropertiesProvider>.value(value: provider),
    ],
    child: MaterialApp(
      home: Scaffold(body: child),
      navigatorObservers: obs != null ? [obs] : const [],
    ),
  );
}

// Wpisanie poprawnych wartości do pól formularza
Future<void> _fillValidBasics(WidgetTester tester) async {
  await tester.enterText(
      find.widgetWithText(TextFormField, 'Nazwa mieszkania'), 'Moje M2');
  await tester.enterText(find.widgetWithText(TextFormField, 'Lokalizacja'),
      'Warszawa, ul. Testowa 1');
  await tester.enterText(
      find.widgetWithText(TextFormField, 'Powierzchnia (m²)'), '45.5');
  await tester.enterText(find.widgetWithText(TextFormField, 'Pokoje'), '2');
  await tester.enterText(find.widgetWithText(TextFormField, 'Piętro'), '3');
  await tester.enterText(find.widgetWithText(TextFormField, 'Czynsz'), '2500');
  await tester.enterText(find.widgetWithText(TextFormField, 'Kaucja'), '2500');
  await tester.enterText(
      find.widgetWithText(TextFormField, 'Cykl płatności (np. miesięczny)'),
      'miesięczny');
  await tester.pump();
}

// Klik w przycisk submit (upewniamy się, że jest w kadrze)
Future<void> _submit(WidgetTester tester) async {
  final btn = find.text('DODAJ MIESZKANIE');
  await tester.ensureVisible(btn);
  await tester.pump();
  await tester.tap(btn, warnIfMissed: false);
  await tester.pump(); // walidacje
}

void main() {
  setUpAll(() {
    registerFallbackValue(
        _FakeRoute()); // dla mocktail verify() na NavigatorObserver
    registerFallbackValue(Property(
      ownerId: 'fallback',
      name: 'f',
      location: 'f',
      size: 1,
      rooms: 1,
      floor: 0,
      features: const [],
      status: 'wolne',
      rentAmount: 1,
      depositAmount: 1,
      paymentCycle: 'miesięczny',
    ));
    registerFallbackValue(File('fallback'));
  });

  testWidgets('blokuje zapis bez zdjęcia i pokazuje komunikat', (tester) async {
    final mock = _MockPropertiesProvider();
    when(() => mock.addProperty(any(), any())).thenAnswer((_) async => true);

    await tester
        .pumpWidget(_wrap(AddNewPropertyOwner(propertiesProvider: mock), mock));

    await _fillValidBasics(tester);
    await _submit(tester);

    expect(find.text('Wymagane zdjęcie'), findsOneWidget);
    verifyNever(() => mock.addProperty(any(), any()));
  });

  testWidgets('status "wynajęte" bez dat -> pokazuje błąd dat i nie wysyła',
      (tester) async {
    final mock = _MockPropertiesProvider();
    when(() => mock.addProperty(any(), any())).thenAnswer((_) async => true);

    await tester
        .pumpWidget(_wrap(AddNewPropertyOwner(propertiesProvider: mock), mock));
    await _fillValidBasics(tester);

    // Znajdź dropdown statusu (bez .first od razu – najpierw upewnij się, że istnieje)
    final dropdownFinderWithinForm = find.descendant(
      of: find.byType(Form),
      matching: find.byType(DropdownButtonFormField),
    );
    expect(dropdownFinderWithinForm, findsWidgets);
    final dropdown = dropdownFinderWithinForm.first;

    // Upewnij się, że widoczny zamiast scrollUntilVisible
    await tester.ensureVisible(dropdown);
    await tester.pump();

    // Otwórz i wybierz "wynajęte"
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('wynajęte').last);
    await tester.pump();

    // Ustaw „zdjęcie” przez callback w SingleImageUploader
    final uploaderFinder = find.byType(SingleImageUploader);
    expect(uploaderFinder, findsOneWidget);
    await tester.ensureVisible(uploaderFinder);
    await tester.pump();
    final uploader = tester.widget<SingleImageUploader>(uploaderFinder);
    uploader.onImageSelected(File('fake.jpg'));
    await tester.pump();

    // Submit bez dat -> oczekujemy błędu dat
    await _submit(tester);
    expect(
      find.text('Wymagane daty rozpoczęcia i zakończenia najmu'),
      findsOneWidget,
    );
    verifyNever(() => mock.addProperty(any(), any()));
  });

  testWidgets(
      'happy path: status "wolne" + zdjęcie -> wywołuje addProperty, snackbar i pop',
      (tester) async {
    // zalogowany user
    globals.loggedUser = app_user.User(
        id: 'u-123',
        email: 't@t.com',
        username: 'Tester',
        firstname: "Firstname",
        secondname: "Secondname");

    final mock = _MockPropertiesProvider();
    final navObs = _MockNavigatorObserver();
    when(() => mock.addProperty(any(), any())).thenAnswer((_) async => true);

    await tester.pumpWidget(
      _wrap(AddNewPropertyOwner(propertiesProvider: mock), mock, obs: navObs),
    );

    await _fillValidBasics(tester);

    // Ustaw obraz – przez callback w uploaderze
    final uploaderFinder = find.byType(SingleImageUploader);
    expect(uploaderFinder, findsOneWidget);
    await tester.ensureVisible(uploaderFinder);
    await tester.pump();
    final uploader = tester.widget<SingleImageUploader>(uploaderFinder);
    final fakeFile = File('fake.jpg');
    uploader.onImageSelected(fakeFile);
    await tester.pump();

    // Submit
    await _submit(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // addProperty wywołany z poprawnymi argumentami
    verify(() => mock.addProperty(any(that: isA<Property>()), fakeFile))
        .called(1);

    // snackbar
    expect(find.text('Mieszkanie zostało dodane.'), findsOneWidget);

    // pop
    await tester.pump(const Duration(milliseconds: 350));
    verify(() => navObs.didPop(any(), any())).called(greaterThanOrEqualTo(1));
  });
}
