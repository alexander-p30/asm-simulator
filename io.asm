%define BUFF_SIZE 50
%define BUFF_SIZE_PLUS_ONE 1025
%define OUTPUT_FILE_MAXSIZE 200
%define SPACE_CHAR 32
%define ZERO_CHAR 48
%define NINE_CHAR 57

%define INSTR_ADD			1
%define INSTR_SUB			2
%define INSTR_MULT		3
%define INSTR_DIV			4
%define INSTR_JMP			5
%define INSTR_JMPN		6
%define INSTR_JMPP		7
%define INSTR_JMPZ		8
%define INSTR_COPY		9
%define INSTR_LOAD		10
%define INSTR_STORE		11
%define INSTR_INPUT		12
%define INSTR_OUTPUT	13
%define INSTR_STOP		14

section .data
line_br db 0dH, 0ah
; INSTRUCTION TEXT ==================
instr_add_text db 'ADD', line_br
instr_sub_text db 'SUB', line_br
instr_mult_text db 'MULT', line_br
instr_div_text db 'DIV', line_br
instr_jmp_text db 'JMP', line_br
instr_jmpn_text db 'JMPN', line_br
instr_jmpp_text db 'JMPP', line_br
instr_jmpz_text db 'JMPZ', line_br
instr_copy_text db 'COPY', line_br
instr_load_text db 'LOAD', line_br
instr_store_text db 'STORE', line_br
instr_input_text db 'INPUT', line_br
instr_output_text db 'OUTPUT', line_br
instr_stop_text db 'STOP', line_br
; INSTRUCTION TEXT ==================

prompt_fname db 'Digite o nome do arquivo: '
prompt_fname_size equ $-prompt_fname

decode_error_msg db 'Erro ao decodificar instrucao! PC: '
decode_error_msg_size equ $-decode_error_msg

debug_print db 'eax: '
debug_print_size equ $-debug_print
fsize_in_bytes dd 0

program_data times BUFF_SIZE dd 0
program_size dd 0
program_size_in_bytes dd 0

output_file_ext db '.diss', 0
output_file_ext_size equ $-output_file_ext

used_instructions	times BUFF_SIZE db 0
used_instructions_count	dd 0

section .bss
output_file_content resb OUTPUT_FILE_MAXSIZE
output_file_name resb BUFF_SIZE
; func read_file
fdescriptor resd 1
fcontent resb BUFF_SIZE
fname resb BUFF_SIZE

; func print_int
digits_string resb BUFF_SIZE

; runtime
program_input resb BUFF_SIZE

section .text
global _start
_start:	

				; print prompt_fname
				mov eax, 4
				mov ebx, 1
				mov ecx, prompt_fname
				mov edx, prompt_fname_size
				int 80h

				; get fname
				mov eax, 3
				mov ebx, 1
				mov ecx, fname
				mov edx, BUFF_SIZE
				int 80h
				; add 0 to end of string
				mov byte [ecx + eax - 1], 0

				push fname
				call read_file
				add ESP, 4

				mov ecx, fcontent
				cmp dword [ecx], 0
				je run_program

				; init counter
				mov eax, 0
build_program_data:
				; convert next string to integer
				push ecx
				call string_to_int
				add ESP, 4

				; check if end of string was reached
				cmp dword [ecx], 0
				je run_program

				; add converted value to program_data's content
				mov dword [program_data + eax], edx

				; inc counter
				add eax, 4
				inc dword [program_size]
				add dword [program_size_in_bytes], 4
				jmp build_program_data

run_program:
				; eax = acc
				mov eax, 0
				; ebx = pc
				mov ebx, 0

run_program_loop:
				; DEBUG PRINT ACC
				;pusha
				;mov eax, 4
				;mov ebx, 1
				;mov ecx, debug_print
				;mov edx, debug_print_size
				;int 80h
				;popa
				;push eax
				;call print_int
				;add ESP, 4

				; check if end of program was reached
				cmp dword [program_size], ebx
				je end

				; add instruction to history
				inc dword [used_instructions_count]
				push eax
				mov eax, dword [used_instructions_count]
				add eax, used_instructions
				mov cl, byte [program_data + ebx * 4]
				mov [eax], cl
				pop eax

				; decode current instruction
				cmp dword [program_data + ebx * 4], INSTR_ADD
				je run_add
				cmp dword [program_data + ebx * 4], INSTR_SUB
				je run_sub
				cmp dword [program_data + ebx * 4], INSTR_MULT
				je run_mult
				cmp dword [program_data + ebx * 4], INSTR_DIV
				je run_div
				cmp dword [program_data + ebx * 4], INSTR_JMP
				je run_jmp
				cmp dword [program_data + ebx * 4], INSTR_JMPN
				je run_jmpn
				cmp dword [program_data + ebx * 4], INSTR_JMPP
				je run_jmpp
				cmp dword [program_data + ebx * 4], INSTR_JMPZ
				je run_jmpz
				cmp dword [program_data + ebx * 4], INSTR_COPY
				je run_copy
				cmp dword [program_data + ebx * 4], INSTR_LOAD
				je run_load
				cmp dword [program_data + ebx * 4], INSTR_STORE
				je run_store
				cmp dword [program_data + ebx * 4], INSTR_INPUT
				je run_input
				cmp dword [program_data + ebx * 4], INSTR_OUTPUT
				je run_output
				cmp dword [program_data + ebx * 4], INSTR_STOP
				je run_stop

				; ERROR: INSTRUCTION COULDN'T BE DECODED

				push ebx

				mov eax, 4
				mov ebx, 1
				mov ecx, decode_error_msg
				mov edx, decode_error_msg_size
				int 80h

				call print_int
				add ESP, 4

				; return
				mov eax, 1
				mov ebx, 1
				int 80h

run_add:
				inc ebx
				push ebx
				; load value address
				mov ebx, dword [program_data + ebx * 4]
				add eax, dword [program_data + ebx * 4]
				; restore ebx as PC
				pop ebx
				inc ebx
				jmp run_program_loop

run_sub:
				inc ebx
				push ebx
				; load value address
				mov ebx, dword [program_data + ebx * 4]
				sub eax, dword [program_data + ebx * 4]
				; restore ebx as PC
				pop ebx
				inc ebx
				jmp run_program_loop

run_mult:
				inc ebx
				push ebx
				; load value address
				mov ebx, dword [program_data + ebx * 4]
				mov ecx, dword [program_data + ebx * 4]
				mul ecx
				; restore ebx as PC
				pop ebx
				inc ebx
				jmp run_program_loop

run_div:
				inc ebx
				push ebx
				; load value address
				mov ebx, dword [program_data + ebx * 4]
				mov ecx, dword [program_data + ebx * 4]
				div ecx
				; restore ebx as PC
				pop ebx
				inc ebx
				jmp run_program_loop

run_jmp:
				inc ebx
				; load jump address into ebx
				mov ebx, dword [program_data + ebx * 4]
				jmp run_program_loop

run_jmpn:
				inc ebx	
				add eax, 0
				js run_jmpn_true
				inc ebx
				jmp run_jmpn_end
run_jmpn_true:
				mov ebx, dword [program_data + ebx * 4]
run_jmpn_end:
				jmp run_program_loop

run_jmpp:
				inc ebx	
				add eax, 0
				jns run_jmpp_true
				inc ebx
				jmp run_jmpp_end
run_jmpp_true:
				mov ebx, dword [program_data + ebx * 4]
run_jmpp_end:
				jmp run_program_loop

run_jmpz:
				inc ebx	
				cmp eax, 0
				je run_jmpz_true
				inc ebx
				jmp run_jmpz_end
run_jmpz_true:
				mov ebx, dword [program_data + ebx * 4]
run_jmpz_end:
				jmp run_program_loop

run_copy:
				inc ebx
				push eax
				; load target address
				mov edx, dword [program_data + ebx * 4]
				; load source address
				inc ebx
				mov eax, dword [program_data + ebx * 4]
				; load source value
				mov ecx, dword [program_data + eax * 4]
				; store source value into target address
				mov dword [program_data + edx * 4], ecx
				; restore eax as acc
				pop eax
				inc ebx
				jmp run_program_loop

run_load:
				inc ebx
				push ebx
				; load value into acc
				mov ebx, dword [program_data + ebx * 4]
				mov eax, dword [program_data + ebx * 4]
				; restore ebx as PC
				pop ebx
				inc ebx
				jmp run_program_loop

run_store:
				inc ebx
				push ebx
				; load target address
				mov ebx, dword [program_data + ebx * 4]
				; store acc value into target address
				mov dword [program_data + ebx * 4], eax
				; restore ebx as PC
				pop ebx
				inc ebx
				jmp run_program_loop

run_input:
				inc ebx
				push eax
				push ebx

				; get input
				mov eax, 3
				mov ebx, 1
				mov ecx, program_input
				mov edx, BUFF_SIZE
				int 80h
				; 0-terminate input
				mov byte [ecx + eax - 1], 0

				; restore ebx as PC
				pop ebx

				; load target address into ecx
				mov eax, dword [program_data + ebx * 4]
				; convert program address into internal address
				mov edx, 0
				mov ecx, 4
				mul ecx
				add eax, program_data

				; edx = input int
				push program_input
				call string_to_int
				add ESP, 4

				; store converted input into target address
				mov [eax], edx

				; restore eax as acc
				pop eax
				inc ebx
				jmp run_program_loop

run_output:
				inc ebx
				push ebx
				; load value address
				mov ebx, dword [program_data + ebx * 4]
				; load value in address into ecx
				mov ecx, dword [program_data + ebx * 4]
				; print ecx
				push ecx
				call print_int
				add ESP, 4
				; restore ebx as PC
				pop ebx
				inc ebx
				jmp run_program_loop
				
run_stop:
				; write disassemble file
				push fname
				push used_instructions
				push used_instructions_count
				call write_disassemble_file
				add ESP, 12

				jmp end

				
end:
				; return
				mov eax, 1
				mov ebx, 0
				int 80h

%define FILE_TO_READ [EBP + 8]
read_file:
				enter 0, 0
				push eax
				push ebx
				push ecx
				push edx

				; open file
				mov eax, 5
				mov ebx, FILE_TO_READ
				mov ecx, 0
				mov edx, 0700
				int 80h
				mov [fdescriptor], eax

				; read file (BUFF_SIZE bytes)
				mov eax, 3
				mov ebx, [fdescriptor]
				mov ecx, fcontent
				mov edx, BUFF_SIZE
				int 80h

				mov ecx, eax
				mov eax, 3

				; close file
				mov eax, 6
				mov ebx, fdescriptor
				int 80h

				pop edx
				pop ecx
				pop ebx
				pop eax

				leave
				ret

%define OUTPUT_FILE_NAME [EBP + 16]
%define INST_HISTORY_PTR [EBP + 12]
%define INST_COUNT [EBP + 8]
write_disassemble_file:
				enter 0, 0

build_output_filename:
				mov eax, OUTPUT_FILE_NAME
				mov ebx, output_file_name
				mov ecx, 0
build_output_filename_loop:
				mov cl, byte [eax]
				inc eax
				inc ebx
				mov [ebx], cl
				cmp cl, 0
				je build_output_filename_ext
				jmp build_output_filename_loop
build_output_filename_ext:
				mov eax, output_file_ext
build_output_filename_ext_loop:
				mov cl, byte [eax]
				inc eax
				inc ebx
				mov [ebx], cl
				cmp cl, 0
				je write_output_file
				jmp build_output_filename_ext_loop
;build_output_filecontent:
;				mov eax, used_instructions
;				mov ebx, output_file_content
;build_output_filecontent_loop:
;				cmp dword [eax], INSTR_ADD
;				je used_add
;				cmp dword [eax], INSTR_SUB
;				je used_sub
;				cmp dword [eax], INSTR_MULT
;				je used_mult
;				cmp dword [eax], INSTR_DIV
;				je used_div
;				cmp dword [eax], INSTR_JMP
;				je used_jmp
;				cmp dword [eax], INSTR_JMPN
;				je used_jmpn
;				cmp dword [eax], INSTR_JMPP
;				je used_jmpp
;				cmp dword [eax], INSTR_JMPZ
;				je used_jmpz
;				cmp dword [eax], INSTR_COPY
;				je used_copy
;				cmp dword [eax], INSTR_LOAD
;				je used_load
;				cmp dword [eax], INSTR_STORE
;				je used_store
;				cmp dword [eax], INSTR_INPUT
;				je used_input
;				cmp dword [eax], INSTR_OUTPUT
;				je used_output
;				cmp dword [eax], INSTR_STOP
;				je used_stop
;used_add:
;				mov ecx, instr_add_text
;				jmp add_instr_to_output_filecontent
;used_sub:
;				mov ecx, instr_sub_text
;				jmp add_instr_to_output_filecontent
;used_mult:
;				mov ecx, instr_mult_text
;				jmp add_instr_to_output_filecontent
;used_div:
;				mov ecx, instr_div_text
;				jmp add_instr_to_output_filecontent
;used_jmp:
;				mov ecx, instr_jmp_text
;				jmp add_instr_to_output_filecontent
;used_jmpn:
;				mov ecx, instr_jmpn_text
;				jmp add_instr_to_output_filecontent
;used_jmpp:
;				mov ecx, instr_jmpp_text
;				jmp add_instr_to_output_filecontent
;used_jmpz:
;				mov ecx, instr_jmpz_text
;				jmp add_instr_to_output_filecontent
;used_copy:
;				mov ecx, instr_copy_text
;				jmp add_instr_to_output_filecontent
;used_load:
;				mov ecx, instr_load_text
;				jmp add_instr_to_output_filecontent
;used_store:
;				mov ecx, instr_store_text
;				jmp add_instr_to_output_filecontent
;used_input:
;				mov ecx, instr_input_text
;				jmp add_instr_to_output_filecontent
;used_output:
;				mov ecx, instr_output_text
;				jmp add_instr_to_output_filecontent
;used_stop:
;				mov ecx, instr_stop_text
;				jmp write_output_file
;add_instr_to_output_filecontent:
;				mov dl, byte [ecx]
;				mov [eax], dl
;				inc eax
;				inc ecx
;				cmp byte [ecx], 0dH
;				je build_output_filecontent_loop
;				jmp add_instr_to_output_filecontent
;				
write_output_file:
				mov eax, 4
				mov ebx, 1
				mov ecx, output_file_name
				mov edx, OUTPUT_FILE_MAXSIZE
				int 80h

				leave
				ret

%define INT_TO_CONVERT [EBP + 12]
%define INT_AS_STRING [EBP + 8]
int_to_string:
				enter 0, 0

				; save registers
				push eax
				push ebx
				push ecx
				push edx

				mov eax, INT_TO_CONVERT
				mov ecx, INT_AS_STRING
				mov bx, 10
				mov edx, 0
int_to_string_loop:
				mov edx, 0
				div ebx
				; transform modulus value to char
				add edx, 48
				push dx
				inc cl
				cmp eax, 0
				jnz int_to_string_loop
				mov eax, INT_AS_STRING
int_to_string_invert:
				pop dx
				mov byte [eax], dl
				inc al
				dec cl
				cmp ecx, INT_AS_STRING
				ja int_to_string_invert

				mov byte [eax], 0Dh
				inc al
				mov byte [eax], 0Ah

				; restore registers
				pop edx
				pop ecx
				pop ebx
				pop eax

				leave
				ret

%define INT_TO_PRINT [EBP + 8]
print_int:
				enter 0, 0

				push dword INT_TO_PRINT
				push dword digits_string
				call int_to_string
				add ESP, 8

				push eax
				push ebx
				push ecx
				push edx

				mov eax, 4
				mov ebx, 1
				mov ecx, digits_string
				mov edx, BUFF_SIZE
				int 80h

				mov eax, 0
print_int_clear_digits_string:
				cmp eax, BUFF_SIZE
				je print_int_end
				mov byte [digits_string + eax], 0
				inc eax
				jmp print_int_clear_digits_string

print_int_end:
				pop edx
				pop ecx
				pop ebx
				pop eax

				leave
				ret

; ecx = string_ptr, edx = int
%define STRING_TO_CONVERT [EBP + 8]
string_to_int:
				enter 0, 0
				push eax
				push ebx
				mov ecx, STRING_TO_CONVERT
				mov edx, 0
				mov eax, 0
string_to_int_find_int_start:
				cmp byte [ecx], ZERO_CHAR
				jae string_to_int_higher_than_zero
				jmp string_to_int_find_int_start_next
string_to_int_higher_than_zero:
				cmp byte [ecx], NINE_CHAR
				jle string_to_int_loop
string_to_int_find_int_start_next:
				cmp byte [ecx], 0
				je string_to_int_end
				inc ecx
				jmp string_to_int_find_int_start
string_to_int_loop:
				cmp byte [ecx], ZERO_CHAR
				jb string_to_int_end
				cmp byte [ecx], NINE_CHAR
				ja string_to_int_end
				mov bl, byte [ecx]
				sub ebx, ZERO_CHAR
				push ebx
				mov ebx, 10
				mul ebx
				pop ebx
				add eax, ebx
				inc ecx
				jmp string_to_int_loop
				
string_to_int_end:
				mov edx, eax
				pop ebx
				pop eax
				leave
				ret

