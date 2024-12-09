(in-package :lem-core)

(defvar *named-key-syms*
  '("Backspace" "Insert" "Delete" "Down" "End" "Escape" "F0" "F1" "F10" "F11" "F12" "F2" "F3" "F4" "F5" "F6" "F7" "F8" "F9"
    "Home" "Left" "NopKey" "PageDown" "PageUp" "Return" "Right" "Space" "Tab" "Up"))

(defun named-key-sym-p (key-sym)
  (find key-sym *named-key-syms* :test #'string=))

(defmacro define-named-key (name)
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (pushnew ,name *named-key-syms* :test 'string=)))

(defparameter *key-sym-to-character-table* (make-hash-table :test 'equal))

(defun key-to-character (key)
  (gethash key *key-sym-to-character-table*))

(defun (setf key-to-character) (character key)
  (setf (gethash key *key-sym-to-character-table*) character))

(defstruct (key (:constructor %make-key))
  (ctrl nil :type boolean)
  (meta nil :type boolean)
  (super nil :type boolean)
  (hypher nil :type boolean)
  (shift nil :type boolean)
  (sym 0 :type string))

(defmethod print-object ((object key) stream)
  (with-slots (ctrl meta super hypher shift sym) object
    (write-string (key-to-string :ctrl ctrl
                                 :meta meta
                                 :super super
                                 :hypher hypher
                                 :shift shift
                                 :sym sym)
                  stream)))

(defun key-to-string (&key ctrl meta super hypher shift sym)
  (with-output-to-string (stream)
    (when hypher (write-string "H-" stream))
    (when super (write-string "S-" stream))
    (when meta (write-string "M-" stream))
    (when ctrl (write-string "C-" stream))
    (when shift (write-string "Shift-" stream))
    (if (string= sym " ")
        (write-string "Space" stream)
        (write-string sym stream))))

(defvar *key-conversions* '(("C-m" . "Return")
                            ("C-i" . "Tab")
                            ("C-[" . "Escape")))

(defvar *key-constructor-cache* (make-hash-table :test 'equal))

(defun convert-key (&rest args &key ctrl meta super hypher shift sym)
  (let ((elt (assoc (apply #'key-to-string args) *key-conversions* :test #'equal)))
    (if elt
        (let ((key (first (parse-keyspec (cdr elt)))))
          (list :ctrl (key-ctrl key)
                :meta (key-meta key)
                :super (key-super key)
                :hypher (key-hypher key)
                :shift (key-shift key)
                :sym (key-sym key)))
        (list :ctrl ctrl
              :meta meta
              :super super
              :hypher hypher
              :shift shift
              :sym sym))))

(defun make-key (&rest args &key ctrl meta super hypher shift sym)
  (let ((hashkey (apply #'convert-key args)))
    (or (gethash hashkey *key-constructor-cache*)
        (setf (gethash hashkey *key-constructor-cache*)
              (apply #'%make-key args)))))

(defun match-key (key &key ctrl meta super hypher shift sym)
  (and (eq (key-ctrl key) ctrl)
       (eq (key-meta key) meta)
       (eq (key-super key) super)
       (eq (key-hypher key) hypher)
       (eq (key-shift key) shift)
       (equal (key-sym key) sym)))

(defun insertion-key-sym-p (sym)
  (= 1 (length sym)))

(defun key-to-char (key)
  (cond ((key-to-character key))
        ((and (insertion-key-sym-p (key-sym key))
              (match-key key :sym (key-sym key)))
         (char (key-sym key) 0))))

(setf (key-to-character (make-key :ctrl t :sym "@")) (code-char 0))
(setf (key-to-character (make-key :ctrl t :sym "a")) (code-char 1))
(setf (key-to-character (make-key :ctrl t :sym "b")) (code-char 2))
(setf (key-to-character (make-key :ctrl t :sym "c")) (code-char 3))
(setf (key-to-character (make-key :ctrl t :sym "d")) (code-char 4))
(setf (key-to-character (make-key :ctrl t :sym "e")) (code-char 5))
(setf (key-to-character (make-key :ctrl t :sym "f")) (code-char 6))
(setf (key-to-character (make-key :ctrl t :sym "g")) (code-char 7))
(setf (key-to-character (make-key :ctrl t :sym "h")) (code-char 8))
(setf (key-to-character (make-key :sym "Tab")) (code-char 9))
(setf (key-to-character (make-key :ctrl t :sym "j")) (code-char 10))
(setf (key-to-character (make-key :ctrl t :sym "k")) (code-char 11))
(setf (key-to-character (make-key :ctrl t :sym "l")) (code-char 12))
(setf (key-to-character (make-key :sym "Return")) (code-char 13))
(setf (key-to-character (make-key :ctrl t :sym "n")) (code-char 14))
(setf (key-to-character (make-key :ctrl t :sym "o")) (code-char 15))
(setf (key-to-character (make-key :ctrl t :sym "p")) (code-char 16))
(setf (key-to-character (make-key :ctrl t :sym "q")) (code-char 17))
(setf (key-to-character (make-key :ctrl t :sym "r")) (code-char 18))
(setf (key-to-character (make-key :ctrl t :sym "s")) (code-char 19))
(setf (key-to-character (make-key :ctrl t :sym "t")) (code-char 20))
(setf (key-to-character (make-key :ctrl t :sym "u")) (code-char 21))
(setf (key-to-character (make-key :ctrl t :sym "v")) (code-char 22))
(setf (key-to-character (make-key :ctrl t :sym "w")) (code-char 23))
(setf (key-to-character (make-key :ctrl t :sym "x")) (code-char 24))
(setf (key-to-character (make-key :ctrl t :sym "y")) (code-char 25))
(setf (key-to-character (make-key :ctrl t :sym "z")) (code-char 26))
(setf (key-to-character (make-key :sym "Escape")) (code-char 27))
(setf (key-to-character (make-key :ctrl t :sym "\\")) (code-char 28))
(setf (key-to-character (make-key :ctrl t :sym "]")) (code-char 29))
(setf (key-to-character (make-key :ctrl t :sym "^")) (code-char 30))
(setf (key-to-character (make-key :ctrl t :sym "_")) (code-char 31))
(setf (key-to-character (make-key :sym "Space")) (code-char #x20))
(setf (key-to-character (make-key :sym "Backspace")) (code-char #x7F))
(setf (key-to-character (make-key :sym "Down")) (code-char #o402))
(setf (key-to-character (make-key :sym "Up")) (code-char #o403))
(setf (key-to-character (make-key :sym "Left")) (code-char 260))
(setf (key-to-character (make-key :sym "Right")) (code-char 261))
(setf (key-to-character (make-key :ctrl t :sym "Down")) (code-char 525))
(setf (key-to-character (make-key :ctrl t :sym "Up")) (code-char 566))
(setf (key-to-character (make-key :ctrl t :sym "Left")) (code-char 545))
(setf (key-to-character (make-key :ctrl t :sym "Right")) (code-char 560))
(setf (key-to-character (make-key :sym "Home")) (code-char 262))
(setf (key-to-character (make-key :sym "Backspace")) (code-char 263))
(setf (key-to-character (make-key :sym "F0")) (code-char 264))
(setf (key-to-character (make-key :sym "F1")) (code-char 265))
(setf (key-to-character (make-key :sym "F2")) (code-char 266))
(setf (key-to-character (make-key :sym "F3")) (code-char 267))
(setf (key-to-character (make-key :sym "F4")) (code-char 268))
(setf (key-to-character (make-key :sym "F5")) (code-char 269))
(setf (key-to-character (make-key :sym "F6")) (code-char 270))
(setf (key-to-character (make-key :sym "F7")) (code-char 271))
(setf (key-to-character (make-key :sym "F8")) (code-char 272))
(setf (key-to-character (make-key :sym "F9")) (code-char 273))
(setf (key-to-character (make-key :sym "F10")) (code-char 274))
(setf (key-to-character (make-key :sym "F11")) (code-char 275))
(setf (key-to-character (make-key :sym "F12")) (code-char 276))
(setf (key-to-character (make-key :shift t :sym "F1")) (code-char 277))
(setf (key-to-character (make-key :shift t :sym "F2")) (code-char 278))
(setf (key-to-character (make-key :shift t :sym "F3")) (code-char 279))
(setf (key-to-character (make-key :shift t :sym "F4")) (code-char 280))
(setf (key-to-character (make-key :shift t :sym "F5")) (code-char 281))
(setf (key-to-character (make-key :shift t :sym "F6")) (code-char 282))
(setf (key-to-character (make-key :shift t :sym "F7")) (code-char 283))
(setf (key-to-character (make-key :shift t :sym "F8")) (code-char 284))
(setf (key-to-character (make-key :shift t :sym "F9")) (code-char 285))
(setf (key-to-character (make-key :shift t :sym "F10")) (code-char 286))
(setf (key-to-character (make-key :shift t :sym "F11")) (code-char 287))
(setf (key-to-character (make-key :shift t :sym "F12")) (code-char 288))
(setf (key-to-character (make-key :sym "Delete")) (code-char 330))
(setf (key-to-character (make-key :ctrl t :sym "Delete")) (code-char 519))
(setf (key-to-character (make-key :shift t :sym "Down")) (code-char 336))
(setf (key-to-character (make-key :shift t :sym "Up")) (code-char 337))
(setf (key-to-character (make-key :sym "PageDown")) (code-char 338))
(setf (key-to-character (make-key :sym "PageUp")) (code-char 339))
(setf (key-to-character (make-key :shift t :sym "Tab")) (code-char 353))
(setf (key-to-character (make-key :sym "End")) (code-char 360))
(setf (key-to-character (make-key :shift t :sym "Delete")) (code-char 383))
(setf (key-to-character (make-key :shift t :sym "End")) (code-char 386))
(setf (key-to-character (make-key :shift t :sym "Home")) (code-char 391))
(setf (key-to-character (make-key :shift t :sym "Left")) (code-char 393))
(setf (key-to-character (make-key :shift t :sym "PageDown")) (code-char 396))
(setf (key-to-character (make-key :shift t :sym "PageUp")) (code-char 398))
(setf (key-to-character (make-key :shift t :sym "Right")) (code-char 402))
(setf (key-to-character (make-key :sym "NopKey")) (code-char 600)) ; used for nop-command

(loop :for code :from #x21 :below #x7F
      :do (setf (key-to-character (make-key :sym (string (code-char code)))) (code-char code)))
