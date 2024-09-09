clear all
close all
%script para resolver los ejercicios uno y dos
mu = 1 %coeficiente de rozamiento 
k=3 %constante de los resortes

%d1 desplazazamiento bloque 1 bloque 1
%x2 desplazamiento  bloque 2
%x3 velocidad bloque 1
%x4 velocidad bloque 2
 
A=[0 0 1 0
   0 0 0 1
   -2*k k -mu 0
   k -2*k 0 -mu]
B=[0 0 1 0]'
C = [0 1 0 0]
%Controlabilidad
co =ctrb(A,B)
rco=rank(co)
%observabilidad
ob = obsv(A,C)
rob=rank(ob)
%polos en lazo abierto
[avec,lambda]=eig(A)
%supongamos que resolvemos para el sistema diagonal
AD = lambda
BD = avec^-1*B
CD = C*avec
sysd = ss(AD,BD,CD,0)
%calculamos para [1 1 0 0]
[y,t,xd]=initial(sysd,[1,1,0,0]',10);
%transformamos los resultados al sistema original
x = (avec*xd')';
% subplot(2,1,1)
% plot(t,x(:,1:2))
% subplot(2,1,2)
% plot(t,x(:,3:4))
plot(t,x)
%calculamos la condicion inicial en el sistema original para hacernos una
%idea
x0=avec*[1 1 0 0]'
x02 = [x0(2);x0(1);x0(3);x0(4)]
% x01=avec*[1 0 0 0]'
% x02= avec*[0 1 0 0]'

sys = ss(A,B,C,0)
[y2,t2,x2] = initial(sys,x02,10)
hold on
plot(t2,x2)
%repetimos el calculo para [0 0 1 1]
%resolvemos para el sistema diagonal
[y,t,xd]=initial(sysd,[0 0 1 1]',10);
%transformamos los resultados al sistema original
x = (avec*xd')';
figure()
subplot(2,1,1)
plot(t,x(:,1:2))
subplot(2,1,2)
plot(t,x(:,3:4))

%initial para probar una c inicial arbitraria arbitraria
[y,t,x]=initial(sys,[-1,-0.5,0,0]',10);
figure()
subplot(2,1,1)
plot(t,x(:,1:2))
subplot(2,1,2)
plot(t,x(:,3:4))

% figure()
% [y,t,x]=step(sys,10)
% subplot(2,1,1)
% plot(t,x(:,1:2))
% subplot(2,1,2)
% plot(t,x(:,3:4))
% pause
%Los polos del sistema original son complejos conjugados, podemos emepzar
%por hacerlos reales: eje 1 1 2 2
k = acker(A,B,[-1 -1 -2 -2])
%construimos el sistema realimentado
sysr = ss(A-B*k,B,C,0)
figure()
[y,t,x]=step(sysr,10);
subplot(2,1,1)
plot(t,x(:,1:2))
subplot(2,1,2)
plot(t,x(:,3:4))

%calculamos un F para llevar el sistema a su sitio
F = (C*(-A+B*k)^-1*B)^-1
%añadimos accion directa
%redefinimos el sistema
figure()
sysrf = ss(A-B*k,B*F,C,0)
[y,t,x]=step(sysrf,10);
subplot(2,1,1)
plot(t,x(:,1:2))
subplot(2,1,2)
plot(t,x(:,3:4))

%vamos a añadir control integral
%en primer lugar calculamos el sistema ampliado
Aamp = [A zeros(4,1)
        C  0]
Bamp = [B; 0]
Camp = [C 0]
D = 0
% recalculamos ahora la posición de los polos añadiendo 1 a la izquierda de
% los anteriores pero conservando la posición de los que ya tenemos
kamp = acker(Aamp,Bamp,[-1 -1 -2 -2 -10])

%recosntruimos el sistema
A_int = [A-B*kamp(1:4)  -B*kamp(5)
         C                0]
B_int = [B*F;-1] %suponemos feedforward unitario
C_int = Camp
D = 0
sys_int =ss(A_int,B_int,C_int,D)
%figure()
[yi,ti,xi]=step(sys_int,10);
subplot(2,1,1)
hold on
plot(ti,xi(:,1:2))
subplot(2,1,2)
hold on
plot(ti,xi(:,3:4))

%estimador de estados
%debemos calcular ahora unos polos para el observador
L = acker(A',C',[-5 -5 -6 -6])'
%reconstruimos el sistema incluyendo el observador. Incluimos ya todos los
%valores calculado en las secciones anteriores. El principio de separación
%hace que no tengamos que recalcular nada más
A_obs = [A, -B*kamp(1:4), -B*kamp(5)
         L*C, A-B*kamp(1:4)-L*C,-B*kamp(5)
         C, zeros(1,5)]
F = 0 %ojo estoy quitando aqui la accione feedforward         
B_obs = [B*F;B*F;-1]
C_obs = [C zeros(1,5)]
sys_obs = ss(A_obs,B_obs,C_obs,D)
%Uso lsim para combinar escalon con condiciones iniciales
t=0:0.01:15;
step = ones(length(t),1);
[y,t,x]=lsim(sys_obs,step,t,[0.5,-1,0,0,0,0,0,0,0]);
figure()
subplot(2,1,1)
hold on
plot(t,x(:,[1 2 5 6]))
subplot(2,1,2)
hold on
plot(t,x(:,[3 4 7 8]))

%Para dibujar los bloques, no es parte del examen
%pongo arbitrariamente la posición de reposo de los bloques en 2 y 5
x1 = x(:,1)+3
x2 = x(:,2)+6
figure()
for i = 1:length(x1)
    plot(linspace(0,x1(i),30),0.025*ones(1,30),'.k')
    hold on
    plot(linspace(x1(i),x2(i),30),0.025*ones(1,30),'.k')
    plot(linspace(x2(i),9,30),0.025*ones(1,30),'.k')
    rectangle('position',[x1(i)-0.3 0 0.6 0.05],'FaceColor','b')
    rectangle('position',[x2(i)-0.3 0 0.6 0.05],'FaceColor','r')
    axis([0 9 0 0.5])
    drawnow
    hold off
end

