%problema del pendulo invertido
%la ecuacion completa seria:
%(M+n)*x''(t) + m*L*theta''(t)*cos(theta(t))+
%- m*L*[theta'(t)]^2*sin(theta(t)) = f(t)
%m*x''(t)*cos(theta(t)) + m*L*theta''(t) - m*g*sin(theta(t)) = 0
% x'' es la aceleración del carro
%x' su velocidad
%theta'' es la aceleración angular del pédulo
%theta' es la velocidad angular
%theta es el angulo que forma con la vertical

%definicion de la variables de estados
%x(1) angulo del pendulo theta
%x(2) posicion del carro x
%x(3) velocidad angular de pendulo theta'
%x(4) velocidad lineal del carro

%parametros del problema 
close all
clear all
M = 1; %masa del carro
m = 0.1; %masa del pendulo
L = 0.5; %longitud del pendulo
g = 10; % aceleracion de la gravedad

%Si linearizamos en torno a theta = 0, theta' = 0: cos(theta) = 1,
% sin(theta) = theta, y theta'^2 * sin(theta) = 0 y despejamos 

A = [0 0 1 0; 0 0 0 1; g*(M+m)/(L*M) 0 0 0; -m*g/M 0 0 0];
B = [0;0;-1/(M*L);1/M];
C = [1 0  0 0;0 1 0 0];
D = [0;0];
bandb = ss(A,B,C,D)
%podemos comprobar que el sistema es asquerosamente inestable
lambda = eig(A)
initial(bandb,[1.2;1;0;0])

%podemos realimentarlo a ver si mejora...
%lo primero que hacemos como siempre es comprobar si es controlable
dim = rank(ctrb(A,B))
%como resulta que si, podemos emplear acker¿?
K = acker(A,B,[-1 -2+0.5j -2-0.5j -3])
%polos con linear quadratic regulator
%queremos una matriz Q que penalice el crecimiento de 
 Q = eye(4)
 Q(1,1) = 100; %penalizamos el crecimiento de x1,
 R = 1
 [K,S,E] = lqr(A,B,Q,R)
% y ahora lo que hacemos es realimentar los estados,

%Calculamos la matriz ampliada,

Are = A-B*K
% el resto de matrices las podemos dejar como estan

bandbre = ss(Are,B,C,D)
[y,t,x]=initial(bandbre,[1.2;1;1;1]);
plot(t,x)
%supongamos ahora que le damos una entrada en escalon para controlar la
%posicion del carro
figure()
step(bandbre)
%evidentemente lo controla pero se para donde le da la gana...
%podemos añadir un poco de control feedforward calculamos F
%ojo nuestra salida realmente manejable es la posicion del carro. El
%pendulo solo puede estabilizarse en cero, en cualquier otro angulo seria
%necesario acelera el bloque sin parar...
F = inv(C(2,:)*inv(B*K-A)*B)
bandreF = ss(Are,B*F,C,D);
figure()
step(bandreF)
t = 0:0.01:25
%podemos simular una condicion inicial fuera del equilibrio usando lsim
u = [ones(length(t),1)];  
[y,t,x]= lsim(bandreF,u,t,[1.2;0;0;0]);
figure()
plot(t,x)
%emplear el resultado para controlar el sistema original no lineal
%el sistema se ha implementado el la función fequ


%introducimos realimentación integral
%vamos a modelarla como un polo mas es decir no vaamos a emplear el lugar de
%las raices
%contruimos la matriz ampliada
Amp = [A zeros(4,1); C(2,:) 0]
Bamp =[B;-1];
%vamos a comprobar que la cosa es controlable
dim = rank(ctrb(Amp,Bamp))
%tambien es controlable porque la vida es asi por tanto le encajamos unos
%polos nuevos
Ka = acker(Amp,Bamp,[E' -10])
%construimos la matrz de estados con la realimentación calculada
%%no tiene sentido realmente recalcular un F para estos polos...
%asi que pasando.. Fi = 10
Fi = 1
Amp = [A-B*Ka(1,1:4) -B*Ka(1,5); C(2,:) 0] 
%podemos ahora construir el sistema completo con su integrador y todo
bandint = ss(Amp,[B*Fi;-1],[C [0;0]],D)
figure()
step(bandint)
[x,t] = step(bandint)

parametros = [g m M L];

%pintabloque(x,L)

%juntamos los parametros en unico vector para pasarlo a la funcion p
[t,x] = ode45(@(t,x)fequ(t,x,K,parametros),[0 10],[1.2;0;0;0]);

figure()
hold on
subplot(2,1,1)
hold on
plot(t,x(:,1))
subplot(2,1,2)
hold on
plot(t,x(:,2))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculamos ahora un estimador de estados a ver que pasa con la masa
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%lo primero que hay que comprobar es si nuestro bonito sistema es
%observable. Elegimos como unica variable de salida la posicion del carro a
%puesto que ademas el la única sobre la que de verdad tenemos una accion
%directa..

dimo = rank(obsv(A,C(2,:)))
%o welch ein jubel! Es observable debemos elegir unos polos para el observador

L = place(A',C(2,:)',[-10,-12,-13,-14])'

%podemos comprobar que pasa si montamos un sistema con realimentacion de
%estados estimados.

Aest = [A -B*K 
        L*C(2,:) A-B*K-L*C(2,:)]
    
Best = [B;B]

Cest = [C zeros(size(C))] 

Dest = 0

sysest =ss(Aest,Best,Cest,Dest)

figure()
[y,t,x]=initial(sysest,[0.5 0 0 0 0 0 0 0])
plot(t,x)

Aesti = [A -B*Ka(1,1:4) -B*Ka(1,5)
        L*C(2,:) A-B*Ka(1,1:4)-L*C(2,:) -B*Ka(1,5)
        C(2,:) zeros(1,4) 0] 
    
Besti = [B;B;-1]

Cesti = [C zeros(size(C)) [0;0]] 

Desti = [0;0]
sysesti =ss(Aesti,Besti,Cesti,Desti)
[y,t,x]=step(sysesti)
figure()
plot(t,x)
