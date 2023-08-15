(define (export-kernel! imagecfg)
  (let* 
    ( (kernel-from (assq 'from (cdr imagecfg)))
      (kernel-dest (assq 'dest (cdr imagecfg))))
    (cond
      (kernel-from
        (system? (list "cp" "-v" (cdr kernel-from) 
          (string-append "/output/" 
						(if kernel-dest (cdr kernel-dest) "kernel.img")))))
      (else #f))))

(define (export-initramfs! imagecfg)
  (let* 
    ( (compression (assq 'compression (cdr imagecfg)))
      (dest (assq 'dest (cdr imagecfg)))
			(from (assq 'from (cdr imagecfg))))
    (system? (list "sh" "-c" 
      (string-append "cd /mnt/target; find . -not -path ./boot -print0 | cpio --null --create --verbose --format=newc"
        (if compression (string-append " | " (cdr compression)) "")
        " > /output/" (if dest (cdr dest) "initramfs.img"))))))

(define (export-tar! imagecfg)
  (let*
    ( (tar-dest (assq 'dest (cdr imagecfg)))
      (tar-args (assq 'args (cdr imagecfg))))
    (system? 
      (append '("tar") (if tar-args (vector->list (cdr tar-args)) '())
        (list "-C" "/mnt/target" "-vcf" (string-append "/output/" (cdr tar-dest)) ".")))))

(define (export-erofs! imagecfg) 
	(let*
		( (erofs-dest (assq 'dest (cdr imagecfg)))
			(erofs-compression (assq 'compression (cdr imagecfg))))
		(system?
			(append '("mkfs.erofs") 
				(if erofs-compression (list "-z" (cdr erofs-compression)) '())
				(list (string-append "/output/" (cdr erofs-dest)))
				(list "/mnt/target")))))

(define (export-uki! imgcfg)
	(let*
		( (uki-dest (assq 'dest (cdr imgcfg)))
			(uki-cmdline (assq 'cmdline (cdr imgcfg)))
      		(uki-kernel (assq 'kernel (cdr imgcfg)))
      		(uki-initramfs-list (assq 'initramfs (cdr imgcfg))))
		(with-directory "/output"
			(lambda _ (system?
				(append `(efi-mkuki -c ,(cdr uki-cmdline) -o ,(cdr uki-dest) ,(cdr uki-kernel))
					(vector->list (cdr uki-initramfs-list))))))))

(define (run-export-image type-string image-process imagecfg)
	(begin
		(display (string-append ">>> Exporting " type-string)) (newline)
		(if (image-process (car imagecfg)) #t 
			(begin (display (string-append "!!! Failed to export " type-string)) (newline) #f))))

(define (export-image! imagecfg) (begin
	(cond
		((assq 'kernel imagecfg)
			(run-export-image "kernel" export-kernel! imagecfg))
		((assq 'initramfs imagecfg)
			(run-export-image "initramfs" export-initramfs! imagecfg))
		((assq 'tar imagecfg)
			(run-export-image "tar" export-tar! imagecfg))
		((assq 'erofs imagecfg)
			(run-export-image "erofs" export-erofs! imagecfg))
		((assq 'uki imagecfg)
			(run-export-image "uki" export-uki! imagecfg))
		(else
			(begin
				(display "!!! Invalid image config detected: ") (newline)
				(display imagecfg) (newline) #f)))))

(define (write-images! config) 
	(and-let* 
		( (images-cfg (assq 'images config))
			(image-list (vector->list (cdr images-cfg)))
		(display ">>> Writing out images...") (newline)
		(fold 
			(lambda (x y) (and (export-image! x) y)) #t image-list))))
