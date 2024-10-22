.386
.MODEL FLAT
OPTION CASEMAP: NONE

.DATA
temp_val real4 ?
val real4 ?
const1 dd 2
sec_val real4 ?

.CODE
_FUNC_F@4 PROC
finit
fld real4 ptr [esp + 4]
fstp val
fld val
fstp sec_val
fldpi
fild const1
fdiv
fstp temp_val
;fld val
;fld temp_val
;fprem
;fldz
;fcomip st(0), st(1)
;je Error
;ok:
fld val
fld temp_val
fdiv
fistp const1
fild const1
fldpi
fmul
fstp temp_val
fld val
fld temp_val
fsub
fstp val
fld val
fptan
fstp val
fstp val
fld val
fld sec_val
fadd
ret 4
;Error:
;fld sec_val
;fldpi
;fprem
;fldz
;fcomip st(0), st(1)
;je ok
;MOV EAX, [0x7FFFFFFF]
;ret 4
_FUNC_F@4 ENDP
END