%bifurcación de hopf

%construimos directamente el sistema en polares
%nos creamos un cnjunto de valores iniciales de theta y r
r = [0,0.1,1]
mu = 0.5
theta = 0:pi/3:2*pi-pi/3
opts = odeset('Reltol',1e-9,'MaxStep',1e-1);
for i =1:length(r)
    for j=1:length(theta)
        [t,rt] = ode45(@(t,rt)hopf(t,rt,mu),[0,10],[r(i);theta(j)],opts);
        figure(1)
        plot(rt(:,1).*cos(rt(:,2)),rt(:,1).*sin(rt(:,2)))
        hold on
        plot(r(i)*cos(theta(j)),r(i)*sin(theta(j)),'+')
        figure(2)
        plot3(0.5*ones(size(rt,1),1),rt(:,1).*cos(rt(:,2)),rt(:,1).*sin(rt(:,2)))
        hold on
        plot3(0.5,r(i).*cos(theta(j)),r(i).*sin(theta(j)),'+')
    end
end
figure(1)
axis('equal')
xlabel('x_1')
ylabel('x_2')

r = [0,0.1,1]
mu = -0.3
theta = 0:pi/3:2*pi-pi/3
opts = odeset('Reltol',1e-9,'MaxStep',1e-1);
for i =1:length(r)
    for j=1:length(theta)
        [t,rt] = ode45(@(t,rt)hopf(t,rt,mu),[0,10],[r(i);theta(j)],opts);
        figure(3)
        plot(rt(:,1).*cos(rt(:,2)),rt(:,1).*sin(rt(:,2)))
        hold on
        plot(r(i)*cos(theta(j)),r(i)*sin(theta(j)),'+')
        figure(2)
        plot3(-0.3*ones(size(rt,1),1),rt(:,1).*cos(rt(:,2)),rt(:,1).*sin(rt(:,2)))
        hold on
        plot3(-0.3,r(i).*cos(theta(j)),r(i).*sin(theta(j)),'+')
    end
end
figure(1)
axis('equal')
xlabel('x_1')
ylabel('x_2')
figure(3)
axis('equal')
xlabel('x_1')
ylabel('x_2')
%dibujo del diagrama de bifurcación.
figure(2)
r = 0:0.1:sqrt(0.6)
theta = -pi:pi/10:pi
[rm,thetam] =meshgrid(r,theta)
zm = rm.^2
s = surf(zm,rm.*cos(thetam),rm.*sin(thetam))
s.FaceColor = 'none'
s.EdgeColor = [0.7 0.7 0.7]
plot3([-0.3 0],[0,0],[0,0],'k')
plot3([0 0.7],[0,0],[0,0],'k-.')
 xlabel ('\mu')
 ylabel('x_1')
 zlabel('x_2')
function rtdot = hopf(t,rt,mu)
    rtdot(1,1) = mu*rt(1,1)-rt(1,1)^3;
    rtdot(2,1) = 1;
end