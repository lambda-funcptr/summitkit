(define-library (summitkit target)
  (import 
    (scheme base)
    (scheme r5rs)
    (srfi 2)
    (srfi 130)
  	(chibi process))
  (include "target.scm")
  (export setup-target! run-task!))