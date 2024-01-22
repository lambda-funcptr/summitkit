(define (apk-chroot! package-args)
	(system?
		(append '(apk add --root=/mnt/target) package-args)))

(define (init-rootfs!)
	(and-let* ()
		(system? '(mkdir -p "/mnt/target/etc/apk"))
		(system? '(cp "/etc/apk/repositories" "/mnt/target/etc/apk/repositories"))
		(display ">>> Initializing root filesystem...") (newline)
		(apk-chroot! '(--initdb --allow-untrusted alpine-base))))

(define (install-initpkgs! initpkgs)
	(and-let* ()
		(display (string-append ">>> Installing initial packages: " (string-join initpkgs  ", "))) (newline)
		(apk-chroot! (map string->symbol initpkgs))))

(define (setup-target! config)
	(let
		( (pkgcfg (assq 'packages config)))
		(and-let* ()
			(init-rootfs!)
			(unless (eqv? pkgcfg #f)
				(install-initpkgs! (vector->list (cdr pkgcfg)))))))

(define (run-chroot! taskcfg)
	(system?
		(append '(chroot /mnt/target sh -c )
			(list (cdr (assq 'chroot taskcfg))))))

(define (run-copy! taskcfg)
	(let*
		( (copy-args (assq 'copy taskcfg))
			(src (cdr (assq 'src copy-args)))
			(dest (cdr (assq 'dest copy-args))))
		(system?
			(append '(cp -avr)
				(list src
					(string-append
						(if (string-prefix? "/" dest) "/mnt/target" "/mnt/target/") dest))))))

(define (task task-type task-process taskcfg)
	(begin
		(display
			(string-append "=== TASK [" task-type "]"
				(if (assq 'name taskcfg) (string-append " : " (cdr (assq 'name taskcfg)))) ""))
		(newline)
		(task-process taskcfg)))

(define (run-task! taskcfg)
	(cond
		((assq 'chroot taskcfg)
			(task "chroot" run-chroot! taskcfg))
		((assq 'copy taskcfg)
			(task "copy" run-copy! taskcfg))
		(else
			(begin
				(display "!!! Invalid task detected: ") (newline)
				(display taskcfg) (newline) #f))))
