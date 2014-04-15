# Annotation Crawler

[![Build Status](https://drone.io/github.com/exitlive/annotation_crawler/status.png)](https://drone.io/github.com/exitlive/annotation_crawler/latest)

Helps finding classes or methods with specific annotations.

## Usage

To find all `ClassMirror`s annotated with a specific annotation type

```dart
import "annotation_crawler";

main () {

  //perform all plays written by Arthur miller
  _annotatedDeclarations(Author))
      .where((decl) => decl.declaration is ClassMirror && decl.annotation == const Author("Arthur Miller"))
      .map((decl) => decl.declaration.newInstance(const Symbol(""), ["Her majesty's Theater"]).reflectee)
      .forEach(perform);
      
  //Perform the first scence of ACT III of the Merchant of Venice
  var play = _annotatedDeclarations(Title)
      .where((decl) => decl.annotation.name = "The Merchant of venice")
      .single.newInstance(const Symbol(""), ["Her majesty's theater"]);
      
  var scene = getField(
      play,
      _annotatedDeclarations(Scene, on: play.reflectee.runtimeType)
        .where((decl) => decl.annotation.act == "III"
                         && decl.annotation.scene == "I")
        .single.simpleName);
        
  scene.reflectee.perform;

}
```