library tests;

import "dart:mirrors";

import "package:unittest/unittest.dart";

import "../lib/annotation_crawler.dart";

class AnnotationInstance { const AnnotationInstance(); }
const anno = const AnnotationInstance();

class unusedAnnotation { const unusedAnnotation(); }

class classAnnotation { const classAnnotation(); }

class methodAnnotation { const methodAnnotation(); }



@classAnnotation()
class ClassWithAnnotation { }

@classAnnotation()
class SecondClassWithAnnotation { }

/// Just to make sure classes without annotation aren't returned.
class RandomClass { }

@anno
foo() {}

abstract class MixinWithMethods {
  @methodAnnotation()
  void interfaceMethod() { }

  void annotatedImplementation();
}

class SuperclassWithMethods {
  @methodAnnotation()
  var superclassVariable;
}


class ClassWithMethods extends SuperclassWithMethods with MixinWithMethods{

  @anno get bar => null;

  @methodAnnotation()
  methodWithAnnotation() { }

  @methodAnnotation()
  anotherMethodWithAnnotation() { }

  methodWithoutAnnotation() { }

  @methodAnnotation()
  annotatedImplementation() { }

  //Variables
  @methodAnnotation()
  var variable;
}






main() {

  group("annotatedDeclarations()", () {
    test("if passed an instance of an annotation, should get any top level declarations with that instance", () {
      expect(annotatedDeclarations(anno).map((decl) => decl.declaration.simpleName), [#foo]);
    });
    test("if passed an annotation type, should get any top level declarations with an instance of that type", () {
      var decls = annotatedDeclarations(classAnnotation);

      expect(decls.map((decl) => decl.declaration.simpleName),
            unorderedEquals([ #ClassWithAnnotation,
                              #SecondClassWithAnnotation
                            ]
      ));
      expect(decls.map((decl) => decl.annotation), everyElement(const classAnnotation()));
    });

    test( "if passed an instance of an annotation, should get all declarations in the given scope with the declaration", () {
      var decls = annotatedDeclarations(anno, on: reflectClass(ClassWithMethods));
      expect(decls.map((decl) => decl.declaration.simpleName), [#bar]);
    });
    test("if passed an annotation type, should get all declarations in scope with an instance of that type", () {
      var decls = annotatedDeclarations(methodAnnotation, on: reflectClass(ClassWithMethods));
      expect(decls.map((decl) => decl.declaration.simpleName),
          unorderedEquals([ #methodWithAnnotation,
                            #anotherMethodWithAnnotation,
                            #variable,
                            #annotatedImplementation ]));
      expect(decls.map((decl) => decl.annotation),
          everyElement(const methodAnnotation()));
    });

    test("if recursive is true, annotations on super classes and interfaces are included", () {
      var decls = annotatedDeclarations(methodAnnotation, on: reflectClass(ClassWithMethods), recursive: true);
      expect(decls.map((decl) => decl.declaration.simpleName),
          unorderedEquals([ #methodWithAnnotation,
                            #anotherMethodWithAnnotation,
                            #variable,
                            #annotatedImplementation,
                            #interfaceMethod,
                            #superclassVariable ]));
      expect(decls.map((decl) => decl.declaration)
          .where((m) => m is MethodMirror)
          .fold(true, (r, MethodMirror m) => r && !m.isAbstract), true);
    });
  });

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

      expect(foundMethods.map((m) => m.simpleName),
          [ #methodWithAnnotation,
            #anotherMethodWithAnnotation,
            #annotatedImplementation ]);

    });
    test("doesn't return methods with unused annotation", () {

      var cls = reflectClass(ClassWithMethods);

      var instance = new ClassWithMethods();

      var foundMethods = findMethodsOnInstance(instance, unusedAnnotation);

      expect(foundMethods, []);


    });
  });



  group('findMethodsOnClass()', () {

    test("returns all methods provided annotation class", () {

      var foundMethods = findMethodsOnClass(ClassWithMethods, methodAnnotation);

      expect(foundMethods.map((m) => m.simpleName),
          [ #methodWithAnnotation,
            #anotherMethodWithAnnotation,
            #annotatedImplementation
          ]);


    });
    test("doesn't return methods with unused annotation", () {

      var foundMethods = findMethodsOnClass(ClassWithMethods, unusedAnnotation);

      expect(foundMethods, []);

    });
  });

}