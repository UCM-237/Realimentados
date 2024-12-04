%creamos unas variables simbolicas

syms x1 x2 real %real no es una variable. Sino que define x1 y x2 como
                %variable reales. 
syms s


%definimos las ecuaciones del sistema
f(1,1) =  x2
f(2,1) = -x1 -x2 + x1*x2 
%la función solve obtendra las soluciones de la ecuación f(x1,x2) =(0,0) y
%por tanto los puntos de equilibrio del sistema
[X01 X02] = solve(f,x1,x2)
X0 = [X01, X02]

%Calculamos el Jacobiano
J = jacobian(f,[x1 x2])
%sustituimos en los puntos en que se anulan las ecuaciones de estado, ya que
%dichos puntos son precisamente los puntos de equilibrio. 

%uso un bucle para obtener la matriz del sistema linealizado y los
%autovalores en todos los puntos de equilibrio obtenidos. (en realidad en
%este caso solo esta el x= (0,0)
for i = 1:size(X0,1)
    Je = subs(J,{x1,x2},[X01(i),X02(i)])
    E = double(eig(Je))
    % En algunos casos, sobre todo si el sistema depende de parametros, es
    % más fácil analizar la estabilidad a partir del polinomio carterístico
    % de de la matriz del sistema (Je) y emplear el método de Routh-Hurwitz
    % para estudiar la estabilidad a partir de los coeficientes del
    % polinomio caracteristico.
    C = det(Je - s*eye(size(Je)))
end

%funcion de liapunov para el linealizado,
%En este caso, solo hay un punto de equilibrio que es el origen. Podemos
%obtener una funcion de Lyapunov para el sistema lineal,resolviendo la
%ecuación de lyapunov, obtenemos una función cuadrática V(x) = x'*P*x. 
%Después empleamos dicha función como candidata de Lyapunov para estudiar
%el sistema no lineal
P =lyap(double(Je'),[1 0;0 1])
V = [x1 x2]*P*[x1;x2]
%calculamos el gradiente de la función de liapunov y multiplicamos por f de
%este modo obtnemos la derivada de Lee, El comando simplify, simplifica el
%resultado.
grV = gradient(V)
dotV = simplify(grV'*f)
%por supuesto, estudia si la derivada de Lee, cumple las condiciones del
%teorema de Lyapunov o encontrar el dominio de atracción es algo que matlab
%no puede hacer por nosotros. Hay que usar la cabeza, normal de pensar ;)

%Empleo los métodos ya vistos en otros ejemplos para resolver el sistmea
%numéricamente y representar el diagrama de fases.

%ode45 va a mostrar un warning por pantalla, debido a que hay soluciones
%que divergen. Para evitarlo, anulo los warning
warning('off')
for i =-3:0.5:3
    for j = -3:0.2:3
        [t,x] = ode45(@ej11,[0 10],[i;j]);
        plot(x(:,1),x(:,2))
        hold on
        plot(i,j,'or')
    end
end
axis([-5 5 -5 5])
%recupero los warnings
warning('on')
%funcion f para emplear con ode45
function dotx = ej11(t,x)
dotx(1,1) = x(2,1);
dotx(2,1) = -x(1,1) - x(2,1) + x(1,1)*x(2,1);
end

