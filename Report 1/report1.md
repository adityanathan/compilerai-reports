# Week 1 Report (March 1)

- TLDR: We created multiple small llvm program pairs using examples from the alive and llvm undefined paper and tested eq32 on them to see what eq32 can handle and cannot handle as of now. We found 1 eq32 bug related to undef handling
- Observations:
  - In many cases, we got symbolic execution error
  - In one case, the programs were not equivalent but eq32 claimed that they were equivalent. On observation of the tfg files, we found that there is a bug in the way eq32 handles undef. The error was thought to be in lib/expr/expr.cpp but it turned out that the the fix is not that easy.

# Description of the different programs tested

- Program correctnes was tested by running llc on the individual programs and if llc was able to convert the .ll files .s, it was assumed the llvm programs were correct.

- Question: Does eq32 optimize the input programs before checking for equivalence?
  - If it does, then it's possible in some cases that the code we wanted eq32 to examine for equivalence might have been deleted because of aggressive optimization.
  - However, in most cases the desired variable was returned by the function so I'm guessing it can't delete that code. I'm also assuming it can't optimize memory operations out.

- The command to execute eq32 in all cases was 

        eq32 -f mul reg1.ll reg2.ll 2>&1 | tee out.log

- Programs tested were all acyclic (except for test1)

## Test 1 (Hoisting of invariant addition)

- Expected Result: Programs are equivalent
- Obtained Result: Programs are equivalent
- The etfg files, proof, programs, etc. are available in [tests/test1](tests/test1)
  - Program 1: [reg1.ll](tests/test1/reg1.ll), Program 2: [reg2.ll](tests/test1/reg2.ll)
  - Proof: [eq.proof.mul](tests/test1/eq.proof.mul)

## Test 2 (Transformation from select to ashr)

- Expected result: The programs are equivalent.
- Obtained Result: This test gave an assertion error ('Assertion 0 failed') related to the z3 SMT Solver
- The programs, etfg files, etc. are available in [tests/test2 directory](tests/test2)
  - The error message can be found in [tests/test2/out.log](tests/test2/out.log)
  - Program 1: [reg1.ll](tests/test2/reg1.ll), Program 2: [reg2.ll](tests/test2/reg2.ll)

## Test 3 (Hoisting out an operation which triggers immediate UB)

- Expected Result: Programs are inequivalent
- Obtained Result: There was a symbolic execution error.
- The operation in question here is a shift left by more than the bitwidth.
- In one of the programs, the operation was put inside a block which never executed. In the other, it was hoisted out of that branch.

    out.log
    ```
    Stack dump:
    0.	Program arguments: /home/adityanathan/superopt-project/usr/local/bin/llvm2tfg --xml-output-format text-color -f mul reg1.ll.bc -o reg1.ll.bc.etfg
    Aborted (core dumped)
    <MSG>0:00 : Converting C source code to LLVM IR bitcode...</MSG>
    <MSG>0:00 : Converting LLVM IR bitcode to Transfer Function Graph (TFG)...</MSG>
    non-zero exit status (134) of command, exiting:
    /home/adityanathan/superopt-project/usr/local/bin/llvm2tfg  --xml-output-format text-color -f mul reg1.ll.bc -o reg1.ll.bc.etfg
    command: /home/adityanathan/superopt-project/usr/local/bin/llvm2tfg  --xml-output-format text-color -f mul reg1.ll.bc -o reg1.ll.bc.etfg.
    <ERR>Symbolic execution of unoptimized LLVM IR bitcode failed. Aborting.</ERR>
    ```

- Assuming this to be related to the undefined operation, I changed the shift to less than the bitwidth and executed eq32 again but strangely the symbolic exeution error occurred again.

    out.log

    ```
    <MSG>0:00 : Converting LLVM IR bitcode to Transfer Function Graph (TFG)...</MSG>
    non-zero exit status (134) of command, exiting:
    /home/adityanathan/superopt-project/usr/local/bin/llvm2tfg  --xml-output-format text-color -f mul reg1.ll.bc -o reg1.ll.bc.etfg
    command: /home/adityanathan/superopt-project/usr/local/bin/llvm2tfg  --xml-output-format text-color -f mul reg1.ll.bc -o reg1.ll.bc.etfg.
    <ERR>Symbolic execution of unoptimized LLVM IR bitcode failed. Aborting.</ERR>
    ```

- The files related to the program pair where the operation was defined (shift amount is less than bitwidth) is in [tests/test3/defined_op](tests/test3/defined_op/)
  - Program 1: [reg1.ll](tests/test3/defined_op/reg1.ll), Program 2: [reg2.ll](tests/test3/defined_op/reg2.ll)
  - Error message: [out.log](tests/test3/defined_op/out_defined_op.log)

- The files related to the program pair where the operation was defined (shift amount is less than bitwidth) is in [tests/test3/undefined_op](tests/test3/undefined_op/)
  - Program 1: [reg1.ll](tests/test3/undefined_op/reg1.ll), Program 2: [reg2.ll](tests/test3/undefined_op/reg2.ll)
  - Error message: [out.log](tests/test3/undefined_op/out_undefined_op.log)

## Test 4 (Converting x*2 to x+x)

- Expected result: The programs are not equivalent.
- Obtained result: The programs are equivalent.

- We expect the programs to be not equivalent because if x is undef, then,

        undef*2 != undef + undef

- We discovered a bug in the tfg files
  - The `add undef, undef` code generates the following tfg piece of code:

        ```
        =Edge: L0%1%1 => L0%2%1
        =Edge.EdgeCond:
        1 : 1 : BOOL
        =Edge.StateTo:
        =dst.llvm-%r
        1 : llvm-undef : BV:4
        2 : bvadd(1, 1) : BV:4
        =state_end
        =Edge.Assumes.begin:
        =Edge.Assumes.end
        =Edge.te_comment
        0:1:  %r = add i4 undef, undef
        tfg_edge_comment end

        ```

  - The bug is in how the undef variable is treated. It is considering the two undef variables to be the same which is clearly wrong because in each use of undef it generates a different value.

      Offending part of the tfg:
      ```
      1 : llvm-undef : BV:4
      2 : bvadd(1, 1) : BV:4
      ```
  - This wrong interpretation/semantics is why it is considering the program to be equivalent.

  - Initially, we (Anurag) thought that this bug could be fixed in lib/expr/expr.cpp but on closer inspection we (Anurag) found that this issue is a bit more complicated and we might have to look into how undef is handled during symbolic execution.


- The corresponding files, proof, etfg, programs, etc. for this test can be found in [tests/test4](tests/test4/)
  - Program 1: [reg1.ll](tests/test4/reg1.ll), Program 2: [reg2.ll](tests/test4/reg2.ll)
  - Proof: [eq.proof.mul](tests/test4/eq.proof.mul)

## Test 5 (Effect of poison on eq32)

- Expected result: No objective in mind. Just wanted to see how eq32 would handle poison. Both programs are designed to trigger immediate UB (because of getelementptr using poison in it's address variable).

- Obtained result: Symbolic Execution Error.

    ```
    Stack dump:
    0.	Program arguments: /home/adityanathan/superopt-project/usr/local/bin/llvm2tfg --xml-output-format text-color -f mul reg1.ll.bc -o reg1.ll.bc.etfg
    Aborted (core dumped)
    <MSG>0:00 : Converting C source code to LLVM IR bitcode...</MSG>
    <MSG>0:00 : Converting LLVM IR bitcode to Transfer Function Graph (TFG)...</MSG>
    non-zero exit status (134) of command, exiting:
    /home/adityanathan/superopt-project/usr/local/bin/llvm2tfg  --xml-output-format text-color -f mul reg1.ll.bc -o reg1.ll.bc.etfg
    command: /home/adityanathan/superopt-project/usr/local/bin/llvm2tfg  --xml-output-format text-color -f mul reg1.ll.bc -o reg1.ll.bc.etfg.
    <ERR>Symbolic execution of unoptimized LLVM IR bitcode failed. Aborting.</ERR>
    ```


- Corresponding files are located in [tests/test5](tests/test5/)
  - Program 1: [reg1.ll](tests/test5/reg1.ll), Program 2: [reg2.ll](tests/test5/reg2.ll)
  - Error message: [out.log](tests/test5/out.log)

## Test 6 (One program triggers immediate UB while the other doesn't)

- Expected result: Programs are not equivalent
- Obtained result: Equivalence proof not found after exhaustive search

- The immediate UB is triggered by dividing by a poison value.

    ```
    %i = add nuw i4 0, -5
	%i2 = sdiv i4 5, %i
    ```

- Corresponding files are located in [tests/test6](tests/test6/)
  - Program 1: [reg1.ll](tests/test6/reg1.ll), Program 2: [reg2.ll](tests/test6/reg2.ll)
  - Output log: [out.log](tests/test6/out.log)
