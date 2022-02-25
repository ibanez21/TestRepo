tspan = [0,2];
x0 = [0,0,0,0,0,0,0,0,0,0,0,0,0];
[t,y] = ode45(@odefun,tspan,x0)
