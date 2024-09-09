
function [x1,x2,v1,v2,t] = bloques(x10,x20,v10,v20,tf,h,k)
i = 1;
v1(i) = v10;
v2(i) = v20;
x1(i) = x10;
x2(i) = x20;
t(i) = 0;
%ecuaciones completas
%v1= v1 -(k*(x1-1) - k*(x2-x1-1))*h
%v2 = v2 +(k*(x2-x1-1)-k*(x2-2))*h
while t(i)<= tf
    v1(i+1) = v1(i) +(k*x2(i)- 2*k*x1(i))*h;
    v2(i+1) = v2(i) + (3*k+k*x1(i)-2*k*x2(i))*h;
    x1(i+1) = x1(i) + v1(i)*h;
    x2(i+1) = x2(i) + v2(i)*h;
    t(i+1) = t(i) + h;
    i = i+1;
end
% figure(1)
% plot(t,x1)
% hold on
% plot(t,x2)
figure(2)
%Para dibujar los bloques, no es parte del examen
for i = 1:10:length(x1)
    plot(linspace(0,x1(i),30),0.025*ones(1,30),'.k')
    hold on
    plot(linspace(x1(i),x2(i),30),0.025*ones(1,30),'.k')
    plot(linspace(x2(i),3,30),0.025*ones(1,30),'.k')
    rectangle('position',[x1(i)-0.3 0 0.3 0.05],'FaceColor','b')
    rectangle('position',[x2(i)-0.3 0 0.3 0.05],'FaceColor','r')
    axis([0 3 0 0.5])
    drawnow
    hold off
end
