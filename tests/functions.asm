jmp 84
allocate 3
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
push 2
offset
+
push 1
store
push 3
offset
+
push 0
store
push 3
offset
+
load
push 1
offset
+
load
lt
jz 56
push 2
offset
+
push 2
offset
+
load
push 0
offset
+
load
*
store
push 3
offset
+
push 3
offset
+
load
push 1
+
store
jmp 22
push 2
offset
+
load
free 4
ret
allocate 2
push 0
offset
+
swap
store
push 1
offset
+
push 0
offset
+
load
push 2
jsr 1
store
push 1
offset
+
load
free 2
ret
allocate 0
push 3
jsr 62
jsr 62
writeln
free 0
