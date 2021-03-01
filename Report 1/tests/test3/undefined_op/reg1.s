	.text
	.file	"reg1.ll"
	.globl	mul                     # -- Begin function mul
	.p2align	4, 0x90
	.type	mul,@function
mul:                                    # @mul
	.cfi_startproc
# %bb.0:                                # %entry
	testb	$1, %dil
	je	.LBB0_1
# %bb.2:                                # %head
                                        # implicit-def: $al
                                        # kill: def $al killed $al killed $eax
	retq
.LBB0_1:
	xorl	%eax, %eax
                                        # kill: def $al killed $al killed $eax
	retq
.Lfunc_end0:
	.size	mul, .Lfunc_end0-mul
	.cfi_endproc
                                        # -- End function
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	xorl	%edi, %edi
	callq	mul
	popq	%rax
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function
	.section	".note.GNU-stack","",@progbits
