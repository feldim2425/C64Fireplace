.macro Put16BAddr(addr, to) {
	lda #addr & $ff 
	sta to
	lda #[addr >> 8] & $ff
	sta to + 1
}


.macro CopyMemoryMod(from, to, size) {
	// Load high size counter into x and low size counter into y
	ldx #[(size-1) >> 8] & $ff
	ldy #(size-1) & $ff
nextbyte1:
	lda from
	sta to

	inc nextbyte1 + 1 // Increment low-address byte of the "lda" instruction
	bne !+ // If the byte did not roll over jump over the next instruction
	inc nextbyte1 + 2 // Increment high-address byte of the "lda" instruction
!:
	inc nextbyte1 + 4  // Increment low-address byte of the "sta" instruction
	bne !+ // If the byte did not roll over jump over the next instruction
	inc nextbyte1 + 5 // Increment high-address byte of the "sta" instruction
!:
	cpy #00 // If Y is at 0 X has to be decremented and checked before decrementing
	bne nodecx 
	cpx #00 // If X is at 0 the copy routine is done
	beq end
	dex
nodecx:
	dey
	jmp nextbyte1
end:
	// Restore original lda and sta before exiting
	lda #from & $ff
	sta nextbyte1 + 1
	lda #[from >> 8] & $ff
	sta nextbyte1 + 2
	lda #to & $ff
	sta nextbyte1 + 4
	lda #[to >> 8] & $ff
	sta nextbyte1 + 5
}


