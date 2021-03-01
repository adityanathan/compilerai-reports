
define i4 @mul() {
	%r = select i1 undef, i4 -1, i4 0
	ret i4 %r
}

define void @main(){
	call i4 @mul()
	ret void
}
