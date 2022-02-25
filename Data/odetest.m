function dxdt = odetest(t,x)
  dxdt = zeros(13,1);

  dxdt(1)  = x(2)*x(1); %CPI
  dxdt(2)  = dxdt(1)+x(2)+x(2);  %inflation
  dxdt(3)  = x(2)+x(6)+x(8)+x(13); %P/E ratio
  dxdt(4)  = dxdt(1)+x(2)+x(4)+x(4)*x(8); %Fed funds rate
  dxdt(5)  = x(8)+x(10)+x(4)+x(12);%Nasdaq-100
  dxdt(6)  = x(6)+x(12)+x(11); %Apples Net Income
  dxdt(7)  = x(7)+x(6)+x(11);  %R&D
  dxdt(8)  = x(6)+dxdt(5)+x(3)+x(4)*x(8)+x(8)+dxdt(10)+dxdt(13); %Apple
  dxdt(9)  = x(10)+x(12)+x(2)+x(9); %GLD
  dxdt(10) = x(4)+x(1)+x(5)+x(12)+x(10); %S&P 500
  dxdt(11) = x(11)+x(11); %iPhone Revenue
  dxdt(12) = dxdt(10)+x(4)+x(1)+x(9);  %CCI
  dxdt(13) = x(10)+x(6)+x(7); %Buybacks
end
