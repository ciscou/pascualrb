jmp 1
allocate 3
push 0
offset
+
push 3
store
push 1
offset
+
push 2
store
push 2
offset
+
push 1
store
push 1
offset
+
load
push 2000
lt
jz 79
push 0
offset
+
push 0
offset
+
load
push 2
offset
+
load
push 4
*
push 1
offset
+
load
push 1
offset
+
load
push 1
+
*
push 1
offset
+
load
push 2
+
*
/
+
store
push 1
offset
+
push 1
offset
+
load
push 2
+
store
push 2
offset
+
push 2
offset
+
load
push -1
*
store
jmp 17
push 0
offset
+
load
writeln
free 3
