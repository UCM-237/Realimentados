function eliptica
x10 = -2:1:2;
x20 = x10;

mu = [2 1];
for i =1:length(x10)
    for j =1:length(x20)
        [t,x]=ode45(@(t,x)elip(t,x,mu),[0 10],[x10(i);x20(j)]);
        plot(x(:,1),x(:,2))
        hold on
        plot(x10(i),x20(j),'o')
    end
end
end
function xdot = elip(t,x,mu)
xdot(1,1) = mu(1)*x(2,1);
xdot(2,1) =-mu(2)*x(1,1)-x(2,1)*(x(1,1)^2+4*x(2,1)^2-4)
end