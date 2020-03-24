.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "BSS"
.code

sei

lda $9F29
ora #$40
and #($FF-$20)
sta $9F29

stz $9F20
lda #$40
sta $9F21
lda #$10
sta $9F22
.repeat 64, i
    lda sprite_data+i
    sta $9F23
.endrep

stz $9F20
lda #$fc
sta $9F21
lda #$11
sta $9F22

.repeat 16, i
    lda sprite_info+i
    sta $9F23
.endrep

lda $0314
sta default_irq
lda $0315
sta default_irq+1

lda $9F26
ora #$04
sta $9F26

lda #<irq
sta $0314
lda #>irq
sta $0315

cli

jmp *

irq:
    lda $9F27
    and #$04
    beq check_vsync_irq

    lda #1
    sta collided

    lda #$00
    sta $9F20
    lda #$fc
    sta $9F21
    lda #$41
    sta $9F22

    lda #$01
    sta $9F23
    lda #$01
    sta $9F23

    lda #$04
    sta $9F27

check_vsync_irq:
    lda $9F27
    and #$01
    beq irq_done

    lda collided
    and #1
    bne update_sprites

    lda #$00
    sta $9F20
    lda #$fc
    sta $9F21
    lda #$41
    sta $9F22

    lda #$00
    sta $9F23
    lda #$00
    sta $9F23

update_sprites:
    stz collided

    lda #$02
    sta $9F20
    lda #$fc
    sta $9F21
    lda #$21
    sta $9F22
    lda count
    sta $9F23
    sta $9F23

    clc
    adc #1
    sta count

    cmp #200
    bne irq_done

    lda default_irq
    sta $0314
    lda default_irq+1
    sta $0315

irq_done:
    jmp (default_irq)

sprite_data:
    .byte $00, $07, $70, $00
    .byte $00, $07, $70, $00
    .byte $00, $07, $70, $00
    .byte $77, $77, $77, $77
    .byte $77, $77, $77, $77
    .byte $00, $07, $70, $00
    .byte $00, $07, $70, $00
    .byte $00, $07, $70, $00

sprite_data_collided:
    .byte $00, $04, $40, $00
    .byte $00, $04, $40, $00
    .byte $00, $04, $40, $00
    .byte $44, $44, $44, $44
    .byte $44, $44, $44, $44
    .byte $00, $04, $40, $00
    .byte $00, $04, $40, $00
    .byte $00, $04, $40, $00

sprite_info:
sprite_info0:
    .byte $00, $02, 0, 0, 0, 0, $1C, 0
sprite_info1:
    .byte $00, $02, 100, 0, 100, 0, $1C, 0

count:
    .byte 0

collided:
    .byte 0

default_irq:
    .byte 0, 0