function  dwr= gramr(t,t1,A,B)
%esta función permite construir el valor del integrando del grammiano de
%alcanzabilidad para un par A,B y un tiempo final t1,tiempo inicial t0=0
%si creamos un handle f = @(t)gramr(t,t1,A,B) in lo pasamos a la funcion de
%matlab integral, obtenemos el valor de gramiano Wr(t1,0)
dwr = expm(A*(t1-t)*B*B'*expm(A'*(t1-t);
end
