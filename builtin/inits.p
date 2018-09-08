lvars s = inits(2);
`a` -> s(1);
`b` -> s(2);
s =>

;;; out| ** ab

`c` -> s(3);

;;; err| ;;; MISHAP - BAD SUBSCRIPT FOR INDEXED ACCESS
;;; err| ;;; INVOLVING:  3 'ab'
;;; err| ;;; FILE     :  builtin/inits.p   LINE
;;; err| ;;; 	NUMBER:  9
;;; err| ;;; PRINT DOING
;;; err| ;;; DOING    :  subscrs trycompile
