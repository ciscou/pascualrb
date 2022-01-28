jmp 1
allocate 14
push 0
offset
+
push 10
store
push 1
offset
+
push 0
+
push 0
store
push 1
offset
+
push 1
+
push 1
push -1
*
store
push 1
offset
+
push 2
+
push 42
store
push 1
offset
+
push 3
+
push 69
store
push 1
offset
+
push 4
+
push 420
push -1
*
store
push 1
offset
+
push 5
+
push 17
store
push 1
offset
+
push 6
+
push 1
store
push 1
offset
+
push 7
+
push 23
store
push 1
offset
+
push 8
+
push 100
store
push 1
offset
+
push 9
+
push 33
store
push 11
offset
+
push 1
offset
+
push 0
+
load
store
push 12
offset
+
push 1
offset
+
push 0
+
load
store
push 13
offset
+
push 0
store
push 13
offset
+
load
push 0
offset
+
load
lt
jz 185
push 1
offset
+
push 13
offset
+
load
+
load
push 11
offset
+
load
lt
jz 145
push 11
offset
+
push 1
offset
+
push 13
offset
+
load
+
load
store
jmp 145
push 1
offset
+
push 13
offset
+
load
+
load
push 12
offset
+
load
gt
jz 174
push 12
offset
+
push 1
offset
+
push 13
offset
+
load
+
load
store
jmp 174
push 13
offset
+
push 13
offset
+
load
push 1
+
store
jmp 106
push 11
offset
+
load
writeln
push 12
offset
+
load
writeln
free 14
