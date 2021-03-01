
define i4 @mul() {
	%r = ashr i4 undef, 3
	ret i4 %r
}

define void @main(){
	call i4 @mul()
	ret void
}
