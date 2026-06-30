// Lapisan kepemilikan — assembly AArch32 (armeabi-v7a), Thumb-2.
// Fragmen seed identitas (SHA-256 string kepemilikan ter-obfuscate) di immediate movw/movt.
// Return 64-bit di r0(low):r1(high).
    .syntax unified
    .thumb
    .text

.macro FRAG name, lo_l, lo_h, hi_l, hi_h
    .global \name
    .type \name, %function
    .thumb_func
\name:
    movw r0, #\lo_l
    movt r0, #\lo_h
    movw r1, #\hi_l
    movt r1, #\hi_h
    bx lr
    .size \name, .-\name
.endm

    FRAG kepem_frag_u0, 0x58ee, 0xa66e, 0x89fc, 0xdfac
    FRAG kepem_frag_u1, 0x07b3, 0xb7a7, 0x517f, 0x314d
    FRAG kepem_frag_u2, 0xe304, 0x95cc, 0xd08b, 0x809b
    FRAG kepem_frag_u3, 0x81f1, 0x28a3, 0x17a9, 0x1762
    FRAG kepem_frag_c0, 0x58ee, 0xa66e, 0x89fc, 0xdfac
    FRAG kepem_frag_c1, 0x07b3, 0xb7a7, 0x517f, 0x314d
    FRAG kepem_frag_c2, 0xe304, 0x95cc, 0xd08b, 0x809b
    FRAG kepem_frag_c3, 0x81f1, 0x28a3, 0x17a9, 0x1762

    .global kepemilikan_magic
    .type kepemilikan_magic, %function
    .thumb_func
kepemilikan_magic:
    b kepem_frag_u0
    .size kepemilikan_magic, .-kepemilikan_magic
