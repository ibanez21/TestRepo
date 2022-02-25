function dxdt = dde_delay(t,x)
  filename = 'coeff_forward_buy.txt';
  [c] = importdata(filename);

  %cpi_delay = Z(:,1);
  %inf_delay = Z(:,2);
  %ffr_delay = Z(:,3);
  %un_rate_delay = Z(:,4);
  %gdp_delay = Z(:,5);
  %ten_yr_delay = Z(:,6);

  dxdt = zeros(6,1);

  dxdt(1) = c(1)*x(1)*x(2);
  dxdt(2) = c(2)*x(1) + c(3)*x(3)*x(2) + c(4)*x(2);
  dxdt(3) = c(5)*dxdt(1) + c(6)*x(3) + c(7)*x(5) + c(8)*x(2)*x(3);
  dxdt(4) = c(9)*x(4) + c(10)*x(5) + c(11)*x(3) + c(12)*x(4)*x(6);
  dxdt(5) = c(13)*x(5) + c(14)*x(6) + c(15)*x(4) + c(16)*x(5)*x(6);
  dxdt(6) = c(17)*x(6) + c(18)*x(5)*x(6) + c(19)*x(3) + c(20)*x(4)*x(6);

end
