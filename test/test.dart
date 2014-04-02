library tests;

import "package:unittest/unittest.dart";

import "../lib/annotation_crawler.dart";


class classAnnotation { const classAnnotation(); }


@classAnnotation()
class ClassWithAnnotation { }



main() {

  group('findClasses', () {

    test("returns all classes with provided annotation class", () {
      
      var foundClasses = findClasses(classAnnotation);

      expect(foundClasses.length, equals(1));

      expect(foundClasses.first.reflectedType, equals(ClassWithAnnotation));
      
    });
  });

}