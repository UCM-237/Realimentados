function dotx = rossler(t,x,param)
%a = param(1)
%b = param(2)
%c = param(3)
dotx(1,1) = x(1,1) -x(1,1)*x(2,1) -x(3,1);
dotx(2,1) = x(1,1)^2 -param(1)*x(2,1);
dotx(3,1) = param(2)*x(1,1) -param(3)*x(3,1);