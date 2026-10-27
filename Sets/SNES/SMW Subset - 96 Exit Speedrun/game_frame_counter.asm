; 32 bit frame counter that keeps incrementing as soon as the game starts.
; by Abdu
; Credit: Fernap for helping me deal with nmi stuff.

if read1($00FFD5) == $23
	sa1rom
	!bank = $000000
	!addr = $6000
else
	lorom
	!bank = $800000
	!addr = $0000
endif

; 6 byte freeram, only 4 bytes are used. Cleared on reset and titlescreen load.
!frame_counter = $0F3A|!addr

; 4 byte freeram.
; Empty. Cleared on reset and titlescreen load. 
; $7E:0DC3 is also cleared when selecting how many players to use, 
; but this can be disabled with no known side effects by setting $00:9E48 to [80 01 EA].
!backup_counter = $0DC3|!addr

; Postive = NMI Disabled, negative = NMI Enabled.
!nmi_flag = $7F9C7B


org $008027
	jsr init_nmi_flag

org $00F9F5
init_nmi_flag:
	lda #$0080 : sta !nmi_flag ; high byte never being used so its fine.
	lda #$F0A9
rts


; Repoint Native NMI vector.
org $00FFEA
	dw native_NMI_vector

org $00FF93
native_NMI_vector:
	php
	rep #$30
	pha : phx : phy : phb
	phk : plb
	sep #$30

	jsr handle_frame_counter
	lda !nmi_flag : bpl .NMIDisabled
	sei
	; <Fernap>:
	; expects a/x/y to be 8-bit...if that's not the case, 
	; set it first, or jmp to $8174 instead
	jmp $8176

	.NMIDisabled:
	rep #$30
	plb : ply : plx : pla : plp
rti


org $00937D
	jsr disable_nmi
org $0096AE
	jsr disable_nmi
org $0096D5
	jsr disable_nmi

org $00BA4D
disable_nmi:
	lda #$01 : sta !nmi_flag
	lda #$80 : sta $4200
rts


org $0082A1
	jsr enable_nmi
org $00838C
	jsr enable_nmi
org $0083C3
	jsr enable_nmi
org $0083F3
	jsr enable_nmi
org $0093F9
	jsr enable_nmi

org $00FA00
enable_nmi:
	sta.w $4200 : sta !nmi_flag
rts


; Overwrite some unused code to make a running Yoshi at the left edge of the screen.
org $00FC23
handle_frame_counter:
	; Make sure code only run in the correct gamemodes.
	lda $0100|!addr : cmp #$0B : bcc .ret
	jsr increment_frame_counter

	lda $0100|!addr : cmp #$0F : bcs .ret
	rep #$20
	lda !frame_counter : sta !backup_counter
	lda !frame_counter+2 : sta !backup_counter+2
	sep #$20
	.ret:
rts


; Overwrite some debug code for freeroam.
org $00CC86
increment_frame_counter:
		; Now this is #peakcoding.
		rep #$20
		lda !frame_counter : inc
	.check_low:
		cmp #$FFFF : bcs .carry_low
		sta !frame_counter
		lda !frame_counter+2
		bra .check_high
	.carry_low:
		sec : sbc #$FFFF
		inc !frame_counter+2
		bra .check_low
	.check_high:
		cmp #$FFFF : bcc .done
		lda #$FFFF : sta !frame_counter : sta !frame_counter+2
	.done:
		sep #$20
rts

