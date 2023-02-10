;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IPL SELECTER for MZ-80B/MZ-2000/2200 Ver.0.9  2021/01/30
;     (c)2001-2021 Hideki Suga (@junk_suga)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;�f�B�X�N�i�[�C���[�W
;Tr Sc (Sect) LOAD
; 0  1 (0000) ----    IPLPRO IPL�p�f�[�^
; 0  2 (0001) 0000    0000 ���Z�N�V����
; 0  3 (0002) 0100 -> F200 ���Z�N�V����
; 0  4 (0003) 0200 -> F300
; 0  5 (0004) 0300 -> F400
; 0  6 (0005) 0400 -> F500
; 0  7 (0006) 0500 -> F600
; 0  8 (0007) 0600 -> F700
; 0  9 (0008) 0700 -> F800
; 0 10 (0009) 0800 -> F900
; 0 11 (000A) 0900 -> FA00
; 0 12 (000B) 0A00 -> FB00
; 0 13 (000C) 0B00 -> FC00
; 0 14 (000D) 0C00 -> FD00
; 0 15 (000E) 0D00 -> FE00
; 0 16 (000F) 0E00 �r�b�g�}�b�v(FAT)
; 1  1 (0010) 0F00 �f�B���N�g��
; 1  2 (0011) 1000     �V
; 1  3 (0012) 1100     �V
; 1  4 (0013) 1200     �V
; 1  5 (0014) 1300     �V
; 1  6 (0015) 1400     �V
; 1  7 (0016) 1500     �V
; 1  8 (0017) 1600 �f�B���N�g���i�I��j
; 1  9 (0018) 1700 ���g�p
; �E�E�E�E�E�E�E�E
; 1 16 (001F) 1700 ���g�p
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MD80B	EQU	'8'
MD2000	EQU	'2'
MD2500	EQU	'5'
DIRSIZ	EQU	00020H
DIR	EQU	08000H	; FILE LIST
IPLDIR	EQU	00F20H	; RECORD 0010 + 20H
VRAM8L	EQU	05000H	; MZ-80B Low VRAM
VRAM	EQU	0D000H	; MZ-80B Hi,MZ-2000/2200 VRAM
VRAM25	EQU	0C000H	; MZ-2500 VRAM
;
DRINO	EQU	0FFECH - 08000H	; Boot Drive
;
; FDD I/O Port
CR	EQU	0D8H
TR	EQU	0D9H
SCR	EQU	0DAH
DR	EQU	0DBH
DM	EQU	0DCH
HS	EQU	0DDH
;
;
;
CLWORK	EQU	0B000H	; VRAM Cler Work
;
BIPL	EQU	0F000H	; 
B1SCT	EQU	0F100H	; 
B2SCT	EQU	0F200H	; 
B2SCTE	EQU	0FEFFH	; 
;
;
	ORG	BIPL	; Tr:0 Sc:1 SharpSector:0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IPLPRO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;IPL�p�f�[�^�\��
;    +0 +1 +2 +3 +4 +5 +6 +7 +8 +9 +A +B +C +D +E +F
;000 01 <-----�i�Ǎ��ݎ��V�X�e���� �Ō�� 0DH�K�{�j
;010 ----> 00 00 00 1F 00 00 XX XX 00 00 00 ?? 01 00
;                ^^^^^ ��MZ80B,2000/2200���Ǎ��݃o�C�g�� 1F00H
;                            ^^^^^ ��MZ2500�����s�J�n�A�h���X
;              MZ2500�����[�h�J�n�Z�N�^ 0001H��^^^^^
;020 08 FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
;    ^^��MZ2500�����[�h���郁�����}�b�v
;030 08 09 0A 0B 0C 0D 0E �ȍ~���g�p
;    ^^^^^^^^^^^^^^^^^^^^��MZ2500���s���������}�b�v
;

IPLPRO: ; 000H-
	DB	001H		; Model : MZ-80B/MZ-2000/2200/2500
	DB	"IPLPRO"	; Launch signature
	; 007H-
	;	 ----+----1-
	DB	"IPLS09bKai"	; System Name
	DB	00DH
	; 012H-
	DW	00000H
	DW	01F00H		; LOAD SIZE
	DW	00000H
	DW	MZ25S - B1SCT	; Execution address (MZ-2500)
	DW	00000H
	DW	00000H
	DW	00001H		; Load start sector
	; 020H-
				; Memory block column to load (MZ-2500 only)
	DB	008H,0FFH,0FFH,0FFH
	DB	0FFH,0FFH,0FFH,0FFH
	DB	0FFH,0FFH,0FFH,0FFH
	DB	0FFH,0FFH,0FFH,0FFH
	; 030H-
				; Memory block column to Execution (MZ-2500 only)
	DB	8,9,10,11,12,13,14
	;
IPLPROE:
	DS	B1SCT - IPLPROE	; spacer
	; -0FFH

;	B1SCT	0F300H -> ���A�h���X 00000H
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MZ-80B/2000/2200 Execution address
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	DI
;
; IPL BOOT�h���C�u�ۑ�
	LD	A,(0FFECH - 08000H)
	LD	(DIRNO),A
;
; 8255 ������
	LD	A,082H		; 8255 A=out B=in C=out
	OUT	(0E3H),A
	LD	A,058H		; b3:BST=1 b4:OPEN=1 b6:WRITE=1
	OUT	(0E2H),A
;
; PIO ������
	LD	A,00FH		; PIO A=out
	OUT	(0E9H),A
	LD	A,0CFH		; PIO B=in
	OUT	(0EBH),A
	LD	A,0FFH		; 2018/08/07�ǉ�
	OUT	(0EBH),A
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  MZ-80B�A2000����
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; ���C���������̋@�픻��ʒu������
	LD	HL,VRAM8L
	LD	(HL),' '
;
; VRAM �I��
;
; MZ-80B  05000H -> CVRAM
; MZ-2000 0D000H -> CVRAM
	IN	A,(0E8H)
	AND	0DFH		; 40�����[�h
	OR	0C0H		; PIOA6=1,PIOA7=1
	OUT	(0E8H),A
;
; MZ-80B���ʕ����Z�b�g
	LD	(HL),MD80B
;
; VRAM �ؗ���
	IN	A,(0E8H)
	AND	03FH
	OUT	(0E8H),A
;
; ���[�h����
; ���C����������MZ-80B�̔��蕶���񂪎c���ĂȂ���� MZ-80B
	LD	A,(HL)
	CP	MD80B
	JR	NZ,MSET80
;
; ���茋�ʁFMZ-2000/2200
	LD	A,MD2000
	LD	(MODE),A

	LD	A,0F7H		; PIO A ������
	OUT	(0E0H),A
	XOR	A
	OUT	(0F6H),A	; �O���t�B�b�N��\��
	OUT	(0F4H),A	; �o�b�N�O�����h��
	LD	A,007H
	OUT	(0F5H),A	; �L�����N�^��
;
	LD	HL,VRAM		; MZ-2000���[�h����C-VRAM�A�h���X
	LD	(VRAMAD),HL
;
	JR	CHKOUT
;
;
; ���茋�ʁFMZ-80B
MSET80:
	LD	A,MD80B
	LD	(MODE),A

	LD	A,012H		; PIO A ������
	OUT	(0E0H),A
	XOR	A		; �O���t�B�b�N��\��
	OUT	(0F4H),A
;
	LD	HL,VRAM8L	; MZ-80B���[�h����C-VRAM�A�h���X
	LD	(VRAMAD),HL

	JR	CHKOUT


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MZ-2500 Execution address
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MZ25S:
	DI
	LD	A,MD2500	; MZ-2500 Mode Set
	LD	(MODE),A
;
	LD	A,00FH		; YM-2203 Port B Select
	OUT	(0C8H),A
	IN	A,(0C9H)
	BIT	6,A		; Resolution SW 0:H(400) 1:L(200)
	JR	Z,MZ25SE	; 400 Line?
;
	LD	A,'L'		; 200 Line
	LD	(MZ25HL),A
	LD	A,001H		; All characters are displayed in 8 lines
	OUT	(0F7H),A
;
MZ25SE:
	LD	HL,VRAM25	; Charactor VRAM Address
	LD	(VRAMAD),HL

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ���Z�N�V���������A�h���X�ɓ]�����W�����v
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHKOUT:
;
	LD	SP,STACK
;
	LD	HL,B2SCT - B1SCT	; ���Z�N�V�����Ǎ��݃A�h���X
	LD	DE,B2SCT		; ���Z�N�V�������s�J�n�A�h���X
	LD	BC,B2SCTE - B2SCT + 1	; �]����
	LDIR

	JP	B2SCT
;
; 
B1SCTE:
	DS	B2SCT - B1SCTE	; spacer


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ���Z�N�V����
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; B2SCT
;
;
;	IPL BOOT�h���C�u�ۑ� (MZ-2500 80B���[�h�΍�)
	LD	A,(0FFECH - 08000H)
	LD	(DIRNO),A

;	��ʑS�̃N���A
	LD	HL,0
	CALL	VRCLR
;
;	MZ-2500���[�h�����H
	LD	A,(MODE)
	CP	MD2500
	JR	NZ,NOT2500
;
;	MZ-2500���[�h�\��
	LD	DE,MZ2500
	LD	HL,0
	LD	BC,40
	CALL	VRDISP
;
;	���[�j���O�\��
	LD	DE,MZ25W
	LD	HL,40 * 18
	LD	BC,40
	CALL	VRDISP
;
;	�A���_�[�o�[�^�g�b�v�o�[�ؑ�
;	2500���[�h���́A'_'�����̂܂ܕ\�������̂ŏ�����
;	80B/2000���[�h���� '~' �ɂȂ�̂Ŏ��s�\�����f�t�H���g�ɂ��Ă�
	LD	A,'_'
	LD	(ERFDUB),A
	LD	(ERFDUB + 2),A
	LD	A,00DH
	LD	(ERFDLF),A
;
;
NOT2500:
;	MZ-80B���[�h���H
	CP	MD80B
	JR	NZ,NOT80B
;
;	MZ-80B���[�h
	LD	DE,MZ80B
	JR	VERDSP
;
;	MZ-2000/2200���[�h
NOT80B:
	LD	DE,MZ2000
;
VERDSP:
	LD	HL,0
	LD	BC,40
	CALL	VRDISP
;
; �o�[�W�����\��
	LD	DE,VERS
	LD	HL,40
	LD	BC,40
	CALL	VRDISP
;
;
; �f�B�X�N�^�C�v�\��(FAT�u���b�N�{��)
	LD	DE,DSK2DD
	LD	A,(00EFFH)	; 0:2D,1:2DD
	CP	0
	JR	NZ,DPDM		; 2DD
;
	LD	A,70		; 2D ����MAX�g���b�N����70
	LD	(MAXTRK + 1),A
;
	LD	DE,DSK2D
;
DPDM:	LD	HL,40 * 3
	LD	BC,40
	CALL	VRDISP

; �I��p�f�B���N�g���̈�N���A
CDIR:	LD	BC,DIRSIZ * 30
	LD	HL,DIR
CDIRLP:	LD	(HL),' '
	INC	HL
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,CDIRLP
;
;
	CALL	MOFF		; ���[�^�[��~
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; �f�B���N�g������OBJ�t�@�C����T���I��p�̈�֓]��
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	XOR	A
	LD	(MAXDIR),A
	LD	(CHKDIR),A
;
	LD	HL,IPLDIR
	LD	(SAVE01),HL
;
	LD	DE,DIR
	LD	(SAVE02),DE
;
CFMDLP:	LD	HL,(SAVE01)
	LD	A,(HL)
	CP	001H		; obj ?
	JR	NZ,CFMDNX
;
; OBJ�f�B���N�g����I��̈�֓]��
	LD	HL,(SAVE01)	; IPL-DIR  (FD)
	LD	DE,(SAVE02)	; LIST-DIR
	LD	BC,00020H
	LDIR
;
; �t�@�C�����̑O��A�`Z:��
	LD	A,(MAXDIR)
	INC	A
	LD	(MAXDIR),A
	ADD	A,'@'
	LD	HL,(SAVE02)
	LD	(HL),A
	INC	HL
	LD	(HL),':'
	INC	HL
	PUSH	HL
	LD	HL,(SAVE01)
	INC	HL
	POP	DE
	LD	BC,17
	LDIR
;
; NEXT IPL-DIR
	LD	HL,(SAVE02)
	LD	DE,DIRSIZ
	ADD	HL,DE
	LD	(SAVE02),HL
;
	LD	A,(MAXDIR)	; �ő�Q�U�܂�
	CP	26
	JR	Z,CFMDEX
;
;
CFMDNX:	LD	HL,(SAVE01)
	LD	DE,DIRSIZ
	ADD	HL,DE
	LD	(SAVE01),HL
	LD	A,(CHKDIR)
	ADD	A,1
	LD	(CHKDIR),A
	CP	60
	JR	NZ,CFMDLP

CFMDEX:

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; �t�@�C���ꗗ�\��
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PDIR:	XOR	A
	LD	(SAVE03),A
	LD	HL,MAXDIR
	CP	(HL)
	JP	Z,ENOFIL		; �t�@�C������ -> �G���[
;
	LD	HL,DIR
	LD	(SAVE04),HL
	LD	DE,40 * 5 + 2
	LD	(SAVE05),DE
;
PDIRLP:
	LD	HL,(SAVE04)
	LD	A,(HL)
	CP	' '
	JR	Z,PDIREX	; �擪���X�y�[�X�Ȃ�\���I��
;
	LD	HL,(SAVE05)
	LD	DE,(SAVE04)
	LD	BC,19
	CALL	VRDISP

;
	LD	HL,(SAVE05)	; ���̉�ʕ\���ʒu�v�Z
	LD	DE,40
	ADD	HL,DE
	LD	(SAVE05),HL
	LD	DE,40 * 18	; �c13+5�s
	SBC	HL,DE
	JR	C,PDIRLP2
	LD	DE,20
	SBC	HL,DE
	JR	NC,PDIRLP2
	LD	DE,40 * 5 + 22
	LD	(SAVE05),DE
PDIRLP2:
	LD	HL,(SAVE04)	; ���̃f�B���N�g���v�Z
	LD	DE,DIRSIZ
	ADD	HL,DE
	LD	(SAVE04),HL
	JR	PDIRLP
;
;
PDIREX:	
	CALL	BEEP
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  �L�[���͗v���\��                                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LD	A,00DH			; �f���~�b�^�Z�b�g
	LD	(SELECT + 1),A

	LD	HL,00000H		; �Ǎ��݊J�n�A�h���X�Z�b�g
	LD	(CLBF0),HL
;
;
	LD	A,(MAXDIR)		; �I��͈�
	ADD	A,'@'
	LD	(SELMAX),A
;
	LD	DE,SELMSG		; �I��͈͕\��
	LD	HL,40 * 20 + 5
	LD	BC,40
	CALL	VRDISP
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  �L�[�{�[�h����                                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
KEYIN:	IN	A,(0E8H)
	AND	0E0H
	OR	014H		; /A-G
	OUT	(0E8H),A
	IN	A,(0EAH)
	CP	0FFH
	JR	Z,KEYL2
	LD	B,'A' - 1
	JR	KEYB0
KEYL2:	IN	A,(0E8H)
	AND	0E0H
	OR	015H		; H-O
	OUT	(0E8H),A
	IN	A,(0EAH)
	CP	0FFH
	JR	Z,KEYL3
	LD	B,'H'
	JR	KEYB0
KEYL3:	IN	A,(0E8H)
	AND	0E0H
	OR	016H		; P-W
	OUT	(0E8H),A
	IN	A,(0EAH)
	CP	0FFH
	JR	Z,KEYL4
	LD	B,'P'
	JR	KEYB0
KEYL4:	IN	A,(0E8H)
	AND	0E0H
	OR	017H		; X-Z
	OUT	(0E8H),A
	IN	A,(0EAH)
	CP	0FFH
	JR	Z,KEYL5
	LD	B,'X'
	JR	KEYB0
;
KEYL5:	JR	KEYIN
;
KEYB0:	BIT	0,A
	JR	NZ,KEYB1
	JR	KEYOUT
KEYB1:	INC	B
	BIT	1,A
	JR	NZ,KEYB2
	JR	KEYOUT
KEYB2:	INC	B
	BIT	2,A
	JR	NZ,KEYB3
	JR	KEYOUT
KEYB3:	INC	B
	BIT	3,A
	JR	NZ,KEYB4
	JR	KEYOUT
KEYB4:	INC	B
	BIT	4,A
	JR	NZ,KEYB5
	JR	KEYOUT
KEYB5:	INC	B
	BIT	5,A
	JR	NZ,KEYB6
	JR	KEYOUT
KEYB6:	INC	B
	BIT	6,A
	JR	NZ,KEYB7
	JR	KEYOUT
KEYB7:	INC	B
	BIT	7,A
	JR	NZ,KEYIN
KEYOUT:	LD	A,B
	LD	(SELECT),A
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  �L�[���͓��e�`�F�b�N                                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	CP	040H		; /
	JP	C,KEYIN		; / �ȉ�
	LD	B,A
	LD	HL,MAXDIR
	LD	A,(HL)
	ADD	A,'A' - 1
	CP	B
	JP	C,KEYIN		; MAX �ȏ�
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; �Z���N�g���e�i�����L�[�L�����N�^�j�\��                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LD	A,(SELECT)
	CP	040H
	JR	NZ, ATOZ
	LD	A, 02FH		; /
	LD	(SELECT), A
ATOZ:
	LD	DE,SELECT
	LD	HL,40 * 20 + 27
	LD	BC,1
	CALL	VRDISP
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; /���I�����ꂽ�ꍇ��MZ-1R12����N������                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LD	A,(SELECT)
	CP	02FH
	JR	NZ, FDD_BOOT
;
	LD	DE,LD1R12MSG		; "NOW LOADING : MZ-1R12"
	LD	HL,40 * 21
	LD	BC,21
	CALL	VRDISP
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MZ-1R12����0000H�`7FFF�Ƀ��������R�s�[����             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MZ1R12_BOOT:
	LD	HL, 0
	LD	BC, 32768
	IN	A,(0F8H)
	XOR	A
	OUT	(0F8H),A
	OUT	(0F9H),A
MZ1R12_READ_LOOP:
	IN	A,(0F9H)
	LD	(HL),A
	INC	HL
	DEC	BC
	LD	A,B			; BC��0�ɂȂ�܂�LOOP����
	OR	C
	JP	NZ, MZ1R12_READ_LOOP
	JP	NOTREAD2ND		; �ʏ�N����
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; �Z���N�g���ꂽ�f�B���N�g���ւ̃I�t�Z�b�g�v�Z           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FDD_BOOT:
	LD	HL,00000H
	LD	DE,00020H
	LD	A,(SELECT)
	SUB	'A'
	JR	Z,OFLEX
OFLP:	ADD	HL,DE
	DEC	A
	JR	NZ,OFLP
OFLEX:	LD	(FOFS),HL
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; �t�@�C�����A�ǂݍ��ݒ����b�Z�[�W�\��                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LD	HL,(FOFS)
	LD	DE,DIR + 2		; �t�@�C����
	ADD	HL,DE
	PUSH	HL
	POP	DE
	LD	HL,40 * 21 + 13
	LD	BC,16
	CALL	VRDISP
;
	LD	DE,LDMSG		; "NOW LOADING :"
	LD	HL,40 * 21
	LD	BC,13
	CALL	VRDISP
;
; ���[�h�A�h���X�� 00000H �Œ�
;
	LD	IX,WKIX
;
; ���[�N�G���A�ݒ�
;
	LD	IY,WKIY
;
;	LD	A,0;(BTDRV)	; �h���C�u�O�Œ�
;	LD	(DIRNO),A
	
;
; �Ǎ��ݑΏۃf�B���N�g�� ==> HL & �X�^�b�N
;
	LD	HL,DIR
	LD	DE,(FOFS)
	ADD	HL,DE
	PUSH	HL
;
; �Ǎ��݊J�n���R�[�h�ԍ��Z�b�g
;
	LD	DE,0001EH
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(STREC),DE		; START RECORD
;
; ���g�p�o�C�g�擾 (FFFFH�ɏ������ރf�[�^�Ƃ��Ďg��)
;
	POP	HL
	PUSH	HL
	LD	DE,00013H
	ADD	HL,DE
	LD	A,(HL)
	LD	(RAMFFFF),A
;
; �Ǎ��݃T�C�Y�Z�b�g
;
	POP	HL
	LD	DE,00014H
	ADD	HL,DE
	LD	A,(HL)
	LD	(IY+2),A
	LD	C,A
	INC	HL
	LD	A,(HL)
	LD	(IY+3),A
	LD	B,A
;
	PUSH	BC
	CALL	BC2HEX
	LD	DE,HEXD
	LD	HL,40 * 21 + 33
	LD	BC,10
	CALL	VRDISP
	POP	BC
;
	; 2�x�ڂ̓ǂݍ��݃T�C�Y0�N���A
	LD	HL,0
	LD	(R2SIZE),HL

	; �t�@�C���T�C�YFBA0H�ȉ���
	LD	HL,ASTART2
	SBC	HL,BC
	JP	NC,LT_FBA0	; �t�@�C���T�C�YFBA0H�ȉ�

	; MZ-2500�Ńt�@�C���T�C�YFBA0H���傫���ꍇ�̓G���[�ɂ���
	LD	A,(MODE)
	CP	MD2500
	JR	NZ,NOT_MZ2500
	JP	ERRBIG

NOT_MZ2500:
	; �t�@�C���T�C�YFBA0H���傫���ꍇ��
	; 0000H�`0DFFFH�܂œǂݍ���ł���2��ڂ̓ǂݍ��݂�E000H�ȍ~��ǂݍ���
	PUSH	BC
	PUSH	DE
	PUSH	HL

	; 2�x�ڂ̓ǂݍ��݃Z�N�^
	LD	HL,(STREC)
	LD	BC,224
	ADD	HL,BC
	LD	(R2STREC), HL

	; 2�x�ڂ̓ǂݍ��݃T�C�Y
	PUSH	HL
	LD	L,(IY+2)
	LD	H,(IY+3)
	LD	DE,0E000H
	OR	A
	SBC	HL, DE
	LD	(R2SIZE), HL
	POP	HL

	; 1�x�ڂ̓ǂݍ��݃T�C�Y��E000H�ɐ�������
	XOR	A
	LD	(IY+2),A
	LD	A, 0E0H
	LD	(IY+3),A
	POP	HL
	POP	DE
	POP	BC
LT_FBA0:
;
;
	JP	START2		; �w��t�@�C���Ǎ������s��
;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  �t�@�C���������b�Z�[�W�\��                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ENOFIL:
	LD	DE,EMNFL
	LD	HL,40 * 5
	LD	BC,40
	CALL	VRDISP
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  �f�B�X�N�������h�o�k���Z�b�g���b�Z�[�W�\��            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ELOOP:	LD	DE,ERMIPL
	LD	HL,40 * 10
	LD	BC,40
	CALL	VRDISP
;
;
	CALL	MOFF		; ���[�^�[��~
;
	JP	ERRORPL		; �i�v���[�v
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  TextVRAM��L�������ēǂݍ��ݏ�����]�����Ď��s 2500�ȊO�Ή� ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
READ2ND:
	; TextVRAM�L��
	CALL	VRON20
	; �ǂݍ��݃T�C�Y
	LD	HL, (R2SIZE)
	LD	D, H
	LD	E, L
	; �ǂݍ��݊J�n�Z�N�^
	LD	HL, (R2STREC)
	; �ǂݍ��݃h���C�u
	LD	A, (DIRNO)
	LD	B, A
	; ��ʂ�����
	IN	A,(0E2H)
	OR	001H
	OUT	(0E2H),A
	; �v���O�����㔼�ǂݍ��ݏ�������
	PUSH	BC
	PUSH	DE
	PUSH	HL
	; MZ-80B��2000��
	LD	A,(MODE)
	CP	MD2000
	JR	NZ,MACHINE_MZ80B
	; 8000h�`8400h(1KB)�܂ł�TVRAM�O���Ƀo�b�N�A�b�v����
	LD	HL, 08000H
	LD	DE, VRAM
	LD	BC, 1024
	LDIR
	; ���Z�b�g�v���O������TVRAM�㔼�ɓ]������
	LD	HL, RESTORE_RESET
	LD	DE, VRAM + 1024
	LD	BC, RESTORE_RESET_END - RESTORE_RESET
	LDIR
	; 8000h�Ƀv���O������]�����Ď��s����
	LD	HL, READTAIL
	LD	DE, 08000H
	LD	BC, READTAILEND - READTAIL
	LDIR
	POP	HL
	POP	DE
	POP	BC
	; DE��1FFF�Ȃ�FFFFH��RAMFFFF����������
	LD	A, (RAMFFFF)
	LD	C, A
	; 8000h������s
EXECUTE8000:
	JP	08000h
MACHINE_MZ80B:
	; 8000h�`8400h(1KB)�܂ł�TVRAM�O���Ƀo�b�N�A�b�v����
	LD	HL, 08000H
	LD	DE, VRAM8L
	LD	BC, 1024
	LDIR
	; ���Z�b�g�v���O������TVRAM�㔼�ɓ]������
	LD	HL, RESTORE_RESET
	LD	DE, VRAM8L + 1024
	LD	BC, RESTORE_RESET_END - RESTORE_RESET
	LDIR
	; 8000h�Ƀv���O������]�����Ď��s����
	LD	HL, READTAIL
	LD	DE, 08000H
	LD	BC, READTAILEND - READTAIL
	LDIR
	; SET 6,A��RES 6,A�ɕύX����8000h������s
	LD	A, 0B7H
	LD	(08027H),A
	POP	HL
	POP	DE
	POP	BC
	JP	08000h

;	TVRAM�Ƀo�b�N�A�b�v�����f�[�^��߂��ēǍ��񂾃v���O�����ւ̐���ڍs�i���Z�b�g���g�p�j
RESTORE_RESET:
	LD	HL, VRAM
	LD	DE, 08000H
	LD	BC, 1024
	LDIR
	IN	A, (0E2H)
	RES	0, A		; ��ʕ\��
	SET	1, A 		; �m�[�}�����Z�b�g
	OUT	(0E2H), A
START4:	JR	START4		; �i�v���[�v
RESTORE_RESET_END:

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  �t�@�C���T�C�Y�G���[                                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ERRBIG:	
	LD	DE,BMSG1
	LD	HL,40 * 22
	LD	BC,40
	CALL	VRDISP
	JP	ERIPLM		; IPL���Z�b�g�v�����i�v���[�v
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  A���W�X�^���ʂS�r�b�g��HEX�L�����N�^�ɕϊ�            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
A2HEX:	PUSH	HL
	PUSH	BC
	AND	00FH
	LD	B,0
	LD	C,A
	LD	HL,HEXC
	ADD	HL,BC
	LD	A,(HL)
	POP	BC
	POP	HL
	RET
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  BC���W�X�^��HEX�L�����ɕϊ����AHEXD�Ɋi�[             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BC2HEX:	PUSH	HL
	PUSH	DE
	PUSH	BC
	PUSH	AF
	LD	HL,HEXD + 1
;
	LD	A,B
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	CALL	A2HEX
	LD	(HL),A
	INC	HL
;
	LD	A,B
	CALL	A2HEX
	LD	(HL),A
	INC	HL
;
	LD	A,C
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	CALL	A2HEX
	LD	(HL),A
	INC	HL
;
	LD	A,C
	CALL	A2HEX
	LD	(HL),A
;
	POP	AF
	POP	BC
	POP	DE
	POP	HL
	RET
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  VRAM �N���A�T�u���[�`��                               ;;
;;    HL: �N���A�J�n��ʈʒu                              ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
VRCLR:
	PUSH	HL
	LD	BC,40 * 25
	LD	HL,CLWORK
CLWLP1:	LD	(HL),' '
	INC	HL
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,CLWLP1
	DEC	HL
	LD	(HL),00DH
;
	POP	HL
	PUSH	HL
	LD	DE,CLWORK
	ADD	HL,DE
	PUSH	HL	; HL -> DE
	POP	DE
	POP	HL
	LD	BC,40 * 25
	CALL	VRDISP
;
	LD	A,(MODE)
	CP	MD2500
	RET	NZ
;
;  MZ-2500���[�h���̓A�g���r���[�gVRAM��ݒ肷��
	LD	BC,40 * 25
	LD	DE,(VRAMAD)
	LD	IX,00800H
	ADD	IX,DE
CLWLP2:
	LD	(IX + 0),007H		; �L�����N�^�F��
	INC	IX
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,CLWLP2
	RET
;
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ���b�Z�[�W��
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;�X�P�[��	 ----+----1----+----2----+----3----+----4
;
MZ80B:	DB	"IPL �ڸ�- << MZ-80B �-�� >>             "
	DB	00DH
;
MZ2000:	DB	"IPL �ڸ�- << MZ-2000/2200 �-�� >>       "
	DB	00DH
;
MZ2500:	DB	"IPL �ڸ�- << MZ-2500 �-�� >>            "
	DB	00DH
;
VERS:	DB	"  Ver0.9bKai 2022.02.10 (c) kuran-kuran"
	DB	00DH
;
MZ25W:	DB	"MZ-2500�-����� �޳������ �òϾ� m(- -;)m"
	DB	00DH
;
EMNFL:	DB	"��- : ��޳�޷�̧�ٶ� ��Ͼ�"
	DB	00DH
;
ERMIPL:	DB	"   �ި������ݼ� IPLؾ�� � �ø�޻�"
	DB	00DH
;
DSK2DD:	DB	"DISK ���� : 2DD Disk(80�����)"
	DB	00DH
;
DSK2D:	DB	"DISK ���� :  2D Disk(35�����)"
	DB	00DH
;
SELMSG:	DB	"��ڦ��޳�Ͻ�[A-"
SELMAX:	DB	" "
	DB	",/] ==>  "
	DB	00DH
;
LD1R12MSG:
	DB	"  �к��޲Ͻ : MZ-1R12"
	DB	00DH
;
LDMSG:	DB	"  �к��޲Ͻ :"
	DB	00DH
;
;			ASTART2
BMSG1:	DB	"��- : FBA0hByte � ��ò���� �к�Ͼ�"
	DB	00DH
;
HEXD:	DB	"(nnnn)"
	DB	00DH
;
HEXC:	DB	"0123456789ABCDEF"

READTAIL:
	BINCLUDE	"READTAIL.bin"
READTAILEND:

;
;
ASTART2	EQU	0FBA0H	; �w��t�@�C���Ǎ������s�̊J�n�A�h���X
NO2E:
	DS	ASTART2 - NO2E	; spacer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; �w��t�@�C���Ǎ������s
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ASTART2	EQU	0FBA0H
;
;
START2:
;
	CALL	BREAD		; �t�@�C���Ǎ���
;
	CALL	MOFF		; ���[�^�[��~

	; R2SIZE��0���傫�����2��ڂ̓ǂݍ��݂�����
	LD	HL, (R2SIZE)
	LD	A, H
	OR	L
	JP	Z, NOTREAD2ND
	CALL	READ2ND
NOTREAD2ND:
;
;	�Ǎ��񂾃v���O�����ւ̐���ڍs�i���Z�b�g���g�p�j
	IN	A,(0E2H)
	SET	1,A 		; �m�[�}�����Z�b�g
	OUT	(0E2H),A
START3:	JR	START3		; �i�v���[�v
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; READY CHECK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
READY:	LD	A,(MTFG)
	RRCA
	CALL	MTON
	LD	A,(DIRNO)	; DRIVE BO GET
	OR	084H
	OUT	(DM),A		; DRIVE SELECT MOTON
	XOR	A
	CALL	DLY60M
	LD	HL,00000H
REDY0:	DEC	HL
	LD	A,H
	OR	L
	JP	Z,DERROR		; NO DISK
	IN	A,(CR)		; STATUS GET
	CPL
	RLCA
	JR	C,REDY0
	LD	A,(DIRNO)
	LD	C,A
;
	LD	HL,CLBF0
;
	LD	B,000H
	ADD	HL,BC
	BIT	0,(HL)
	RET	NZ
	CALL	RCLB
	RET
;
; MOTOR ON
;
MTON:	LD	A,080H
	OUT	(DM),A
	LD	B,10		; 1SEC DLAY
MTD1:	LD	HL,03C19H
MTD2:	DEC	HL
	LD	A,L
	OR	H
	JR	NZ,MTD2
	DJNZ	MTD1
	LD	A,1
	LD	(MTFG),A
	RET
;
; MOTOR OFF
;
MOFF:	CALL	DLY1M		; 1000US DELAY
	XOR	A
	OUT	(DM),A
	LD	(MTFG),A
	RET
;
; SEEK TREATMENT
;
SEEK:	LD	A,01BH
	CPL
	OUT	(CR),A
	CALL	BUSY
	CALL	DLY60M
	IN	A,(CR)
	CPL
	AND	099H
	RET
;
; RECALIBLATION
;
RCLB:	PUSH	HL
	LD	A,00BH
	CPL
	OUT	(CR),A
	CALL	BUSY
	CALL	DLY60M
	IN	A,(CR)
	CPL
	AND	085H
	XOR	004H
	POP	HL
	RET	Z
	JP	DERROR
;
; BUSY AND WAIT
;
BUSY:	PUSH	DE
	PUSH	HL
	CALL	DLY80U
	LD	E,7
BUSY2:	LD	HL,000H
BUSY0:	DEC	HL
	LD	A,H
	OR	L
	JR	Z,BUSY1
	IN	A,(CR)
	CPL
	RRCA
	JR	C,BUSY0
	POP	HL
	POP	DE
	RET
;
BUSY1:	DEC	E
	JR	NZ,BUSY2
	JP	DERROR
;
; DATA CHECK
;
CONVRT:	LD	B,0
	LD	DE,16
	LD	HL,(STREC)		; START RECORD
	XOR	A
TRANS:	SBC	HL,DE
	JR	C,TRANS1
	INC	B
	JR	TRANS
TRANS1:	ADD	HL,DE
	LD	H,B
	INC	L
	LD	(IY+4),H
	LD	(IY+5),L
DCHK:	LD	A,(DIRNO)
	CP	4
	JR	NC,DTCK1
	LD	A,(IY+4)
MAXTRK:	CP	160		; MAX TRACK ( 70 -> 35TRACK 2D)
				; MAX TRACK (160 -> 80TRACK 2D)
	JR	NC,DTCK1
	LD	A,(IY+5)
	OR	A
	JR	Z,DTCK1
	CP	17		; MAX SECTOR
	JR	NC,DTCK1
	LD	A,(IY+2)
	OR	(IY+3)
	RET	NZ
DTCK1:	JP	DERROR
;
; SEQENTIAL READ
;
BREAD:	DI
	CALL	CONVRT
	LD	A,10
	LD	(RETRY),A
READ1:	CALL	READY
	LD	D,(IY+3)
	LD	A,(IY+2)
	OR	A
	JR	Z,RE0
	INC	D
RE0:	LD	A,(IY+5)
	LD	(IY+1),A
	LD	A,(IY+4)
	LD	(IY+0),A
	PUSH	IX
	POP	HL
RE8:	SRL	A
	CPL
	OUT	(DR),A
	JR	NC,RE1
	LD	A,001H
	JR	RE2
RE1:	LD	A,000H
RE2:	CPL
	OUT	(HS),A
	CALL	SEEK
	JR	NZ,REE
	LD	C,0DBH
	LD	A,(IY+0)
	SRL	A
	CPL
	OUT	(TR),A
	LD	A,(IY+1)
	CPL
	OUT	(SCR),A
	EXX
	LD	HL,RE3
	PUSH	HL
	EXX
	LD	A,094H		;READ & CMD
	CPL
	OUT	(CR),A
	CALL	WAIT
RE6:	LD	B,000H
RE4:	IN	A,(CR)
	RRCA
	RET	C
	RRCA
	JR	C,RE4
	INI
	JR	NZ,RE4
	INC	(IY+1)
	LD	A,(IY+1)
	CP	17
	JR	Z,RETS
	DEC	D
	JR	NZ,RE6
	JR	RE5
RETS:	DEC	D
RE5:	LD	A,0D8H		; FORCE INTER RUPT
	CPL
	OUT	(CR),A
	CALL	BUSY
RE3:	IN	A,(CR)
	CPL
	AND	0FFH
	JR	NZ,REE
	EXX
	POP	HL
	EXX
	LD	A,(IY+1)
	CP	17
	JR	NZ,REX
	LD	A,001H
	LD	(IY+1),A
	INC	(IY+0)
REX:	LD	A,D
	OR	A
	JR	NZ,RE7
	LD	A,080H
	OUT	(DM),A
	RET
RE7:	LD	A,(IY+0)
	JR	RE8
REE:	LD	A,(RETRY)
	DEC	A
	LD	(RETRY),A
	JR	Z,DERROR
	CALL	RCLB
	JP	READ1
;
; WAIT AND BUSY OFF
;
WAIT:	PUSH	DE
	PUSH	HL
	CALL	DLY80U
WAIT2:	LD	HL,00000H
WAIT0:	DEC	HL
	LD	A,H
	OR	L
	JR	Z,WAIT1
	IN	A,(CR)
	CPL
	RRCA
	JR	NC,WAIT0
	POP	HL
	POP	DE
	RET
WAIT1:	DEC	E
	JR	NZ,WAIT2
	JR	DERROR
;
DERROR:	CALL	MOFF
	LD	A,0A5H
	OUT	(TR),A
	CALL	DLY80U
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  �Ǎ��G���[����
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ���b�Z�[�W�\��
ERIPLM:
	LD	DE,ERFD
	LD	HL,40 * 23
	LD	BC,80
	CALL	VRDISP
;
;
; BEEP���i�v���[�v
ERRORPL:
;
	CALL	BEEP
	CALL	DLY60M
	CALL	BEEP
	CALL	DLY60M
	CALL	BEEP
;
ERRPL:	JR	ERRPL
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TIME DELAY (1M & 60M & 80U)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DLY80U:	PUSH	DE
	LD	DE,13
	JP	DLYT
DLY1M:	PUSH	DE
	LD	DE,130
	JP	DLYT
DLY60M:	PUSH	DE
	LD	DE,6700
DLYT:	DEC	DE
	LD	A,E
	OR	D
	JR	NZ,DLYT
	POP	DE
	RET
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  VRAM�����C���������G���A�ɔz�u
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
VRONN:
	LD	A,(MODE)
	CP	MD2500
	JR	Z,VRON25

VRON20:			; MZ-2000/2200���[�h��	$D000-$DFFF
			; MZ-80B���[�h��	$5000-$5FFF
	IN	A,(0E8H)
	SET	6,A
	SET	7,A
	OUT	(0E8H),A
	RET
;
VRON25:				; MZ-2500���[�h��
	LD	A,006H		; �������}�b�v 0C000H�`
	OUT	(0B4H),A
	LD	A,038H		; �e�L�X�g�u�q�`�l
	OUT	(0B5H),A
;
; -->(2002.01.05 Ver0.5b)
	LD	A,(MZ25HL)
	CP	'H'
	RET	Z		; 400���C�����[�h���͂��̂܂�
	LD	A,002H		; 16x16�̍��i8x8�j
	LD	(CT8F + 1),A	; ���ȏ���(^^;
; <--(2002.01.05 Ver0.5b)
;
	RET
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  VRAM�����C���������G���A����؂藣��
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
VROFF:
	LD	A,(MODE)
	CP	MD2500
	JP	Z,VROF25
;
	IN	A,(0E8H)	; MZ-80B,2000/2200���[�h��
	RES	6,A
	RES	7,A
	OUT	(0E8H),A
;
	RET
;
VROF25:
	LD	A,006H		; �������}�b�v 0E000H�`
	OUT	(0B4H),A
	LD	A,00FH		; IPL���[�N���C��������
	OUT	(0B5H),A
	RET
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  ������\��
;    DE: �\��������i�[�A�h���X�i�I���� 00DH�j
;    HL: �\���J�n��ʈʒu
;    BC: �ő�\��������
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
VRDISP:
	PUSH	HL
	PUSH	DE
	PUSH	BC
	PUSH	AF
	PUSH	IX
	PUSH	IY
	CALL	VRONN
	CALL	VRDISP2
	CALL	VROFF
	POP	IY
	POP	IX
	POP	AF
	POP	BC
	POP	DE
	POP	HL
	RET
;
VRDISP2:
	LD	A,(MODE)
	CP	MD2500
	JR	Z,VRD25
;
;  MZ-80B,MZ-2000/2200�p�\������
	PUSH	BC
	LD	BC,(VRAMAD)
	ADD	HL,BC
	PUSH	HL
	POP	IX	; IX = VRAM �̕\���J�n���A�h���X
	PUSH	DE
	POP	HL	; HL = �\��������i�[�A�h���X
	POP	BC
VRD80L:
	LD	A,(HL)
	CP	00DH
	RET	Z	; 00DH�ŏI��
	LD	(IX + 0),A
	INC	HL
	INC	IX
	DEC	BC
	LD	A,B
	OR	C
	JP	NZ,VRD80L
	RET			; �ő啶�����I�[�o�[
;
;  MZ-2500�p�\������
VRD25:
	PUSH	BC
	PUSH	DE
	LD	BC,(VRAMAD)
	ADD	HL,BC
	PUSH	HL	; HL -> IX
	POP	IX	; IX = VRAM1 �̕\���J�n���A�h���X
	PUSH	IX	; IX -> IY
	POP	IY
	LD	BC,01000H
	ADD	IY,BC	; IY = VRAM2 �̕\���J�n���A�h���X
	POP	HL	; HL = �\��������i�[�A�h���X
	POP	BC
VRD25L:
	LD	A,(HL)
	CP	00DH
	RET	Z	; 00DH�ŏI��
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	OR	08CH
	LD	(IY + 0),A	; �e�L�X�gV-RAM 2
	LD	A,(HL)
	SLA	A
	SLA	A
;
; -->(2002.01.05 Ver0.5b)
CT8F:	OR	000H		; 200���C�����ɂ� OR 002H �ɂȂ�
				; 002H:8x8 ����\��
; <--(2002.01.05 Ver0.5b)
;
	LD	(IX + 0),A	; �e�L�X�gV-RAM 1
	INC	HL
	INC	IY
	INC	IX
	DEC	BC
	LD	A,B
	OR	C
	JP	NZ,VRD25L
	RET			; �ő啶�����I�[�o�[
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  BEEP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BEEP:
	PUSH	BC
	LD	BC,50
BEEPL:
	LD	A,005H
	OUT	(0E3H),A
	CALL	BEEPW
	LD	A,004H
	OUT	(0E3H),A
	CALL	BEEPW
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,BEEPL
;
	POP	BC
;
	RET
;
;
BEEPW:	PUSH	DE
;	����	MZ-80B,2000/2200(4MHz): 100
	LD	DE,100
;
	LD	A,(MODE)
	CP	MD2500
	JP	NZ,DLYT
;
;	����	MZ-2500���[�h(6MHz)   :130

	LD	DE,130
	JP	DLYT
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ���b�Z�[�W�G���A�Q
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ERFD:	DB	"�-�޴�-��ʯ���ϼ� IPLؾ�ļø�޻� m("
ERFDUB:	DB	"   )m"
ERFDLF:	DB	"                                   _ _"
	DB	00DH

PGEND:
	DS	0FF00H - PGEND	;spacer
; MAX 0FF00H

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ���[�N�G���A
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
MODE	EQU	0FF00H		; DB	8:MZ-80B  2:MZ-2000/2200  5:MZ-2500
MZ25HL	EQU	MODE + 1	; DB	MZ-2500  H:400Line  L:200Line
VRAMAD	EQU	MZ25HL + 1	; DW	Char VRAM Address
MAXDIR	EQU	VRAMAD + 2	; DB
CHKDIR	EQU	MAXDIR + 1	; DB
SAVE01	EQU	CHKDIR + 1	; DW
SAVE02	EQU	SAVE01 + 2	; DW
SAVE03	EQU	SAVE02 + 2	; DW
SAVE04	EQU	SAVE03 + 2	; DW
SAVE05	EQU	SAVE04 + 2	; DW
CLBF0	EQU	SAVE05 + 2	; DW
STREC	EQU	CLBF0 + 2	; DW �Ǎ��݊J�n�Z�N�^
DIRNO	EQU	STREC + 2	; DB �h���C�u�ԍ�(0-3)
MTFG	EQU	DIRNO + 1	; DB ���[�^0:OFF/1:ON
RETRY	EQU	MTFG + 1	; DB
SELECT	EQU	RETRY + 1	; DB x 2 �L�[����(�P����)
FOFS	EQU	SELECT + 2	; DW �Ǎ��݃t�@�C��DIR�I�t�Z�b�g
R2STREC	EQU	FOFS + 2	; DW 2nd�ǂݍ��� �Ǎ��݊J�n�Z�N�^
R2SIZE	EQU	R2STREC + 2	; DW 2nd�ǂݍ��� �T�C�Y
RAMFFFF	EQU	R2SIZE + 2	; DB FFFFH�ɏ������ރf�[�^
WKIY	EQU	RAMFFFF + 1	; 6byte FD READ �w���A���[�N
;
;
WKIX	EQU	00000H		; �v���O�����Ǎ��݃A�h���X
;
STACK	EQU	00000H		; Stack Pointer
	END