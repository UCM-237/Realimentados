"""
Calculo de sistemas lineales: estables, inestables, asintoticamente
estables, etc. Version en Python de lineal2.m (numpy + scipy + matplotlib).
"""

import numpy as np
from scipy.integrate import solve_ivp
import matplotlib.pyplot as plt

xm = np.arange(-1, 1 + 0.2, 0.2)   # equivalente a -1:0.2:1
t_span = (0, 1)

real_menos = np.array([[-3, -2], [1, 0]])
cpl_mas = np.array([[-3, -2], [1, 0]])
cpl_menos = np.array([[-1, -3], [4, -2]])
real_mas = np.array([[3, -2], [1, 0]])
silla = np.array([[0, 1], [1, 0]])
imaginario = np.array([[-1, -3], [4, 1]])
repetidosp = np.array([[0, 1], [-1, 2]])
repetidosm = np.array([[-2, 1], [-1, 0]])
uncero = np.array([[-3, 1], [3, -1]])
unceroi = np.array([[1, 1], [1, 1]])
iguales = np.array([[-1, 0], [0, -1]])

theta = np.pi / 4
R = np.array([[np.cos(theta), -np.sin(theta)],
              [np.sin(theta), np.cos(theta)]])
A_ceros = np.array([[0, 0], [1, 0]])
#roto la matriz A_ceros 45 grados 
# Para que no quede alineada con los ejes coordenados
ceros = R @ A_ceros @ np.linalg.inv(R)     
circular = np.array([[0, -3.316624790355399], [3.316624790355399, 0]])


A = imaginario  # Cambiar por la matriz que se quiera analizar    

# eig devuelve (autovalores, autovectores); en MATLAB era [l,v] = eig(A)
# -> V (autovectores), D (autovalores en diagonal). Aqui numpy ya nos da
# los autovalores directamente como vector.
lambda_, V = np.linalg.eig(A)


def piltrafilla(t, x, A):
    return A @ x


def formatea_autovalor(val):
    """Formatea un autovalor (real o complejo) para el titulo."""
    if np.isclose(val.imag, 0):
        return f"{val.real:.3g}"
    signo = "+" if val.imag >= 0 else "-"
    return f"{val.real:.3g} {signo} {abs(val.imag):.3g}i"


fig, ax = plt.subplots()

n_puntos_dibujo = 200
t_dense = np.linspace(t_span[0], t_span[1], n_puntos_dibujo)

for xi in xm:
    for xj in xm:
        x0 = np.array([xi, xj])

        sol = solve_ivp(piltrafilla, t_span, x0, args=(A,), dense_output=True)
        x = sol.sol(t_dense)  # shape (2, n_puntos_dibujo), curva mas suave

        ax.plot(x0[0], x0[1], '.', color='C0')
        ax.plot(x[0, :], x[1, :], color='C1')
        ax.plot(x[0, -1], x[1, -1], 'x', color='C2')

titulo = (r"$\lambda_1 = " + formatea_autovalor(lambda_[0]) +
          r",\ \lambda_2 = " + formatea_autovalor(lambda_[1]) + r"$")
ax.set_title(titulo)
ax.set_xlabel(r"$x_1$")
ax.set_ylabel(r"$x_2$")

plt.show()
