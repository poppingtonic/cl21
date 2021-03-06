(in-package :cl-user)
(defpackage cl21.core
  (:use :cl)
  (:shadow :function
           :destructuring-bind)
  (:import-from :cl21.core.cons
                :maptree)
  (:import-from :alexandria
                :once-only
                :if-let
                :when-let
                :xor
                :unwind-protect-case
                :doplist)
  (:import-from :cl-utilities
                :with-collectors
                :collecting
                :collect)
  (:export
   :compile
   :eval
   :eval-when
   :load-time-value
   :quote
   :t
   :nil

   :compiler-macro-function
   :define-compiler-macro
   :defmacro
   :macro-function
   :macroexpand
   :macroexpand-1
   :define-symbol-macro
   :symbol-macrolet
   :*macroexpand-hook*

   :proclaim
   :declaim
   :declare
   :ignore :ignorable
   :dynamic-extent
   :type
   :inline :notinline
   :ftype
   :declaration
   :optimize
   :special
   :locally
   :the
   :special-operator-p
   :constantp
   :space
   :speed
   :safety
   :debug
   :compilation-speed

   ;; Data and Control Flow
   :defconstant
   :defparameter
   :defvar
   :destructuring-bind
   :let
   :let*
   :progv
   :setq
   :psetq
   :block
   :catch
   :go
   :return-from
   :return
   :tagbody
   :throw
   :unwind-protect
   :not
   :eq
   :eql
   :equal
   :identity
   :complement
   :constantly
   :every
   :some
   :notevery
   :notany
   :and
   :cond
   :if
   :or
   :when
   :unless
   :case
   :ccase
   :ecase
   :typecase
   :ctypecase
   :etypecase
   :otherwise
   :multiple-value-bind
   :multiple-value-call
   :multiple-value-list
   :multiple-value-prog1
   :multiple-value-setq
   :values
   :values-list
   :multiple-values-limit
   :nth-value
   :prog
   :prog*
   :prog1
   :prog2
   :progn
   :define-modify-macro
   :defsetf
   :define-setf-expander
   :get-setf-expansion
   :setf
   :psetf
   :shiftf
   :rotatef
   :undefined-function
   :if-let
   :when-let
   :xor
   :unwind-protect-case
   :with-slots
   :with-accessors

   ;; Iteration
   :loop
   :do
   :do*
   :dotimes
   :dolist
   :doplist ;; from Alexandria
   :loop-finish

   :with-collectors
   :collecting
   :collect

   :until
   :while
   :while-let
   :doeach

   ;; Printer
   :copy-pprint-dispatch
   :formatter
   :pprint-dispatch
   :pprint-exit-if-list-exhausted
   :pprint-fill
   :pprint-linear
   :pprint-tabular
   :pprint-indent
   :pprint-logical-block
   :pprint-newline
   :pprint-pop
   :pprint-tab
   :print-unreadable-object
   :set-pprint-dispatch
   :prin1
   :print
   :pprint
   :princ
   :write
   :write-to-string
   :prin1-to-string
   :princ-to-string
   :*print-array*
   :*print-base*
   :*print-radix*
   :*print-case*
   :*print-circle*
   :*print-escape*
   :*print-gensym*
   :*print-level*
   :*print-length*
   :*print-lines*
   :*print-miser-width*
   :*print-pprint-dispatch*
   :*print-pretty*
   :*print-readably*
   :*print-right-margin*
   :print-not-readable
   :print-not-readable-object
   :format

   ;; System Construction
   :compile-file
   :compile-file-pathname
   :load
   :require  ;; Though this is deprecated, commonly used without cl: prefix.
   :with-compilation-unit
   :*features*
   :*compile-file-pathname*
   :*compile-file-truename*
   :*load-pathname*
   :*load-truename*
   :*compile-print*
   :*compile-verbose*
   :*load-print*
   :*load-verbose*

   ;; Environment
   :export :decode-universal-time
   :encode-universal-time
   :get-universal-time
   :get-decoded-time
   :sleep
   :trace
   :untrace
   :step
   :time
   :internal-time-units-per-second
   :get-internal-real-time
   :get-internal-run-time
   :disassemble
   :documentation
   :variable
   :compiler-macro
   :room
   :ed
   :dribble
   :lisp-implementation-type
   :lisp-implementation-version
   :short-site-name
   :long-site-name
   :machine-instance
   :machine-type
   :machine-version
   :software-type
   :software-version
   :user-homedir-pathname

   ;; misc
   :&optional
   :&rest
   :&body
   :&environment
   :&key
   :&whole
   :&allow-other-keys
   :&aux

   :once-only))
(in-package :cl21.core)

(cl:dolist (package-name '(:cl21.core.types
                           :cl21.core.condition
                           :cl21.core.package
                           :cl21.core.object
                           :cl21.core.function
                           :cl21.core.structure
                           :cl21.core.symbol
                           :cl21.core.number
                           :cl21.core.character
                           :cl21.core.cons
                           :cl21.core.array
                           :cl21.core.string
                           :cl21.core.sequence
                           :cl21.core.hash-table
                           :cl21.core.file
                           :cl21.core.stream
                           :cl21.core.generic
                           :cl21.core.repl
                           :cl21.core.readtable
                           :cl21.core.cltl2))
  (cl:let ((package (cl:find-package package-name)))
    (cl:unless package
      (cl:error "Package \"~A\" doesn't exist." package-name))
    (cl:do-external-symbols (symbol package)
      (cl:shadowing-import symbol)
      (cl:export symbol))))

(defmacro destructuring-bind (lambda-list expression &body body)
  "Bind the variables in LAMBDA-LIST to the corresponding values in the
tree structure resulting from the evaluation of EXPRESSION.

CL21 Feature: NIL in LAMBDA-LIST will be ignored."
  (let* (gensym-list
         (new-lambda-list (maptree (lambda (elem)
                                     (cond
                                       ((eq elem nil) (let ((gensym (gensym "NIL")))
                                                      (push gensym gensym-list)
                                                      gensym))
                                       (T elem)))
                                   lambda-list)))
    `(cl:destructuring-bind ,new-lambda-list ,expression
       (declare (ignore ,@gensym-list))
       ,@body)))

(defmacro until (expression &body body)
  "Executes `body` until `expression` is true."
  `(do ()
       (,expression)
     ,@body))

(defmacro while (expression &body body)
  "Executes `body` while `expression` is true."
  `(until (not ,expression)
     ,@body))

(defmacro while-let ((varsym expression) &body body)
  "Executes `body` while `expression` is true and binds its return value to `varsym`"
  `(let (,varsym)
     (while (setf ,varsym ,expression)
       ,@body)))

(defmacro doeach ((varsym object &optional return) &body body)
  (let ((elem (gensym "ELEM")))
    (once-only (object)
      `(block nil
         (etypecase ,object
           (sequence
            (map nil
                 ,(if (listp varsym)
                      `(lambda (,elem)
                         (destructuring-bind ,varsym ,elem
                           (tagbody ,@body)))
                      `(lambda (,varsym)
                         (tagbody ,@body)))
                 ,object))
           (hash-table
            ,(if (and (listp varsym)
                      (null (cddr varsym)))
                 `(maphash (lambda ,varsym
                             (tagbody ,@body))
                           ,object)
                 `(error "~A can't be destructured against the key/value pairs of a hash-table."
                         ',varsym))))
         ,return))))
