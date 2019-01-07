function  c = run_pilot
% tACS Social Norms Pilot
% Subjects play the dictator or ultimatum game and decide how much money
% (0-100) to alot to a 'human' or pc opponent.
% Controls:
% - '0' through '9':  Give $0 through $90.
% - 'a':              Give $100 or all allotted funds.
% Screen Order:   
% - ITI Fixation Screen: 1s
% - Inform Screen:       2s
% - Decision Screen:     3s
% - Outcome Sc reen:     1s
% 
% We combine this with stimulation of the DLPFC and the TPJ.
% In each game block, stimulation is conditions 1-6.
% Stimulation is off during fixation blocks.
% 
% Stimulation Conditions:
% acTpjBlock = 1, acDlpfcBlock = 2,
% acSyncBlock = 3, rnTpjBlock = 4, rnDlpfcBlock = 5, shamBlock = 6.
% 
% BK - Feb 2017, MS - modified Sept. 2018
import neurostim.*; 

%% General Parameters
subjectID      = '023'; 
hostNameOrIP   = '10.109.9.205'; % Update with actual IP address of starstim PC.
practice       = false; 
tacs_amplitude = 1999;  
trns_amplitude = 639; 

%% Trial Duration Parameters
decisionDuration = 3000; % milliseconds
outcomeDuration  = 1000;
informDuration   = 2000;
itiDuration      = 1000;

%% Behavioral Paradigm 
if practice == true
    subjectID    = '999';
    NUMBER_BLOCKS = 1; 
    TRIALS_PER_BLOCK = 20;
else
    NUMBER_BLOCKS = 6; 
    TRIALS_PER_BLOCK = 20;   
end

%% Stimulation Parameters
protocolName = 'rDLPFCrTPJ';
stimFileFolder = 'c:/temp/'; % Folder on the starstim machine where data
                             % are saved (must exist)
stimFrequency = 10; % Hz
rampTime = 500;                  
debugFlag = false;
eyelinkFlag = false;


%% Setup CIC and the stimuli.
c = klabRig('debug',debugFlag,'eyelink', eyelinkFlag);
c.screen.colorMode        = 'RGB'; % Specify colors as RGB gunvalue sbetween 0 and 1 (uncalibrated).
c.screen.color.text       = [1 1 1];  % Block/Start text
c.screen.color.background = [0.15 0.15 0.15];
c.dirs.output = 'c:/temp/';
c.screen.type = 'GENERIC';
c.itiClear    = 0;
c.iti         = 0;
c.paradigm    = 'tacs-social-norms';
% Define total trial duration
c.trialDuration = '@game.decisionDuration + game.informDuration + game.outcomeDuration + game.itiDuration';

%% Setup the social norms games(Ultimatum & Dictator) stimulus
sng = socialnormsgames(c,'game');
sng.textColor        = [1 1 1];
sng.decisionDuration = decisionDuration;
sng.outcomeDuration  = outcomeDuration;
sng.informDuration   = informDuration;
sng.itiDuration      = itiDuration;

%% Setup the output file
% Create and Pass filename to socialnorms games object
outputFileName = strcat(subjectID,'_results.tsv');
outputFileName = strcat('tacs-social-norms\experiments-master\Matt\socialnorms\output\',outputFileName);
sng.fileName = outputFileName;
% Save header to output file
header = {'Condition','GameType','OpponentType','PlayerChoice','PlayerRT',...
    'OpponentLoss','PlayerLoss'};
header = header.';
outputFile = fopen(outputFileName,'a'); 
fprintf(outputFile,'%s\t%s\t%s\t%s\t%s\t%s\t%s\r\n',header{:});
fclose(outputFile);

%% Define stimulation
stm = stimuli.starstim(c,hostNameOrIP);
stm.protocol  = protocolName;
stm.mode      = 'BLOCKED';
stm.type      ='tACS';
stm.frequency = stimFrequency;
stm.mean      = 0;
stm.transition = rampTime; % Ramp up/down
stm.sham = false;
if practice == true
    stm.fake = true;
    stm.enabled  = false;
else
    stm.fake = false;
    stm.enabled  = true;
end
stm.debug    = false;
stm.path     = stimFileFolder;

% Define amplitude array functions
tacs_tpj_stim_array = @(x) [x floor(x*1/3) floor(x*1/3) ceil(x*1/3) 0 0 0 0];
tacs_dlpfc_stim_array = @(x) [0 0 0 0 ceil(x*1/3) floor(x*1/3) floor(x*1/3) x];
tacs_tpj_dlpfc_stim_array = @(x) [x floor(x*1/3) floor(x*1/3) ceil(x*1/3) ceil(x*1/3) floor(x*1/3) floor(x*1/3) x];
trns_tpj_stim_array = @(x) [x -floor(x*1/3) -floor(x*1/3) -ceil(x*1/3) 0 0 0 0];
trns_dlpfc_stim_array = @(x) [0 0 0 0 -ceil(x*1/3) -floor(x*1/3) -floor(x*1/3) x];

%% Define All Block Types
% Corresponding Montage Array: [CP6 P4 C4 T8 F4 AF8 Fp2 AF4]
% Condition 1
acTPJ = design('AC_TPJ');
acTPJ.conditions(1).starstim.type = 'tACS';
acTPJ.conditions(1).starstim.amplitude = tacs_tpj_stim_array(tacs_amplitude);
acTPJ.conditions(1).starstim.phase = [0 180 180 180 0 0 0 0];
acTPJ.conditions(1).starstim.sham = false;
acTpjBlock = block('acTPJ',acTPJ,'nrRepeats',TRIALS_PER_BLOCK,'beforeKeyPress',false,'afterKeyPress',false);
% Condition 2 
acDLPFC = design('AC_DLPFC');
acDLPFC.conditions(1).starstim.type      = 'tACS';
acDLPFC.conditions(1).starstim.amplitude = tacs_dlpfc_stim_array(tacs_amplitude);
acDLPFC.conditions(1).starstim.phase     = [0 0 0 0 180 180 180 0];
acDLPFC.conditions(1).starstim.sham      = false;
acDlpfcBlock = block('acDLPFC',acDLPFC,'nrRepeats',TRIALS_PER_BLOCK,'beforeKeyPress',false,'afterKeyPress',false);
% Condition 3 
acSYNC = design('AC_DLPFC_TPJ_SYNC');
acSYNC.conditions(1).starstim.type = 'tACS';
acSYNC.conditions(1).starstim.amplitude = tacs_tpj_dlpfc_stim_array(tacs_amplitude);
acSYNC.conditions(1).starstim.phase = [0 180 180 180 180 180 180 0];
acSYNC.conditions(1).starstim.sham = false;
acSyncBlock = block('acSYNC',acSYNC,'nrRepeats',TRIALS_PER_BLOCK,'beforeKeyPress',false,'afterKeyPress',false);
% Condition 4 
rnTPJ = design('RN_TPJ');
rnTPJ.conditions(1).starstim.type = 'tRNS';
rnTPJ.conditions(1).starstim.amplitude = trns_tpj_stim_array(trns_amplitude);
rnTPJ.conditions(1).starstim.phase = [0 0 0 0 0 0 0 0];
rnTPJ.conditions(1).starstim.sham = false;
rnTpjBlock = block('rnTPJ',rnTPJ,'nrRepeats',TRIALS_PER_BLOCK,'beforeKeyPress',false,'afterKeyPress',false);
% Condition 5 
rnDLPFC = design('RN_DLPFC');
rnDLPFC.conditions(1).starstim.type = 'tRNS';
rnDLPFC.conditions(1).starstim.amplitude = trns_dlpfc_stim_array(trns_amplitude);
rnDLPFC.conditions(1).starstim.phase = [0 0 0 0 0 0 0 0];
rnDLPFC.conditions(1).starstim.sham = false;
rnDlpfcBlock = block('rnDLPFC',rnDLPFC,'nrRepeats',TRIALS_PER_BLOCK,'beforeKeyPress',false,'afterKeyPress',false);
% Condition 6 
sham = design('SHAM');
sham.conditions(1).starstim.type = 'tACS';
sham.conditions(1).starstim.amplitude = tacs_tpj_dlpfc_stim_array(tacs_amplitude);
sham.conditions(1).starstim.phase = [0 180 180 180 180 180 180 0];
sham.conditions(1).starstim.sham = true;
shamBlock = block('sham',sham,'nrRepeats',TRIALS_PER_BLOCK,'beforeKeyPress',false,'afterKeyPress',false);

%% Condition Order
% dcAnodalTPJBlock = 1, dcCathodalTPJBlock = 2, dcAnodalDlpfcBlock = 3,
% dcCathodalDlpfcBlock = 4, acTpjBlock = 5, acDlpfcBlock = 6,
% acSyncBlock = 7, rnTpjBlock = 8, rnDlpfcBlock = 9, shamBlock = 10
blockType = block.empty(0,NUMBER_BLOCKS); % 
trialConditions = int16.empty(0,NUMBER_BLOCKS*TRIALS_PER_BLOCK); % 1x400
randomizedOrder = randperm(NUMBER_BLOCKS)'; % Randomized order of stim
                                           % condition blocks. (1-10)
% Populate blockOrder array based on randomizedOrder.
for blockTypeIndex = 1:NUMBER_BLOCKS
    switch randomizedOrder(blockTypeIndex)
        case 1
            blockType(blockTypeIndex) = acTpjBlock;
            leftIndex = ((blockTypeIndex-1)*TRIALS_PER_BLOCK)+1;
            rightIndex = (blockTypeIndex*TRIALS_PER_BLOCK);
            trialConditions(leftIndex:rightIndex) =...
                randomizedOrder(blockTypeIndex) * ones(1,TRIALS_PER_BLOCK);
        case 2
            blockType(blockTypeIndex) = acDlpfcBlock;
            leftIndex = ((blockTypeIndex-1)*TRIALS_PER_BLOCK)+1;
            rightIndex = (blockTypeIndex*TRIALS_PER_BLOCK);
            trialConditions(leftIndex:rightIndex) =...
                randomizedOrder(blockTypeIndex) * ones(1,TRIALS_PER_BLOCK);
        case 3
            blockType(blockTypeIndex) = acSyncBlock;
            leftIndex = ((blockTypeIndex-1)*TRIALS_PER_BLOCK)+1;
            rightIndex = (blockTypeIndex*TRIALS_PER_BLOCK);
            trialConditions(leftIndex:rightIndex) =...
                randomizedOrder(blockTypeIndex) * ones(1,TRIALS_PER_BLOCK);
        case 4
            blockType(blockTypeIndex) = rnTpjBlock;
            leftIndex = ((blockTypeIndex-1)*TRIALS_PER_BLOCK)+1;
            rightIndex = (blockTypeIndex*TRIALS_PER_BLOCK);
            trialConditions(leftIndex:rightIndex) =...
                randomizedOrder(blockTypeIndex) * ones(1,TRIALS_PER_BLOCK);
        case 5
            blockType(blockTypeIndex) = rnDlpfcBlock;
            leftIndex = ((blockTypeIndex-1)*TRIALS_PER_BLOCK)+1;
            rightIndex = (blockTypeIndex*TRIALS_PER_BLOCK);
            trialConditions(leftIndex:rightIndex) =...
                randomizedOrder(blockTypeIndex) * ones(1,TRIALS_PER_BLOCK);
        case 6
            blockType(blockTypeIndex) = shamBlock;
            leftIndex = ((blockTypeIndex-1)*TRIALS_PER_BLOCK)+1;
            rightIndex = (blockTypeIndex*TRIALS_PER_BLOCK);
            trialConditions(leftIndex:rightIndex) =...
                randomizedOrder(blockTypeIndex) * ones(1,TRIALS_PER_BLOCK);
    end
end

% Determine order of gameType: 1x400 array containing each trials game type 
totalTrials = TRIALS_PER_BLOCK * NUMBER_BLOCKS;
gameOrder = zeros(totalTrials,2); % [stim type, offer type]
partnerGamePerumations = fullfact([2 2]);
partnerGamePerumations = [partnerGamePerumations;partnerGamePerumations;...
                          partnerGamePerumations;partnerGamePerumations;
                          partnerGamePerumations];
for i = 1:NUMBER_BLOCKS
    rng('shuffle');
    shuffledArray = partnerGamePerumations(randperm(size(partnerGamePerumations,1)),:); 
    leftIndex = ((i-1) * TRIALS_PER_BLOCK)+1; 
    rightIndex = (i * TRIALS_PER_BLOCK);
    gameOrder(leftIndex:rightIndex,:) = shuffledArray;
end
% Assign the each trials game type (gameOrder) and each trials stim type
% (trialConditions) of each trial to our social norms games object
% instance sng.
sng.gameOrder = gameOrder;
sng.trialConditions = trialConditions;

%% Run the experiment
if practice == true
    c.run(shamBlock,'RANDOMIZATION','ORDERED','blockOrder', 1);
else
    c.run(blockType(1),blockType(2),blockType(3),blockType(4),blockType(5),...
        blockType(6),'RANDOMIZATION','ORDERED','blockOrder',randomizedOrder');
end

end
