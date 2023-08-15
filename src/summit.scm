(import 
	(scheme base)
	(scheme r5rs)
	(srfi 1)
	(srfi 2)
	(chibi process)
	(chibi json))

(import
	(summitkit target)
	(summitkit image))

(define (read-config)
	(string->json (process->string "yq -o=json eval config.yaml")))

(define (build! config)
	(and-let* 
		( (tasks (vector->list (cdr (assq 'tasks config)))))
		(setup-target! config)
		(display ">>> Running Tasks...") (newline)
		(fold
			(lambda (x y) (and (run-task! x) y)) #t tasks)))

(define (main arguments)
	(display "=== Starting Summit Build Toolkit") (newline)
	(let* 
		( (config (read-config)) 
		 (image-name (cdr (assq 'name config))))
		(display ">>> Updating/initalizing apk cache...")
		(system '(apk update))
		(display (string-append ">>> Building image [" image-name "]")) (newline)
		(unless (build! config)
			(display (string-append "!!! Failed to build image [" image-name "]!")) (newline)
			(exit 1))
		(display (string-append ">>> Writing out exports for image [" image-name "]")) (newline)
		(unless (write-images! config)
			(display (string-append "!!! Failed to write image [" image-name "]!")) (newline)
			(exit 1))
		(display (string-append ">>> Finished building [" (cdr (assq 'name config)) "]")) (newline) 
			(exit 0)))
