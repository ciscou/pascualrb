jmp 1
allocate 3
push 0
offset
+
load
push 2
lt
jz 22
push 0
offset
+
load
push 0
eq
jz 19
push 1
writeln
jmp 21
push 2
writeln
jmp 24
push 3
writeln
push 0
offset
+
load
push 0
eq
push 1
offset
+
load
push 0
eq
push 2
offset
+
load
push 0
gt
not
and
and
jz 49
push 42
writeln
jmp 49
free 3
