# Annotation Crawler

[![Build Status](https://drone.io/github.com/exitlive/annotation_crawler/status.png)](https://drone.io/github.com/exitlive/annotation_crawler/latest)

Helps finding annotated declarations in a particular scope. 

## Usage

```dart
    
    import "annotation_crawler";

    main () {

      //perform all plays written by Arthur miller
      annotatedDeclarations(Author)
          .where((decl) => decl.declaration is ClassMirror && decl.annotation == const Author("Arthur Miller"))
          .map((decl) => decl.declaration.newInstance(const Symbol(""), ["Her majesty's Theater"]).reflectee)
          .forEach(perform);
      
      //Perform the first scence of ACT III of the Merchant of Venice
      var play = annotatedDeclarations(Title)
        .where((decl) => decl.annotation.name = "The Merchant of venice")
        .single.newInstance(const Symbol(""), ["Her majesty's theater"]);
      
      MethodMirror scene = annotatedDeclarations(Scene, on: play.runtimeType)
      .where((decl) => decl.annotation.act == "III" &&
                      decl.annotation.scene == "I")
      .single;
      
      perform(play.getField(scene.simpleName).reflectee); 

    }
```