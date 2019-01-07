function  c = run_simple
% Ultimatum Game
% Subjects play the ultimatum game and decides whether to accept or refuse 
% an offer. Each trial has a stimulation condition, herd type,
% Controls:
% - 'f':              Accept
% - 'g':              Reject
% Screen Order:
% - ITI Fixation Screen: 1s
% - Decision Screen:     3s
%
% We combine this with stimulation of the DLPFC and the TPJ.
% In each game block, stimulation is conditions 1-6. These are the 
% same conditions as 5-10 in the regular run.m file.
% Stimulation is off during fixation blocks.
% 
% Stimulation Conditions:
% acTpjBlock = 1, acDlpfcBlock = 2, acSyncBlock = 3, 
% rnTpjBlock = 4, rnDlpfcBlock = 5, shamBlock = 6.
% 
% BK - Feb 2017, MS - modified Sept. 2018
import neurostim.*;  

%% General Parameters
subjectID    = '999';
hostNameOrIP = '10.109.14.164';
practice     = true;
stimOn       = false;
amplitude    = 0; % mA

%% Trial Duration Parameters
decisionDuration = 3000; % milliseconds
itiDuration      = 1000;

%% Behavioral Paradigm 
if practice == true
    NUMBER_BLOCKS = 1; 
    TRIALS_PER_BLOCK = 5;
else
    NUMBER_BLOCKS = 1; 
    TRIALS_PER_BLOCK = 40;   
end

%% Stimulation Parameters
protocolName = 'rDLPFCrTPJ';
stimFileFolder = 'c:/temp/'; % Folder on the starstim machine where data
                             % are saved (must exist)
stimFrequency = 10; % Hz
rampTime = 500; % milliseconds
debugFlag = false;
eyelinkFlag = false;

%% Setup CIC and the stimuli.
c = klabRig('debug',debugFlag,'eyelink', eyelinkFlag);
c.screen.colorMode        = 'RGB';
c.screen.color.text       = [1 1 1]; % Block/Start text
c.screen.color.background = [0.15 0.15 0.15];
c.dirs.output = 'c:/temp/';
c.screen.type = 'GENERIC';
c.itiClear    = 0;
c.iti         = 0;
c.paradigm    = 'tacs-herding';
% Define total trial duration
c.trialDuration = '@game.decisionDuration + game.itiDuration';

%% Setup the dictator stimulus
ssmg = simpleslotmachinegame(c,'game');
ssmg.decisionDuration = decisionDuration;
ssmg.itiDuration      = itiDuration;
if rand >.5 % Randmoze which machine is high payout
    % Blue(slot 1) is high payout, Orange(Slot 2) is low
    ssmg.highPayoutMachineDownImage = imread('images/slot1_down.jpg');
    ssmg.lowPayoutMachineDownImage = imread('images/slot2_down.jpg');
    ssmg.highPayoutMachineUpImage = imread('images/slot1_up.jpg');
    ssmg.lowPayoutMachineUpImage = imread('images/slot2_up.jpg');
else
    % Orange(Slot 2) is high payout, Blue(Slot 1) is low
    ssmg.highPayoutMachineDownImage = imread('images/slot2_down.jpg');
    ssmg.lowPayoutMachineDownImage = imread('images/slot1_down.jpg');
    ssmg.highPayoutMachineUpImage = imread('images/slot2_up.jpg');
    ssmg.lowPayoutMachineUpImage = imread('images/slot1_up.jpg');
end
moneyImage = imread('images/euro.jpg');
ssmg.moneyImage = moneyImage;
%ssmg.moneyTexture = Screen('MakeTexture',o.window,moneyImage);

%% Setup the output file
% Create and Pass filename to herding ultimatum game object
outputFileName = strcat(subjectID,'_results.tsv');
outputFileName = strcat('tacs-social-norms\experiments-master\Matt\herding\output\',outputFileName);
ssmg.fileName   = outputFileName;
% Create output file, write header
header = {'StimulationCondition','HerdType','FramingType','OfferType',...
    'PlayerChoice','PlayerReactionTime'};
header = header.';
outputFile = fopen(outputFileName,'a'); 
fprintf(outputFile,'%s\t%s\t%s\t%s\t%s\t%s\r\n',header{:});
fclose(outputFile);

%% Define stimulation
stm = stimuli.starstim(c,hostNameOrIP);
stm.protocol  = protocolName;
stm.mode      = 'BLOCKED';
stm.type      ='tACS';
stm.frequency = stimFrequency;
stm.mean      = 0;
stm.transition = rampTime; % Ramp up/down
stm.fake = true;
stm.enabled  = stimOn;
stm.debug    = false;
stm.path     = stimFileFolder;

% Define amplitude array functions
tacs_tpj_stim_array =...
    @(x) [x floor(x*1/3) floor(x*1/3) ceil(x*1/3) 0 0 0 0];
tacs_dlpfc_stim_array =...
    @(x) [0 0 0 0 ceil(x*1/3) floor(x*1/3) floor(x*1/3) x];

%% Define All Block Types
% Corresponding Montage Array: [CP6 P4 C4 T8 F4 AF8 Fp2 AF4]
% Referene: CMS- left cheek bone area DRL- behind left ear area
% Condition 1 
acTPJ = design('AC_TPJ');
acTPJ.conditions(1).starstim.type      = 'tACS';
acTPJ.conditions(1).starstim.amplitude = tacs_tpj_stim_array(amplitude);
acTPJ.conditions(1).starstim.phase     = [0 180 180 180 0 0 0 0];
acTPJ.conditions(1).starstim.sham      = false;
acTpjBlock = block('acTPJ',acTPJ,'nrRepeats',TRIALS_PER_BLOCK,...
                   'beforeKeyPress',false,'afterKeyPress',false);
% Condition 2
acDLPFC = design('AC_DLPFC');
acDLPFC.conditions(1).starstim.type      = 'tACS';
acDLPFC.conditions(1).starstim.amplitude = tacs_dlpfc_stim_array(amplitude);
acDLPFC.conditions(1).starstim.phase     = [0 0 0 0 180 180 180 0];
acDLPFC.conditions(1).starstim.sham      = false;
acDlpfcBlock = block('acDLPFC',acDLPFC,'nrRepeats',TRIALS_PER_BLOCK,...
                     'beforeKeyPress',false,'afterKeyPress',false);
% Practice 
sham = design('SHAM');
sham.conditions(1).starstim.sham = true;
shamBlock = block('sham',sham,'nrRepeats',TRIALS_PER_BLOCK,...
    'beforeKeyPress',false,'afterKeyPress',false);

%% Condition Order 
%  acTpjBlock = 1, acDlpfcBlock = 2, rnTpjBlock = 3, rnDlpfcBlock =4. 
blockType = block.empty(0,NUMBER_BLOCKS); 
stimulationConditions = int16.empty(0,NUMBER_BLOCKS*TRIALS_PER_BLOCK); 
randomizedOrder = randperm(NUMBER_BLOCKS); % Randomized order of stim 
                                            % condition blocks. 
% Populate blockOrder array based on randomizedOrder. 
for blockTypeIndex = 1:NUMBER_BLOCKS
    switch randomizedOrder(blockTypeIndex)
        case 1
            blockType(blockTypeIndex) = acTpjBlock;
            leftIndex = ((blockTypeIndex-1)*TRIALS_PER_BLOCK)+1;
            rightIndex = (blockTypeIndex*TRIALS_PER_BLOCK);
            % Populate stimulation conditions with each trials stimulation
            % condition.
            stimulationConditions(leftIndex:rightIndex) =...
                randomizedOrder(blockTypeIndex) * ones(1,TRIALS_PER_BLOCK);
        case 2
            blockType(blockTypeIndex) = acDlpfcBlock;
            leftIndex = ((blockTypeIndex-1)*TRIALS_PER_BLOCK)+1;
            rightIndex = (blockTypeIndex*TRIALS_PER_BLOCK);
            stimulationConditions(leftIndex:rightIndex) =...
                randomizedOrder(blockTypeIndex) * ones(1,TRIALS_PER_BLOCK);
    end
end

% Determine order of conditions per trial
leftPositions = ones(20,1);
rightPositions = 2*ones(20,1);
positions = [];
for i = 1:NUMBER_BLOCKS
    rng('shuffle');
    positions = [positions,Shuffle([leftPositions;rightPositions])];
end

% Assign each trial's game type (gameOrder) and each trial's stim type    
% (stimulationConditions) of each trial to our social norms games object  
% instance ssmg. % herdOfferTypes = [partner type, offer type]                                                          
ssmg.positions = positions;
ssmg.stimulationConditions = stimulationConditions;

%% Run the experiment
if practice == true
    c.run(shamBlock,'RANDOMIZATION','ORDERED','blockOrder', 1);
else
    c.run(shamBlock,'RANDOMIZATION','ORDERED','blockOrder',1);
end

end
