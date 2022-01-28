jmp 1
allocate 3
push 0
offset
+
push 3
push 4
*
push 6
push 2
/
+
store
push 1
offset
+
push 420
push -1
*
push 10
/
push 3
push 4
*
+
store
push 0
offset
+
load
push 1
offset
+
load
lt
jz 42
push 2
offset
+
push 1
store
jmp 47
push 2
offset
+
push 0
store
free 3
