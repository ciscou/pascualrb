jmp 1
allocate 2
push 1
offset
+
push 100
store
push 0
offset
+
push 1
store
push 0
offset
+
load
push 1
offset
+
load
lte
jz 80
push 0
offset
+
load
push 15
mod
push 0
eq
jz 36
push 15
push -1
*
writeln
jmp 69
push 0
offset
+
load
push 3
mod
push 0
eq
jz 50
push 3
push -1
*
writeln
jmp 69
push 0
offset
+
load
push 5
mod
push 0
eq
jz 64
push 5
push -1
*
writeln
jmp 69
push 0
offset
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
jmp 12
free 2
