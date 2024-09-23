%Bifurcación silla-nodo

mu = -1:0.2:1;
x0= -1:0.2:1;

opts = odeset('Reltol',1e-9,'MaxStep',1e-1);
for i =1:length(mu)
   for j = 1:length(x0)         
        tiempo = [0 10];
        
        [t,x] = ode45(@(t,x)pitch(t,x,mu(i)),tiempo,x0(j),opts);
        plot(mu(i)*ones(length(x),1),x,'k')
        hold on
        plot(mu(i),x0(j),'xb')
        plot(mu(i),x(end),'or')
      
    end
end
%mus negativas
% x0 =1;
% mu = -1:0.2:-0.2;
% for i =1:length(mu)
%        
%         [t,x] = ode45(@(t,x)trans(t,x,mu(i)),[0 3],x0,opts);
%         plot(mu(i)*ones(length(x),1),x,'k')
%         hold on
%         plot(mu(i),x0,'xb')
%         plot(mu(i),x(end),'or')
%       
%  
% end
% %axis('equal')
xlabel('\mu')
ylabel('x')


%pintamos la recta
mu = 0:0.02:1;
xpp =sqrt(mu);
plot(mu,xpp,'r')
xpp =-sqrt(mu);
plot(mu,xpp,'r')
xpm = zeros(length(mu),1);
plot(mu,xpm,'-.r')

mu = 0:-0.1:-1;
xpp =mu;
xpm = zeros(length(mu),1);
%plot(mu,xpp,'-.r')
plot(mu,xpm,'r')
axis([-1,1,-1,1])


function xdot = pitch(t,x,mu)
    xdot = mu*x-x^3;
end