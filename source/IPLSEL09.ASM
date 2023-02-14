;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IPL SELECTER for MZ-80B/MZ-2000/2200 Ver.0.9  2021/01/30
;     (c)2001-2021 Hideki Suga (@junk_suga)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;ディスク格納イメージ
;Tr Sc (Sect) LOAD
; 0  1 (0000) ----    IPLPRO IPL用データ
; 0  2 (0001) 0000    0000 第一セクション
; 0  3 (0002) 0100 -> F200 第二セクション
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
; 0 16 (000F) 0E00 ビットマップ(FAT)
; 1  1 (0010) 0F00 ディレクトリ
; 1  2 (0011) 1000     〃
; 1  3 (0012) 1100     〃
; 1  4 (0013) 1200     〃
; 1  5 (0014) 1300     〃
; 1  6 (0015) 1400     〃
; 1  7 (0016) 1500     〃
; 1  8 (0017) 1600 ディレクトリ（終り）
; 1  9 (0018) 1700 未使用
; ・・・・・・・・
; 1 16 (001F) 1700 未使用
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
;IPL用データ構成
;    +0 +1 +2 +3 +4 +5 +6 +7 +8 +9 +A +B +C +D +E +F
;000 01 <-----（読込み時システム名 最後に 0DH必須）
;010 ----> 00 00 00 1F 00 00 XX XX 00 00 00 ?? 01 00
;                ^^^^^ ←MZ80B,2000/2200時読込みバイト数 1F00H
;                            ^^^^^ ←MZ2500時実行開始アドレス
;              MZ2500時ロード開始セクタ 0001H→^^^^^
;020 08 FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
;    ^^←MZ2500時ロードするメモリマップ
;030 08 09 0A 0B 0C 0D 0E 以降未使用
;    ^^^^^^^^^^^^^^^^^^^^←MZ2500実行時メモリマップ
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

;	B1SCT	0F300H -> 実アドレス 00000H
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MZ-80B/2000/2200 Execution address
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	DI
;
; IPL BOOTドライブ保存
	LD	A,(0FFECH - 08000H)
	LD	(DIRNO),A
;
; 8255 初期化
	LD	A,082H		; 8255 A=out B=in C=out
	OUT	(0E3H),A
	LD	A,058H		; b3:BST=1 b4:OPEN=1 b6:WRITE=1
	OUT	(0E2H),A
;
; PIO 初期化
	LD	A,00FH		; PIO A=out
	OUT	(0E9H),A
	LD	A,0CFH		; PIO B=in
	OUT	(0EBH),A
	LD	A,0FFH		; 2018/08/07追加
	OUT	(0EBH),A
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  MZ-80B、2000判定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; メインメモリの機種判定位置初期化
	LD	HL,VRAM8L
	LD	(HL),' '
;
; VRAM 選択
;
; MZ-80B  05000H -> CVRAM
; MZ-2000 0D000H -> CVRAM
	IN	A,(0E8H)
	AND	0DFH		; 40桁モード
	OR	0C0H		; PIOA6=1,PIOA7=1
	OUT	(0E8H),A
;
; MZ-80B判別文字セット
	LD	(HL),MD80B
;
; VRAM 切離し
	IN	A,(0E8H)
	AND	03FH
	OUT	(0E8H),A
;
; モード判定
; メインメモリにMZ-80Bの判定文字列が残ってなければ MZ-80B
	LD	A,(HL)
	CP	MD80B
	JR	NZ,MSET80
;
; 判定結果：MZ-2000/2200
	LD	A,MD2000
	LD	(MODE),A

	LD	A,0F7H		; PIO A 初期化
	OUT	(0E0H),A
	XOR	A
	OUT	(0F6H),A	; グラフィック非表示
	OUT	(0F4H),A	; バックグランド黒
	LD	A,007H
	OUT	(0F5H),A	; キャラクタ白
;
	LD	HL,VRAM		; MZ-2000モード時のC-VRAMアドレス
	LD	(VRAMAD),HL
;
	JR	CHKOUT
;
;
; 判定結果：MZ-80B
MSET80:
	LD	A,MD80B
	LD	(MODE),A

	LD	A,012H		; PIO A 初期化
	OUT	(0E0H),A
	XOR	A		; グラフィック非表示
	OUT	(0F4H),A
;
	LD	HL,VRAM8L	; MZ-80Bモード時のC-VRAMアドレス
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
; 第二セクションを実アドレスに転送しジャンプ
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHKOUT:
;
	LD	SP,STACK
;
	LD	HL,B2SCT - B1SCT	; 第二セクション読込みアドレス
	LD	DE,B2SCT		; 第二セクション実行開始アドレス
	LD	BC,B2SCTE - B2SCT + 1	; 転送量
	LDIR

	JP	B2SCT
;
; 
B1SCTE:
	DS	B2SCT - B1SCTE	; spacer


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 第二セクション
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; B2SCT
;
;
;	IPL BOOTドライブ保存 (MZ-2500 80Bモード対策)
	LD	A,(0FFECH - 08000H)
	LD	(DIRNO),A

;	画面全体クリア
	LD	HL,0
	CALL	VRCLR
;
;	MZ-2500モード時か？
	LD	A,(MODE)
	CP	MD2500
	JR	NZ,NOT2500
;
;	MZ-2500モード表示
	LD	DE,MZ2500
	LD	HL,0
	LD	BC,40
	CALL	VRDISP
;
;	ワーニング表示
	LD	DE,MZ25W
	LD	HL,40 * 18
	LD	BC,40
	CALL	VRDISP
;
;	アンダーバー／トップバー切替
;	2500モード時は、'_'がそのまま表示されるので書換え
;	80B/2000モード時は '~' になるので次行表示をデフォルトにしてる
	LD	A,'_'
	LD	(ERFDUB),A
	LD	(ERFDUB + 2),A
	LD	A,00DH
	LD	(ERFDLF),A
;
;
NOT2500:
;	MZ-80Bモードか？
	CP	MD80B
	JR	NZ,NOT80B
;
;	MZ-80Bモード
	LD	DE,MZ80B
	JR	VERDSP
;
;	MZ-2000/2200モード
NOT80B:
	LD	DE,MZ2000
;
VERDSP:
	LD	HL,0
	LD	BC,40
	CALL	VRDISP
;
; バージョン表示
	LD	DE,VERS
	LD	HL,40
	LD	BC,40
	CALL	VRDISP
;
;
; ディスクタイプ表示(FATブロック倍率)
	LD	DE,DSK2DD
	LD	A,(00EFFH)	; 0:2D,1:2DD
	CP	0
	JR	NZ,DPDM		; 2DD
;
	LD	A,70		; 2D 時のMAXトラック数は70
	LD	(MAXTRK + 1),A
;
	LD	DE,DSK2D
;
DPDM:	LD	HL,40 * 3
	LD	BC,40
	CALL	VRDISP

; 選択用ディレクトリ領域クリア
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
	CALL	MOFF		; モーター停止
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ディレクトリからOBJファイルを探し選択用領域へ転送
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
; OBJディレクトリを選択領域へ転送
	LD	HL,(SAVE01)	; IPL-DIR  (FD)
	LD	DE,(SAVE02)	; LIST-DIR
	LD	BC,00020H
	LDIR
;
; ファイル名の前にA～Z:を
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
	LD	A,(MAXDIR)	; 最大２６個まで
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
; ファイル一覧表示
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PDIR:	XOR	A
	LD	(SAVE03),A
	LD	HL,MAXDIR
	CP	(HL)
	JP	Z,ENOFIL		; ファイル無し -> エラー
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
	JR	Z,PDIREX	; 先頭がスペースなら表示終り
;
	LD	HL,(SAVE05)
	LD	DE,(SAVE04)
	LD	BC,19
	CALL	VRDISP

;
	LD	HL,(SAVE05)	; 次の画面表示位置計算
	LD	DE,40
	ADD	HL,DE
	LD	(SAVE05),HL
	LD	DE,40 * 18	; 縦13+5行
	SBC	HL,DE
	JR	C,PDIRLP2
	LD	DE,20
	SBC	HL,DE
	JR	NC,PDIRLP2
	LD	DE,40 * 5 + 22
	LD	(SAVE05),DE
PDIRLP2:
	LD	HL,(SAVE04)	; 次のディレクトリ計算
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
;;  キー入力要求表示                                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LD	A,00DH			; デリミッタセット
	LD	(SELECT + 1),A

	LD	HL,00000H		; 読込み開始アドレスセット
	LD	(CLBF0),HL
;
;
	LD	A,(MAXDIR)		; 選択範囲
	ADD	A,'@'
	LD	(SELMAX),A
;
	LD	DE,SELMSG		; 選択範囲表示
	LD	HL,40 * 20 + 5
	LD	BC,40
	CALL	VRDISP
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  キーボード入力                                        ;;
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
;;  キー入力内容チェック                                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	CP	040H		; /
	JP	C,KEYIN		; / 以下
	LD	B,A
	LD	HL,MAXDIR
	LD	A,(HL)
	ADD	A,'A' - 1
	CP	B
	JP	C,KEYIN		; MAX 以上
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; セレクト内容（押下キーキャラクタ）表示                 ;;
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
;; /が選択された場合はMZ-1R12から起動する                 ;;
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
;; MZ-1R12から0000H～7FFFにメモリをコピーする             ;;
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
	LD	A,B			; BCが0になるまでLOOPする
	OR	C
	JP	NZ, MZ1R12_READ_LOOP
	JP	NOTREAD2ND		; 通常起動へ
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; セレクトされたディレクトリへのオフセット計算           ;;
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
;; ファイル名、読み込み中メッセージ表示                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LD	HL,(FOFS)
	LD	DE,DIR + 2		; ファイル名
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
; ロードアドレスは 00000H 固定
;
	LD	IX,WKIX
;
; ワークエリア設定
;
	LD	IY,WKIY
;
;	LD	A,0;(BTDRV)	; ドライブ０固定
;	LD	(DIRNO),A
	
;
; 読込み対象ディレクトリ ==> HL & スタック
;
	LD	HL,DIR
	LD	DE,(FOFS)
	ADD	HL,DE
	PUSH	HL
;
; 読込み開始レコード番号セット
;
	LD	DE,0001EH
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(STREC),DE		; START RECORD
;
; 未使用バイト取得 (FFFFHに書き込むデータとして使う)
;
	POP	HL
	PUSH	HL
	LD	DE,00013H
	ADD	HL,DE
	LD	A,(HL)
	LD	(RAMFFFF),A
;
; 読込みサイズセット
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
	; 2度目の読み込みサイズ0クリア
	LD	HL,0
	LD	(R2SIZE),HL

	; ファイルサイズFBA0H以下か
	LD	HL,ASTART2
	SBC	HL,BC
	JP	NC,LT_FBA0	; ファイルサイズFBA0H以下

	; MZ-2500でファイルサイズFBA0Hより大きい場合はエラーにする
	LD	A,(MODE)
	CP	MD2500
	JR	NZ,NOT_MZ2500
	JP	ERRBIG

NOT_MZ2500:
	; ファイルサイズFBA0Hより大きい場合は
	; 0000H～0DFFFHまで読み込んでから2回目の読み込みでE000H以降を読み込む
	PUSH	BC
	PUSH	DE
	PUSH	HL

	; 2度目の読み込みセクタ
	LD	HL,(STREC)
	LD	BC,224
	ADD	HL,BC
	LD	(R2STREC), HL

	; 2度目の読み込みサイズ
	PUSH	HL
	LD	L,(IY+2)
	LD	H,(IY+3)
	LD	DE,0E000H
	OR	A
	SBC	HL, DE
	LD	(R2SIZE), HL
	POP	HL

	; 1度目の読み込みサイズをE000Hに制限する
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
	JP	START2		; 指定ファイル読込＆実行へ
;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  ファイル無しメッセージ表示                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ENOFIL:
	LD	DE,EMNFL
	LD	HL,40 * 5
	LD	BC,40
	CALL	VRDISP
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  ディスク交換＆ＩＰＬリセットメッセージ表示            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ELOOP:	LD	DE,ERMIPL
	LD	HL,40 * 10
	LD	BC,40
	CALL	VRDISP
;
;
	CALL	MOFF		; モーター停止
;
	JP	ERRORPL		; 永久ループ
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  TextVRAMを有効化して読み込み処理を転送して実行 2500以外対応 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
READ2ND:
	; TextVRAM有効
	CALL	VRON20
	; 読み込みサイズ
	LD	HL, (R2SIZE)
	LD	D, H
	LD	E, L
	; 読み込み開始セクタ
	LD	HL, (R2STREC)
	; 読み込みドライブ
	LD	A, (DIRNO)
	LD	B, A
	; 画面を消す
	IN	A,(0E2H)
	OR	001H
	OUT	(0E2H),A
	; プログラム後半読み込み処理準備
	PUSH	BC
	PUSH	DE
	PUSH	HL
	; MZ-80Bか2000か
	LD	A,(MODE)
	CP	MD2000
	JR	NZ,MACHINE_MZ80B
	; 8000h～8400h(1KB)までをTVRAM前半にバックアップする
	LD	HL, 08000H
	LD	DE, VRAM
	LD	BC, 1024
	LDIR
	; リセットプログラムをTVRAM後半に転送する
	LD	HL, RESTORE_RESET
	LD	DE, VRAM + 1024
	LD	BC, RESTORE_RESET_END - RESTORE_RESET
	LDIR
	; 8000hにプログラムを転送して実行する
	LD	HL, READTAIL
	LD	DE, 08000H
	LD	BC, READTAILEND - READTAIL
	LDIR
	POP	HL
	POP	DE
	POP	BC
	JR	CHECK_RAMFFFF
MACHINE_MZ80B:
	; 8000h～8400h(1KB)までをTVRAM前半にバックアップする
	LD	HL, 08000H
	LD	DE, VRAM8L
	LD	BC, 1024
	LDIR
	; リセットプログラムをTVRAM後半に転送する
	LD	HL, RESTORE_RESET
	LD	DE, VRAM8L + 1024
	LD	BC, RESTORE_RESET_END - RESTORE_RESET
	LDIR
	; 8000hにプログラムを転送して実行する
	LD	HL, READTAIL
	LD	DE, 08000H
	LD	BC, READTAILEND - READTAIL
	LDIR
	; SET 6,AをRES 6,Aに変更して8000hから実行
	LD	A, 0B7H
	LD	(08027H),A
	POP	HL
	POP	DE
	POP	BC
CHECK_RAMFFFF:
	; DEが1FFFならFFFFHにRAMFFFFを書き込む
	LD	A, D
	CP	01FH
	JR	NZ, EXECUTE8000
	LD	A, E
	CP	0FFH
	JR	NZ, EXECUTE8000
	LD	A, (RAMFFFF)
	LD	C, A
	; 8000hから実行
EXECUTE8000:
	JP	08000h

;	TVRAMにバックアップしたデータを戻して読込んだプログラムへの制御移行（リセットを使用）
RESTORE_RESET:
	LD	HL, VRAM
	LD	DE, 08000H
	LD	BC, 1024
	LDIR
	IN	A, (0E2H)
	RES	0, A		; 画面表示
	SET	1, A 		; ノーマルリセット
	OUT	(0E2H), A
START4:	JR	START4		; 永久ループ
RESTORE_RESET_END:

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  ファイルサイズエラー                                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ERRBIG:	
	LD	DE,BMSG1
	LD	HL,40 * 22
	LD	BC,40
	CALL	VRDISP
	JP	ERIPLM		; IPLリセット要求＆永久ループ
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Aレジスタ下位４ビットをHEXキャラクタに変換            ;;
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
;;  BCレジスタをHEXキャラに変換し、HEXDに格納             ;;
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
;;  VRAM クリアサブルーチン                               ;;
;;    HL: クリア開始画面位置                              ;;
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
;  MZ-2500モード時はアトリビュートVRAMを設定する
	LD	BC,40 * 25
	LD	DE,(VRAMAD)
	LD	IX,00800H
	ADD	IX,DE
CLWLP2:
	LD	(IX + 0),007H		; キャラクタ：白
	INC	IX
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,CLWLP2
	RET
;
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; メッセージ等
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;スケール	 ----+----1----+----2----+----3----+----4
;
MZ80B:	DB	"IPL ｾﾚｸﾀ- << MZ-80B ﾓ-ﾄﾞ >>             "
	DB	00DH
;
MZ2000:	DB	"IPL ｾﾚｸﾀ- << MZ-2000/2200 ﾓ-ﾄﾞ >>       "
	DB	00DH
;
MZ2500:	DB	"IPL ｾﾚｸﾀ- << MZ-2500 ﾓ-ﾄﾞ >>            "
	DB	00DH
;
VERS:	DB	"  Ver0.9bKai 2022.02.14 (c) kuran-kuran"
	DB	00DH
;
MZ25W:	DB	"MZ-2500ﾓ-ﾄﾞﾃﾞﾉ ﾄﾞｳｻｶｸﾆﾝﾊ ｼﾃｲﾏｾﾝ m(- -;)m"
	DB	00DH
;
EMNFL:	DB	"ｴﾗ- : ｷﾄﾞｳﾃﾞｷﾙﾌｧｲﾙｶﾞ ｱﾘﾏｾﾝ"
	DB	00DH
;
ERMIPL:	DB	"   ﾃﾞｨｽｸｦｺｳｶﾝｼﾃ IPLﾘｾｯﾄ ｦ ｼﾃｸﾀﾞｻｲ"
	DB	00DH
;
DSK2DD:	DB	"DISK ﾀｲﾌﾟ : 2DD Disk(80ｼﾘﾝﾀﾞ)"
	DB	00DH
;
DSK2D:	DB	"DISK ﾀｲﾌﾟ :  2D Disk(35ｼﾘﾝﾀﾞ)"
	DB	00DH
;
SELMSG:	DB	"ﾄﾞﾚｦｷﾄﾞｳｼﾏｽｶ[A-"
SELMAX:	DB	" "
	DB	",/] ==>  "
	DB	00DH
;
LD1R12MSG:
	DB	"  ﾖﾐｺﾝﾃﾞｲﾏｽ : MZ-1R12"
	DB	00DH
;
LDMSG:	DB	"  ﾖﾐｺﾝﾃﾞｲﾏｽ :"
	DB	00DH
;
;			ASTART2
BMSG1:	DB	"ｴﾗ- : FBA0hByte ｦ ｺｴﾃｲﾙﾉﾃﾞ ﾖﾐｺﾒﾏｾﾝ"
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
ASTART2	EQU	0FBA0H	; 指定ファイル読込＆実行の開始アドレス
NO2E:
	DS	ASTART2 - NO2E	; spacer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 指定ファイル読込＆実行
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ASTART2	EQU	0FBA0H
;
;
START2:
;
	CALL	BREAD		; ファイル読込み
;
	CALL	MOFF		; モーター停止

	; R2SIZEが0より大きければ2回目の読み込みをする
	LD	HL, (R2SIZE)
	LD	A, H
	OR	L
	JP	Z, NOTREAD2ND
	CALL	READ2ND
NOTREAD2ND:
;
;	読込んだプログラムへの制御移行（リセットを使用）
	IN	A,(0E2H)
	SET	1,A 		; ノーマルリセット
	OUT	(0E2H),A
START3:	JR	START3		; 永久ループ
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
;  読込エラー発生
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; メッセージ表示
ERIPLM:
	LD	DE,ERFD
	LD	HL,40 * 23
	LD	BC,80
	CALL	VRDISP
;
;
; BEEP＆永久ループ
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
;  VRAMをメインメモリエリアに配置
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
VRONN:
	LD	A,(MODE)
	CP	MD2500
	JR	Z,VRON25

VRON20:			; MZ-2000/2200モード時	$D000-$DFFF
			; MZ-80Bモード時	$5000-$5FFF
	IN	A,(0E8H)
	SET	6,A
	SET	7,A
	OUT	(0E8H),A
	RET
;
VRON25:				; MZ-2500モード時
	LD	A,006H		; メモリマップ 0C000H～
	OUT	(0B4H),A
	LD	A,038H		; テキストＶＲＡＭ
	OUT	(0B5H),A
;
; -->(2002.01.05 Ver0.5b)
	LD	A,(MZ25HL)
	CP	'H'
	RET	Z		; 400ラインモード時はそのまま
	LD	A,002H		; 16x16の左（8x8）
	LD	(CT8F + 1),A	; 自己書換(^^;
; <--(2002.01.05 Ver0.5b)
;
	RET
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  VRAMをメインメモリエリアから切り離し
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
VROFF:
	LD	A,(MODE)
	CP	MD2500
	JP	Z,VROF25
;
	IN	A,(0E8H)	; MZ-80B,2000/2200モード時
	RES	6,A
	RES	7,A
	OUT	(0E8H),A
;
	RET
;
VROF25:
	LD	A,006H		; メモリマップ 0E000H～
	OUT	(0B4H),A
	LD	A,00FH		; IPLワークメインメモリ
	OUT	(0B5H),A
	RET
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  文字列表示
;    DE: 表示文字列格納アドレス（終了は 00DH）
;    HL: 表示開始画面位置
;    BC: 最大表示文字数
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
;  MZ-80B,MZ-2000/2200用表示処理
	PUSH	BC
	LD	BC,(VRAMAD)
	ADD	HL,BC
	PUSH	HL
	POP	IX	; IX = VRAM の表示開始実アドレス
	PUSH	DE
	POP	HL	; HL = 表示文字列格納アドレス
	POP	BC
VRD80L:
	LD	A,(HL)
	CP	00DH
	RET	Z	; 00DHで終了
	LD	(IX + 0),A
	INC	HL
	INC	IX
	DEC	BC
	LD	A,B
	OR	C
	JP	NZ,VRD80L
	RET			; 最大文字数オーバー
;
;  MZ-2500用表示処理
VRD25:
	PUSH	BC
	PUSH	DE
	LD	BC,(VRAMAD)
	ADD	HL,BC
	PUSH	HL	; HL -> IX
	POP	IX	; IX = VRAM1 の表示開始実アドレス
	PUSH	IX	; IX -> IY
	POP	IY
	LD	BC,01000H
	ADD	IY,BC	; IY = VRAM2 の表示開始実アドレス
	POP	HL	; HL = 表示文字列格納アドレス
	POP	BC
VRD25L:
	LD	A,(HL)
	CP	00DH
	RET	Z	; 00DHで終了
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	OR	08CH
	LD	(IY + 0),A	; テキストV-RAM 2
	LD	A,(HL)
	SLA	A
	SLA	A
;
; -->(2002.01.05 Ver0.5b)
CT8F:	OR	000H		; 200ライン時には OR 002H になる
				; 002H:8x8 左上表示
; <--(2002.01.05 Ver0.5b)
;
	LD	(IX + 0),A	; テキストV-RAM 1
	INC	HL
	INC	IY
	INC	IX
	DEC	BC
	LD	A,B
	OR	C
	JP	NZ,VRD25L
	RET			; 最大文字数オーバー
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
;	音程	MZ-80B,2000/2200(4MHz): 100
	LD	DE,100
;
	LD	A,(MODE)
	CP	MD2500
	JP	NZ,DLYT
;
;	音程	MZ-2500モード(6MHz)   :130

	LD	DE,130
	JP	DLYT
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; メッセージエリア２
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ERFD:	DB	"ﾛ-ﾄﾞｴﾗ-ｶﾞﾊｯｾｲｼﾏｼﾀ IPLﾘｾｯﾄｼﾃｸﾀﾞｻｲ m("
ERFDUB:	DB	"   )m"
ERFDLF:	DB	"                                   _ _"
	DB	00DH

PGEND:
	DS	0FF00H - PGEND	;spacer
; MAX 0FF00H

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ワークエリア
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
STREC	EQU	CLBF0 + 2	; DW 読込み開始セクタ
DIRNO	EQU	STREC + 2	; DB ドライブ番号(0-3)
MTFG	EQU	DIRNO + 1	; DB モータ0:OFF/1:ON
RETRY	EQU	MTFG + 1	; DB
SELECT	EQU	RETRY + 1	; DB x 2 キー入力(１文字)
FOFS	EQU	SELECT + 2	; DW 読込みファイルDIRオフセット
R2STREC	EQU	FOFS + 2	; DW 2nd読み込み 読込み開始セクタ
R2SIZE	EQU	R2STREC + 2	; DW 2nd読み込み サイズ
RAMFFFF	EQU	R2SIZE + 2	; DB FFFFHに書き込むデータ
WKIY	EQU	RAMFFFF + 1	; 6byte FD READ 指示、ワーク
;
;
WKIX	EQU	00000H		; プログラム読込みアドレス
;
STACK	EQU	00000H		; Stack Pointer
	END
