%define   SHORT_PADDING    4
%define   LONG_PADDING     8
%define   FACTOR           10
%define   NODE_SIZE        12
%define   MINUS            45
%define   ZERO             48

section  .data
    delim db " ", 0

section  .bss
    root resd 1

section  .text

extern   check_atoi
extern   print_tree_inorder
extern   print_tree_preorder
extern   evaluate_tree

extern   strtok
extern   calloc
extern   strdup

global   create_tree
global   iocla_atoi

iocla_atoi:
    push ebp
    mov  ebp, esp
    ; se aduce in edx sirul primit ca parametru
    mov  edx, [ebp + LONG_PADDING]
    ; se initializeaza ecx si edi, fiind utilizate in continuare
    mov  ecx, 0
    mov  edi, 0

; se verifica daca numarul este negativ
verify_negative:    
	mov  al, byte[edx + ecx]
	cmp  al, MINUS
	; daca primul caracter al sirului nu e minus, se trece la formarea numarului
	jne  adding
	; daca numarul e negativ, se retine in ebx 0 pentru a scadea din 0 numarul
	; obtinut in urma converisei, rezultand un numar negativ
	mov  ebx, 0
	inc  ecx

adding:
	mov  eax, 0
	; se copiaza in al cate o cifra din sir
	mov  al, byte[edx + ecx]
	; daca se ajunge la \0 sau la \n, se opreste bucla
	cmp  al, ZERO
	jl 	 final
	; pentru a converti caracterul in cifra, se scade codul ascii al lui 10 din
	; aceasta
	sub  al, ZERO
	; se inmulteste numarul actual din edi cu 10 pentru a adauga o noua
	; cifra acestuia la final
	imul edi, FACTOR
	add  edi, eax
	inc  ecx
	jmp  adding

final:
	; daca numarul este negativ, se converteste numarul pozitiv in negativ
	cmp  ebx, 0
	je   convert

returnare:
	mov  eax, 0
	; se pune rezultatul in eax si se returneaza
	mov  eax, edi
	leave
    ret

convert:
    ; se scade din 0 (ebx) numarul pentru a-i schimba semnul
	sub  ebx, edi
	mov  edi, ebx
	jmp  returnare

; functie recrusiva pentru creearea arborelui
create_nodes:
    push ebp
    mov  ebp, esp
    ; functia primeste ca parametru un sir de caractere, urmand sa creeze
    ; un nod pentru acesta
    mov  edi, [ebp + LONG_PADDING]
    cmp  edi, 0
    je   null_node
    ; Se aloca memorie pentru un nod. Se da push lui 12 deoarece se vor
    ; aloca 4 octeti pentru sir si cate 4 pentru a retine un pointer catre
    ; subarborele stang si unul catre subarborele drept
    push NODE_SIZE
    push 1
    call calloc
    add  esp, LONG_PADDING
    ; se muta structura in esi
    mov  esi, eax
    ; se apeleaza strdup pentru alocarea sirului primit ca parametru
    push edi
    call strdup
    add  esp, SHORT_PADDING
    ; se pune sirul alocat la adresa lui esi(primul camp al structurii)
    mov  [esi], eax
    mov  cl, byte[eax]
    ; daca nodul contine un numar, este returnat
    cmp  cl, ZERO
    jge  end
    ; se verifica suplimentar si al doilea caracter, deoarece exista si numere
    ; negative
    mov  cl, byte[eax + 1]
    cmp  cl, 0
    jne  end
    ; se pune pe stiva operatorul creat
    push esi
    ; se extrage urmatorul simbol din sir
	push delim
    push 0
    call strtok
    add  esp, LONG_PADDING
    ; se apeleaza functia create nodes si se leaga rezultatul la stanga
    ; operatorului creat
    push eax
    call create_nodes
    add  esp, SHORT_PADDING
    pop  eax
    mov  [eax + SHORT_PADDING], esi
    ; se extrage alt simbol si se apeleaza functia din nou
    push eax
    push delim
    push 0
    call strtok
    add  esp, LONG_PADDING
    push eax
    call create_nodes
    add  esp, SHORT_PADDING
    pop  eax
    mov  [eax + LONG_PADDING], esi
    ; se copiaza subarborele astfel creat in esi pentru a fi la randul sau legat
	mov  esi, eax
	jmp  end

; bloc de instructiuni pentru cazul cand strtok-ul pe un sir se termina
null_node:
	mov  esi, 0
	jmp  end

end:
	leave
    ret

create_tree:
    enter 0, 0
    ; se extrage sirul primit ca parametru
    mov   edx, [ebp + LONG_PADDING]
    ; se apeleaza strtok pentru sir
    push  delim
    push  edx
    call  strtok
    add   esp, LONG_PADDING
    ; se apeleaza functia recursiva ce creeaza arborele
    push  eax
    call  create_nodes
    add   esp, SHORT_PADDING
    leave
    ret
