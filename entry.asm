#import "moveutils.asm"

BasicUpstart2(main)

.const ticktime = 50
.const screenbase = petmateexport + 2
.const colorbase = petmateexport + 1002

.macro Randomize() {
	lda $d012
	eor $dc04
	sbc $dc05 
}

.macro RandomFireLine(color, thrs, x, y, len) {
	.const addrScr = $0400 + (y * 40)
	.const addrCol = $d800 + (y * 40)
	.const addrBaseScr = screenbase + (y * 40)
	.const addrBaseCol = colorbase + (y * 40)
	cld
	Put16BAddr(addrCol, $fb)
	Put16BAddr(addrScr, $fd)

	ldy #x+len-1
next:
	Randomize()
	cmp #$ff-thrs
	bcc nofire

	Randomize()
	and #$07
	ora #(firechars & $f8)
	sta * + 4

	lda firechars
	sta ($fd),y
	lda #color
	sta ($fb),y
	jmp finish
nofire:
	Put16BAddr(addrBaseCol, copyorig + 1)
	tya
	clc
	adc copyorig + 1
	sta copyorig + 1
	lda copyorig + 2
	adc #$00
	sta copyorig + 2

	Put16BAddr(addrBaseScr, copyorig + 1 + asmCommandSize(STA_IZPY) + asmCommandSize(LDA_ABS))
	tya
	clc
	adc copyorig + 1 + asmCommandSize(STA_IZPY) + asmCommandSize(LDA_ABS)
	sta copyorig + 1 + asmCommandSize(STA_IZPY) + asmCommandSize(LDA_ABS)
	lda copyorig + 2 + asmCommandSize(STA_IZPY) + asmCommandSize(LDA_ABS)
	adc #$00
	sta copyorig + 2 + asmCommandSize(STA_IZPY) + asmCommandSize(LDA_ABS)
copyorig:
	lda $FFFF
	sta ($fb),y
	lda $FFFF
	sta ($fd),y
finish:
	dey
	cpy #x-1
	beq end
	bcs next

end: 
}

* = $4000
main:        
		lda $d011 	// switch to bitmap
		and #%10011111
		sta $d011

		lda $d016 	// switch to multicolor
		ora #%11101111
		sta $d016

			   // Set Background and Border Colors
		lda petmateexport + 1
		sta $d021
		lda petmateexport
		sta $d020	
		
		CopyMemoryMod(colorbase,  $d800, 40*25)
		CopyMemoryMod(screenbase, $0400, 40*25)

	next:
		RandomFireLine(GREY,        $30, 13, 15, 1)
		RandomFireLine(ORANGE,      $80, 14, 15, 2)
		RandomFireLine(LIGHT_RED,   $d0, 16, 15, 2)
		RandomFireLine(YELLOW,      $f0, 18, 15, 4)
		RandomFireLine(LIGHT_RED,   $d0, 22, 15, 2)
		RandomFireLine(ORANGE,      $80, 24, 15, 2)
		RandomFireLine(GREY,        $30, 26, 15, 1)

		RandomFireLine(GREY,        $20, 12, 14, 3)
		RandomFireLine(ORANGE,      $80, 15, 14, 2)
		RandomFireLine(LIGHT_RED,   $d0, 17, 14, 2)
		RandomFireLine(YELLOW,      $d8, 19, 14, 2)
		RandomFireLine(LIGHT_RED,   $d0, 21, 14, 2)
		RandomFireLine(ORANGE,      $80, 23, 14, 2)
		RandomFireLine(GREY,        $20, 25, 14, 3)

		RandomFireLine(GREY,        $10, 11, 13, 5)
		RandomFireLine(ORANGE,      $80, 16, 13, 2)
		RandomFireLine(LIGHT_RED,   $d0, 18, 13, 4)
		RandomFireLine(ORANGE,      $80, 22, 13, 2)
		RandomFireLine(GREY,        $10, 24, 13, 5)

		RandomFireLine(GREY,        $05, 11, 12, 6)
		RandomFireLine(ORANGE,      $80, 17, 12, 2)
		RandomFireLine(LIGHT_RED,   $d0, 19, 12, 2)
		RandomFireLine(ORANGE,      $80, 21, 12, 2)
		RandomFireLine(GREY,        $05, 23, 12, 6)

		RandomFireLine(GREY,        $05, 11, 11, 7)
		RandomFireLine(ORANGE,      $80, 18, 11, 4)
		RandomFireLine(GREY,        $05, 22, 11, 7)

		RandomFireLine(GREY,        $05, 11, 10, 18)

		RandomFireLine(GREY,        $05, 11,  9, 18)

		RandomFireLine(GREY,        $05, 11,  8, 18)

		sei
		ldx #00
loop1:
		lda #$fb
		cmp $d012
		bne loop1
		inx
		cpx #ticktime
		bcc loop1
		cli
		jmp next

petmateexport:
	#import "fire.asm"

* = $6000
firechars: // . , ; ( ) ? ' " 
	.byte $2E
	.byte $2C
	.byte $3B
	.byte $28
	.byte $29
	.byte $3F
	.byte $27
	.byte $22

timer:
	.byte $00
