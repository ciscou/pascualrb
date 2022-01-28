jmp 1
allocate 4
push 0
offset
+
push 100
store
push 1
offset
+
push 2
store
push 1
offset
+
load
push 0
offset
+
load
lte
jz 100
push 3
offset
+
push 1
store
push 2
offset
+
push 2
store
push 3
offset
+
load
push 2
offset
+
load
push 1
offset
+
load
push 2
/
lte
and
jz 78
push 1
offset
+
load
push 2
offset
+
load
mod
push 0
eq
jz 67
push 3
offset
+
push 0
store
jmp 67
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
jmp 32
push 3
offset
+
load
jz 89
push 1
offset
+
load
writeln
jmp 89
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
jmp 12
free 4
