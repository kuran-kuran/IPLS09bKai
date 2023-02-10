;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  IPC SELECTER DISK MAKER for MZ-80B・2000・2200
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  作成：菅 秀樹
;  履歴：Ver 0.9 2021年01月30日 新規作成
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  モニタ内ルーチン等
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MONIT	EQU	00000H	; モニタ コールドスタート
GOOUT	EQU	000AEH	; モニタ初期化後の実行アドレス
ST	EQU	000B1H	; モニタ ワームスタート
GETL	EQU	006A4H	; 1ライン入力
LETNL	EQU	00A2EH	; [CR]の実行

WRINF	EQU	00251H	; CMTインフォメーションブロック書き込み
WRDAT	EQU	00282H	; CMTデータブロック書き込み

SAME	EQU	0063AH	; 文字列比較
MSG	EQU	00889H	; メッセージ表示
LIST	EQU	0087BH	; リスト用メッセージ表示(MSGX:)
MELDY	EQU	00F3FH	; 音楽演奏の実行
BELL	EQU	00F14H	; ベル音
XTEMP	EQU	00E50H	; テンポセット

PRTWRD	EQU	005D8H	; 16進2バイトHEX表示(HL)(PRTHL:)
PRTBYT	EQU	005DDH	; 16進1バイトHEX表示(A)(PRTHX:)
PRT3	EQU	008B5H	; Aレジスタの1文字出力 制御無し
PRNT	EQU	008C6H	; Aレジスタの1文字出力 制御有
;
;
DSPXY	EQU	011D1H	; カーソル位置
;
;		FD-IF I/O Port Address
CR	EQU	0D8H	; コマンド
TR	EQU	0D9H	; トラック
SCR	EQU	0DAH	; セクター
DR	EQU	0DBH	; ドライブセレクト
DM	EQU	0DCH	; モーター
HS	EQU	0DDH	; ヘッドセレクト


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  メイン
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ORG	012A0H
	JR	START
;
;	; モニタと一体化した時のスタートアドレス
STARTM:
	LD	A,01
	LD	(GOOUT),A	; リセット時に再び呼ばれるのを防止

START:
	CALL	MOFF		; ドライブ モータ オフ
;
; オープニング メッセージ表示
	CALL	LETNL		; 改行
	CALL	LETNL		; 改行
	LD	DE,OPMSG1	; OP1
	CALL	MSG
	CALL	LETNL		; 改行
;
;
;   ターゲットのドライブ番号入力
;
DSELL:
	CALL	LETNL		; 改行
	LD	DE,SETMSG	; ディスクセットMSG
	CALL	MSG
	CALL	LETNL		; 改行
	LD	DE,SDMSG	; ドライブ入力MSG
	CALL	MSG

	LD	DE,SELWK
	CALL	GETL		; 1ライン入力
	LD	HL,SDMSGE - SDMSG - 1	; 入力値格納 オフセット
	ADD	HL,DE		; 入力値格納アドレス
	LD	A,(HL)		; A<-入力値

	CP	'!'
	JP	Z,ST		; モニタに戻る

	SUB	'1'		; '1'～'4' -> 0～3
	JR	C,DSELL		; 1未満?

	CP	4
	JR	NC,DSELL	; 4より大きい?


;   ドライブ番号をセット
	LD	(P_DIR),A
;   セクタの情報をセット
	LD	HL,00000H	; 開始セクタ
	LD	(P_SEC),HL
	LD	HL,00100H	; 読込サイズ(1セクタ)
	LD	(P_SIZ),HL
	LD	HL,DIR1		; 読込アドレス
	LD	(P_ADR),HL

;   ディスク読込
	LD	IX,P_DIR
	CALL	SECT_RD
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ディスク情報チェック・表示
	CALL	LETNL		; 改行
	LD	DE,DINFO
	CALL	MSG
	CALL	LETNL		; 改行
	LD	DE,DMODEL	; 機種
	CALL	MSG
	LD	A,(DIR1)
	CALL	PRTBYT		; HEX表示
	LD	A,(DIR1)
	CP	001H
	JR	NZ,DCK02
	LD	DE,MDL01	; 01:MZ-80B/2000/2200/2500
	JR	DCKE
DCK02:
	CP	002H
	JR	NZ,DCK03
	LD	DE,MDL02	; 02:MZ-80A
	JR	DCKE
DCK03:
	CP	003H
	JR	NZ,DCK04
	LD	DE,MDL03	; 03:MZ-700/1500
	JR	DCKE
DCK04:
	CP	004H
	JR	NZ,DCK05
	LD	DE,MDL04	; 04:MZ-2500 DATA DISK
	JR	DCKE
DCK05:
	LD	DE,MDLOT	; OTHER
DCKE:	
	CALL	MSG
	CALL	LETNL		; 改行
;
;	シグネチャ確認
	LD	DE,DSIG
	CALL	MSG
	LD	HL,DIR1 + 1
	LD	DE,IPLPRO
	LD	B,6
	CALL	SAME
	JR	NZ,SIGNO
	LD	DE,DYES
	CALL	MSG
	CALL	LETNL		; 改行
;
;	SYSTEM名表示
	LD	DE,DSYSN
	CALL	MSG
	LD	DE,DIR1 + 7
	JR	SIGE
SIGNO:
	LD	DE,DNO
SIGE:
	CALL	MSG
	CALL	LETNL		; 改行

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ディスク書込み実行確認

MKSLP:
	CALL	LETNL		; 改行
	LD	DE,LASTS
	CALL	MSG
	LD	DE,SELWK
	CALL	GETL		; 1ライン入力
	LD	HL,LASTSE - LASTS - 1	; 入力値格納 オフセット
	ADD	HL,DE		; 入力値格納アドレス
	LD	A,(HL)		; A<-入力値

	CP	'N'
	JP	Z,ST		; モニタへ戻る

	CP	'Y'
	JP	NZ,MKSLP	; 再入力

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ディスク書込み
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   セクタの情報をセット
	LD	HL,00000H	; 開始セクタ
	LD	(P_SEC),HL
	LD	HL,00F00H	; 書込みサイズ(15セクタ)
	LD	(P_SIZ),HL
	LD	HL,IPCSEL	; 書込みDATAアドレス
	LD	(P_ADR),HL

;   ディスク書込み
	LD	IX,P_DIR
	CALL	SECT_WR

	CALL	LETNL		; 改行
	LD	DE,DONE
	CALL	MSG
	CALL	LETNL		; 改行

	JP	MKSLP		; もう一回？

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  ディスク関係
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  指定セクタ読込
;
SECT_RD:
	CALL	FDCC		; FD IF Check
	JP	NZ,NOTIO
	; READ COMMAND & INI 自己書き換え
	LD	A,094H		; READ CMD
	LD	(DCMD + 1),A
	LD	A,0A2H		; INI 2バイト目
	LD	(DINI + 1),A
	CALL	BREAD		; SEQUENTIAL READ
	CALL	MOFF		; モータOFF
	RET
;
;  指定セクタ書込み
;
SECT_WR:
	CALL	FDCC		; FD IF Check
	JP	NZ,NOTIO
	; WRITE COMMAND & OUTI 自己書き換え
	LD	A,0B4H		; WRITE CMD
	LD	(DCMD + 1),A
	LD	A,0A3H		; OUTI 2バイト目
	LD	(DINI + 1),A
	CALL	BREAD		; SEQUENTIAL WRITE
	CALL	MOFF		; モータOFF
	RET
;
;
; FD IF Check
;
FDCC:
	LD	A,0A5H
	LD	B,A
	OUT	(TR),A
	CALL	DLY80U
	IN	A,(TR)
	CP	B
	RET
;
;
; READY CHECK
;
READY:
	LD	A,(F_MT)
	RRCA
	CALL	NC,MTON
	LD	A,(IX+000H)
	OR	084H
	OUT	(DM),A
	XOR	A
	LD	(F_CR),A
	CALL	DLY60M
	LD	HL,00000H
REDY0:
	DEC	HL
	LD	A,H
	OR	L
	JR	Z,REDY1
	IN	A,(CR)
	CPL
	RLCA
	JR	C,REDY0
	LD	C,(IX+000H)
	LD	HL,F_DRV0
	LD	B,000H
	ADD	HL,BC
	BIT	0,(HL)
	JR	NZ,REDY2
	CALL	RCLB
	SET	0,(HL)
REDY2:
	RET

REDY1:
;	LD	A,032H
	LD	DE,RDY_ER
	JP	ERJMP
;
;
; SEEK TREATMENT
;
SEEK:
	LD	A,01BH
	CALL	CMDOT1
	AND	099H
	RET
;
;
; MOTOR	ON
;
MTON:
	LD	A,080H
	OUT	(DM),A
	LD	B,010H
MTD1:
	CALL	DLY60M
	DJNZ	MTD1
	LD	A,001H
	LD	(F_MT),A
	RET
;
;
; MOTOR	OFF
;
MOFF:
	PUSH	AF
	CALL	DLY1M
	XOR	A
	OUT	(DM),A
	LD	(F_MT),A
	LD	(F_DRV0),A
	LD	(F_DRV1),A
	LD	(F_DRV2),A
	LD	(F_DRV3),A
	POP	AF
	RET
;
;
; RECALIBRATION
;
RCLB:
	LD	A,00BH
	CALL	CMDOT1
	AND	085H
	XOR	004H
	RET	Z
	JP	FD_ERROR
;
;
; COMMAND OUT ROUTINE
;
CMDOT1:
	LD	(F_CR),A
	CPL
	OUT	(CR),A
	CALL	BSYON
	CALL	DLY60M
	IN	A,(CR)
	CPL
	LD	(F_C_CR),A
	RET
;
;
; BUSY AND WAIT
;
BSYON:
	PUSH	DE
	PUSH	HL
	CALL	BSY0
BSYON2:
	LD	HL,00000H
BSYON0:
	DEC	HL
	LD	A,H
	OR	L
	JR	Z,BSYON1
	IN	A,(CR)
	RRCA
	JR	NC,BSYON0
	POP	HL
	POP	DE
	RET
;
BSYON1:
	DEC	E
	JR	NZ,BSYON2
BSYONE:
	LD	A,029H
	POP	HL
	POP	DE
	JP	ERJMP
;
BSYOFF:
	PUSH	DE
	PUSH	HL
	CALL	BSY0
BSYOF2:
	LD	HL,00000H
BSYOF0:
	DEC	HL
	LD	A,H
	OR	L
	JR	Z,BSYOF1
	IN	A,(CR)
	RRCA
	JR	C,BSYOF0
	POP	HL
	POP	DE
	RET
;
BSYOF1:
	DEC	E
	JR	NZ,BSYOF2
	JR	BSYONE
;
BSY0:
	CALL	DLY80U
	LD	E,007H
	RET
;
;
; SEQUENTIAL READ
;
BREAD:
	CALL	CNVRT
	CALL	PARST1
RE8:
	CALL	SIDST
	CALL	SEEK
	JP	NZ,ER_SEEK
	CALL	PARST2
	DI
DCMD:	LD	A,094H
	CALL	CMDOT2
RE6:
	LD	B,000H
RE4:
	IN	A,(CR)
	RRCA
	JR	C,RE3
	RRCA
	JR	C,RE4
DINI:	INI
	JR	NZ,RE4
	INC	(IX+008H)
	LD	A,(IX+008H)
	CP	011H
	JR	Z,RE10
	DEC	D
	JR	NZ,RE6
	JR	RE11
RE10:
	DEC	D
RE11:
	CALL	INTER
RE3:
	EI
	IN	A,(CR)
	CPL
	LD	(F_C_CR),A
	AND	0FFH
	JR	NZ,FD_ERROR
	CALL	ADJ
	JP	Z,REND
	LD	A,(IX+007H)
	JR	RE8
REND:
	LD	A,080H
	OUT	(DM),A
	RET
;
;
; PARAMETER SET
;
;
PARST1:
	CALL	READY
	LD	D,(IX+004H)
	LD	A,(IX+003H)
	OR	A
	JR	Z,PARST1_1
	INC	D
PARST1_1:
	LD	A,(IX+00AH)
	LD	(IX+008H),A
	LD	A,(IX+009H)
	LD	(IX+007H),A
	LD	L,(IX+005H)
	LD	H,(IX+006H)
	RET

;
;
; SIZE SEEK SET
;
SIDST:
	SRL	A
	CPL
	OUT	(DR),A
	JR	NC,SIDST1
	LD	A,001H
	JR	SIDST2
SIDST1:
	XOR	A
SIDST2:
	CPL
	OUT	(HS),A
	RET
;
;
; TRACK	& SECTOR SET
;
PARST2:
	LD	C,0DBH
	LD	A,(IX+007H)
	SRL	A
	CPL
	OUT	(TR),A
	LD	A,(IX+008H)
	CPL
	OUT	(SCR),A
	RET
;
;
; ADJUST SECT & TRACK
;
ADJ:
	LD	A,(IX+008H)
	CP	011H
	JR	NZ,ADJ_H0
	LD	A,001H
	LD	(IX+008H),A
	INC	(IX+007H)
ADJ_H0:
	LD	A,D
	OR	A
	RET
;
;
; COMMAND OUT & WAIT
;
CMDOT2:
	LD	(F_CR),A
	CPL
	OUT	(CR),A
	CALL	BSYOFF
	RET
;
;
; FORCE	INTERRUPT
;
INTER:
	LD	A,0D8H
	CPL
	OUT	(CR),A
	CALL	BSYON
	RET

;
;
; ERROR STATUS CHECK
;
FD_ERROR:
	LD	A,(F_CR)
	CP	00BH
	JR	Z,ERCK1
	CP	01BH
	JR	Z,ERCK1
	CP	0F4H
	JR	Z,ERCK1
	LD	A,(F_C_CR)
	BIT	7,A
	JR	NZ,ERRET
	BIT	6,A
	JR	NZ,ERRET1
	BIT	4,A
;	LD	A,036H
	LD	DE,M36_ER
	JR	NZ,ERJMP
	JR	ERRET1
ERCK1:
	LD	A,(F_C_CR)
	BIT	7,A
	JR	NZ,ERRET
ERRET1:
	LD	DE,LD_ER
	JR	ERJMP
ERRET:
	LD	DE,MR_FD
ERJMP:
	CALL	MOFF
	CALL	LETNL
	CALL	MSG
	JP	E_HOOK
;
; FD-IF が無い
NOTIO:
	LD	DE,NO_IF
	JR	ERJMP
;
; SEEK ERROR
ER_SEEK:
	LD	DE,SEK_ER
	JR	ERJMP
;
; STATUS ERROR
ER_STS:
	LD	DE,ST_ER
	JR	ERJMP

;
;
; SECTOR TO TRACK & SECTOR CONVERT
;
CNVRT:
	LD	B,000H
	LD	DE,00010H
	LD	L,(IX+001H)
	LD	H,(IX+002H)
	XOR	A
;
TRANS0:
	SBC	HL,DE
	JR	C,TRANS1
	INC	B
	JR	TRANS0
;
TRANS1:
	ADD	HL,DE
	LD	H,B
	INC	L
	LD	(IX+009H),H
	LD	(IX+00AH),L
	RET
;
;
;	TIME DELAY ( 1m	& 60m &	80u )
;
DLY80U:
	PUSH	DE
	LD	DE,0000FH
	JP	DLYT

DLY1M:
	PUSH	DE
	LD	DE,000A0H
	JP	DLYT

DLY60M:
	PUSH	DE
	LD	DE,02026H
DLYT:
	DEC	DE
	LD	A,E
	OR	D
	JR	NZ,DLYT
	POP	DE
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  エラーフック
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
E_HOOK:
	LD	SP,010F0H	; スタックポインタ初期化
	CALL	LETNL
	LD	DE,EH_MSG	; エラーフック メッセージ表示
	CALL	MSG
	CALL	MOFF		; ドライブ モータ オフ

EH_MSG:	DB	"ERROR (HOOK)",00DH

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  各種データ・エリア
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			; オープニング メッセージ
	;	 ----+----1----+----2----+----3----+----4
OPMSG1:	DB	"* IPL SELECTER MAKER MZ-80B,2000,2200 * "
	DB	"      VER.0.9 (c)2021.01.31 HIDEKI SUGA", 00DH

	;	 ----+----1----+----2----+----3----+----4
SETMSG:	DB	"SET SLAVE DISK", 00DH
SDMSG:	DB	" TARGET DRIVE [1-4/!:MON] ?",00DH
SDMSGE:

LASTS:	DB	" BOOT SYSTEM OVERWRITE [Y/N] ?",00DH
LASTSE:

DINFO:	DB	"DISK INFOMATION",00DH
DMODEL:	DB	" MODEL    ",00DH
DSIG:	DB	" SIGNATURE   ",00DH
DSYSN:	DB	" SYSTEM NAME : ",00DH

MDL01:	DB	" : MZ-80B/2000/2200/2500",00DH
MDL02:	DB	" : MZ-80A",00DH
MDL03:	DB	" : MZ-700/1500",00DH
MDL04:	DB	" : MZ-2500 DATA DISK",00DH
MDLOT:	DB	" : OTHER",00DH

DYES:	DB	": YES",00DH
DNO:	DB	": NO",00DH

IPLPRO:	DB	"IPLPRO"

DONE:	DB	"DONE",00DH	; 4

MR_FD:	DB	"MAKE READY FD",00DH
NO_IF:	DB	"FDD IF NOT FOUND.",00DH
LD_ER:	DB	"FD LOADING ERROR.",00DH
SEK_ER:	DB	"SEEK ERROR.",00DH
ST_ER:	DB	"STATUS ERROR.",00DH
RDY_ER:	DB	"READY ERROR.",00DH
M36_ER:	DB	"36 ERROR.",00DH

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

F_MT:	DS	1		; モーターフラグ
F_CR:	DS	1		; 
F_DRV0:	DS	1		; ドライブ0
F_DRV1:	DS	1		; ドライブ1
F_DRV2:	DS	1		; ドライブ2
F_DRV3:	DS	1		; ドライブ3

F_C_CR:	DS	1		; CR

SELASC:	DS	1		; セレクト入力文字

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  リードパラメータ
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

P_DIR:	DB	0	; ドライブ	(IX+0)
P_SEC:	DW	0	; セクタ番号	(IX+1,IX+2)
P_SIZ:	DW	0	; 読込サイズ	(IX+3,IX+4)
P_ADR:	DW	0	; 読込アドレス	(IX+5,IX+6)
P_NT:	DB	0	; 次のトラック	(IX+7)
P_NS:	DB	0	; 次のセクタ	(IX+8)
P_ST:	DB	0	; Start track	(IX+9)
P_SS:	DB	0	; Start sector	(IX+10)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  IPL SELECTER 書込み内容
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
IPCSEL:
	BINCLUDE	"IPLSEL09.bin"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  最大アドレス
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PEND:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  ワークエリア等
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
SELWK	EQU	PEND		; セレクト 入力ワーク

DIR1	EQU	SELWK +	80	; 0セクタ目読込先

	END
