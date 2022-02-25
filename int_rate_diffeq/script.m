% Import data
clc
k = 7;
v = 210;
lags=[1,1,1,1,1,1];

cpi = csvread('CPI_2000.csv',1,1);
inf = csvread('INF_2000.csv',1,1);
ffr = csvread('FFR_2000.csv',1,1);
un_rate = csvread('UNRATE_2000.csv',1,1);
gdp = csvread('GDP_2000.csv',1,1);
ten_yr = csvread('DGS10.csv',1,1);


% Interpolate data to match length of longest variable, the ten yr

days = 1:length(ten_yr);

cpi_nz = cpi(cpi ~= 0);
cpi_index = find(cpi ~= 0);
daily_cpi = interp1(cpi_index, cpi_nz, days, 'linear');

inf_nz = inf(inf ~= 0);
inf_index = find(inf ~= 0);
daily_inf = interp1(inf_index, inf_nz, days, 'linear');

ffr_nz = ffr(ffr ~= 0);
ffr_index = find(ffr ~= 0);
daily_ffr = interp1(ffr_index, ffr_nz, days, 'linear');

un_rate_nz = un_rate(un_rate ~= 0);
un_rate_index = find(un_rate ~= 0);
daily_un_rate = interp1(un_rate_index, un_rate_nz, days, 'linear');

gdp_nz = gdp(gdp ~= 0);
gdp_index = find(gdp ~= 0);
daily_gdp = interp1(gdp_index, gdp_nz, days, 'linear');

daily_ten_yr = reshape(ten_yr,1,length(ten_yr));


% Solve for coefficients of Diff Eq system

inf_int = zeros(1,k);
inf_diff = zeros(1,k);
inf_coeff = zeros(3,k);
cpi_int = zeros(1,k);
cpi_diff = zeros(1,k);
cpi_coeff = zeros(1,k);
ffr_int = zeros(1,k);
ffr_diff = zeros(1,k);
ffr_coeff = zeros(4,k);
un_rate_int = zeros(1,k);
un_rate_diff = zeros(1,k);
un_rate_coeff = zeros(4,k);
gdp_int = zeros(1,k);
gdp_diff = zeros(1,k);
gdp_coeff = zeros(4,k);
ten_yr_int = zeros(1,k);
ten_yr_diff = zeros(1,k);
ten_yr_coeff = zeros(4,k);

for i = 1:k
  cpi_int(i) = trapz(daily_cpi(((i-1)*30)+1 : i*30));
  cpi_diff(i) = daily_cpi(i*30) - daily_cpi(((i-1)*30)+1);
  inf_int(i) = trapz(daily_inf(((i-1)*30)+1 : i*30));
  inf_diff(i) = daily_inf(i*30) - daily_inf(((i-1)*30)+1);
  ffr_int(i) = trapz(daily_ffr(((i-1)*30)+1 : i*30));
  ffr_diff(i) = daily_cpi(i*30) - daily_cpi(((i-1)*30)+1);
  un_rate_int(i) = trapz(daily_un_rate(((i-1)*30)+1 : i*30));
  un_rate_diff(i) = daily_un_rate(i*30) - daily_un_rate(((i-1)*30)+1);
  gdp_int(i) = trapz(daily_gdp(((i-1)*30)+1 : i*30));
  gdp_diff(i) = daily_gdp(i*30) - daily_gdp(((i-1)*30)+1);
  ten_yr_int(i) = trapz(daily_ten_yr(((i-1)*30)+1 : i*30));
  ten_yr_diff(i) = daily_ten_yr(i*30) - daily_ten_yr(((i-1)*30)+1);
end

for i = 1:k
  cpi_coeff(1,i) = trapz(daily_cpi(((i-1)*30)+1 : i*30).*daily_inf(((i-1)*30)+1 : i*30));

  inf_coeff(1,i) = cpi_diff(i);
  inf_coeff(2,i) = trapz(daily_inf(((i-1)*30)+1 : i*30).*daily_ffr(((i-1)*30)+1: i*30));
  inf_coeff(3,i) = inf_int(i);

  ffr_coeff(1,i) = inf_int(i);
  ffr_coeff(2,i) = ffr_diff(i);
  ffr_coeff(3,i) = un_rate_diff(i);
  ffr_coeff(4,i) = trapz(daily_ffr(((i-1)*30)+1 : i*30).*daily_inf(((i-1)*30)+1 : i*30));

  un_rate_coeff(1,i) = un_rate_diff(i);
  un_rate_coeff(2,i) = gdp_diff(i);
  un_rate_coeff(3,i) = ffr_diff(i);
  un_rate_coeff(4,i) = trapz(daily_ten_yr(((i-1)*30)+1 : i*30).*daily_un_rate(((i-1)*30)+1 : i*30));

  gdp_coeff(1,i) = gdp_diff(i);
  gdp_coeff(2,i) = ten_yr_diff(i);
  gdp_coeff(3,i) = un_rate_diff(i);
  gdp_coeff(4,i) = trapz(daily_gdp(((i-1)*30)+1 : i*30).*daily_ten_yr(((i-1)*30)+1 : i*30));

  ten_yr_coeff(1,i) = ten_yr_diff(i);
  ten_yr_coeff(2,i) = trapz(daily_gdp(((i-1)*30)+1 : i*30).*daily_ten_yr(((i-1)*30)+1 : i*30));
  ten_yr_coeff(3,i) = ffr_diff(i);
  ten_yr_coeff(4,i) = trapz(daily_ten_yr(((i-1)*30)+1 : i*30).*daily_un_rate(((i-1)*30)+1 : i*30));

end

% Collect coefficients and save to text file

c1 = cpi_coeff'\cpi_diff';
c2 = inf_coeff'\inf_diff';
c3 = ffr_coeff'\ffr_diff';
c4 = un_rate_coeff'\un_rate_diff';
c5 = gdp_coeff'\gdp_diff';
c6 = ten_yr_coeff'\ten_yr_diff';

c = [c1;c2;c3;c4;c5;c6];
fid = fopen('coeff_forward_buy.txt','wt');  %'wt' for writing in text mode
fprintf(fid,'%f\n',c);
fclose(fid);

% Initial conditions

x0(1) = daily_cpi(30*k);
x0(2) = daily_inf(30*k);
x0(3) = daily_ffr(30*k);
x0(4) = daily_un_rate(30*k);
x0(5) = daily_gdp(30*k);
x0(6) = daily_ten_yr(30*k);


% Solve DDE System

TYR = daily_ten_yr(30*k : (k+1)*30);
time = linspace(30*k, (k+1)*30, length(TYR));
tspan = [30*k, (k+1)*30];
sol = ode15s(@dde_delay, tspan, x0);
y = interp1(sol.x, sol.y(6,:), time, 'linear');
derivative = interp1(sol.x, sol.yp(6,:), time, 'linear');
