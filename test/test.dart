library tests;

import "dart:mirrors";

import "package:unittest/unittest.dart";

import "../lib/annotation_crawler.dart";


class unusedAnnotation { const unusedAnnotation(); }

class classAnnotation { const classAnnotation(); }

class methodAnnotation { const methodAnnotation(); }



@classAnnotation()
class ClassWithAnnotation { }

@classAnnotation()
class SecondClassWithAnnotation { }

/// Just to make sure classes without annotation aren't returned.
class RandomClass { }



class ClassWithMethods {
  
  @methodAnnotation()
  methodWithAnnotation() { }
  
  @methodAnnotation()
  anotherMethodWithAnnotation() { }
  
  methodWithoutAnnotation() { }
  
}




main() {

  group('findClasses()', () {

    test("returns all classes with provided annotation class", () {
      
      var foundClasses = findClasses(classAnnotation);

      expect(foundClasses.length, equals(2));

      
      expect(foundClasses.firstWhere((classMirror) =>
          classMirror.reflectedType == ClassWithAnnotation, orElse: () => null) != null,
          equals(true));

      expect(foundClasses.firstWhere((ClassMirror classMirror) =>
          classMirror.reflectedType == SecondClassWithAnnotation, orElse: () => null) != null,
          equals(true));
      
      
    });
    test("doesn't return classes with unnused annotation", () {
      
      var foundClasses = findClasses(unusedAnnotation);
      
      expect(foundClasses.length, equals(0));
    
    });
  });

  
  
  group('findMethodsOnInstance()', () {
    
    test("returns all methods provided annotation class", () {
      
      var instance = new ClassWithMethods();

      var foundMethods = findMethodsOnInstance(instance, methodAnnotation);
      
      expect(foundMethods.length, equals(2));
      
      expect(foundMethods.firstWhere((MethodMirror methodMirror) =>
          methodMirror.simpleName == const Symbol("methodWithAnnotation"), orElse: () => null) != null,
          equals(true));

      expect(foundMethods.firstWhere((MethodMirror methodMirror) =>
          methodMirror.simpleName == const Symbol("anotherMethodWithAnnotation"), orElse: () => null) != null,
          equals(true));
      
    });
    test("doesn't return methods with unused annotation", () {
      
      var instance = new ClassWithMethods();
      
      var foundMethods = findMethodsOnInstance(instance, unusedAnnotation);
      
      expect(foundMethods.length, equals(0));
      
    });
  });
  
}