define i4 @mul() {
	%addr = alloca i4
	%i = add nuw i4 0, -1
	%i2 = getelementptr i4, i4* %addr, i4 %i
	store i4 0, i4* %i2
	%r = load i4, i4* %i2
	ret i4 %r
}

define void @main(){
	call i4 @mul()
	ret void
}
