define i4 @mul(i4 %x) {
	%addr = alloca i4
	%i = add nuw i4 0, -5
	%i2 = sdiv i4 5, %i
	ret i4 %i2
}

define void @main(){
	call i4 @mul(i4 undef)
	ret void
}
