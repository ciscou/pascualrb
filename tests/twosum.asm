jmp 1
allocate 8
push 0
offset
+
push 4
store
push 1
offset
+
push 0
+
push 2
store
push 1
offset
+
push 1
+
push 11
store
push 1
offset
+
push 2
+
push 7
store
push 1
offset
+
push 3
+
push 15
store
push 5
offset
+
push 9
store
push 6
offset
+
push 0
store
push 6
offset
+
load
push 0
offset
+
load
lt
jz 133
push 7
offset
+
push 6
offset
+
load
push 1
+
store
push 7
offset
+
load
push 0
offset
+
load
lt
jz 122
push 1
offset
+
push 6
offset
+
load
+
load
push 1
offset
+
push 7
offset
+
load
+
load
+
push 5
offset
+
load
eq
jz 111
push 6
offset
+
load
writeln
push 7
offset
+
load
writeln
jmp 111
push 7
offset
+
push 7
offset
+
load
push 1
+
store
jmp 65
push 6
offset
+
push 6
offset
+
load
push 1
+
store
jmp 45
free 8
