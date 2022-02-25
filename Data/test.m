%location of the first day of every month in old data value file
mo1=[1;32;63;93;124;154;185;216;244;275;305;337;366;397;428;458;489;
    519;550;581;610;641;671;702;732;763;794;824;855;885;916;947;975;
    1006;1036;1067;1097;1128;1159;1189;1220;1250;1281;1312;1340;1371;
    1401;1432;1462;1493;1524;1554;1585;1615;1646;1677;1705;1736;1766;
    1797;1827;1858;1889;1919;1950;1980;2011;2043;2071;2102;2132;2163;
    2193;2224;2255;2285;2316;2346;2377;2408;2436;2467;2497;2528;2558;
    2589;2620;2650;2681;2711;2742;2773;2801;2832;2862;2893;2923;2954;
    2985;3015;3046;3076;3107;3138;3166;3197;3227;3258;3288;3319;3350;
    3380;3411;3441;3472;3503;3532;3563;3593;3624;3654;3685;3716;3746;
    3777;3807;3838;3869;3897;3928;3958;3989;4019;4050;4081;4111;4142;
    4172;4203;4234;4262;4293;4323;4354;4384;4415;4446;4476;4507;4537;
    4568;4599;4627;4658;4688;4719;4749;4780;4811;4841;4872;
    4902;4933];

%location of the first day of every month in new data value file
mo=[1;32;61;92;122;153;183;214;245;275;306;336;367;398;426;457;487;
    518;548;579;610;640;671;701;732;763;791;822;852;883;913;944;975;
    1005;1036;1066;1097;1128;1156;1187;1217;1248;1278;1309;1340;1370;
    1401;1431;1462;1493;1522;1553;1583;1614;1644;1675;1706;1736;1767;
    1797;1828;1859;1887;1918;1948;1979;2009;2040;2071;2101;2132;2162;
    2193;2224;2252;2283;2313;2344;2374;2405;2436;2466;2497;2527;2558;
    2589;2617;2648;2678;2709;2739;2770;2801;2831;2862;2892;2923;2954;
    2983;3014;3044;3075;3105;3136;3167;3197;3228;3258;3289;3320;3348;
    3379;3409;3440;3470;3501;3532;3562;3593;3623;3654;3685;3713;3744;
    3774;3805;3835;3866;3897;3927;3958;3988;4019;4050;4078];

%Randomness and checking for solutions going negative are commented out
%--add accordingly
%for v=240:259

v=290; %months past 07/94 that we want to predict--change this to
       %look at different month's predictions
       %must be >=28 and <= 295
%------------------------------------------
%228 and up-include buybacks in P/E ratio
%240 and up-include buybacks for Apple
%159 and up--include iPhone
%126 and up--include GLD
%This is all accounted for in 'if' loop
%178 singularity for 2 months. If you do 1 month, it's fine
%since Jan. 1, 2011=199--59/92 successful
%-------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

lags=[12,1,1,20,1,12,17,1,1,1,1,1,1]; %delays for each variable x1-x13
                                      %some delays aren't used so they're
                                      %set to 1 (month)
%--------------------------------------------------------------------------
k=7; %number of months of past data used for solving coefficients
l=2; %months shown on plot (how far into the future is predicted)
%--------------------------------------------------------------------------
%Importing data csv files
rev1=csvread('net_income.csv',1,1).*10^9;     %Apple's net income
SandP500=csvread('GSPC.csv',1,1);             %S&P 500
cpi1=csvread('CPI2.csv',1,1);                 %Consumer Price Index
inflation1=csvread('inf.csv',1,1).*0.01;      %inflation rate as decimal
ir1=csvread('EFFR.csv',1,1).*0.01;            %Fed funds rate as as decimal
gld1=csvread('GLD.csv',1,1);                  %SPDR Gold Trust
rd1=csvread('RandD.csv',1,1).*10^9;           %Apple's R&D Spending
pe1=csvread('pe_apple.csv',366,1);            %P/E ratio
NASDAQ=csvread('NASDAQ100.csv',1,1);          %NASDAQ 100 index
AAPL1=csvread('AAPL3.csv',1,1);               %Apple's Stock Price
iphone1=csvread('iphone_rev.csv',1,1).*10^9 ; %iphone revenue
conf1=csvread('cci_oecd.csv',1,1);            %Consumer Confidence Index
buy1=csvread('buyback.csv',1,1).*10^9;        %buybacks

%Local Volatility results imported here
%sigma=csvread('sigma6_29-7_6.csv',0,1);
%sigma2=csvread('sigma8_3_9_21.csv',0,1);
%sigma=csvread('sigma_sept_oct.csv',0,1);
%sigma1=csvread('sigma9_28-11_2.csv',0,1);
%sigma2=csvread('sigma11_9_12_28.csv',0,1);
%sigma=[sigma2;sigma1];

%--------------------------------------------------------------------------

% Linearly Interpolate the Data Down to the Day
%--------------------------------------------------------------------------
iv = 1:mo(end);                           %Interpolation Vector

%Apple Stock Price
AAPL_nz = AAPL1(AAPL1 ~= 0);              % Find Non-Zero Elements
vnz1 = find(AAPL1 ~= 0);                  % Indices Of Non-Zero Elements
AAPL = interp1(vnz1, AAPL_nz, [iv,mo(end)+1], 'linear')';
%Interpolated Apple stock price
%stock prices weren't reported on Jan 1,2008, so we included 12/31/07 price
%and inearly interpolated from there.

%Apple's net income
rev_nz = rev1(rev1 ~= 0);
vnz2 = find(rev1 ~= 0);
rev = interp1(vnz2, rev_nz, iv, 'linear')';

%S&P 500
sp500_nz = SandP500(SandP500 ~= 0);
vnz3 = find(SandP500 ~= 0);
sp500 = interp1(vnz3, sp500_nz, [iv,mo(end)+1], 'linear')';

%Consumer Price Index
cpi_nz = cpi1(cpi1 ~= 0);
vnz4 = find(cpi1 ~= 0);
cpi = interp1(vnz4, cpi_nz, iv, 'linear')';

%Inflation rate
inf_nz = inflation1(inflation1 ~= 0);
vnz5 = find(inflation1 ~= 0);
inflation = interp1(vnz5, inf_nz, iv, 'linear')';

%Fed funds rate
ir_nz = ir1(ir1 ~= 0);
vnz6 = find(ir1 ~= 0);
ir = interp1(vnz6, ir_nz, iv, 'linear')';

%GLD
gld_nz = gld1(gld1 ~= 0);
vnz7 = find(gld1 ~= 0);
gld = interp1(vnz7, gld_nz, [iv, mo(end)+1], 'linear')';

%Apple's R&D Spending
rd_nz = rd1(rd1 ~= 0);
vnz8 = find(rd1 ~= 0);
rd = interp1(vnz8, rd_nz, iv, 'linear')';

%P/E Ratio
pe_nz = pe1(pe1 ~= 0);
vnz9 = find(pe1 ~= 0);
pe = interp1(vnz9, pe_nz, iv, 'linear')';

%NASDAQ 100
NASDAQ100_nz = NASDAQ(NASDAQ ~= 0);
vnz10 = find(NASDAQ ~= 0);
NASDAQ100 = interp1(vnz10, NASDAQ100_nz, [iv,mo(end)+1], 'linear')';

%iPhone Revenue
iphone_nz = iphone1(iphone1 ~= 0);
vnz12 = find(iphone1 ~= 0);
iphone = interp1(vnz12, iphone_nz, iv, 'linear')';

%Confidence Index
conf_nz = conf1(conf1 ~= 0);
vnz13 = find(conf1 ~= 0);
conf = interp1(vnz13, conf_nz, iv, 'linear')';

%Buybacks
buy1(1:1736)=zeros(1,1736);
buy_nz = buy1(buy1 ~= 0);
vnz17 = find(buy1 ~= 0);
buyback = interp1(vnz17, buy_nz, iv, 'linear')';
buyback(1736:1829)=linspace(0,buyback(1828),94);
buyback(1:1736)=zeros(1736,1); %Set buybacks before October 2012 equal to 0
                               %without this MATLAB uses NaN


%Make all data vectors the same length--some data was interpolated starting
%on December 1,2007, so now we account for that and start all vectors on
%January 1, 2008
rev=rev(1:mo(end));
rd=rd(1:mo(end));
iphone=iphone(1:mo(end));
conf=conf(1:mo(end));
NASDAQ100=NASDAQ100(2:mo(end)+1);
AAPL=AAPL(2:mo(end)+1);
pe=pe(1:mo(end));
gld=gld(1:mo(end)+1);
ir=ir(1:mo(end));
inflation=inflation(1:mo(end));
cpi=cpi(1:mo(end));
sp500=sp500(2:mo(end)+1);
buyback=buyback(1:mo(end));
%--------------------------------------------------------------------------

%Complete the same process with the older data files
%--------------------------------------------------------------------------
rev_old=csvread('old_netincome.csv',1,1).*10^6;   %Apple's Net Income
sp500_old=csvread('old_SP500.csv',1,1);           %S&P 500
cpi_old=csvread('old_cpi.csv',1,1);               %Consumer Price Index
inf_old=csvread('old_inf.csv',1,1).*0.01;         %inflation as decimal
ir_old=csvread('old_ir.csv',1,1).*0.01;           %Fed funds as decimal
gld_old=csvread('old_gld.csv',1,1);               %GLD
rd_old=csvread('old_rd.csv',1,1).*10^6;           %Apple's R&D Spending
nas_old=csvread('old_nasdaq.csv',1,1);            %NASDAQ 100 Index
AAPL_old=csvread('old_apple.csv',1,1);            %Apple's Stock Price
iphone_old=csvread('old_iphone.csv',1,1).*10^6 ;  %iPhone Revenue
conf_old=csvread('old_cci.csv',1,1);              %CCI
buyback_old=zeros(mo1(end),1);                    %Apple didn't have any
                                                  %buybacks prior to 2008
                                                  %so this variable is 0
eps_old=csvread('old_eps.csv',1,1);               %Apple's EPS

%------- Linearly Interpolate the Old Data--------------------------------

%Apple's Stock Price
iv1 = 1:mo1(end);                        %Interpolation Vector
AAPL_onz = AAPL_old(AAPL_old ~= 0);      %Non-Zero Elements
vnz1_old = find(AAPL_old ~= 0);          %Indices Of Non-Zero Elements
AAPL_old = interp1(vnz1_old, AAPL_onz, 1:mo1(end)-1, 'linear')';
%Interpolated APPL function is above


%The same process is repeated for each variable

%Apples Net Income
rev_onz = rev_old(rev_old ~= 0);
vnz2_old = find(rev_old ~= 0);
rev_old = interp1(vnz2_old, rev_onz, iv1, 'linear')';

%S&P 500
sp500_onz = sp500_old(sp500_old ~= 0);
vnz3_old = find(sp500_old ~= 0);
sp500_old = interp1(vnz3_old, sp500_onz, 1:mo1(end)-1, 'linear')';

%Consumer Price Index
cpi_onz = cpi_old(cpi_old ~= 0);
vnz4_old = find(cpi_old ~= 0);
cpi_old = interp1(vnz4_old, cpi_onz, iv1, 'linear')';

%inflation
inf_onz = inf_old(inf_old ~= 0);
vnz5_old = find(inf_old ~= 0);
inf_old = interp1(vnz5_old, inf_onz, iv1, 'linear')';

%interate rate
ir_onz = ir_old(ir_old ~= 0);
vnz6_old = find(ir_old ~= 0);
ir_old = interp1(vnz6_old, ir_onz, iv1, 'linear')';

%GLD
gld_onz = gld_old(gld_old ~= 0);
vnz7_old = find(gld_old ~= 0);
gld_old = interp1(vnz7_old, gld_onz, iv1, 'linear')';
gld_old(1:3793)=zeros(1,3793);

%Apple's R&D Spending
rd_onz = rd_old(rd_old ~= 0);
vnz8_old = find(rd_old ~= 0);
rd_old = interp1(vnz8_old, rd_onz, iv1, 'linear')';

%P/E Ratio
eps_nz = eps_old(eps_old ~= 0);
vnz9_old = find(eps_old ~= 0);
eps = interp1(vnz9_old, eps_nz, iv1, 'linear')';

%NASDAQ 100
nas_onz = nas_old(nas_old ~= 0);
vnz10_old = find(nas_old ~= 0);
nas_old = interp1(vnz10_old, nas_onz, iv1, 'linear')';

%iPhone Revenue
iphone_onz = iphone_old(iphone_old ~= 0);
vnz12_old = find(iphone_old ~= 0);
iphone_old = interp1(vnz12_old, iphone_onz, iv1, 'linear');
iphone_old(1:4749)=zeros(1,4749);

%Confidence Index
conf_onz = conf_old(conf_old ~= 0);
vnz13_old = find(conf_old ~= 0);
conf_old = interp1(vnz13_old, conf_onz, iv1, 'linear');

%make all data same length
%subtract 1 so that the data files end on 12/31/07 (or 12/30/07 in special
%cases) instead of January 1,2018, which is where the new data files start
rev_old=rev_old(1:mo1(end)-1);
rd_old=rd_old(1:mo1(end)-1);
iphone_old=iphone_old(1:mo1(end)-1);
conf_old=conf_old(1:mo1(end)-1);
nas_old=nas_old(1:mo1(end)-1);
AAPL_old=AAPL_old(1:mo1(end)-1);
eps=eps(1:mo1(end)-1);
gld_old=gld_old(1:mo1(end)-1);
ir_old=ir_old(1:mo1(end)-1);
inf_old=inf_old(1:mo1(end)-1);
cpi_old=cpi_old(1:mo1(end)-1);
sp500_old=sp500_old(1:mo1(end)-1);
buyback_old=buyback_old(1:mo1(end)-1);
pe_old=AAPL_old./eps(1:mo1(end)-1); %caculate P/E ratio using EPS and stock price

%Combine old data values and new data values
rev=[rev_old;rev];
rd=[rd_old;rd];
iphone=[iphone_old;iphone];
NASDAQ100=[nas_old;NASDAQ100];
AAPL=[AAPL_old;AAPL];
gld=[gld_old;gld];
ir=[ir_old;ir];
inflation=[inf_old;inflation];
cpi=[cpi_old;cpi];
sp500=[sp500_old;sp500];
buyback=[buyback_old;buyback];
pe=[pe_old;pe];
conf=[conf_old;conf];

mo=[mo1;mo1(end)+mo(2:end)-1];%create new vector of locations of the start
                              %of every month
    %  for v=199:295
%--------------------------------------------------------------------------
%Now we use the data to solve for the coefficients. Solving for the
%coefficients ends ~ on line 1130
%--------------------------------------------------------------------------
%This if-loop automatically incorporates buybacks, iPhone revenue, and GLD
%if they're nonzero and excludes them otherwise.

if v < 126 %No GLD, No iPhone, No buybacks
%-------------------------------------------------------------------------
%setting up initial vectors so size isnt changing in loop

inflation_int=zeros(1,k);
apple_int=zeros(1,k);
sp500_int=zeros(1,k);
cpi_int=zeros(1,k);
ir_int=zeros(1,k);
pe_int=zeros(1,k);
nasdaq_int=zeros(1,k);
rev_int=zeros(1,k);
rd_int=zeros(1,k);
gld_int=zeros(1,k);
conf_int=zeros(1,k);
buy_int=zeros(1,k);
    cpi_diff=zeros(1,k);
    inflation_diff=zeros(1,k);
    pe_diff=zeros(1,k);
    ir_diff=zeros(1,k);
    nasdaq_diff=zeros(1,k);
    rev_diff=zeros(1,k);
    rd_diff=zeros(1,k);
    apple_diff=zeros(1,k);
    gld_diff=zeros(1,k);
    sp500_diff=zeros(1,k);
    conf_diff=zeros(1,k);
    buy_diff=zeros(1,k);
 cpi_coeff=zeros(1,k);
 inflation_coeff=zeros(3,k);
 pe_coeff=zeros(3,k);
 ir_coeff=zeros(4,k);
 nasdaq_coeff=zeros(4,k);
 rev_coeff=zeros(3,k);
 rd_coeff=zeros(2,k);
 apple_coeff=zeros(6,k);
 gld_coeff=zeros(4,k);
 sp500_coeff=zeros(5,k);
 conf_coeff=zeros(3,k);
 buy_coeff=zeros(3,k);

%--------------------------------------------------------------------------
for i=v-k:v-1
   %integrate each variable for linear components of equation
   cpi_int(i-(v-k)+1)=trapz(cpi(mo(i):mo(i+1)));
   inflation_int(i-(v-k)+1)=trapz(inflation(mo(i):mo(i+1)));
   pe_int(i-(v-k)+1)=trapz(pe(mo(i):mo(i+1)));
   ir_int(i-(v-k)+1)=trapz(ir(mo(i):mo(i+1)));
   nasdaq_int(i-(v-k)+1)=trapz(NASDAQ100(mo(i):mo(i+1)));
   rev_int(i-(v-k)+1)=trapz(rev(mo(i):mo(i+1)));
   rd_int(i-(v-k)+1)=trapz(rd(mo(i):mo(i+1)));
   apple_int(i-(v-k)+1)=trapz(AAPL(mo(i):mo(i+1)));
   sp500_int(i-(v-k)+1)=trapz(sp500(mo(i):mo(i+1)));
   conf_int(i-(v-k)+1)=trapz(conf(mo(i):mo(i+1)));
     cpi_diff(i-(v-k)+1)=cpi(mo(i+1))-cpi(mo(i));
     inflation_diff(i-(v-k)+1)=inflation(mo(i+1))-inflation(mo(i));
     pe_diff(i-(v-k)+1)=pe(mo(i+1))-pe(mo(i));
     ir_diff(i-(v-k)+1)=ir(mo(i+1))-ir(mo(i));
     nasdaq_diff(i-(v-k)+1)=NASDAQ100(mo(i+1))-NASDAQ100(mo(i));
     rev_diff(i-(v-k)+1)=rev(mo(i+1))-rev(mo(i));
     rd_diff(i-(v-k)+1)=rd(mo(i+1))-rd(mo(i));
     apple_diff(i-(v-k)+1)=AAPL(mo(i+1))-AAPL(mo(i));
     sp500_diff(i-(v-k)+1)=sp500(mo(i+1))-sp500(mo(i));
     conf_diff(i-(v-k)+1)=conf(mo(i+1))-conf(mo(i));
end

%set up RHS of equations
%enter the variables in rows-but will take transpose before solving
for i=v-k:v-1
 %x1--CPI
cpi_coeff(1,i-(v-k)+1)=trapz(cpi(mo(i):mo(i+1)).*inflation(mo(i):mo((i+1))));

%x2--inflation
inflation_coeff(1,i-(v-k)+1)=cpi_diff(i-(v-k)+1);
inflation_coeff(2,i-(v-k)+1)=trapz(inflation(mo(i):mo(i+1)).*ir(mo(i)-lags(4)*30:mo(i+1)-lags(4)*30));
inflation_coeff(3,i-(v-k)+1)=inflation_int(i-(v-k)+1);

%x3--P/E ratio
pe_coeff(1,i-(v-k)+1)=inflation_int(i-(v-k)+1);
pe_coeff(2,i-(v-k)+1)=rev_int(i-(v-k)+1);
pe_coeff(3,i-(v-k)+1)=apple_int(i-(v-k)+1);

%x4--Fed funds rate
ir_coeff(1,i-(v-k)+1)=cpi_diff(i-(v-k)+1);
ir_coeff(2,i-(v-k)+1)=trapz(inflation(mo(i):mo(i+1)).*ir(mo(i)-lags(4)*30:mo(i+1)-lags(4)*30));
ir_coeff(3,i-(v-k)+1)=ir_int(i-(v-k)+1);
ir_coeff(4,i-(v-k)+1)=trapz(ir(mo(i):mo(i+1)).*AAPL(mo(i):mo((i+1))));

%x5--NASDAQ100 Index
nasdaq_coeff(1,i-(v-k)+1)=apple_int(i-(v-k)+1);
nasdaq_coeff(2,i-(v-k)+1)=sp500_int(i-(v-k)+1);
nasdaq_coeff(3,i-(v-k)+1)=trapz(ir(mo(i):mo(i+1)));
nasdaq_coeff(4,i-(v-k)+1)=conf_int(i-(v-k)+1);

%x6--Apples revenue
rev_coeff(1,i-(v-k)+1)=rev_int(i-(v-k)+1);
rev_coeff(2,i-(v-k)+1)=trapz(rd(mo(i)-lags(7)*30:mo(i+1)-lags(7)*30)); %1.5 year delay
rev_coeff(3,i-(v-k)+1)=conf_int(i-(v-k)+1);


%x7--Apples R&D Spending
rd_coeff(1,i-(v-k)+1)=rd_int(i-(v-k)+1);
rd_coeff(2,i-(v-k)+1)=rev_int(i-(v-k)+1);


%x8--Apples stock pricce
apple_coeff(1,i-(v-k)+1)=rev_int(i-(v-k)+1);
apple_coeff(2,i-(v-k)+1)=nasdaq_diff(i-(v-k)+1);
apple_coeff(3,i-(v-k)+1)=pe_int(i-(v-k)+1);
apple_coeff(4,i-(v-k)+1)=trapz(ir(mo(i):mo((i+1))).*AAPL(mo(i):mo(i+1)));
apple_coeff(5,i-(v-k)+1)=apple_int(i-(v-k)+1);
apple_coeff(6,i-(v-k)+1)=sp500_diff(i-(v-k)+1);


%x9--GLD
c9=zeros(4,1);

%x10--S&P 500
sp500_coeff(1,i-(v-k)+1)=ir_int(i-(v-k)+1);
sp500_coeff(2,i-(v-k)+1)=cpi_int(i-(v-k)+1);
sp500_coeff(3,i-(v-k)+1)=nasdaq_int(i-(v-k)+1);
sp500_coeff(4,i-(v-k)+1)=conf_int(i-(v-k)+1);
sp500_coeff(5,i-(v-k)+1)=sp500_int(i-(v-k)+1);

%x11--iPhone revenue
c11=zeros(3,1);

%x12--Consumer Confidence Index
conf_coeff(1,i-(v-k)+1)=sp500_diff(i-(v-k)+1);
conf_coeff(2,i-(v-k)+1)=ir_int(i-(v-k)+1);
conf_coeff(3,i-(v-k)+1)=cpi_int(i-(v-k)+1);

%x13--Buybacks
%There are no buybacks prior to this time so we make all the coefficients
%zero for this equation
c13=zeros(3,1);
end

%--------------------------------------------------------------------------
%Solve for coefficients
c1=cpi_coeff'\cpi_diff';
c2=inflation_coeff'\inflation_diff';
c3=pe_coeff'\pe_diff' ;
c4=ir_coeff'\ir_diff' ;
c5=nasdaq_coeff'\nasdaq_diff' ;
c6=rev_coeff'\rev_diff';
c7=rd_coeff'\rd_diff';
c8=apple_coeff'\apple_diff';
c10=sp500_coeff'\sp500_diff' ;
c12=conf_coeff'\conf_diff';


%Create the vector of coefficients
c=[c1;c2;c3(1:3);c4;c5;c6;0;c7;0;c8(1:5);c9;c10;c11;c12;0;c13;c8(6);0;0];

%--------------------------------------------------------------------------
elseif (v>=126) && (v < 159) %No iPhone, No Buybacks
%--------------------------------------------------------------------------
%setting up initial vectors so size isnt changing in loop

inflation_int=zeros(1,k);
apple_int=zeros(1,k);
sp500_int=zeros(1,k);
cpi_int=zeros(1,k);
ir_int=zeros(1,k);
pe_int=zeros(1,k);
nasdaq_int=zeros(1,k);
rev_int=zeros(1,k);
rd_int=zeros(1,k);
gld_int=zeros(1,k);
conf_int=zeros(1,k);
buy_int=zeros(1,k);
    cpi_diff=zeros(1,k);
    inflation_diff=zeros(1,k);
    pe_diff=zeros(1,k);
    ir_diff=zeros(1,k);
    nasdaq_diff=zeros(1,k);
    rev_diff=zeros(1,k);
    rd_diff=zeros(1,k);
    apple_diff=zeros(1,k);
    gld_diff=zeros(1,k);
    sp500_diff=zeros(1,k);
    conf_diff=zeros(1,k);
    buy_diff=zeros(1,k);
 cpi_coeff=zeros(1,k);
 inflation_coeff=zeros(3,k);
 pe_coeff=zeros(3,k);
 ir_coeff=zeros(4,k);
 nasdaq_coeff=zeros(4,k);
 rev_coeff=zeros(3,k);
 rd_coeff=zeros(2,k);
 apple_coeff=zeros(6,k);
 gld_coeff=zeros(4,k);
 sp500_coeff=zeros(5,k);
 conf_coeff=zeros(4,k);
 buy_coeff=zeros(3,k);

%--------------------------------------------------------------------------
for i=v-k:v-1
   %integrate each variable for linear components of equation
   cpi_int(i-(v-k)+1)=trapz(cpi(mo(i):mo(i+1)));
   inflation_int(i-(v-k)+1)=trapz(inflation(mo(i):mo(i+1)));
   pe_int(i-(v-k)+1)=trapz(pe(mo(i):mo(i+1)));
   ir_int(i-(v-k)+1)=trapz(ir(mo(i):mo(i+1)));
   nasdaq_int(i-(v-k)+1)=trapz(NASDAQ100(mo(i):mo(i+1)));
   rev_int(i-(v-k)+1)=trapz(rev(mo(i):mo(i+1)));
   rd_int(i-(v-k)+1)=trapz(rd(mo(i):mo(i+1)));
   apple_int(i-(v-k)+1)=trapz(AAPL(mo(i):mo(i+1)));
   gld_int(i-(v-k)+1)=trapz(gld(mo(i):mo(i+1)));
   sp500_int(i-(v-k)+1)=trapz(sp500(mo(i):mo(i+1)));
   conf_int(i-(v-k)+1)=trapz(conf(mo(i):mo(i+1)));
     cpi_diff(i-(v-k)+1)=cpi(mo(i+1))-cpi(mo(i));
     inflation_diff(i-(v-k)+1)=inflation(mo(i+1))-inflation(mo(i));
     pe_diff(i-(v-k)+1)=pe(mo(i+1))-pe(mo(i));
     ir_diff(i-(v-k)+1)=ir(mo(i+1))-ir(mo(i));
     nasdaq_diff(i-(v-k)+1)=NASDAQ100(mo(i+1))-NASDAQ100(mo(i));
     rev_diff(i-(v-k)+1)=rev(mo(i+1))-rev(mo(i));
     rd_diff(i-(v-k)+1)=rd(mo(i+1))-rd(mo(i));
     apple_diff(i-(v-k)+1)=AAPL(mo(i+1))-AAPL(mo(i));
     gld_diff(i-(v-k)+1)=gld(mo(i+1))-gld(mo(i));
     sp500_diff(i-(v-k)+1)=sp500(mo(i+1))-sp500(mo(i));
     conf_diff(i-(v-k)+1)=conf(mo(i+1))-conf(mo(i));
end

%set up RHS of equations
%enter the variables in rows-but will take transpose before solving
for i=v-k:v-1
 %x1--CPI
cpi_coeff(1,i-(v-k)+1)=trapz(cpi(mo(i):mo(i+1)).*inflation(mo(i):mo((i+1))));

%x2--inflation
inflation_coeff(1,i-(v-k)+1)=cpi_diff(i-(v-k)+1);
inflation_coeff(2,i-(v-k)+1)=trapz(inflation(mo(i):mo(i+1)).*ir(mo(i)-lags(4)*30:mo(i+1)-lags(4)*30));
inflation_coeff(3,i-(v-k)+1)=inflation_int(i-(v-k)+1);

%x3--P/E ratio
pe_coeff(1,i-(v-k)+1)=inflation_int(i-(v-k)+1);
pe_coeff(2,i-(v-k)+1)=rev_int(i-(v-k)+1);
pe_coeff(3,i-(v-k)+1)=apple_int(i-(v-k)+1);

%x4--Fed funds rate
ir_coeff(1,i-(v-k)+1)=cpi_diff(i-(v-k)+1);
ir_coeff(2,i-(v-k)+1)=trapz(inflation(mo(i):mo(i+1)).*ir(mo(i)-lags(4)*30:mo(i+1)-lags(4)*30));
ir_coeff(3,i-(v-k)+1)=ir_int(i-(v-k)+1);
ir_coeff(4,i-(v-k)+1)=trapz(ir(mo(i):mo(i+1)).*AAPL(mo(i):mo((i+1))));

%x5--NASDAQ100 Index
nasdaq_coeff(1,i-(v-k)+1)=apple_int(i-(v-k)+1);
nasdaq_coeff(2,i-(v-k)+1)=sp500_int(i-(v-k)+1);
nasdaq_coeff(3,i-(v-k)+1)=trapz(ir(mo(i):mo(i+1)));
nasdaq_coeff(4,i-(v-k)+1)=conf_int(i-(v-k)+1);

%x6--Apples revenue
rev_coeff(1,i-(v-k)+1)=rev_int(i-(v-k)+1);
rev_coeff(2,i-(v-k)+1)=trapz(rd(mo(i)-lags(7)*30:mo(i+1)-lags(7)*30));
rev_coeff(3,i-(v-k)+1)=conf_int(i-(v-k)+1);


%x7--Apples R&D Spending
rd_coeff(1,i-(v-k)+1)=rd_int(i-(v-k)+1);
rd_coeff(2,i-(v-k)+1)=rev_int(i-(v-k)+1);


%x8--Apples stock pricce
apple_coeff(1,i-(v-k)+1)=rev_int(i-(v-k)+1);
apple_coeff(2,i-(v-k)+1)=nasdaq_diff(i-(v-k)+1);
apple_coeff(3,i-(v-k)+1)=pe_int(i-(v-k)+1);
apple_coeff(4,i-(v-k)+1)=trapz(ir(mo(i):mo((i+1))).*AAPL(mo(i):mo(i+1)));
apple_coeff(5,i-(v-k)+1)=apple_int(i-(v-k)+1);
apple_coeff(6,i-(v-k)+1)=sp500_diff(i-(v-k)+1);


%x9--GLD
gld_coeff(1,i-(v-k)+1)=sp500_int(i-(v-k)+1);
gld_coeff(2,i-(v-k)+1)=conf_int(i-(v-k)+1);
gld_coeff(3,i-(v-k)+1)=inflation_int(i-(v-k)+1);
gld_coeff(4,i-(v-k)+1)=gld_int(i-(v-k)+1);

%x10--S&P 500
sp500_coeff(1,i-(v-k)+1)=ir_int(i-(v-k)+1);
sp500_coeff(2,i-(v-k)+1)=cpi_int(i-(v-k)+1);
sp500_coeff(3,i-(v-k)+1)=nasdaq_int(i-(v-k)+1);
sp500_coeff(4,i-(v-k)+1)=conf_int(i-(v-k)+1);
sp500_coeff(5,i-(v-k)+1)=sp500_int(i-(v-k)+1);

%x11--iPhone revenue
c11=zeros(3,1);

%x12--Consumer Confidence Index
conf_coeff(1,i-(v-k)+1)=sp500_diff(i-(v-k)+1);
conf_coeff(2,i-(v-k)+1)=ir_int(i-(v-k)+1);
conf_coeff(3,i-(v-k)+1)=cpi_int(i-(v-k)+1);
conf_coeff(4,i-(v-k)+1)=gld_int(i-(v-k)+1);

%x13--Buybacks
%There are no buybacks prior to this time so we make all the coefficients
%zero for this equation
c13=zeros(3,1);
end

%--------------------------------------------------------------------------
%Solve for coefficients
c1=cpi_coeff'\cpi_diff';
c2=inflation_coeff'\inflation_diff';
c3=pe_coeff'\pe_diff' ;
c4=ir_coeff'\ir_diff' ;
c5=nasdaq_coeff'\nasdaq_diff' ;
c6=rev_coeff'\rev_diff';
c7=rd_coeff'\rd_diff';
c8=apple_coeff'\apple_diff';
c9=gld_coeff'\gld_diff';
c10=sp500_coeff'\sp500_diff' ;
c12=conf_coeff'\conf_diff';


%Create the vector of coefficients
c=[c1;c2;c3(1:3);c4;c5;c6;0;c7;0;c8(1:5);c9;c10;c11;c12;c13;c8(6);0;0];

%--------------------------------------------------------------------------
elseif (v>=159) && (v < 228) %No Buybacks
%--------------------------------------------------------------------------
  %setting up initial vectors so size isnt changing in loop

inflation_int=zeros(1,k);
apple_int=zeros(1,k);
sp500_int=zeros(1,k);
cpi_int=zeros(1,k);
ir_int=zeros(1,k);
pe_int=zeros(1,k);
nasdaq_int=zeros(1,k);
rev_int=zeros(1,k);
rd_int=zeros(1,k);
gld_int=zeros(1,k);
iphone_int=zeros(1,k);
conf_int=zeros(1,k);
buy_int=zeros(1,k);
    cpi_diff=zeros(1,k);
    inflation_diff=zeros(1,k);
    pe_diff=zeros(1,k);
    ir_diff=zeros(1,k);
    nasdaq_diff=zeros(1,k);
    rev_diff=zeros(1,k);
    rd_diff=zeros(1,k);
    apple_diff=zeros(1,k);
    gld_diff=zeros(1,k);
    sp500_diff=zeros(1,k);
    iphone_diff=zeros(1,k);
    conf_diff=zeros(1,k);
    buy_diff=zeros(1,k);
    vol_diff=zeros(1,k);
 cpi_coeff=zeros(1,k);
 inflation_coeff=zeros(3,k);
 pe_coeff=zeros(3,k);
 ir_coeff=zeros(4,k);
 nasdaq_coeff=zeros(4,k);
 rev_coeff=zeros(4,k);
 rd_coeff=zeros(3,k);
 apple_coeff=zeros(6,k);
 gld_coeff=zeros(4,k);
 sp500_coeff=zeros(5,k);
 iphone_coeff=zeros(3,k);
 conf_coeff=zeros(4,k);
 buy_coeff=zeros(3,k);

%--------------------------------------------------------------------------
for i=v-k:v-1
   %integrate each variable for linear components of equation
   cpi_int(i-(v-k)+1)=trapz(cpi(mo(i):mo(i+1)));
   inflation_int(i-(v-k)+1)=trapz(inflation(mo(i):mo(i+1)));
   pe_int(i-(v-k)+1)=trapz(pe(mo(i):mo(i+1)));
   ir_int(i-(v-k)+1)=trapz(ir(mo(i):mo(i+1)));
   nasdaq_int(i-(v-k)+1)=trapz(NASDAQ100(mo(i):mo(i+1)));
   rev_int(i-(v-k)+1)=trapz(rev(mo(i):mo(i+1)));
   rd_int(i-(v-k)+1)=trapz(rd(mo(i):mo(i+1)));
   apple_int(i-(v-k)+1)=trapz(AAPL(mo(i):mo(i+1)));
   gld_int(i-(v-k)+1)=trapz(gld(mo(i):mo(i+1)));
   sp500_int(i-(v-k)+1)=trapz(sp500(mo(i):mo(i+1)));
   iphone_int(i-(v-k)+1)=trapz(iphone(mo(i):mo(i+1)));
   conf_int(i-(v-k)+1)=trapz(conf(mo(i):mo(i+1)));
   buy_int(i-(v-k)+1)=trapz(buyback(mo(i):mo(i+1)));
     cpi_diff(i-(v-k)+1)=cpi(mo(i+1))-cpi(mo(i));
     inflation_diff(i-(v-k)+1)=inflation(mo(i+1))-inflation(mo(i));
     pe_diff(i-(v-k)+1)=pe(mo(i+1))-pe(mo(i));
     ir_diff(i-(v-k)+1)=ir(mo(i+1))-ir(mo(i));
     nasdaq_diff(i-(v-k)+1)=NASDAQ100(mo(i+1))-NASDAQ100(mo(i));
     rev_diff(i-(v-k)+1)=rev(mo(i+1))-rev(mo(i));
     rd_diff(i-(v-k)+1)=rd(mo(i+1))-rd(mo(i));
     apple_diff(i-(v-k)+1)=AAPL(mo(i+1))-AAPL(mo(i));
     gld_diff(i-(v-k)+1)=gld(mo(i+1))-gld(mo(i));
     sp500_diff(i-(v-k)+1)=sp500(mo(i+1))-sp500(mo(i));
     iphone_diff(i-(v-k)+1)=iphone(mo(i+1))-iphone(mo(i));
     conf_diff(i-(v-k)+1)=conf(mo(i+1))-conf(mo(i));
     buy_diff(i-(v-k)+1)=buyback(mo(i+1))-buyback(mo(i));
end

%set up RHS of equations
%enter the variables in rows-but will take transpose before solving
for i=v-k:v-1
 %x1--CPI
cpi_coeff(1,i-(v-k)+1)=trapz(cpi(mo(i):mo(i+1)).*inflation(mo(i):mo((i+1))));

%x2--inflation
inflation_coeff(1,i-(v-k)+1)=cpi_diff(i-(v-k)+1);
inflation_coeff(2,i-(v-k)+1)=trapz(inflation(mo(i):mo(i+1)).*ir(mo(i)-lags(4)*30:mo(i+1)-lags(4)*30));
inflation_coeff(3,i-(v-k)+1)=inflation_int(i-(v-k)+1);

%x3--P/E ratio
pe_coeff(1,i-(v-k)+1)=inflation_int(i-(v-k)+1);
pe_coeff(2,i-(v-k)+1)=rev_int(i-(v-k)+1);
pe_coeff(3,i-(v-k)+1)=apple_int(i-(v-k)+1);

%x4--Fed funds rate
ir_coeff(1,i-(v-k)+1)=cpi_diff(i-(v-k)+1);
ir_coeff(2,i-(v-k)+1)=trapz(inflation(mo(i):mo(i+1)).*ir(mo(i)-lags(4)*30:mo(i+1)-lags(4)*30));
ir_coeff(3,i-(v-k)+1)=ir_int(i-(v-k)+1);
ir_coeff(4,i-(v-k)+1)=trapz(ir(mo(i):mo(i+1)).*AAPL(mo(i):mo((i+1))));

%x5--NASDAQ100 Index
nasdaq_coeff(1,i-(v-k)+1)=apple_int(i-(v-k)+1);
nasdaq_coeff(2,i-(v-k)+1)=sp500_int(i-(v-k)+1);
nasdaq_coeff(3,i-(v-k)+1)=trapz(ir(mo(i):mo(i+1)));
nasdaq_coeff(4,i-(v-k)+1)=conf_int(i-(v-k)+1);

%x6--Apples revenue
rev_coeff(1,i-(v-k)+1)=rev_int(i-(v-k)+1);
rev_coeff(2,i-(v-k)+1)=trapz(rd(mo(i)-lags(7)*30:mo(i+1)-lags(7)*30));
rev_coeff(3,i-(v-k)+1)=conf_int(i-(v-k)+1);
rev_coeff(4,i-(v-k)+1)=iphone_int(i-(v-k)+1);

%x7--Apple's R&D Spending
rd_coeff(1,i-(v-k)+1)=rd_int(i-(v-k)+1);
rd_coeff(2,i-(v-k)+1)=rev_int(i-(v-k)+1);
rd_coeff(3,i-(v-k)+1)=iphone_int(i-(v-k)+1);

%x8--Apple's stock pricce
apple_coeff(1,i-(v-k)+1)=rev_int(i-(v-k)+1);
apple_coeff(2,i-(v-k)+1)=nasdaq_diff(i-(v-k)+1);
apple_coeff(3,i-(v-k)+1)=pe_int(i-(v-k)+1);
apple_coeff(4,i-(v-k)+1)=trapz(ir(mo(i):mo((i+1))).*AAPL(mo(i):mo(i+1)));
apple_coeff(5,i-(v-k)+1)=apple_int(i-(v-k)+1);
apple_coeff(6,i-(v-k)+1)=sp500_diff(i-(v-k)+1);

%x9--GLD
gld_coeff(1,i-(v-k)+1)=sp500_int(i-(v-k)+1);
gld_coeff(2,i-(v-k)+1)=conf_int(i-(v-k)+1);
gld_coeff(3,i-(v-k)+1)=inflation_int(i-(v-k)+1);
gld_coeff(4,i-(v-k)+1)=gld_int(i-(v-k)+1);

%x10--S&P 500
sp500_coeff(1,i-(v-k)+1)=ir_int(i-(v-k)+1);
sp500_coeff(2,i-(v-k)+1)=cpi_int(i-(v-k)+1);
sp500_coeff(3,i-(v-k)+1)=nasdaq_int(i-(v-k)+1);
sp500_coeff(4,i-(v-k)+1)=conf_int(i-(v-k)+1);
sp500_coeff(5,i-(v-k)+1)=sp500_int(i-(v-k)+1);

%x11--iPhone revenue
iphone_coeff(1,i-(v-k)+1)=iphone_int(i-(v-k)+1);
iphone_coeff(2,i-(v-k)+1)=trapz(rd(mo(i)-lags(7)*30:mo(i+1)-lags(7)*30));
iphone_coeff(3,i-(v-k)+1)=trapz(iphone(mo(i):mo(i+1)).*ir(mo(i)-lags(4)*30:mo(i+1)-lags(4)*30));

%x12--Consumer Confidence Index
conf_coeff(1,i-(v-k)+1)=sp500_diff(i-(v-k)+1);
conf_coeff(2,i-(v-k)+1)=ir_int(i-(v-k)+1);
conf_coeff(3,i-(v-k)+1)=cpi_int(i-(v-k)+1);
conf_coeff(4,i-(v-k)+1)=gld_int(i-(v-k)+1);

%x13--Buybacks
%There are no buybacks prior to this time so we make all the coefficients
%zero for this equation
c13=zeros(3,1);
end

%--------------------------------------------------------------------------
%Solve for coefficients
c1=cpi_coeff'\cpi_diff';
c2=inflation_coeff'\inflation_diff';
c3=pe_coeff'\pe_diff' ;
c4=ir_coeff'\ir_diff' ;
c5=nasdaq_coeff'\nasdaq_diff' ;
c6=rev_coeff'\rev_diff';
c7=rd_coeff'\rd_diff';
c8=apple_coeff'\apple_diff';
c9=gld_coeff'\gld_diff';
c10=sp500_coeff'\sp500_diff' ;
c11=iphone_coeff'\iphone_diff';
c12=conf_coeff'\conf_diff';


%Create the vector of coefficients
c=[c1;c2;c3(1:3);c4;c5;c6;c7;c8(1:5);c9;c10;c11;c12;c13;c8(6);0;0];
%--------------------------------------------------------------------------
elseif (v>=228) && (v< 240) %Buybacks are in PE equation, but not Apple

%setting up initial vectors so size isnt changing in loop
inflation_int=zeros(1,k);
apple_int=zeros(1,k);
sp500_int=zeros(1,k);
cpi_int=zeros(1,k);
ir_int=zeros(1,k);
pe_int=zeros(1,k);
nasdaq_int=zeros(1,k);
rev_int=zeros(1,k);
rd_int=zeros(1,k);
gld_int=zeros(1,k);
iphone_int=zeros(1,k);
conf_int=zeros(1,k);
buy_int=zeros(1,k);
    cpi_diff=zeros(1,k);
    inflation_diff=zeros(1,k);
    pe_diff=zeros(1,k);
    ir_diff=zeros(1,k);
    nasdaq_diff=zeros(1,k);
    rev_diff=zeros(1,k);
    rd_diff=zeros(1,k);
    apple_diff=zeros(1,k);
    gld_diff=zeros(1,k);
    sp500_diff=zeros(1,k);
    iphone_diff=zeros(1,k);
    conf_diff=zeros(1,k);
    buy_diff=zeros(1,k);
    vol_diff=zeros(1,k);
 cpi_coeff=zeros(1,k);
 inflation_coeff=zeros(3,k);
 pe_coeff=zeros(4,k);
 ir_coeff=zeros(4,k);
 nasdaq_coeff=zeros(4,k);
 rev_coeff=zeros(4,k);
 rd_coeff=zeros(3,k);
 apple_coeff=zeros(6,k);
 gld_coeff=zeros(4,k);
 sp500_coeff=zeros(5,k);
 iphone_coeff=zeros(3,k);
 conf_coeff=zeros(4,k);
 buy_coeff=zeros(3,k);

%--------------------------------------------------------------------------
for i=v-k:v-1
   %integrate each variable for linear components of equation
   cpi_int(i-(v-k)+1)=trapz(cpi(mo(i):mo(i+1)));
   inflation_int(i-(v-k)+1)=trapz(inflation(mo(i):mo(i+1)));
   pe_int(i-(v-k)+1)=trapz(pe(mo(i):mo(i+1)));
   ir_int(i-(v-k)+1)=trapz(ir(mo(i):mo(i+1)));
   nasdaq_int(i-(v-k)+1)=trapz(NASDAQ100(mo(i):mo(i+1)));
   rev_int(i-(v-k)+1)=trapz(rev(mo(i):mo(i+1)));
   rd_int(i-(v-k)+1)=trapz(rd(mo(i):mo(i+1)));
   apple_int(i-(v-k)+1)=trapz(AAPL(mo(i):mo(i+1)));
   gld_int(i-(v-k)+1)=trapz(gld(mo(i):mo(i+1)));
   sp500_int(i-(v-k)+1)=trapz(sp500(mo(i):mo(i+1)));
   iphone_int(i-(v-k)+1)=trapz(iphone(mo(i):mo(i+1)));
   conf_int(i-(v-k)+1)=trapz(conf(mo(i):mo(i+1)));
   buy_int(i-(v-k)+1)=trapz(buyback(mo(i):mo(i+1)));
     cpi_diff(i-(v-k)+1)=cpi(mo(i+1))-cpi(mo(i));
     inflation_diff(i-(v-k)+1)=inflation(mo(i+1))-inflation(mo(i));
     pe_diff(i-(v-k)+1)=pe(mo(i+1))-pe(mo(i));
     ir_diff(i-(v-k)+1)=ir(mo(i+1))-ir(mo(i));
     nasdaq_diff(i-(v-k)+1)=NASDAQ100(mo(i+1))-NASDAQ100(mo(i));
     rev_diff(i-(v-k)+1)=rev(mo(i+1))-rev(mo(i));
     rd_diff(i-(v-k)+1)=rd(mo(i+1))-rd(mo(i));
     apple_diff(i-(v-k)+1)=AAPL(mo(i+1))-AAPL(mo(i));
     gld_diff(i-(v-k)+1)=gld(mo(i+1))-gld(mo(i));
     sp500_diff(i-(v-k)+1)=sp500(mo(i+1))-sp500(mo(i));
     iphone_diff(i-(v-k)+1)=iphone(mo(i+1))-iphone(mo(i));
     conf_diff(i-(v-k)+1)=conf(mo(i+1))-conf(mo(i));
     buy_diff(i-(v-k)+1)=buyback(mo(i+1))-buyback(mo(i));
end

%set up RHS of equations
%enter the variables in rows-but will take transpose before solving
for i=v-k:v-1
 %x1--CPI
cpi_coeff(1,i-(v-k)+1)=trapz(cpi(mo(i):mo(i+1)).*inflation(mo(i):mo((i+1))));

%x2--inflation
inflation_coeff(1,i-(v-k)+1)=cpi_diff(i-(v-k)+1);
inflation_coeff(2,i-(v-k)+1)=trapz(inflation(mo(i):mo(i+1)).*ir(mo(i)-lags(4)*30:mo(i+1)-lags(4)*30));
inflation_coeff(3,i-(v-k)+1)=inflation_int(i-(v-k)+1);

%x3--P/E ratio
pe_coeff(1,i-(v-k)+1)=inflation_int(i-(v-k)+1);
pe_coeff(2,i-(v-k)+1)=rev_int(i-(v-k)+1);
pe_coeff(3,i-(v-k)+1)=apple_int(i-(v-k)+1);
pe_coeff(4,i-(v-k)+1)=buy_int(i-(v-k)+1);

%x4--Fed funds rate
ir_coeff(1,i-(v-k)+1)=cpi_diff(i-(v-k)+1);
ir_coeff(2,i-(v-k)+1)=trapz(inflation(mo(i):mo(i+1)).*ir(mo(i)-lags(4)*30:mo(i+1)-lags(4)*30));
ir_coeff(3,i-(v-k)+1)=ir_int(i-(v-k)+1);
ir_coeff(4,i-(v-k)+1)=trapz(ir(mo(i):mo(i+1)).*AAPL(mo(i):mo((i+1))));

%x5--NASDAQ100 Index
nasdaq_coeff(1,i-(v-k)+1)=apple_int(i-(v-k)+1);
nasdaq_coeff(2,i-(v-k)+1)=sp500_int(i-(v-k)+1);
nasdaq_coeff(3,i-(v-k)+1)=trapz(ir(mo(i):mo(i+1)));
nasdaq_coeff(4,i-(v-k)+1)=conf_int(i-(v-k)+1);

%x6--Apples revenue
rev_coeff(1,i-(v-k)+1)=rev_int(i-(v-k)+1);
rev_coeff(2,i-(v-k)+1)=trapz(rd(mo(i)-lags(7)*30:mo(i+1)-lags(7)*30)); %1.5 year delay
rev_coeff(3,i-(v-k)+1)=conf_int(i-(v-k)+1);
rev_coeff(4,i-(v-k)+1)=iphone_int(i-(v-k)+1);

%x7--Apples R&D Spending
rd_coeff(1,i-(v-k)+1)=rd_int(i-(v-k)+1);
rd_coeff(2,i-(v-k)+1)=rev_int(i-(v-k)+1);
rd_coeff(3,i-(v-k)+1)=iphone_int(i-(v-k)+1);

%x8--Apple's stock pricce
apple_coeff(1,i-(v-k)+1)=rev_int(i-(v-k)+1);
apple_coeff(2,i-(v-k)+1)=nasdaq_diff(i-(v-k)+1);
apple_coeff(3,i-(v-k)+1)=pe_int(i-(v-k)+1);
apple_coeff(4,i-(v-k)+1)=trapz(ir(mo(i):mo((i+1))).*AAPL(mo(i):mo(i+1)));
apple_coeff(5,i-(v-k)+1)=apple_int(i-(v-k)+1);
apple_coeff(6,i-(v-k)+1)=sp500_diff(i-(v-k)+1);
%apple_coeff(7,i-(v-k)+1)=buy_diff(i-(v-k)+1);

%x9--GLD
gld_coeff(1,i-(v-k)+1)=sp500_int(i-(v-k)+1);
gld_coeff(2,i-(v-k)+1)=conf_int(i-(v-k)+1);
gld_coeff(3,i-(v-k)+1)=inflation_int(i-(v-k)+1);
gld_coeff(4,i-(v-k)+1)=gld_int(i-(v-k)+1);

%x10--S&P 500
sp500_coeff(1,i-(v-k)+1)=ir_int(i-(v-k)+1);
sp500_coeff(2,i-(v-k)+1)=cpi_int(i-(v-k)+1);
sp500_coeff(3,i-(v-k)+1)=nasdaq_int(i-(v-k)+1);
sp500_coeff(4,i-(v-k)+1)=conf_int(i-(v-k)+1);
sp500_coeff(5,i-(v-k)+1)=sp500_int(i-(v-k)+1);

%x11--iPhone revenue
iphone_coeff(1,i-(v-k)+1)=iphone_int(i-(v-k)+1);
iphone_coeff(2,i-(v-k)+1)=trapz(rd(mo(i)-lags(7)*30:mo(i+1)-lags(7)*30));
iphone_coeff(3,i-(v-k)+1)=trapz(iphone(mo(i):mo(i+1)).*ir(mo(i)-lags(4)*30:mo(i+1)-lags(4)*30));

%x12--Consumer Confidence Index
conf_coeff(1,i-(v-k)+1)=sp500_diff(i-(v-k)+1);
conf_coeff(2,i-(v-k)+1)=ir_int(i-(v-k)+1);
conf_coeff(3,i-(v-k)+1)=cpi_int(i-(v-k)+1);
conf_coeff(4,i-(v-k)+1)=gld_int(i-(v-k)+1);

%x13--Buybacks
buy_coeff(1,i-(v-k)+1)=sp500_int(i-(v-k)+1);
buy_coeff(2,i-(v-k)+1)=rev_int(i-(v-k)+1);
buy_coeff(3,i-(v-k)+1)=rd_int(i-(v-k)+1);
end

%--------------------------------------------------------------------------
%Solve for coefficients
c1=cpi_coeff'\cpi_diff';
c2=inflation_coeff'\inflation_diff';
c3=pe_coeff'\pe_diff' ;
c4=ir_coeff'\ir_diff' ;
c5=nasdaq_coeff'\nasdaq_diff' ;
c6=rev_coeff'\rev_diff';
c7=rd_coeff'\rd_diff';
c8=apple_coeff'\apple_diff';
c9=gld_coeff'\gld_diff';
c10=sp500_coeff'\sp500_diff' ;
c11=iphone_coeff'\iphone_diff';
c12=conf_coeff'\conf_diff';
c13=buy_coeff'\buy_diff';


%Create the vector of coefficients
c=[c1;c2;c3(1:3);c4;c5;c6;c7;c8(1:5);c9;c10;c11;c12;c13;c8(6);0;c3(4)];
%--------------------------------------------------------------------------

elseif v >= 240 %Buybacks are included in PE equation and Apple's equation
%setting up initial vectors so size isn't changing in loop
inflation_int=zeros(1,k);
apple_int=zeros(1,k);
sp500_int=zeros(1,k);
cpi_int=zeros(1,k);
ir_int=zeros(1,k);
pe_int=zeros(1,k);
nasdaq_int=zeros(1,k);
rev_int=zeros(1,k);
rd_int=zeros(1,k);
gld_int=zeros(1,k);
iphone_int=zeros(1,k);
conf_int=zeros(1,k);
buy_int=zeros(1,k);
    cpi_diff=zeros(1,k);
    inflation_diff=zeros(1,k);
    pe_diff=zeros(1,k);
    ir_diff=zeros(1,k);
    nasdaq_diff=zeros(1,k);
    rev_diff=zeros(1,k);
    rd_diff=zeros(1,k);
    apple_diff=zeros(1,k);
    gld_diff=zeros(1,k);
    sp500_diff=zeros(1,k);
    iphone_diff=zeros(1,k);
    conf_diff=zeros(1,k);
    buy_diff=zeros(1,k);
    vol_diff=zeros(1,k);
 cpi_coeff=zeros(1,k);
 inflation_coeff=zeros(3,k);
 pe_coeff=zeros(4,k);
 ir_coeff=zeros(4,k);
 nasdaq_coeff=zeros(4,k);
 rev_coeff=zeros(4,k);
 rd_coeff=zeros(3,k);
 apple_coeff=zeros(7,k);
 gld_coeff=zeros(4,k);
 sp500_coeff=zeros(5,k);
 iphone_coeff=zeros(3,k);
 conf_coeff=zeros(4,k);
 buy_coeff=zeros(3,k);

%--------------------------------------------------------------------------
for i=v-k:v-1
   %integrate each variable for linear components of equation
   cpi_int(i-(v-k)+1)=trapz(cpi(mo(i):mo(i+1)));
   inflation_int(i-(v-k)+1)=trapz(inflation(mo(i):mo(i+1)));
   pe_int(i-(v-k)+1)=trapz(pe(mo(i):mo(i+1)));
   ir_int(i-(v-k)+1)=trapz(ir(mo(i):mo(i+1)));
   nasdaq_int(i-(v-k)+1)=trapz(NASDAQ100(mo(i):mo(i+1)));
   rev_int(i-(v-k)+1)=trapz(rev(mo(i):mo(i+1)));
   rd_int(i-(v-k)+1)=trapz(rd(mo(i):mo(i+1)));
   apple_int(i-(v-k)+1)=trapz(AAPL(mo(i):mo(i+1)));
   gld_int(i-(v-k)+1)=trapz(gld(mo(i):mo(i+1)));
   sp500_int(i-(v-k)+1)=trapz(sp500(mo(i):mo(i+1)));
   iphone_int(i-(v-k)+1)=trapz(iphone(mo(i):mo(i+1)));
   conf_int(i-(v-k)+1)=trapz(conf(mo(i):mo(i+1)));
   buy_int(i-(v-k)+1)=trapz(buyback(mo(i):mo(i+1)));
     cpi_diff(i-(v-k)+1)=cpi(mo(i+1))-cpi(mo(i));
     inflation_diff(i-(v-k)+1)=inflation(mo(i+1))-inflation(mo(i));
     pe_diff(i-(v-k)+1)=pe(mo(i+1))-pe(mo(i));
     ir_diff(i-(v-k)+1)=ir(mo(i+1))-ir(mo(i));
     nasdaq_diff(i-(v-k)+1)=NASDAQ100(mo(i+1))-NASDAQ100(mo(i));
     rev_diff(i-(v-k)+1)=rev(mo(i+1))-rev(mo(i));
     rd_diff(i-(v-k)+1)=rd(mo(i+1))-rd(mo(i));
     apple_diff(i-(v-k)+1)=AAPL(mo(i+1))-AAPL(mo(i));
     gld_diff(i-(v-k)+1)=gld(mo(i+1))-gld(mo(i));
     sp500_diff(i-(v-k)+1)=sp500(mo(i+1))-sp500(mo(i));
     iphone_diff(i-(v-k)+1)=iphone(mo(i+1))-iphone(mo(i));
     conf_diff(i-(v-k)+1)=conf(mo(i+1))-conf(mo(i));
     buy_diff(i-(v-k)+1)=buyback(mo(i+1))-buyback(mo(i));
end

%set up RHS of equations
%enter the variables in rows-but will take transpose before solving
for i=v-k:v-1
 %x1--CPI
cpi_coeff(1,i-(v-k)+1)=trapz(cpi(mo(i):mo(i+1)).*inflation(mo(i):mo((i+1))));

%x2--inflation
inflation_coeff(1,i-(v-k)+1)=cpi_diff(i-(v-k)+1);
inflation_coeff(2,i-(v-k)+1)=trapz(inflation(mo(i):mo(i+1)).*ir(mo(i)-lags(4)*30:mo(i+1)-lags(4)*30));
inflation_coeff(3,i-(v-k)+1)=inflation_int(i-(v-k)+1);

%x3--P/E ratio
pe_coeff(1,i-(v-k)+1)=inflation_int(i-(v-k)+1);
pe_coeff(2,i-(v-k)+1)=rev_int(i-(v-k)+1);
pe_coeff(3,i-(v-k)+1)=apple_int(i-(v-k)+1);
pe_coeff(4,i-(v-k)+1)=buy_int(i-(v-k)+1);

%x4--Fed funds rate
ir_coeff(1,i-(v-k)+1)=cpi_diff(i-(v-k)+1);
ir_coeff(2,i-(v-k)+1)=trapz(inflation(mo(i):mo(i+1)).*ir(mo(i)-lags(4)*30:mo(i+1)-lags(4)*30));%1 year delay-52 weeks
ir_coeff(3,i-(v-k)+1)=ir_int(i-(v-k)+1);
ir_coeff(4,i-(v-k)+1)=trapz(ir(mo(i):mo(i+1)).*AAPL(mo(i):mo((i+1))));

%x5--NASDAQ100 Index
nasdaq_coeff(1,i-(v-k)+1)=apple_int(i-(v-k)+1);
nasdaq_coeff(2,i-(v-k)+1)=sp500_int(i-(v-k)+1);
nasdaq_coeff(3,i-(v-k)+1)=trapz(ir(mo(i):mo(i+1)));
nasdaq_coeff(4,i-(v-k)+1)=conf_int(i-(v-k)+1);

%x6--Apples revenue
rev_coeff(1,i-(v-k)+1)=rev_int(i-(v-k)+1);
rev_coeff(2,i-(v-k)+1)=trapz(rd(mo(i)-lags(7)*30:mo(i+1)-lags(7)*30));
rev_coeff(3,i-(v-k)+1)=conf_int(i-(v-k)+1);
rev_coeff(4,i-(v-k)+1)=iphone_int(i-(v-k)+1);

%x7--Apple's R&D Spending
rd_coeff(1,i-(v-k)+1)=rd_int(i-(v-k)+1);
rd_coeff(2,i-(v-k)+1)=rev_int(i-(v-k)+1);
rd_coeff(3,i-(v-k)+1)=iphone_int(i-(v-k)+1);

%x8--Apples stock pricce
apple_coeff(1,i-(v-k)+1)=rev_int(i-(v-k)+1);
apple_coeff(2,i-(v-k)+1)=nasdaq_diff(i-(v-k)+1);
apple_coeff(3,i-(v-k)+1)=pe_int(i-(v-k)+1);
apple_coeff(4,i-(v-k)+1)=trapz(ir(mo(i):mo((i+1))).*AAPL(mo(i):mo(i+1)));
apple_coeff(5,i-(v-k)+1)=apple_int(i-(v-k)+1);
apple_coeff(6,i-(v-k)+1)=sp500_diff(i-(v-k)+1);
apple_coeff(7,i-(v-k)+1)=buy_diff(i-(v-k)+1);
%apple_coeff(7,i-(v-k)+1)=buy_int(i-(v-k)+1);

%x9--GLD
gld_coeff(1,i-(v-k)+1)=sp500_int(i-(v-k)+1);
gld_coeff(2,i-(v-k)+1)=conf_int(i-(v-k)+1);
gld_coeff(3,i-(v-k)+1)=inflation_int(i-(v-k)+1);
gld_coeff(4,i-(v-k)+1)=gld_int(i-(v-k)+1);

%x10--S&P 500
sp500_coeff(1,i-(v-k)+1)=ir_int(i-(v-k)+1);
sp500_coeff(2,i-(v-k)+1)=cpi_int(i-(v-k)+1);
sp500_coeff(3,i-(v-k)+1)=nasdaq_int(i-(v-k)+1);
sp500_coeff(4,i-(v-k)+1)=conf_int(i-(v-k)+1);
sp500_coeff(5,i-(v-k)+1)=sp500_int(i-(v-k)+1);

%x11--iPhone revenue
iphone_coeff(1,i-(v-k)+1)=iphone_int(i-(v-k)+1);
iphone_coeff(2,i-(v-k)+1)=trapz(rd(mo(i)-lags(7)*30:mo(i+1)-lags(7)*30));
iphone_coeff(3,i-(v-k)+1)=trapz(iphone(mo(i):mo(i+1)).*ir(mo(i)-lags(4)*30:mo(i+1)-lags(4)*30));

%x12--Consumer Confidence Index
conf_coeff(1,i-(v-k)+1)=sp500_diff(i-(v-k)+1);
conf_coeff(2,i-(v-k)+1)=ir_int(i-(v-k)+1);
conf_coeff(3,i-(v-k)+1)=cpi_int(i-(v-k)+1);
conf_coeff(4,i-(v-k)+1)=gld_int(i-(v-k)+1);

%x13--Buybacks
buy_coeff(1,i-(v-k)+1)=sp500_int(i-(v-k)+1);
buy_coeff(2,i-(v-k)+1)=rev_int(i-(v-k)+1);
buy_coeff(3,i-(v-k)+1)=rd_int(i-(v-k)+1);
end

%--------------------------------------------------------------------------
%Solve for coefficients
c1=cpi_coeff'\cpi_diff';
c2=inflation_coeff'\inflation_diff';
c3=pe_coeff'\pe_diff' ;
c4=ir_coeff'\ir_diff' ;
c5=nasdaq_coeff'\nasdaq_diff' ;
c6=rev_coeff'\rev_diff';
c7=rd_coeff'\rd_diff';
c8=apple_coeff'\apple_diff';
c9=gld_coeff'\gld_diff';
c10=sp500_coeff'\sp500_diff' ;
c11=iphone_coeff'\iphone_diff';
c12=conf_coeff'\conf_diff';
c13=buy_coeff'\buy_diff';

%Create the vector of coefficients
c=[c1;c2;c3(1:3);c4;c5;c6;c7;c8(1:5);c9;c10;c11;c12;c13;c8(6);c8(7);c3(4)];

end %of if statement


%----------save the coefficient values to a txt file-----------------------
%will use these coefficients to populate DE function
fid = fopen('coeff_forward_buy.txt','wt');  %'wt' for writing in text mode
fprintf(fid,'%f\n',c);
fclose(fid);
%--------------------------------------------------------------------------

%------------------DDE Initial Condition Vector----------------------------
%Define histroy vector--assuming all are constant
x0(1)=cpi(mo(v));
x0(2)=inflation(mo(v));
x0(3)=pe(mo(v));
x0(4)=ir(mo(v));
x0(5)=NASDAQ100(mo(v));
x0(6)=rev(mo(v));
x0(7)=rd(mo(v));
x0(8)=AAPL(mo(v));
x0(9)=gld(mo(v));
x0(10)=sp500(mo(v));
x0(11)=iphone(mo(v));
x0(12)=conf(mo(v));
x0(13)=buyback(mo(v));

%--------------------------------------------------------------------------
%Solving the DDE system

A=AAPL(mo(v):mo(v+l)); %Defining 'A' to compare DDE resuts to
time=linspace(v,v+l,length(A));
tspan=[v,v+l]; %time for which the DDE is solved--in months
sol=dde23(@delay_buy,lags, x0,tspan);      %solve DDE
