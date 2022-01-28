jmp 38
allocate 1
push 0
offset
+
swap
store
push 0
offset
+
load
push 2
lte
jz 18
push 1
free 1
ret
jmp 35
push 0
offset
+
load
push 1
-
jsr 1
push 0
offset
+
load
push 2
-
jsr 1
+
free 1
ret
push -1
free 1
ret
allocate 0
push 10
jsr 1
writeln
free 0
