define i4 @mul(i4 %x) {
	%addr = alloca i4
	%i = add nuw i4 0, 1
	%i2 = sdiv i4 6, %i
	ret i4 %i2
}

define void @main(){
	call i4 @mul(i4 undef)
	ret void
}
