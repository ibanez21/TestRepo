function dxdt = delay_buy(t,x,Z)

%Import coefficients found in main code
filename = 'coeff_forward_buy.txt';
[c]=importdata(filename);


%Delays
cpi_delay=Z(:,1);
inf_delay=Z(:,2);
pe_delay=Z(:,3);
ir_delay=Z(:,4);
NASDAQ_delay=Z(:,5);
rev_delay=Z(:,6);
rd_delay=Z(:,7);
apple_delay=Z(:,8);
gld_delay=Z(:,9);
djia_delay=Z(:,10);
iphone_delay=Z(:,11);
conf_delay=Z(:,12);
buyback_delay=Z(:,13);




dxdt = zeros(13,1);

dxdt(1)  = c(1)*x(2)*x(1); %CPI
dxdt(2)  = c(2)*x(1)+c(3)*ir_delay(4)*x(2)+c(4)*x(2);  %inflation
dxdt(3)  = c(5)*x(2)+c(6)*x(6)+c(7)*x(8)+c(49)*x(13); %P/E ratio
dxdt(4)  = c(8)*dxdt(1)+c(9)*x(2)*ir_delay(4)+c(10)*x(4)+c(11)*x(4)*x(8); %Fed funds rate
dxdt(5)  = c(12)*x(8)+c(13)*x(10)+c(14)*x(4)+c(15)*x(12);%Nasdaq-100
dxdt(6)  = c(16)*x(6)+c(17)*rd_delay(7)+c(18)*x(12)+c(19)*x(11); %Apples Net Income
dxdt(7)  = c(20)*x(7)+c(21)*x(6)+c(22)*x(11);  %R&D
dxdt(8)  = c(23)*x(6)+c(24)*dxdt(5)+c(25)*x(3)+c(26)*x(4)*x(8)+c(27)*x(8)+c(47)*dxdt(10)+c(48)*dxdt(13); %Apple
dxdt(9)  = c(28)*x(10)+c(29)*x(12)+c(30)*x(2)+c(31)*x(9); %GLD
dxdt(10) = c(32)*x(4)+c(33)*x(1)+c(34)*x(5)+c(35)*x(12)+c(36)*x(10); %S&P 500
dxdt(11) = c(37)*x(11)+c(38)*rd_delay(7)+c(39)*ir_delay(4)*x(11); %iPhone Revenue
dxdt(12) = c(40)*dxdt(10)+c(41)*x(4)+c(42)*x(1)+c(43)*x(9);  %CCI
dxdt(13) = c(44)*x(10)+c(45)*x(6)+c(46)*x(7); %Buybacks

end
