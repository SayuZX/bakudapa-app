// Lapisan kepemilikan — assembly AArch64 (arm64-v8a).
// Fragmen seed identitas (SHA-256 string kepemilikan ter-obfuscate) di immediate movz/movk.
    .text

.macro FRAG name, w0, w1, w2, w3
    .global \name
    .type \name, %function
\name:
    movz x0, #\w0
    movk x0, #\w1, lsl #16
    movk x0, #\w2, lsl #32
    movk x0, #\w3, lsl #48
    ret
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
kepemilikan_magic:
    b kepem_frag_u0
    .size kepemilikan_magic, .-kepemilikan_magic
