import numpy as np
from scipy.integrate import odeint, solve_ivp
import matplotlib.pyplot as plt

# function that returns dz/dt
def model1(z,t):
    dxdt = z[0] + 5
    dydt = -z[1] + 3
    dzdt = 0.2*z[2] - 6

    dwdt = [dxdt,dydt,dzdt]
    return dwdt

# initial condition
z0 = [0,0,0]

# time points
t = np.linspace(0,5,27)
t1 = [0,1.33*1e-5,8*1e-5,0.000413,0.0021,0.0104,0.0521,0.1598,0.3137,0.5021,0.7165,0.9506,1.1995,1.4598,1.7286,2.0038,2.2837,2.5673,2.8536,3.1419,3.4318,3.7227,4.0145,4.3069,4.5998,4.8930,5]

# solve ODE
z = odeint(model1,z0,t1)
print(z)
# plot results
plt.plot(t,z[:,0],'b-',label=r'$\frac{dx}{dt}=3 \; \exp(-t)$')
plt.plot(t,z[:,1],'r--',label=r'$\frac{dy}{dt}=-y+3$')
plt.plot(t,z[:,2],'g-')
plt.ylabel('response')
plt.xlabel('time')
plt.legend(loc='best')
plt.show()
