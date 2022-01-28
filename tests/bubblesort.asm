jmp 1
allocate 14
push 4
offset
+
push 0
+
push 1
store
push 4
offset
+
push 1
+
push 42
store
push 4
offset
+
push 2
+
push 69
store
push 4
offset
+
push 3
+
push 3
push -1
*
store
push 4
offset
+
push 4
+
push 222
store
push 4
offset
+
push 5
+
push 17
store
push 4
offset
+
push 6
+
push 23
push -1
*
store
push 4
offset
+
push 7
+
push 15
store
push 4
offset
+
push 8
+
push 33
store
push 4
offset
+
push 9
+
push 0
store
push 0
offset
+
push 9
store
push 0
offset
+
load
push 0
gt
jz 196
push 1
offset
+
push 0
store
push 1
offset
+
load
push 0
offset
+
load
lt
jz 185
push 4
offset
+
push 1
offset
+
load
+
load
push 4
offset
+
push 1
offset
+
load
push 1
+
+
load
gt
jz 174
push 2
offset
+
push 4
offset
+
push 1
offset
+
load
+
load
store
push 4
offset
+
push 1
offset
+
load
+
push 4
offset
+
push 1
offset
+
load
push 1
+
+
load
store
push 4
offset
+
push 1
offset
+
load
push 1
+
+
push 2
offset
+
load
store
jmp 174
push 1
offset
+
push 1
offset
+
load
push 1
+
store
jmp 93
push 0
offset
+
push 0
offset
+
load
push 1
-
store
jmp 81
push 0
offset
+
push 0
store
push 0
offset
+
load
push 10
lt
jz 229
push 4
offset
+
push 0
offset
+
load
+
load
writeln
push 0
offset
+
push 0
offset
+
load
push 1
+
store
jmp 201
free 14
