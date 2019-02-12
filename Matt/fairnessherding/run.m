function  c = run
% tACS Fairness Herding
% Participants play modified ultimatum game with social information.
% Participants have choice to accept or reject offer.
% When their is social information, the ration for participants who
% accepted the offer is displayed.
% Controls:
% - 'f'       left option
% - 'g'       right option
% Screen Order:
% - Inform Screen:       1.5s
% - Decision Screen:     3s
% - Outcome Screen:      1s
% - ITI Fixation Screen: 1s
%
% We combine this with stimulation of the DLPFC and the TPJ.
% In each game block, stimulation is conditions 1-5.
% Stimulation is off during fixation blocks.
% 
% Stimulation Conditions:
% acTpjBlock = 1, acDlpfcBlock = 2,
% acSyncBlock = 3, shamBlock = 4, break2Min = 5(9 in output file).
% 
% BK - Feb 2017, MS - modified Jan. 2019
import neurostim.*; 

%% General Parameters
subjectID      = '999'; 
hostNameOrIP   = '10.109.10.247'; % Update with actual IP address of starstim PC.
practice       = false;
stimOn         = false;
tacs_amplitude = 1999;  

%% Trial Duration Parameters
decisionDuration = 3000; % milliseconds
outcomeDuration  = 1000;
informDuration   = 2000;
itiDuration      = 1000;

%% Behavioral Paradigm 
numberSocialOptions = 2;
numberHerdOptions   = 3;
numberOfferOptions  = 8;
TRIALS_PER_BREAK    = 17;

if practice == true
    subjectID     = '999';
    NUMBER_BLOCKS = 1; 
    TRIALS_PER_BLOCK = 48; % Can make smaller if takes too long
else
    NUMBER_BLOCKS = 4; 
    TRIALS_PER_BLOCK = 48;   
end

%% Stimulation Parameters
protocolName = 'rDLPFCrTPJ';
stimFileFolder = 'c:/temp/'; % Folder on the starstim machine where data
                             % are saved (must exist)
stimFrequency = 10; % Hz
rampTime = 500;                  
debugFlag = false;
eyelinkFlag = false;

%% Setup CIC
c = klabRig('debug',debugFlag,'eyelink', eyelinkFlag);
c.screen.colorMode        = 'RGB'; % Specify colors as RGB gunvalue sbetween 0 and 1 (uncalibrated).
c.screen.color.text       = [1 1 1];  % Block/Start text
c.screen.color.background = [0.15 0.15 0.15];
c.dirs.output             = 'c:/temp/';
c.screen.type             = 'GENERIC';
c.itiClear                = 0;
c.iti                     = 1000;
c.paradigm                = 'tacs-social-norms';
% Define total trial duration
c.trialDuration = '@game.decisionDuration + game.informDuration + game.outcomeDuration';

%% Setup a fixation star.
fix = neurostim.stimuli.fixation(c,'fix');
fix.shape = 'star';
fix.size = 0.25;
fix.color = [1 1 1];
fix.duration = inf;

%% Setup the social norms games(Ultimatum & Dictator) stimulus
fhg                  = fairnessherdinggame(c,'game');
fhg.informDuration   = informDuration;
fhg.decisionDuration = decisionDuration;
fhg.outcomeDuration  = outcomeDuration;


%% Setup output file
% Create and Pass filename to socialnorms games object
outputFileName = strcat(subjectID,'_results.tsv');
outputFileName = strcat('tacs-social-norms\experiments-master\Matt\fairnessherding\output\',outputFileName);
fhg.fileName = outputFileName;
% Save header to output file
header = 'Stim\tSocial\tHerd\tOffer\tChoice\tRT\r\n';
outputFile = fopen(outputFileName,'a'); 
fprintf(outputFile,header);
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
stm.enabled = stimOn;
if stimOn == true
    stm.fake = false;
else
    stm.fake = true;
end
stm.debug    = false;
stm.path     = stimFileFolder;

% Define amplitude array functions
tacs_tpj_stim_array = @(x) [x floor(x*1/3) floor(x*1/3) ceil(x*1/3) 0 0 0 0];
tacs_dlpfc_stim_array = @(x) [0 0 0 0 ceil(x*1/3) floor(x*1/3) floor(x*1/3) x];
tacs_tpj_dlpfc_stim_array = @(x) [x floor(x*1/3) floor(x*1/3) ceil(x*1/3) ceil(x*1/3) floor(x*1/3) floor(x*1/3) x];

%% Define Block Types
% Corresponding Montage Array: [CP6 P4 C4 T8 F4 AF8 Fp2 AF4]
% Condition 1
acTPJ = design('AC_TPJ');
acTPJ.conditions(1).starstim.enabled = true;
acTPJ.conditions(1).starstim.type      = 'tACS';
acTPJ.conditions(1).starstim.amplitude = tacs_tpj_stim_array(tacs_amplitude);
acTPJ.conditions(1).starstim.phase     = [0 180 180 180 0 0 0 0];
acTPJ.conditions(1).starstim.sham      = false;
acTpjBlock = block('acTPJ',acTPJ,'nrRepeats',TRIALS_PER_BLOCK,'beforeKeyPress',false,'afterKeyPress',false);

% Condition 2 
acDLPFC = design('AC_DLPFC');
acDLPFC.conditions(1).starstim.enabled = true;
acDLPFC.conditions(1).starstim.type      = 'tACS';
acDLPFC.conditions(1).starstim.amplitude = tacs_dlpfc_stim_array(tacs_amplitude);
acDLPFC.conditions(1).starstim.phase     = [0 0 0 0 180 180 180 0];
acDLPFC.conditions(1).starstim.sham      = false;
acDlpfcBlock = block('acDLPFC',acDLPFC,'nrRepeats',TRIALS_PER_BLOCK,'beforeKeyPress',false,'afterKeyPress',false);

% Condition 3 
acSYNC = design('AC_DLPFC_TPJ_SYNC');
acSYNC.conditions(1).starstim.enabled = true;
acSYNC.conditions(1).starstim.type      = 'tACS';
acSYNC.conditions(1).starstim.amplitude = tacs_tpj_dlpfc_stim_array(tacs_amplitude);
acSYNC.conditions(1).starstim.phase     = [0 180 180 180 180 180 180 0];
acSYNC.conditions(1).starstim.sham      = false;
acSyncBlock = block('acSYNC',acSYNC,'nrRepeats',TRIALS_PER_BLOCK,'beforeKeyPress',false,'afterKeyPress',false);

% Condition 4  
sham = design('SHAM');
sham.conditions(1).starstim.enabled = true;
sham.conditions(1).starstim.type      = 'tACS';
sham.conditions(1).starstim.amplitude = tacs_tpj_dlpfc_stim_array(tacs_amplitude);
sham.conditions(1).starstim.phase     = [0 180 180 180 180 180 180 0];
sham.conditions(1).starstim.sham      = true;
shamBlock = block('sham',sham,'nrRepeats',TRIALS_PER_BLOCK,'beforeKeyPress',false,'afterKeyPress',false);

% Condition 5
break2min = design('BREAK2MIN');
break2min.conditions(1).starstim.enabled = false;
breakBlock = block('break2min',break2min,'nrRepeats',TRIALS_PER_BREAK,'beforeKeyPress',false,'afterKeyPress',false);

%% Block Order
blockType = block.empty(0,NUMBER_BLOCKS+(NUMBER_BLOCKS-1));  
stimConditions = []; 

mySquare = latinSquare(4);
stimBlockOrder = mySquare(mod(str2num(subjectID),4),:);

stimBlockOrder = [stimBlockOrder(1) 5 stimBlockOrder(2) 5 stimBlockOrder(3)...
    5 stimBlockOrder(4)];
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
            blockType(blockTypeIndex) = breakBlock;
            stimConditions = [stimConditions,...
                stimBlockOrder(blockTypeIndex) * ones(1,TRIALS_PER_BREAK)];
    end
end

%% Trial Conditions
% Determine order of each condition type per trial
trialConditionData = int8.empty(0,3); % [social type, herd type, offer type]
% Acquire all possible permutations
conditionPermutations = fullfact([numberSocialOptions numberHerdOptions numberOfferOptions]);

for i = 1:NUMBER_BLOCKS
    rng('shuffle');
    trialConditionData = [trialConditionData;...
        conditionPermutations(randperm(size(conditionPermutations,1)),:)];
    if i < NUMBER_BLOCKS
        trialConditionData = [trialConditionData;...
            9 * ones(TRIALS_PER_BREAK,3)];
    end
end
% Pass the trial conditions and stim conditions to game 
% stimConditions is just used for logging purposes in fairnessherdinggame.m
% trialConditionData is used to determine the conditions for each trial in
% fairnessherdinggame.m
fhg.trialConditionData = trialConditionData;
fhg.stimConditions     = stimConditions;

%% Run the experiment
if practice == true
    c.run(shamBlock,'RANDOMIZATION','ORDERED','blockOrder', 1);
else
    c.run(acTpjBlock,acDlpfcBlock,acSyncBlock,shamBlock,breakBlock,...
    'RANDOMIZATION','ORDERED','blockOrder',stimBlockOrder);
end

end
%% Latin Square Function
% By - Jos (10584)
function LS = latinSquare(N)
    LS = [1:N ; ones(N-1,N)];
    LS = rem(cumsum(LS)-1,N)+1;
end