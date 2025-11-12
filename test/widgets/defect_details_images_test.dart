// test/widgets/defect_details_images_test.dart
import 'package:cas_house/sections/defects/components/defects_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:cas_house/providers/defects_provider.dart';
import 'package:cas_house/models/defect.dart';
import 'package:cas_house/widgets/fullscreen_image_viewer.dart';

class _MockDefectsProvider extends Mock implements DefectsProvider {}

Widget _app(Widget child) => MaterialApp(home: child);

Defect makeDefectWithImages() {
  return Defect(
    id: 'd2',
    title: 'Zacieki',
    description: 'Sufit',
    status: 'nowy',
    createdAt: DateTime(2025, 11, 11, 10, 0),
    updatedAt: DateTime(2025, 11, 11, 10, 5),
    property: null,
    imageFilenames: const ['a.jpg', 'b.png'],
  );
}

void main() {
  testWidgets('zakładka Zdjęcia pokazuje miniatury i na tap otwiera viewer',
      (tester) async {
    await mockNetworkImagesFor(() async {
      final mock = _MockDefectsProvider();
      final defect = makeDefectWithImages();

      await tester.pumpWidget(
          _app(DefectDetails(defect: defect, defectsProvider: mock)));
      await tester.pump(); // pierwsze buildy

      // Przełącz na "Zdjęcia"
      await tester.tap(find.text('Zdjęcia'));
      await tester.pump(); // start animacji TabBarView
      await tester.pump(const Duration(milliseconds: 350)); // koniec animacji

      // Liczymy obrazki tylko w GridView (header ma też Image)
      final grid = find.byType(GridView);
      final gridImages =
          find.descendant(of: grid, matching: find.byType(Image));
      expect(gridImages, findsNWidgets(2));

      // Tap w miniaturę -> nawigacja do FullscreenImageViewer
      await tester.tap(gridImages.first);
      await tester.pump(); // start transition
      await tester.pump(const Duration(milliseconds: 350)); // koniec transition

      expect(find.byType(FullscreenImageViewer), findsOneWidget);
    });
  });
}
