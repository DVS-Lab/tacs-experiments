function  c = run_simple
% Learning Task
% Participants play a simple slot machines game.
% In each block, a new slot machine combination is chosen.
% One machine is randomly assigned to be the high payout machine.
% The other is assigned to be low payout.
% Controls:
% - '1':              Left Option
% - '0':              Right Option
% Screen Order:
% - ITI Fixation Screen: 1s
% - Decision Screen:     1.5s
%
% We combine this with stimulation of the DLPFC and the TPJ.
% In each game block, stimulation is conditions 1-8.
% Stimulation is off during break blocks.
% 
% Stimulation Conditions:
% acRPFCBlock = 1, acLPFCBlock = 2, acSyncBlock = 3, 
% rnTpjBlock = 4, rnDlpfcBlock = 5, shamBlock = 6.
% 
% BK - Feb 2017, MS - modified Feb. 2019
import neurostim.*;  

%% General Parameters
subjectID    = '999';
hostNameOrIP = '10.109.14.164';
practice     = false;
stimOn       = false;
tacs_amplitude    = 0; % mA

%% Trial Duration Parameters
decisionDuration = 1500; % milliseconds
itiDuration      = 1000;

%% Behavioral Paradigm 
if practice == true
    NUMBER_BLOCKS = 1; 
    TRIALS_PER_BLOCK = 40;
else
    NUMBER_BLOCKS = 8; 
    TRIALS_PER_BLOCK = 40; 
    TRIALS_PER_BREAK = 48;
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

%% Setup the slot machine game stimulus
ssmg = simpleslotmachinegame(c,'game');
ssmg.decisionDuration = decisionDuration;
ssmg.itiDuration      = itiDuration;

%% Get Slot Machine Images
path = 'C:\Users\mslip\OneDrive\Documents\MATLAB\tacs-social-norms\experiments-master\Matt\tacs_learning\images';
imagesRaw = dir(fullfile(path, '*.jpg'));
images = fullfile(path, {imagesRaw.name});

slotMachineFilePaths = [];
for i = 1:4:length(images)
    machineCombination = [];
    if rand > .5
        machineCombination = [images(i),images(i+1),images(i+2),images(i+3)];
    else
        machineCombination = [images(i+2),images(i+3),images(i),images(i+1)];
    end
    slotMachineFilePaths = [slotMachineFilePaths; machineCombination];
end
sortedMachineFilePaths = slotMachineFilePaths(randperm(size(slotMachineFilePaths, 1)), :);
machineFiles = [];
for i = 1:NUMBER_BLOCKS
    blockFiles = [];
    for j = 1:(TRIALS_PER_BLOCK)
        blockFiles = [blockFiles;sortedMachineFilePaths(i,:)];
    end
    if i < NUMBER_BLOCKS
        for j = 1:(TRIALS_PER_BREAK)
            blockFiles = [blockFiles;sortedMachineFilePaths(i,:)];
        end
    end
    machineFiles = [machineFiles;blockFiles];
end
ssmg.imageFiles = machineFiles;
% if rand >.5 % Randmoze which machine is high payout
%     ssmg.highPayoutMachineDownImage = imread(ssmg.imageFiles{ssmg.machineCounter,1});
%     ssmg.highPayoutMachineUpImage = imread(ssmg.imageFiles{ssmg.machineCounter,2});
%     ssmg.lowPayoutMachineDownImage = imread(ssmg.imageFiles{ssmg.machineCounter,3});
%     ssmg.lowPayoutMachineUpImage = imread(ssmg.imageFiles{ssmg.machineCounter,4});
% else
%     ssmg.highPayoutMachineDownImage = imread(ssmg.imageFiles{ssmg.machineCounter,3});
%     ssmg.highPayoutMachineUpImage = imread(ssmg.imageFiles{ssmg.machineCounter,4});
%     ssmg.lowPayoutMachineDownImage = imread(ssmg.imageFiles{ssmg.machineCounter,1});
%     ssmg.lowPayoutMachineUpImage = imread(ssmg.imageFiles{ssmg.machineCounter,2});
% end
moneyImage = imread('images/coin.png');
ssmg.moneyImage = moneyImage;
%ssmg.moneyTexture = Screen('MakeTexture',o.window,moneyImage);

%% Setup the output file
% Create and Pass filename to herding ultimatum game object
outputFileName = strcat(subjectID,'_results.tsv');
outputFileName = strcat('tacs-social-norms\experiments-master\Matt\tacs_learning\output\',outputFileName);
ssmg.fileName   = outputFileName;
% Create output file, write header
header = {'TrialNumber','BlockNumber','StimulationCondition','Choice','Payout','PlayerReactionTime'};
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
tacs_tpj_stim_array = @(x) [x floor(x*1/3) floor(x*1/3) ceil(x*1/3) 0 0 0 0];
tacs_dlpfc_stim_array = @(x) [0 0 0 0 ceil(x*1/3) floor(x*1/3) floor(x*1/3) x];
tacs_tpj_dlpfc_stim_array = @(x) [x floor(x*1/3) floor(x*1/3) ceil(x*1/3) ceil(x*1/3) floor(x*1/3) floor(x*1/3) x];

%% Define All Block Types
% Corresponding Montage Array: [CP6 P4 C4 T8 F4 AF8 Fp2 AF4]
% Referene: CMS- left cheek bone area DRL- behind left ear area
% Condition 1 & 5
acTPJ = design('AC_TPJ');
acTPJ.conditions(1).starstim.enabled = true;
acTPJ.conditions(1).starstim.type      = 'tACS';
acTPJ.conditions(1).starstim.amplitude = tacs_tpj_stim_array(tacs_amplitude);
acTPJ.conditions(1).starstim.phase     = [0 180 180 180 0 0 0 0];
acTPJ.conditions(1).starstim.sham      = false;
acTpjBlock = block('acTPJ',acTPJ,'nrRepeats',TRIALS_PER_BLOCK,'beforeKeyPress',false,'afterKeyPress',false);

% Condition 2 & 6
acDLPFC = design('AC_DLPFC');
acDLPFC.conditions(1).starstim.enabled = true;
acDLPFC.conditions(1).starstim.type      = 'tACS';
acDLPFC.conditions(1).starstim.amplitude = tacs_dlpfc_stim_array(tacs_amplitude);
acDLPFC.conditions(1).starstim.phase     = [0 0 0 0 180 180 180 0];
acDLPFC.conditions(1).starstim.sham      = false;
acDlpfcBlock = block('acDLPFC',acDLPFC,'nrRepeats',TRIALS_PER_BLOCK,'beforeKeyPress',false,'afterKeyPress',false);

% Condition 3 & 7
acSYNC = design('AC_DLPFC_TPJ_SYNC');
acSYNC.conditions(1).starstim.enabled = true;
acSYNC.conditions(1).starstim.type      = 'tACS';
acSYNC.conditions(1).starstim.amplitude = tacs_tpj_dlpfc_stim_array(tacs_amplitude);
acSYNC.conditions(1).starstim.phase     = [0 180 180 180 180 180 180 0];
acSYNC.conditions(1).starstim.sham      = false;
acSyncBlock = block('acSYNC',acSYNC,'nrRepeats',TRIALS_PER_BLOCK,'beforeKeyPress',false,'afterKeyPress',false);

% Condition 4 & 8
sham = design('SHAM');
sham.conditions(1).starstim.enabled = true;
sham.conditions(1).starstim.type      = 'tACS';
sham.conditions(1).starstim.amplitude = tacs_tpj_dlpfc_stim_array(tacs_amplitude);
sham.conditions(1).starstim.phase     = [0 180 180 180 180 180 180 0];
sham.conditions(1).starstim.sham      = true;
shamBlock = block('sham',sham,'nrRepeats',TRIALS_PER_BLOCK,'beforeKeyPress',false,'afterKeyPress',false);

% Condition 9
break2min = design('BREAK2MIN');
break2min.conditions(1).starstim.enabled = false;
breakBlock = block('break2min',break2min,'nrRepeats',TRIALS_PER_BREAK,'beforeKeyPress',false,'afterKeyPress',false);

%% Condition Order 
% Populate blockOrder array based on randomizedOrder. 
blockType = block.empty(0,NUMBER_BLOCKS);  
stimConditions = []; 

mySquare = latinSquare(8);
stimBlockOrder = mySquare(mod(str2num(subjectID),8),:);

stimBlockOrder = [stimBlockOrder(1) 9 stimBlockOrder(2) 9 stimBlockOrder(3)...
   9 stimBlockOrder(4) 9 stimBlockOrder(5) 9 stimBlockOrder(6)...
   9 stimBlockOrder(7) 9 stimBlockOrder(8)];
% Populate blockOrder array based on stimBlockOrder.
for blockTypeIndex = 1:NUMBER_BLOCKS+(NUMBER_BLOCKS-1)
    switch stimBlockOrder(blockTypeIndex)
        case 1
            blockType(blockTypeIndex) = acTpjBlock;
            stimConditions = [stimConditions,...
                stimBlockOrder(blockTypeIndex) * ones(1,TRIALS_PER_BLOCK)];
        case 2
            blockType(blockTypeIndex) = acDlpfcBlock;
            stimConditions = [stimConditions,...
                stimBlockOrder(blockTypeIndex) * ones(1,TRIALS_PER_BLOCK)];
        case 3
            blockType(blockTypeIndex) = acSyncBlock;
            stimConditions = [stimConditions,...
                stimBlockOrder(blockTypeIndex) * ones(1,TRIALS_PER_BLOCK)];
        case 4
            blockType(blockTypeIndex) = shamBlock;
            stimConditions = [stimConditions,...
                stimBlockOrder(blockTypeIndex) * ones(1,TRIALS_PER_BLOCK)];
        case 5
            blockType(blockTypeIndex) = acTpjBlock;
            stimConditions = [stimConditions,...
                stimBlockOrder(blockTypeIndex) * ones(1,TRIALS_PER_BLOCK)];
        case 6
            blockType(blockTypeIndex) = acDlpfcBlock;
            stimConditions = [stimConditions,...
                stimBlockOrder(blockTypeIndex) * ones(1,TRIALS_PER_BLOCK)];
        case 7
            blockType(blockTypeIndex) = acSyncBlock;
            stimConditions = [stimConditions,...
                stimBlockOrder(blockTypeIndex) * ones(1,TRIALS_PER_BLOCK)];
        case 8
            blockType(blockTypeIndex) = shamBlock;
            stimConditions = [stimConditions,...
                stimBlockOrder(blockTypeIndex) * ones(1,TRIALS_PER_BLOCK)];
        case 9
            blockType(blockTypeIndex) = breakBlock;
            stimConditions = [stimConditions,...
                stimBlockOrder(blockTypeIndex) * ones(1,TRIALS_PER_BREAK)];
    end
end


% Determine order of conditions per trial
leftPositions = ones(TRIALS_PER_BLOCK/2,1);
rightPositions = 2*ones(TRIALS_PER_BLOCK/2,1);
positions = [leftPositions;rightPositions];
trialPositions = [];
for i = 1:NUMBER_BLOCKS
    rng('shuffle');
    trialPositions = [trialPositions;Shuffle(positions)];
    if i < NUMBER_BLOCKS
        trialPositions = [trialPositions;...
            9 * ones(TRIALS_PER_BREAK,1)];
    end
end

% Assign each trial's game type (gameOrder) and each trial's stim type    
% (stimulationConditions) of each trial to our social norms games object  
% instance ssmg. % herdOfferTypes = [partner type, offer type]                                                          
ssmg.positions = trialPositions;
ssmg.stimulationConditions = stimConditions;
trialBlockNumber = [ones(TRIALS_PER_BLOCK,1);9*ones(TRIALS_PER_BREAK,1);...
    2*ones(TRIALS_PER_BLOCK,1);9*ones(TRIALS_PER_BREAK,1);3*ones(TRIALS_PER_BLOCK,1);...
    9*ones(TRIALS_PER_BREAK,1);4*ones(TRIALS_PER_BLOCK,1);9*ones(TRIALS_PER_BREAK,1);...
    5*ones(TRIALS_PER_BLOCK,1);9*ones(TRIALS_PER_BREAK,1);6*ones(TRIALS_PER_BLOCK,1);...
    9*ones(TRIALS_PER_BREAK,1);7*ones(TRIALS_PER_BLOCK,1);9*ones(TRIALS_PER_BREAK,1);8*ones(TRIALS_PER_BLOCK,1)];
ssmg.blockNumber = trialBlockNumber;

%% Run the experiment
if practice == true
    c.run(shamBlock,'RANDOMIZATION','ORDERED','blockOrder', 1);
else
    c.run(acTpjBlock,acDlpfcBlock,acSyncBlock,shamBlock,acTpjBlock,acDlpfcBlock,acSyncBlock,shamBlock,breakBlock,...
        'RANDOMIZATION','ORDERED','blockOrder',stimBlockOrder);
end

end
%% Latin Square Function
% By - Jos (10584)
function LS = latinSquare(N)
    LS = [1:N ; ones(N-1,N)];
    LS = rem(cumsum(LS)-1,N)+1;
end