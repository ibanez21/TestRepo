import pandas as pd
import numpy as np
from scipy.integrate import odeint
import pdb

look_back_window = 7

# Import csv files into data frames

ffr = pd.read_csv('EFFR.csv',header=0,names=['Date','Fed Funds'])
bb = pd.read_csv('buyback.csv',header=0,names=['Date','Buy Backs'])
cci = pd.read_csv('cci_oecd.csv',header=0,names=['Date','CCI'])
iphone = pd.read_csv('iphone_rev.csv',header=0,names=['Date','IPhone_Rev'])
gld = pd.read_csv('GLD.csv',header=0,names=['Date','GOLD'])
aapl = pd.read_csv('AAPL3.csv')
rd = pd.read_csv('RandD.csv',header=0,names=['Date','R&D'])
nas = pd.read_csv('NASDAQ100.csv',header=0,names=['Date','NSD'])
pe = pd.read_csv('pe_apple.csv',header=0,skiprows=365,names=['Date','P/E'])
cpi = pd.read_csv('CPI2.csv',header=0,names=['Date','CPI'])
inf= pd.read_csv('inf.csv',header=0,names=['Date','Inflation'])
sandp = pd.read_csv('GSPC.csv',header=0,names=['Date','S&P'])
net_inc = pd.read_csv('net_income.csv',header=0,names=['Date','Net Income'])

macro_vars = [ffr,bb,cci,iphone,gld,aapl,rd,nas,pe,cpi,inf,sandp,net_inc]

### DATA PREPROCESSING AND CLEANING

# Apple stock price data needs unique cleaning

aapl.at[1,'Open'] = 28.5
aapl = aapl[1:]
aapl = aapl[['Date','Open']]
aapl.index = range(4053)

macro_vars = [ffr,bb,cci,iphone,gld,aapl,rd,nas,pe,cpi,inf,sandp,net_inc]
for var in macro_vars:
    var_name = list(var)[1]
    # replace NAN's with 0
    var[var_name].fillna(0,inplace=True)
    # some variables begin at 12/31/07, if so replace value if 01/01/08 is 0
    if var.loc[0]['Date'][-2:] == '07':
        if var.loc[1][var_name] == 0:
            var.at[1,var_name] = var.at[0,var_name]
            var = var[1:]
        else:
            var = var[1:]

    # make sure all data ends on 12/30/18
    var = var[:4017]

    # linear interpolation, all data will now be daily
    xvals = range(4017)
    data_arr = var[var_name].to_list()

    # get non-zero valued indices of array
    nonzero_ind = np.nonzero(data_arr)[0]
    # remove 0's from array
    nonzero_var = [num for num in data_arr if num]

    interp_data = np.interp(xvals, nonzero_ind, nonzero_var)
    var[var_name] = interp_data

### END OF DATA PREPROCESSING AND CLEANING

#-----------------------------------------------------------------------------

### SOLVE FOR COEFFICIENTS

cpi_int = np.zeros(look_back_window)
cpi_diff = np.zeros(look_back_window)
cpi_coeff = np.zeros((1,look_back_window))
inf_int = np.zeros(look_back_window)
inf_diff = np.zeros(look_back_window)
inf_coeff = np.zeros((3,look_back_window))
pe_int = np.zeros(look_back_window)
pe_diff = np.zeros(look_back_window)
pe_coeff = np.zeros((4,look_back_window))
ffr_int = np.zeros(look_back_window)
ffr_diff = np.zeros(look_back_window)
ffr_coeff = np.zeros((4,look_back_window))
nas_int = np.zeros(look_back_window)
nas_diff = np.zeros(look_back_window)
nas_coeff = np.zeros((4,look_back_window))
net_inc_int = np.zeros(look_back_window)
net_inc_diff = np.zeros(look_back_window)
net_inc_coeff = np.zeros((4,look_back_window))
rd_int = np.zeros(look_back_window)
rd_diff = np.zeros(look_back_window)
rd_coeff = np.zeros((3,look_back_window))
aapl_int = np.zeros(look_back_window)
aapl_diff = np.zeros(look_back_window)
aapl_coeff = np.zeros((7,look_back_window))
gld_int = np.zeros(look_back_window)
gld_diff = np.zeros(look_back_window)
gld_coeff = np.zeros((4,look_back_window))
sandp_int = np.zeros(look_back_window)
sandp_diff = np.zeros(look_back_window)
sandp_coeff = np.zeros((5,look_back_window))
iphone_int = np.zeros(look_back_window)
iphone_diff = np.zeros(look_back_window)
iphone_coeff = np.zeros((3,look_back_window))
cci_int = np.zeros(look_back_window)
cci_diff = np.zeros(look_back_window)
cci_coeff = np.zeros((4,look_back_window))
bb_int = np.zeros(look_back_window)
bb_diff = np.zeros(look_back_window)
bb_coeff = np.zeros((3,look_back_window))

# Calculate (most, not all) of integration and difference terms

for i in range(look_back_window):
    cpi_int[i] = np.trapz(cpi['CPI'][i*30:(i+1)*30])
    cpi_diff[i] = cpi['CPI'][(i+1)*30] - cpi['CPI'][i*30]
    inf_int[i] = np.trapz(inf['Inflation'][i*30:(i+1)*30])
    inf_diff[i] = inf['Inflation'][(i+1)*30] - inf['Inflation'][i*30]
    pe_int[i] = np.trapz(pe['P/E'][i*30:(i+1)*30])
    pe_diff[i] = pe['P/E'][(i+1)*30] - pe['P/E'][i*30]
    ffr_int[i] = np.trapz(ffr['Fed Funds'][i*30:(i+1)*30])
    ffr_diff[i] = ffr['Fed Funds'][(i+1)*30] - ffr['Fed Funds'][i*30]
    nas_int[i] = np.trapz(nas['NSD'][i*30:(i+1)*30])
    nas_diff[i] = nas['NSD'][(i+1)*30] - nas['NSD'][i*30]
    net_inc_int[i] = np.trapz(net_inc['Net Income'][i*30:(i+1)*30])
    net_inc_diff[i] = net_inc['Net Income'][(i+1)*30] - net_inc['Net Income'][i*30]
    rd_int[i] = np.trapz(rd['R&D'][i*30:(i+1)*30])
    rd_diff[i] = rd['R&D'][(i+1)*30] - rd['R&D'][i*30]
    aapl_int[i] = np.trapz(aapl['Open'][i*30:(i+1)*30])
    aapl_int[i] = aapl['Open'][(i+1)*30] - aapl['Open'][i*30]
    gld_int[i] = np.trapz(gld['GOLD'][i*30:(i+1)*30])
    gld_diff[i] = gld['GOLD'][(i+1)*30] - gld['GOLD'][i*30]
    sandp_int[i] = np.trapz(sandp['S&P'][i*30:(i+1)*30])
    sandp_diff[i] = sandp['S&P'][(i+1)*30] - sandp['S&P'][i*30]
    iphone_int[i] = np.trapz(iphone['IPhone_Rev'][i*30:(i+1)*30])
    iphone_diff[i] = iphone['IPhone_Rev'][(i+1)*30] - iphone['IPhone_Rev'][i*30]
    cci_int[i] = np.trapz(cci['CCI'][i*30:(i+1)*30])
    cci_diff[i] = cci['CCI'][(i+1)*30] - cci['CCI'][i*30]
    bb_int[i] = np.trapz(bb['Buy Backs'][i*30:(i+1)*30])
    bb_diff[i] = bb['Buy Backs'][(i+1)*30] - bb['Buy Backs'][i*30]

# Calculate coefficient matrices

for i in range(look_back_window):
    cpi_coeff[0,i] = np.trapz(cpi['CPI'][i*30:(i+1)*30] * inf['Inflation'][i*30:(i+1)*30])

    inf_coeff[0,i] = cpi_int[i]
    inf_coeff[1,i] = np.trapz(ffr['Fed Funds'][i*30:(i+1)*30] * inf['Inflation'][i*30:(i+1)*30])
    inf_coeff[2,i] = inf_int[i]

    pe_coeff[0,i] = inf_int[i]
    pe_coeff[1,i] = net_inc_int[i]
    pe_coeff[2,i] = aapl_int[i]
    pe_coeff[3,i] = bb_int[i]

    ffr_coeff[0,i] = cpi_diff[i]
    ffr_coeff[1,i] = ffr_int[i]
    ffr_coeff[2,i] = np.trapz(inf['Inflation'][i*30:(i+1)*30] * ffr['Fed Funds'][i*30:(i+1)*30])
    ffr_coeff[3,i] = np.trapz(ffr['Fed Funds'][i*30:(i+1)*30] * aapl['Open'][i*30:(i+1)*30])

    nas_coeff[0,i] = aapl_int[i]
    nas_coeff[1,i] = sandp_int[i]
    nas_coeff[2,i] = ffr_int[i]
    nas_coeff[3,i] = cci_int[i]

    net_inc_coeff[0,i] = net_inc_int[i]
    net_inc_coeff[1,i] = rd_int[i]
    net_inc_coeff[2,i] = iphone_int[i]
    net_inc_coeff[3,i] = cci_int[i]

    rd_coeff[0,i] = rd_int[i]
    rd_coeff[1,i] = net_inc_int[i]
    rd_coeff[2,i] = iphone_int[i]

    aapl_coeff[0,i] = net_inc_int[i]
    aapl_coeff[1,i] = nas_diff[i]
    aapl_coeff[2,i] = aapl_int[i]
    aapl_coeff[3,i] = np.trapz(ffr['Fed Funds'][i*30:(i+1)*30] * aapl['Open'][i*30:(i+1)*30])
    aapl_coeff[4,i] = pe_int[i]
    aapl_coeff[5,i] = sandp_diff[i]
    aapl_coeff[6,i] = bb_diff[i]

    gld_coeff[0,i] = sandp_int[i]
    gld_coeff[1,i] = cci_int[i]
    gld_coeff[2,i] = inf_int[i]
    gld_coeff[3,i] = gld_int[i]

    sandp_coeff[0,i] = sandp_int[i]
    sandp_coeff[1,i] = ffr_int[i]
    sandp_coeff[2,i] = cpi_int[i]
    sandp_coeff[3,i] = nas_int[i]
    sandp_coeff[4,i] = cci_int[i]

    iphone_coeff[0,i] = rd_int[i]
    iphone_coeff[1,i] = iphone_int[i]
    iphone_coeff[2,i] = np.trapz(ffr['Fed Funds'][i*30:(i+1)*30] * iphone['IPhone_Rev'][i*30:(i+1)*30])

    cci_coeff[0,i] = sandp_diff[i]
    cci_coeff[1,i] = gld_int[i]
    cci_coeff[2,i] = ffr_int[i]
    cci_coeff[3,i] = cpi_int[i]

    bb_coeff[0,i] = sandp_int[i]
    bb_coeff[1,i] = net_inc_int[i]
    bb_coeff[2,i] = rd_int[i]

# Solve for coefficients and append to coefficients list

c = []
var_pairs = [(cpi_coeff,cpi_diff),(inf_coeff, inf_diff),(pe_coeff,pe_diff),(ffr_coeff,ffr_diff),
             (nas_coeff,nas_diff),(net_inc_coeff,net_inc_diff),(rd_coeff, rd_diff),(aapl_coeff,aapl_diff),
             (gld_coeff,gld_diff),(sandp_coeff,sandp_diff),(iphone_coeff,iphone_diff),(cci_coeff,cci_diff),
             (bb_coeff,bb_diff)]
for pair in var_pairs:
    coeffs = np.matrix.flatten(np.linalg.lstsq(pair[0].transpose(),pair[1],rcond=None)[0])
    for coefficients in coeffs:
        c.append(coefficients)


### END SOLVE FOR COEFFICIENTS

#--------------------------------------------------------------------------------------------------

# Initial conditions for Diff Eq
init_conds = [cpi['CPI'][look_back_window*30], inf['Inflation'][look_back_window*30],pe['P/E'][look_back_window*30],
           ffr['Fed Funds'][look_back_window*30], nas['NSD'][look_back_window*30], net_inc['Net Income'][look_back_window*30],
           rd['R&D'][look_back_window*30], aapl['Open'][look_back_window*30], gld['GOLD'][look_back_window*30],
           sandp['S&P'][look_back_window*30], iphone['IPhone_Rev'][look_back_window*30], cci['CCI'][look_back_window*30],
           bb['Buy Backs'][look_back_window*30]]

def model(x,t):
    dxdt = np.zeros(13)
    dxdt[0] = c[0]*x[1]*x[0]
    dxdt[1] = c[1]*x[0] + c[2]*x[3] + c[3]*x[1]
    dxdt[2] = c[4]*x[1] + c[5]*x[5] + c[6]*x[7] + c[7]*x[12]
    dxdt[3] = c[8]*dxdt[0] + c[9]*x[3] + c[10]*x[1]*x[3] +c[11]*x[3]*x[7]
    dxdt[4] = c[12]*x[7] + c[13]*x[9] + c[14]*x[3] + c[15]*x[11]
    dxdt[5] = c[16]*x[5] + c[17]*x[6] + c[18]*x[10] + c[19]*x[11]
    dxdt[6] = c[20]*x[6] + c[21]*x[5] + c[22]*x[10]
    dxdt[7] = c[23]*x[5] + c[24]*dxdt[5] + c[25]*x[7] + c[26]*x[7]*x[3] + c[27]*x[2] + c[28]*dxdt[9] + c[29]*dxdt[12]
    dxdt[8] = c[30]*x[9] + c[31]*x[11] + c[32]*x[1] + c[33]*x[8]
    dxdt[9] = c[34]*x[9] + c[35]*x[3] + c[36]*x[0] + c[37]*x[4] + c[38]*x[11]
    dxdt[10] = c[39]*x[6] + c[40]*x[10] + c[41]*x[3]*x[10]
    dxdt[11] = c[42]*x[9] + c[43]*x[8] + c[44]*x[3] + c[45]*x[0]
    dxdt[12] = c[46]*x[9] + c[47]*x[5] + c[48]*x[6]

    return dxdt

A = aapl['Open'][look_back_window*30:(look_back_window+1)*30]
tspan = [look_back_window*30,(look_back_window+1)*30]
sol = odeint(model,init_conds,tspan)
