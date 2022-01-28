jmp 82
allocate 4
push 1
offset
+
swap
store
push 0
offset
+
swap
store
push 3
offset
+
push 1
store
push 2
offset
+
push 0
store
push 2
offset
+
load
push 1
offset
+
load
lt
jz 56
push 3
offset
+
push 3
offset
+
load
push 0
offset
+
load
*
store
push 2
offset
+
push 2
offset
+
load
push 1
+
store
jmp 22
push 3
offset
+
load
free 4
ret
push -1
free 4
ret
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
jsr 1
free 1
ret
push -1
free 1
ret
allocate 0
push 3
jsr 65
jsr 65
writeln
free 0
