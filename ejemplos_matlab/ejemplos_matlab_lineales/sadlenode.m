%Bifurcación silla-nodo

mu = 0:0.1:1
x0= -1:0.2:1;

opts = odeset('Reltol',1e-9,'MaxStep',1e-1);
for i =1:length(mu)
    for j=1:length(x0)
        if x0(j) < -sqrt(mu(i))
            
            tiempo = [0,2];
        else
            tiempo = [0 10];
        end
        [t,x] = ode45(@(t,x)sadlenodef(t,x,mu(i)),tiempo,x0(j),opts);
        plot(mu(i)*ones(length(x),1),x,'k')
        hold on
        plot(mu(i),x0(j),'xb')
        plot(mu(i),x(end),'or')
      
    end
end
%mus negativas
x0 =1;
mu = -1:0.2:-0.2;
for i =1:length(mu)
       
        [t,x] = ode45(@(t,x)sadlenodef(t,x,mu(i)),[0 3],x0,opts);
        plot(mu(i)*ones(length(x),1),x,'k')
        hold on
        plot(mu(i),x0,'xb')
        plot(mu(i),x(end),'or')
      
 
end
%axis('equal')
xlabel('\mu')
ylabel('x')


%pintamos la parábola
mu = 0:0.02:1;
xpp =sqrt(mu);
xpm = -sqrt(mu);
plot(mu,xpp,'r')
plot(mu,xpm,'-.r')
axis([-1,1,-2,1])


function xdot = sadlenodef(t,x,mu)
    xdot = mu-x^2;
end