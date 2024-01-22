(define-library (summitkit image)
  (import
    (scheme base)
    (scheme r5rs)
    (srfi 1)
    (srfi 2)
    (srfi 130)
    (chibi filesystem)
  	(chibi process))
  (include
    "image.scm")
  (export write-images!))
