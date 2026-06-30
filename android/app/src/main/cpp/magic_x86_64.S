    .text

.macro FRAG name, imm
    .globl \name
    .type \name, @function
\name:
    movabs $\imm, %rax
    ret
    .size \name, .-\name
.endm

    FRAG kepem_frag_u0, 0xdfac89fca66e58ee
    FRAG kepem_frag_u1, 0x314d517fb7a707b3
    FRAG kepem_frag_u2, 0x809bd08b95cce304
    FRAG kepem_frag_u3, 0x176217a928a381f1
    FRAG kepem_frag_c0, 0xdfac89fca66e58ee
    FRAG kepem_frag_c1, 0x314d517fb7a707b3
    FRAG kepem_frag_c2, 0x809bd08b95cce304
    FRAG kepem_frag_c3, 0x176217a928a381f1

    .globl kepemilikan_magic
    .type kepemilikan_magic, @function
kepemilikan_magic:
    jmp kepem_frag_u0
    .size kepemilikan_magic, .-kepemilikan_magic
