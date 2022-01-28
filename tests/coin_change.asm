jmp 45
allocate 3
push 1
offset
+
swap
store
push 0
offset
+
swap
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
jz 31
push 2
offset
+
push 0
offset
+
load
store
jmp 39
push 2
offset
+
push 1
offset
+
load
store
push 2
offset
+
load
free 3
ret
allocate 133
push 132
offset
+
push 123
store
push 0
offset
+
push 0
+
push 1
store
push 0
offset
+
push 1
+
push 4
store
push 0
offset
+
push 2
+
push 7
store
push 0
offset
+
push 3
+
push 11
store
push 130
offset
+
push 0
store
push 130
offset
+
load
push 132
offset
+
load
lte
jz 115
push 5
offset
+
push 130
offset
+
load
+
push 999999
store
push 130
offset
+
push 130
offset
+
load
push 1
+
store
jmp 84
push 5
offset
+
push 0
+
push 0
store
push 130
offset
+
push 1
store
push 130
offset
+
load
push 132
offset
+
load
lte
jz 227
push 129
offset
+
push 0
store
push 129
offset
+
load
push 4
lt
jz 216
push 131
offset
+
push 130
offset
+
load
push 0
offset
+
push 129
offset
+
load
+
load
-
store
push 131
offset
+
load
push 0
gte
jz 205
push 5
offset
+
push 130
offset
+
load
+
push 5
offset
+
push 130
offset
+
load
+
load
push 1
push 5
offset
+
push 131
offset
+
load
+
load
+
jsr 1
store
jmp 205
push 129
offset
+
push 129
offset
+
load
push 1
+
store
jmp 142
push 130
offset
+
push 130
offset
+
load
push 1
+
store
jmp 127
push 5
offset
+
push 132
offset
+
load
+
load
writeln
free 133
