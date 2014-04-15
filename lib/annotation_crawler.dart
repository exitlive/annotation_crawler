/**
 * This library helps finding classes and methods with specific annotations.
 */
library annotation_crawler;


import "dart:mirrors";
import 'dart:collection';

class AnnotatedDeclaration {
  final DeclarationMirror declaration;
  final annotation;

  AnnotatedDeclaration._(DeclarationMirror this.declaration, this.annotation);
}

/**
 * Returns a [List] of annotated declarations. If [:onType:] is `null`, finds
 * declarations at the top level of any library in the current [MirrorSystem], otherwise
 * finds declarations (variables, properties, methods and constructors) declared on [:on:].
 *
 * If [:annotation:] is a [Type], finds all annotations with the given type, otherwise
 * finds all annotations which match the given type.
 *
 * If [:recursive:] is `true` and a class scope is provided, superclasses, annotated methods
 * defined on superclasses and interfaces will be included. If an abstract method is annotated on both
 * a class and on the implementing class, then only the overriden method is included.
 *
 * eg. given the annotations
 *
 *      class Annotation1 { const Annotation(); }
 *
 *      const anno = const Annotation1();
 *
 *      class Annotation2 {
 *        final String name;
 *        const Annotation(int this.name);
 *
 *        String toString() => name;
 *      }
 *
 *      @anno
 *      bar();
 *
 *      @Annotation2("Clazz")
 *      class Clazz {
 *        @anno
 *        foo();
 *      }
 *
 * then,
 *
 *      annotatedDeclarations(Annotation2).single;
 *
 * is an [AnnotatedDeclaration] with [:declaration:] being a [ClassMirror] on [Clazz] and
 * [:annotation:] set to `const Annotation("Clazz")`.
 *
 *
 * ### Top level vs scoped declarations
 *
 *      // A MethodMirror on the top level method `bar`
 *      annotatedDeclarations(anno).single.declaration;
 *
 *      // A MethodMirror on `Clazz.foo`.
 *      annotatedDeclarations(anno, Clazz).single.declaration;
 */
List<AnnotatedDeclaration> annotatedDeclarations(var annotation, {ClassMirror on, recursive: false}) =>
    new UnmodifiableListView(
        on == null
            ? _topLevelAnnotatedDeclarations(annotation)
            : _findDeclarationsOn(on, annotation, recursive: recursive)
    );

/**
 * Goes through all the classes in this library, and returns those with the
 * provided class as annotation.
 */
List<ClassMirror> findClasses(Type annotation) =>
    new UnmodifiableListView(
        _topLevelAnnotatedDeclarations(annotation)
        .where((annoDecl) => annoDecl.declaration is ClassMirror)
        .map((annoDecl) => annoDecl.declaration)
    );

/**
 * Returns all methods with provided annotation on passed class.
 */
List<MethodMirror> findMethodsOnClass(Type cls, Type annotation) =>
    new UnmodifiableListView(
        _findDeclarationsOn(reflectClass(cls), annotation)
        .where((annoDecl) => annoDecl.declaration is MethodMirror)
        .map((annoDecl) => annoDecl.declaration)
    );

/**
 * Returns all methods with provided annotation in the provided instance.
 */
List<MethodMirror> findMethodsOnInstance(Object obj, Type annotation) =>
    findMethodsOnClass(obj.runtimeType, annotation);


Iterable<AnnotatedDeclaration> _findDeclarationsOn(ClassMirror cls, var annotation, {bool recursive: false}) {
  if (annotation is! Type) annotation = annotation.runtimeType;

  _toMap(var decls) => new Map.fromIterable(decls, key: (decl) => decl.declaration.simpleName);

  var decls = new Map();
  if (recursive) {
    if (cls.superclass != null) {
      decls.addAll(_toMap(_findDeclarationsOn(cls.superclass, annotation, recursive: recursive)));
    }
    decls.addAll(_toMap(
        cls.superinterfaces
        .expand((iface) => _findDeclarationsOn(iface, annotation, recursive: recursive))
    ));
  }

  decls.addAll(_toMap(
      _filterAnnotated(cls.declarations.values, reflectClass(annotation)).toList()
  ));

  return decls.values;
}


Iterable<AnnotatedDeclaration> _topLevelAnnotatedDeclarations(var annotation) {
  if (annotation is! Type) annotation = annotation.runtimeType;

  var topLevelDeclarations =
      currentMirrorSystem().libraries.values
      .expand((lib) => _filterAnnotated(lib.declarations.values, reflectClass(annotation)));

  return topLevelDeclarations;
}

Iterable<AnnotatedDeclaration> _filterAnnotated(Iterable<DeclarationMirror> decls, ClassMirror anno) {
  AnnotatedDeclaration annotatedWith(DeclarationMirror declMirror) {
    for (var mdata in declMirror.metadata) {
      if (mdata.type == anno) {
        return new AnnotatedDeclaration._(declMirror, mdata.reflectee);
      }
    }
    return null;
  }

  return decls.map(annotatedWith).where((anno) => anno != null);
}


