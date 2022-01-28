jmp 1
allocate 3
push 0
offset
+
push 12345
store
push 1
offset
+
push 0
store
push 0
offset
+
load
push 0
gt
jz 55
push 2
offset
+
push 0
offset
+
load
push 10
mod
store
push 0
offset
+
push 0
offset
+
load
push 10
div
store
push 1
offset
+
push 1
offset
+
load
push 10
*
push 2
offset
+
load
+
store
jmp 12
push 1
offset
+
load
writeln
free 3
