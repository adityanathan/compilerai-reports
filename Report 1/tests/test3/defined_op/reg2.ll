define i4 @mul(i1 %x) {
entry:
	%i1 = shl i4 3, 1
	br i1 %x, label %head, label %end
head:
	%i2 = add i4 %i1, 0
	br label %end
end:
	%r = phi i4 [0, %entry], [%i2, %head]
	ret i4 %r
}

define void @main(){
	call i4 @mul(i1 0)
	ret void
}
