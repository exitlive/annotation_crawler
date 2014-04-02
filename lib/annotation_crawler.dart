/**
 * This library helps finding classes and methods with specific annotations.
 */
library annotation_crawler;


import "dart:mirrors";



/**
 * Goes through all the classes in this library, and returns those with the
 * provided class as annotation.
 */
List<ClassMirror> findClasses(Type annotation) {

  List classes = [];

  MirrorSystem mirror = currentMirrorSystem();
  for(LibraryMirror lib in mirror.libraries.values) {
    for(DeclarationMirror cls in lib.declarations.values) {
      if (cls is ClassMirror) {
        for (InstanceMirror metadataMirror in cls.metadata) {
          if (metadataMirror.reflectee.runtimeType == annotation) {
            classes.add(cls);
          }
        }
      }
    }
  }

  return classes;
}


/**
 * Returns all methods with provided annotation in the provided instance.
 */
List<MethodMirror> findMethodsOnInstance(Object instance, Type annotation) {

  InstanceMirror reflectedInstance = reflect(instance);
  ClassMirror myClassMirror = reflectedInstance.type;

  return _findMethodsOnClassMirror(myClassMirror, annotation);

}

/**
 * Returns all methods with provided annotation on passed class.
 */
List<MethodMirror> findMethodsOnClass(Type clazz, Type annotation) {

  return _findMethodsOnClassMirror(reflectClass(clazz), annotation);

}




List<MethodMirror> _findMethodsOnClassMirror(ClassMirror classMirror, Type annotation) {
  
  var methodMirrors = [];

  for (DeclarationMirror dm in classMirror.declarations.values) {
    if (dm is MethodMirror && dm.isRegularMethod && dm.metadata.length > 0) {
      for (InstanceMirror meta in dm.metadata) {
        if (meta.reflectee.runtimeType == annotation) {
          methodMirrors.add(dm);
          break;
        }
      }
    }
  }

  return methodMirrors;
  
}


