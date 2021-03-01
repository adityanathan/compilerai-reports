define i4 @mul(i4 %x) {
	; %r = add i4 %x, %x
	%r = add i4 undef, undef
	ret i4 %r
}

define void @main(){
	call i4 @mul(i4 undef)
	ret void
}
