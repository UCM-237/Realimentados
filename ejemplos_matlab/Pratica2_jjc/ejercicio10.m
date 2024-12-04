syms L11 L12 L22 real
syms a b real

A = [0 1; -b -a]
L = [L11 L12;L12 L22]
liapu = L*A + A'*L

coef = [0 -2*b 0; 1 -a -b; 0 2 -2*a]
ind = [-1;0;-1]
inco = coef\ind

L =[inco(1,1) inco(2,1);inco(2,1) inco(3,1)]

auto = eig(L)
traza =trace(L)
dl =det(L)
