%el modelo de voterra lotke se puede escribir como 
%dotx1=x1-x1*x2-mux1^2
%dotx2 = x1*x2 -x2 -taux2*dotx1
%encotrar puntos de equilibrio
%linelaizar en torno aqule cuyas dos varibles de estado son distintas de
%cero y mostrar como la estabilidad e inestabilidad de dicho punto depende
%de mu y tau. discutir la posibiidad de la existencia de un ciclo límite

%creamos unas variables simbolicas 
syms x1 x2 s
%y unos parametros mu y tau tambien simbolicos
syms mu tau

%definimos las ecuaciones del sistema
f(1,1) = x1-x1*x2-mu*x1^2
f(2,1) = x1*x2 -x2 -tau* x2 * (x1-x1*x2-mu*x1^2)

%Calculamos el Jacobiano
J = jacobian(f,[x1 x2])
%obtenemos los puntos en que se anulan las ecuaciones de estado, ya que
%dichos puntos son precisamente los puntos de equilibrio
[x10,x20] = solve(f,[x1 x2])
X0 = [x10,x20]
%calculamos ahora resultados para todos los puntos de equilibrio
%encontrados



%buscamos resultados distints de cero,
%j = find(X0(:,1).*X0(:,2)~= 0)
%X0 = X0(j,:)


for i =1:size(X0,1)
    %sustituimos la solucion en la expresion del Jacobiano
    Je = subs(J,{x1,x2},X0(i,:))
    E = eig(Je)
    %calculamos el p carcateristico
    D = det(s*eye(length(X0(i,:))) - Je) %ver que forma tiene mas que nada
    D = collect(D)
end 
% %podriamos dar valores a mu y tau y representar los dos autovalores..
% TAU = [0:0.25:5]
% MU = [0:0.25:5]
% 
% for i = 1:length(TAU)
%     for j = 1: length(MU)
%   for i =1:5%5
%      Er1(i,j) = real(subs(E(1),[mu,tau],[vpa(MU(i)),vpa(TAU(j))]));
%         Er2(i,j) = real(subs(E(2),[mu,tau],[vpa(MU(i)),vpa(TAU(j))]));
%     end
% end
% 
% [TAUM,MUM] = meshgrid(MU,TAU)
% mesh(TAUM,MUM,double(Er1))
% hold on
% mesh(TAUM,MUM,double(Er2))
%fuera de los valores de estabilidad el sistema da problemas... numericos
%y hay que manejar el ode45 con cautela o el tiempo de integracion se vuelve
%terriblemente largo 

mu = 0.5
tau = 0.5
%estable y convergente
for i =1:5%5
    for j = 1:5 %5
        [t,x] = ode45(@(t,x)volterra(t,x,mu,tau),[0 1000],[i;j]);
        plot(i,j,'xr')
        hold on
        plot(x(:,1),x(:,2))
        
    end
end
plot(0,0,'o')
plot(1/mu,0,'x')
plot(1, 1-mu,'^')

figure
%retorno a a Volterra puro
mu = 0.0
tau = 0.0
opts = odeset('Reltol',1e-9,'MaxStep',1e-1);
for i =1:5%5
    for j = 1:5 %5
        [t,x] = ode45(@(t,x)volterra(t,x,mu,tau),[0 1000],[i;j],opts);
        plot(i,j,'xr')
        hold on
        plot(x(:,1),x(:,2))
        
    end
end
plot(0,0,'o')
plot(1/mu,0,'x')
plot(1, 1-mu,'^')
[t,x] = ode45(@(t,x)volterra(t,x,mu,tau),[0 1000],[1.1;1.1],opts);
plot(x(:,1),x(:,2),'+')


%ciclo limite pinto solo un caso de dentro y otro de fuera
figure
mu = 0.1
tau = 0.2
x0=[6;8]
[t,x] = ode45(@(t,x)volterra(t,x,mu,tau),[0 1000],x0);
plot(x0(1),x0(2),'xr')
hold on
plot(x(:,1),x(:,2),'r')

x0=[1;3]
[t,x] = ode45(@(t,x)volterra(t,x,mu,tau),[0 1000],x0);
plot(x0(1),x0(2),'xb')
plot(x(:,1),x(:,2),'b')  
plot(0,0,'o')
plot(1/mu,0,'*')
plot(1, 1-mu,'^')




