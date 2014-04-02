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




//
///**
// * Uses the mirror library to get all information from the metadata, and returns
// * a list of valid routes in the controller.
// */
//List<Route> getRoutes() {
//  if (_routes == null) {
//    InstanceMirror reflectedInstance = reflect(this);
//    ClassMirror myClassMirror = reflectedInstance.type;
//
//    _routes = [];
//
//    InstanceMirror controllerMeta = myClassMirror.metadata.firstWhere((meta) => meta.reflectee is controller);
//
//    if (controllerMeta != null) {
//
//      controller controllerAnnotation = controllerMeta.reflectee;
//
//      for (DeclarationMirror dm in myClassMirror.declarations.values) {
//        if (dm is MethodMirror && dm.isRegularMethod && dm.metadata.length > 0) {
//          for (InstanceMirror meta in dm.metadata) {
//            if (meta.reflectee is route) {
//              route routeAnnotation = meta.reflectee;
//              var pattern = "${controllerAnnotation.urlPattern}${routeAnnotation.urlPattern}";
//              var requiresAuthentication = (routeAnnotation.requiresAuthentication != null) ? routeAnnotation.requiresAuthentication : controllerAnnotation.requiresAuthentication;
//              _routes.add(new Route(reflectedInstance.getField(dm.simpleName).reflectee, pattern, method: routeAnnotation.method, controller: this, requiresAuthentication: requiresAuthentication));
//            }
//          }
//        }
//      }
//    }
//  }
//
//  return _routes;
//}
