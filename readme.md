# Annotation Crawler

[![Build Status](https://drone.io/github.com/exitlive/annotation_crawler/status.png)](https://drone.io/github.com/exitlive/annotation_crawler/latest)

Helps finding classes or methods with specific annotations.


## Usage

```dart

import "annotation_crawler";

main () {

  List<ClassMirror> classes = findClasses(myAnnotation);
  
  List instances = [ ];
  
  for (var cls in classes) {
    instances.push(cls.newInstance(const Symbol(""), [ "param1", "param2", "param3" ]).reflectee);
  }

}


```