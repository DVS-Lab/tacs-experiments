% stim_detect.m
% This script allows the user to manually send stimulation commands to the
% participant via the matlab command window. The user has a choice of
% [tACS,tRNS, quit].
% 
% Directions: 
% - Run file
% - Input tACS
% - Enter 90 to send 90 mA
% - Increase amplitude by 30 mA type: 30 (Do not increase by more than 30)
% - Decrease amplitude by 3 mA type: -3 (Decrease in steps of 3)
% - Once correct amplitude is reached, enter -1 to exit tACS stimulation
% - You will be brough back to the [ tACS, tRNS, quit ] menu
% - Repeat process for tRNS if needed
% - Enter quit to exit stim_detect task and display results
% - Use results as values to tACS and tRNS amplitudes in tasks
%
% MS - Jan 2019

% Parameters:
ipAddress = '10.109.9.205';
protocol  = 'rDLPFCrTPJ';
% Define stimulation array functions based on montage
tacs = @(x) [x floor(x*1/3) floor(x*1/3) ceil(x*1/3)...
             ceil(x*1/3) floor(x*1/3) floor(x*1/3) x];
trns = @(x) [x -floor(x*1/3) -floor(x*1/3)...
             -ceil(x*1/3) 0 0 0 0];
tacs_amplitude = 0; 
trns_amplitude = 0; % Value sent
f = [10 10 10 10 10 10 10 10];     % Frequency
p = [0 180 180 180 180 180 180 0]; % Phase 
t = 500;                           % Ramp up/Ramp down
c = 8;                             % Number of Electrodes
% Connect to NIC2 (stimulation) computer and start protocol
[ret, status, socket] = MatNICConnect (ipAddress)
[ret]                 = MatNICLoadProtocol (protocol, socket)
[ret]                 = MatNICStartProtocol (socket)
str = ' ';
% Main Loop
while (~strcmp(str,"quit"))
    prompt = 'Select an option: [ tACS, tRNS, quit ]';
    str = input(prompt,'s');
    switch str
        case "tACS"
            x = 0; % User input
            while (1)
                prompt = '\nAccepted Amplitude Range: tACS amplitude 0-1999(mA)\nEnter how much you want to increase/decrease: \nEnter -1 to exit tACS stimulation\n';
                x = input(prompt);
                if isempty(x)
                    x = 0;
                end
                if x == -1 % Exit tACS menu
                    break;
                end
                tacs_amplitude = tacs_amplitude + x; % Update amplitude
                if tacs_amplitude > 2000 % 2000 mA is the maximum value
                    tacs_amplitude = 0;
                end
                [ret] = MatNICOnlinetACSChange(tacs(tacs_amplitude), f, p, c, t, socket)
                sprintf("current tACS amplitude: %d", tacs_amplitude)
            end
            % Zero Signal
            [ret] = MatNICOnlinetACSChange(tacs(0), f, p, c, t, socket)
        case "tRNS"
            x = 0; % User input
            while (1)
                prompt = 'Accepted Amplitude Range: tRNS amplitude 0-640(mA)\nEnter how much you want to increase/decrease: \nEnter -1 to exit tRNS stimulation\n';
                x = input(prompt);
                if isempty(x)
                    x = 0;
                end
                if x == -1 % Exit tRNS menu
                    break;
                end
                trns_amplitude = trns_amplitude + x; % Update amplitude
                if trns_amplitude > 640 % 639 mA is the maximum value
                    trns_amplitude = 0;
                end
                [ret] = MatNICOnlineAtrnsChange(trns(trns_amplitude), c, socket)
                sprintf("current tRNS amplitude: %d", trns_amplitude)
            end
            % Zero Signal
            [ret] = MatNICOnlineAtrnsChange(trns(0), c, socket)
        case "quit"
            disp("Exiting Stim Detection Program");
    end
end

[ret] = MatNICPauseProtocol (socket)
[ret] = MatNICAbortProtocol (socket)
% Output 
sprintf("tACS Amplitude (mA) : %d", tacs_amplitude)
sprintf("tRNS Amplitude (mA) : %d", trns_amplitude)

% 009 -   468 mA, 291 mA
% 010 -  1104 mA, 630 mA
% 011 -  1999 mA, 639 mA
% 012 -  1999 mA, 639 mA
% 013 -  1999 mA, 639 mA
% 014 -   480 mA, 318 mA
% 015 -  1350 mA, 606 mA
% 016 -  1482 mA, 639 mA
% 017 -  1999 mA, 639 mA
% 018 -  n/a
% 019 -  1999 mA, 639 mA
% 020 - 
% 021 - 