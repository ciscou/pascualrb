jmp 1
allocate 2
push 0
offset
+
push 1
store
push 1
offset
+
push 10
store
push 1
offset
+
load
push 0
gt
jz 43
push 0
offset
+
push 0
offset
+
load
push 1
offset
+
load
*
store
push 1
offset
+
push 1
offset
+
load
push 1
-
store
jmp 12
push 0
offset
+
load
writeln
free 2
