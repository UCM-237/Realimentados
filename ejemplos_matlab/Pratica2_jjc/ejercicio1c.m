%Encotrar los puntos singulares para los siguientes sistemas. Linealizar
%las ecuaciones en su entorno y determinar la naturaleza de dichos puntos
%singulares.

%creamos unas variables simbolicas que sirvan para todos los ejemplos
syms x1 x2 s
%a)
%definimos las ecuaciones del sistema
f(1,1) =  x1*(1-x2)
f(2,1) =  x2*(x1-1)

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
%Aqui los tiempos son criticos porque hay soluciones que divergen a toda
%velocidad y hacen el algoritmo inestable...poer eso lo hacemos por
%cuadrantes aprovechando que 0,0 es un punto de silla
options = odeset('Maxstep',1e-3);
for i =0:0.5:3
    for j = 0.001:0.5:3
        [t,x] = ode45(@ej1c,[0 10],[i;j],options);
        plot(x(:,1),x(:,2))
        hold on
    end
end
for i =-3:0.5:0
    for j = 0:0.5:3
        [t,x] = ode45(@ej1c,[0 1],[i;j],options);
        plot(x(:,1),x(:,2))
        hold on
    end
end
for i =-3:0.5:0
    for j = -3:0.5:0
        [t,x] = ode45(@ej1c,[0 0.5],[i;j],options);
        plot(x(:,1),x(:,2))
        hold on
    end
end

%diverge a lo bestia
for i =0:0.5:3
    for j = -3:0.5:0
        [t,x] = ode45(@ej1c,[0 0.3],[i;j],options);
        plot(x(:,1),x(:,2))
        hold on
    end
end



