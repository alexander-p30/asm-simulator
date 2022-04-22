; TODO: write readme
%define BUFF_SIZE 1024
%define OUTPUT_FILE_MAXSIZE 4096
%define ZERO_CHAR 48
%define NINE_CHAR 57
%define MINUS_CHAR 45

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
%define LINE_BR 0dH, 0ah

section .data
; INSTRUCTION TEXT ==================
instr_add_text db 'ADD', LINE_BR
instr_sub_text db 'SUB', LINE_BR
instr_mult_text db 'MULT', LINE_BR
instr_div_text db 'DIV', LINE_BR
instr_jmp_text db 'JMP', LINE_BR
instr_jmpn_text db 'JMPN', LINE_BR
instr_jmpp_text db 'JMPP', LINE_BR
instr_jmpz_text db 'JMPZ', LINE_BR
instr_copy_text db 'COPY', LINE_BR
instr_load_text db 'LOAD', LINE_BR
instr_store_text db 'STORE', LINE_BR
instr_input_text db 'INPUT', LINE_BR
instr_output_text db 'OUTPUT', LINE_BR
instr_stop_text db 'STOP', LINE_BR
; INSTRUCTION TEXT ==================

decode_error_msg db 'Erro ao decodificar instrucao! PC: '
decode_error_msg_size equ $-decode_error_msg

debug_print db 'eax: '
debug_print_size equ $-debug_print

program_data times BUFF_SIZE dd 0
program_size dd 0
program_size_in_bytes dd 0

output_file_ext db '.diss', 0

used_instructions	times BUFF_SIZE dd 0
used_instructions_char_count	dd 0

; output file data
output_file_content times OUTPUT_FILE_MAXSIZE db 0
output_file_name times 256 db 0
output_file_position dd 0
output_file_size dd 0

; file read error
file_read_error_msg db 'Erro ao ler arquivo ou arquivo inexistente.', LINE_BR
file_read_error_msg_size equ $-file_read_error_msg

section .bss
; func read_file
fdescriptor resd 1
fcontent resb BUFF_SIZE
fname resb BUFF_SIZE

; func print_int
digits_string resb BUFF_SIZE

; runtime
program_input resb BUFF_SIZE

section .text
global c_entrypoint
%define ARGV_1 [EBP + 8]
c_entrypoint:
				enter 0, 0

				mov ebx, ARGV_1
				mov eax, 0
c_entrypoint_count_loop:
				mov cl, [ebx + eax]
				mov [fname + eax], cl
				cmp cl, 0
				je c_entrypoint_end
				inc eax
				jmp c_entrypoint_count_loop

c_entrypoint_end:
				mov eax, 4
				mov ebx, 1
				mov ecx, fname
				mov edx, 13

				push fname
				call read_file
				add ESP, 4

				add dword [fdescriptor], 0
				jns file_read_success
				cmp dword [fcontent], 0
				jne file_read_success

				mov eax, 4
				mov ebx, 1
				mov ecx, file_read_error_msg
				mov edx, file_read_error_msg_size
				int 80h

				mov eax, 1
				mov ebx, 1
				int 80h

file_read_success:
				mov ecx, fcontent

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
				
				; add instruction to output file
				push eax
				push edx
				push instr_add_text
				call add_instr_to_output_filecontent
				add ESP, 4
				pop edx
				pop eax

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
				
				; add instruction to output file
				push eax
				push edx
				push instr_sub_text
				call add_instr_to_output_filecontent
				add ESP, 4
				pop edx
				pop eax

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
				
				; add instruction to output file
				push eax
				push edx
				push instr_mult_text
				call add_instr_to_output_filecontent
				add ESP, 4
				pop edx
				pop eax

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

				; add instruction to output file
				push eax
				push edx
				push instr_div_text
				call add_instr_to_output_filecontent
				add ESP, 4
				pop edx
				pop eax

				jmp run_program_loop

run_jmp:
				inc ebx
				; load jump address into ebx
				mov ebx, dword [program_data + ebx * 4]

				; add instruction to output file
				push eax
				push edx
				push instr_jmp_text
				call add_instr_to_output_filecontent
				add ESP, 4
				pop edx
				pop eax

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

				; add instruction to output file
				push eax
				push edx
				push instr_jmpn_text
				call add_instr_to_output_filecontent
				add ESP, 4
				pop edx
				pop eax

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

				; add instruction to output file
				push eax
				push edx
				push instr_jmpp_text
				call add_instr_to_output_filecontent
				add ESP, 4
				pop edx
				pop eax

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
				; add instruction to output file
				push eax
				push edx
				push instr_jmpz_text
				call add_instr_to_output_filecontent
				add ESP, 4
				pop edx
				pop eax

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

				; add instruction to output file
				push eax
				push edx
				push instr_copy_text
				call add_instr_to_output_filecontent
				add ESP, 4
				pop edx
				pop eax

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

				; add instruction to output file
				push eax
				push edx
				push instr_load_text
				call add_instr_to_output_filecontent
				add ESP, 4
				pop edx
				pop eax

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

				; add instruction to output file
				push eax
				push edx
				push instr_store_text
				call add_instr_to_output_filecontent
				add ESP, 4
				pop edx
				pop eax

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

				; add instruction to output file
				push eax
				push edx
				push instr_input_text
				call add_instr_to_output_filecontent
				add ESP, 4
				pop edx
				pop eax

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

				; add instruction to output file
				push eax
				push edx
				push instr_output_text
				call add_instr_to_output_filecontent
				add ESP, 4
				pop edx
				pop eax

				jmp run_program_loop
				
run_stop:
				; add instruction to output file
				push eax
				push edx
				push instr_stop_text
				call add_instr_to_output_filecontent
				add ESP, 4
				pop edx
				pop eax

				; write disassemble file
				push fname
				push used_instructions
				call write_disassemble_file
				add ESP, 12

				jmp end

				
end:
				mov eax, [output_file_size]
				; return
				leave 
				ret

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

%define OUTPUT_FILE_NAME [EBP + 12]
%define INST_HISTORY_PTR [EBP + 8]
write_disassemble_file:
				enter 0, 0

build_output_filename:
				mov eax, OUTPUT_FILE_NAME
				mov ebx, output_file_name
				mov ecx, 0
build_output_filename_loop:
				mov cl, byte [eax]
				inc eax
				cmp cl, 0
				je build_output_filename_ext
				mov [ebx], cl
				inc ebx
				jmp build_output_filename_loop
build_output_filename_ext:
				mov eax, output_file_ext
build_output_filename_ext_loop:
				mov cl, byte [eax]
				inc eax
				mov [ebx], cl
				inc ebx
				cmp cl, 0
				je write_output_file
				jmp build_output_filename_ext_loop

write_output_file:
				mov eax, 8
				mov ebx, output_file_name
				mov ecx, 666o
				int 80h

				mov ebx, eax
				mov eax, 4
				mov ecx, output_file_content
				mov edx, [output_file_size]
				int 80h

				mov eax, 6
				int 80h

				leave
				ret

%define INSTR_TO_ADD [ESP + 8]
add_instr_to_output_filecontent:
				enter 0, 0
				mov eax, [output_file_position]
				mov ecx, INSTR_TO_ADD
add_instr_to_output_filecontent_loop:
				mov edx, 0
				mov dl, byte [ecx]
				mov [output_file_content + eax], dl
				inc eax
				inc dword [output_file_size]
				cmp byte [ecx], 0aH
				je add_instr_to_output_filecontent_end
				inc ecx
				jmp add_instr_to_output_filecontent_loop
add_instr_to_output_filecontent_end:
				mov [output_file_position], eax
				leave
				ret
				
%define INT_TO_CONVERT [EBP + 12]
%define INT_AS_STRING [EBP + 8]
%define INT_AS_STRING_NUMBER_START [EBP - 4]
int_to_string:
				enter 4, 0

				; save registers
				push eax
				push ebx
				push ecx
				push edx

				mov eax, INT_TO_CONVERT
				mov ecx, INT_AS_STRING
				mov INT_AS_STRING_NUMBER_START, ecx
				mov ebx, 10
				mov edx, 0
				add eax, 0
				jns int_to_string_loop
				; convert "unsigned" to signed
				mov byte [ecx], 45
				inc ecx
				add dword INT_AS_STRING_NUMBER_START, 1
				sub edx, 1
				imul edx
				mov edx, 0
int_to_string_loop:
				mov edx, 0
				div ebx
				; transform modulus value to char
				add edx, 48
				push edx
				inc ecx
				cmp eax, 0
				jnz int_to_string_loop
				mov eax, INT_AS_STRING_NUMBER_START
int_to_string_invert:
				pop edx
				mov byte [eax], dl
				inc eax
				dec ecx
				cmp ecx, INT_AS_STRING_NUMBER_START
				ja int_to_string_invert

				mov byte [eax], 0Dh
				inc eax
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
%define IS_NEGATIVE [EBP - 4]
string_to_int:
				enter 4, 0
				push eax
				push ebx
				mov ecx, STRING_TO_CONVERT
				mov edx, 0
				mov eax, 0
				mov dword IS_NEGATIVE, 0
string_to_int_find_int_start:
				cmp byte [ecx], ZERO_CHAR
				jae string_to_int_higher_than_zero
				jmp string_to_int_find_int_start_next
string_to_int_higher_than_zero:
				cmp byte [ecx], NINE_CHAR
				jle its_a_digit
string_to_int_find_int_start_next:
				cmp byte [ecx], 0
				je string_to_int_end
				inc ecx
				jmp string_to_int_find_int_start
its_a_digit:
				cmp ecx, STRING_TO_CONVERT
				je string_to_int_loop
				push ecx
				dec ecx
				cmp byte [ecx], MINUS_CHAR
				je its_negative
				pop ecx
				jmp string_to_int_loop
its_negative:
				pop ecx
				mov dword IS_NEGATIVE, 1
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
				cmp dword IS_NEGATIVE, 1
				jne string_to_int_return
				mov edx, 0
				push ebx
				mov ebx, -1
				imul ebx
				pop ebx
string_to_int_return:
				mov edx, eax
				pop ebx
				pop eax
				leave
				ret

