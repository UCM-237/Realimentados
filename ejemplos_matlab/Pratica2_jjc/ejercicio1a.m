%Encotrar los puntos singulares para los siguientes sistemas. Linealizar
%las ecuaciones en su entorno y determinar la naturaleza de dichos puntos
%singulares.

%creamos unas variables simbolicas que sirvan para todos los ejemplos
syms x1 x2 s
%a)
%definimos las ecuaciones del sistema
f(1,1) = x2
f(2,1) = -x1 + x2*(1 -x2^2)

%Calculamos el Jacobiano
J = jacobian(f,[x1 x2])
%obtenemos los puntos en que se anulan las ecuaciones de estado, ya que
%dichos puntos son precisamente los puntos deequilibrio
[x10,x20] = solve(f,[x1 x2])
X0 = [x10,x20]
%calculamos ahora resultados para todos los puntos de equilibrio
%encontrados
for i =1:size(X0,1)
    %sustituimos la solucion en la expresion del Jacobiano
    Je = subs(J,{x1,x2},X0(i,:))
    E = double(eig(Je))
    %calculamos el p carcateristico
    D = det(s*eye(length(X0)) - Je) %ver que forma tiene mas que nada 
end 

%vamos a pintar las fases del invento
for i =-2:0.5:2
    for j = -2:0.5:2
        [t,x] = ode45(@ej1a,[0 50],[i;j]);
        plot(x(:,1),x(:,2))
        hold on
    end
end


