
define void @mul(i32 %x, i32 %y, i8* %z) {
init:
	%x1 = add nsw i32 %x, 1
	br label %head
head:
	%i = phi i32 [ 0, %init ], [ %i1, %body ]
	%c = icmp slt i32 %i, %y
	br i1 %c, label %body, label %exit
body:
	%ptr = getelementptr i8, i8* %z, i32 %i
	%new = trunc i32 %x1 to i8
	store i8 %new, i8* %ptr
	%i1 = add nsw i32 %i, 1
	br label %head

exit:
	ret void
}

define void @main(){
	%temp = alloca i8
	call void @mul(i32 0, i32 5, i8* %temp)
	ret void
}
