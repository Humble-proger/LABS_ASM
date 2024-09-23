.386
.MODEL FLAT, STDCALL
OPTION CASEMAP: NONE
; прототипы внешних функций (процедур) описываются директивой EXTERN, 
; после знака @ указывается общая длина передаваемых параметров,
; после двоеточия указывается тип внешнего объекта – процедура
EXTERN  GetStdHandle@4: PROC
EXTERN  WriteConsoleA@20: PROC
EXTERN  CharToOemA@8: PROC
EXTERN  ReadConsoleA@20: PROC
EXTERN  ExitProcess@4: PROC; функция выхода из программы
EXTERN  lstrlenA@4: PROC; функция определения длины строки

.DATA; сегмент данных
STRN1 db "Введите первое число: ",13,10,0; выводимая строка, в конце добавлены
; управляющие символы: 13 – возврат каретки, 10 – переход на новую 
; строку, 0 – конец строки; с использованием директивы DB 
; резервируется массив байтов
STRN2 db "Введите второе число: ", 13, 10, 0;
DERR db "ERROR: Число введено не верно", 13, 10, 0;
DIN DD ?; дескриптор ввода; директива DD резервирует память объемом
; 32 бита (4 байта), знак «?» используется для неинициализированных данных
DOUT DD ?; дескриптор вывода
BUF  DB 200 dup (?); буфер для вводимых/выводимых строк длиной 200 байтов
LENS DD ?; переменная для количества выведенных символов
VAL SDWORD ?; переменная хранящая значение первого числа


.CODE; сегмент кода
CONVERTCHARTOINT PROC
; Подпрограмма берёт число из BUF, размера LENS и сохраняет в регистр EAX
; Проверяем число является ли отрицательным
MOV ESI, OFFSET BUF
MOV ECX, LENS
XOR EBX, EBX
MOV EAX, 0
MOV BL, [ESI];
CMP BL, '-'
JNE NO_Otr
JE Otr
NO_Otr: ; Если не отрицательно
	CONVERT:
		MOV EDX, 10
		MOV BL, [ESI];
		SUB BL, '0';
		MUL EDX;
		ADD EAX, EBX
		INC ESI;
	LOOP CONVERT;
	jmp end_proces
Otr: ; Если отрицательно
	INC ESI;
	CONVERT_1:
		MOV EDX, 10
		MOV BL, [ESI];
		SUB BL, '0';
		IMUL EDX;
		ADD EAX, EBX
		INC ESI;
	LOOP CONVERT_1;
	MOV EDX, -1
	IMUL EDX
end_proces:
	ret
CONVERTCHARTOINT ENDP

CONVERT10TO16 PROC
; Переводит результат в шестнадцатеричный формат
; Первый параметр число которое переводится 
MOV ESI, OFFSET BUF
PUSH OFFSET BUF
CALL lstrlenA@4
MOV ECX, EAX
CLEAR_LIST:
	MOV EBX, 0
	MOV [ESI], EBX
	INC ESI
LOOP CLEAR_LIST

MOV ESI, OFFSET BUF
MOV EAX, VAL

CMP EAX, 0
JL Be
JA next
JE next
Be:
	MOV EBX, '-'
	MOV [ESI], EBX
	INC ESI
	MOV EDX, -1
	IMUL EDX
next:
MOV EBX, 16
MOV ECX, EAX
MOV EBP, 0
CONVERT_2:
	XOR EDX, EDX
	DIV EBX
	CMP EDX, 9
	JA large
	JE ok_num
	JB ok_num
	large:
		SUB EDX, 10
		ADD EDX, 'A'
		PUSH EDX
		jmp end_if
	ok_num:
		ADD EDX, '0'
		PUSH EDX
	end_if:
	INC EBP
	MOV ECX, EAX
	INC ECX
LOOP CONVERT_2

MOV ECX, EBP
TO_BUF:
	POP EAX
	MOV [ESI], EAX
	INC ESI
LOOP TO_BUF
ret
CONVERT10TO16 ENDP

CHECKNUM PROC
; Проверить является ли число подходящим под условие
; Условие: число имеет минимум 4 символа
; Нужно: не пустой BUF, LENS
MOV ESI, OFFSET BUF
MOV BL, [ESI];
CMP BL, '-'
JE Minus
JNE Not_minus
Minus:
	SUB LENS, 1
Not_minus:
CMP LENS, 4
JB Error
JE Not_err
JA Not_err
Error:
	PUSH OFFSET DERR
	CALL lstrlenA@4; длина в EAX
	PUSH 0; в стек помещается 5-й параметр
	PUSH OFFSET LENS; 4-й параметр
	PUSH EAX; 3-й параметр
	PUSH OFFSET DERR; 2-й параметр
	PUSH DOUT; 1-й параметр
	CALL WriteConsoleA@20
	PUSH 1
	CALL ExitProcess@4
Not_err:
	ret
CHECKNUM ENDP

MAIN PROC; начало описания процедуры с именем MAIN
MOV  EAX, OFFSET STRN1;	командой MOV  значение второго операнда 
; перемещается в первый, OFFSET – операция, возвращающая адрес
PUSH EAX; параметры функции помещаются в стек командой PUSH
PUSH EAX
CALL CharToOemA@8;
MOV  EAX, OFFSET STRN2
PUSH EAX 
PUSH EAX
CALL CharToOemA@8; вызов функции
MOV  EAX, OFFSET DERR
PUSH EAX 
PUSH EAX
CALL CharToOemA@8; вызов функции
; получим дескриптор ввода 
PUSH -10
CALL GetStdHandle@4
MOV DIN, EAX 	; переместить результат из регистра EAX 
; в ячейку памяти с именем DIN
; получим дескриптор вывода
PUSH -11
CALL GetStdHandle@4
MOV DOUT, EAX 
; определим длину строк STRN
PUSH OFFSET STRN1; в стек помещается адрес строки
CALL lstrlenA@4; длина в EAX
PUSH 0; в стек помещается 5-й параметр
PUSH OFFSET LENS; 4-й параметр
PUSH EAX; 3-й параметр
PUSH OFFSET STRN1; 2-й параметр
PUSH DOUT; 1-й параметр
CALL WriteConsoleA@20
PUSH 0; в стек помещается 5-й параметр
PUSH OFFSET LENS; 4-й параметр
PUSH 200; 3-й параметр
PUSH OFFSET BUF; 2-й параметр
PUSH DIN; 1-й параметр
CALL ReadConsoleA@20 ; обратите внимание: LENS больше числа введенных
; символов на два, дополнительно введенные символы: 13 – возврат каретки и 
; 10 – переход на новую строку
; вывод полученной строки
SUB LENS, 2;
CALL CHECKNUM;
CALL CONVERTCHARTOINT;
MOV VAL, EAX
PUSH OFFSET STRN2; в стек помещается адрес строки
CALL lstrlenA@4; длина в EAX
PUSH 0; в стек помещается 5-й параметр
PUSH OFFSET LENS; 4-й параметр
PUSH EAX; 3-й параметр
PUSH OFFSET STRN2; 2-й параметр
PUSH DOUT; 1-й параметр
CALL WriteConsoleA@20
PUSH 0; в стек помещается 5-й параметр
PUSH OFFSET LENS; 4-й параметр
PUSH 200; 3-й параметр
PUSH OFFSET BUF; 2-й параметр
PUSH DIN; 1-й параметр
CALL ReadConsoleA@20 ; обратите внимание: LENS больше числа введенных
; символов на два, дополнительно введенные символы: 13 – возврат каретки и 
; 10 – переход на новую строку
; вывод полученной строки
SUB LENS, 2;
CALL CHECKNUM;
CALL CONVERTCHARTOINT;
ADD VAL, EAX
CALL CONVERT10TO16
PUSH OFFSET BUF
CALL lstrlenA@4;
PUSH 0
PUSH OFFSET LENS
PUSH EAX
PUSH OFFSET BUF
PUSH DOUT
CALL WriteConsoleA@20
PUSH 0; параметр: код выхода
CALL ExitProcess@4
MAIN ENDP; завершение описания модуля с указанием первой выполняемой процедуры
END MAIN;
