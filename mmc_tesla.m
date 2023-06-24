global count Cind Cvolt perror Ctank
count = 0;Cind = 0;Cvolt = 0;perror = 0;Ctank = 0;
loop_condition = mmc_calc('NO');
loop_condition_len = strlength(loop_condition);
while  loop_condition_len ~= 2
    loop_condition_len = strlength(loop_condition);
    if loop_condition_len == 3
        loop_condition = mmc_calc('NO');
        loop_condition_len = strlength(loop_condition);
    else
        count = 0;
        loop_condition = mmc_calc('NO');
        loop_condition_len = strlength(loop_condition);
    end
end

function loop_condition = mmc_calc(x)
global count Cind Cvolt perror Ctank
%user input branch decider based on # of times ran
if count ~= 0
    prompt = {'Individual Capacitance (uF):'};
    dims = [1 50];
    dlgtitle = 'MMC Parameters';
    usr_input = inputdlg(prompt,dlgtitle,dims);
else
    prompt = {'Individual Capacitance (uF):','MMC Capacitance (nF):','MMC Voltage (V):','Acceptable Error (%):'};
    dims = [1 50];
    dlgtitle = 'MMC Parameters';
    usr_input = inputdlg(prompt,dlgtitle,dims);
end

%input washing for production of usable datatypes
if count ~= 0
    parameters = str2double(usr_input);
else
    parameters = zeros(1,4);
    for i = 1:4
        parameters(i) = str2double(usr_input(i));
    end
end

%input parsing to break user input washed data arrays
if count ~= 0
    Cind = parameters*1e-6;
else
    Cind = parameters(1)*1e-6;
    Ctank = parameters(2)*1e-9;
    Cvolt = parameters(3);
    perror = parameters(4)/100;
end

%MMC calculations returns n number of caps in series & obtained capacitance
Crange = [Ctank- Ctank*perror,Ctank+ Ctank*perror];
n = 0;
isInside = 0;

while isInside == 0
    n=n+1;
    Ctest = ((1/Cind)*n)^-1;
    isInside = discretize(Ctest, Crange)==1;
end

Vind = round(Cvolt/n,3);
discrepancy = abs((Ctest-Ctank)/Ctest);

% dialouge output for displaying results
formatSpec_body = [' Individual Capacitor Values: %GuF %GVDC              ' ...
                   '\n Capacitor configuration: %Gs1p\n' ...
                   ' Obtained MMC Capacitance: %GnF\n' ...
                   ' Deviation Error: %G\n' ...
                   ' Would you like to change the individual capacitance value?'];
str = sprintf(formatSpec_body,Cind*1e6,Vind,n,Ctest*1e9,discrepancy);
formatSpec_title = 'MMC Values (Target: %GnF)';
title = sprintf(formatSpec_title,Ctank*1e9);
loop_condition = questdlg(str,title,'YES','CHANGE OTHER VALUES','NO','NO');
count = count + 1;
end
