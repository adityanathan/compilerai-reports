define i4 @mul(i4 %x) {
	; %r = mul i4 %x, 2
	%r = mul i4 undef, 2
	ret i4 %r
}

define void @main(){
	call i4 @mul(i4 undef)
	ret void
}
