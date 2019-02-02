function  c = run_pilot
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
subjectID = '023';
hostNameOrIP = '10.109.9.205';
practice = true; % Stim disabled during practice
tacs_amplitude = 1999; % mA

%% Trial Duration Parameters
decisionDuration = 3000; % milliseconds
itiDuration      = 1000;

%% Behavioral Paradigm 
uniqueHerds      = 6; % Includes framing 
uniqueOffers     = 5;
uniqueHerdOffers = uniqueHerds * uniqueOffers;
numberRepeats = 3;

if practice == true
    subjectID        = '999';
    NUMBER_BLOCKS    = 1; 
    TRIALS_PER_BLOCK = uniqueHerdOffers * numberRepeats;
else
    NUMBER_BLOCKS    = 2; 
    TRIALS_PER_BLOCK = uniqueHerdOffers * numberRepeats;   
end

%% Stimulation Parameters
protocolName = 'rDLPFCrTPJ';
 % Update with actual IP address of starstim PC.
stimFileFolder = 'c:/temp/'; % Folder on the starstim machine where data
                             % are saved (must exist)

stimFrequency = 10; % Hz
rampTime      = 500; % milliseconds

debugFlag   = false;
eyelinkFlag = false;

%% Setup CIC and the stimuli.
c = klabRig('debug',debugFlag,'eyelink', eyelinkFlag);
c.screen.colorMode = 'RGB'; 
c.screen.color.text = [1 1 1]; % Block/Start text
c.screen.color.background = [0.15 0.15 0.15];
c.dirs.output = 'c:/temp/';
c.screen.type = 'GENERIC';
c.itiClear      = 0;
c.iti           = 0;
c.paradigm      = 'tacs-herding';
% Define total trial duration
c.trialDuration = '@game.decisionDuration + game.itiDuration';

%% Setup the herding ultimatum game stimulus
hug = herdingultimatumgame(c,'game');
hug.decisionDuration = decisionDuration;
hug.itiDuration = itiDuration;

%% Setup the output file
% Create and Pass filename to herding ultimatum game object
outputFileName = strcat(subjectID,'_results.tsv');
outputFileName = strcat('tacs-social-norms\experiments-master\Matt\herding\output\',outputFileName);
hug.fileName = outputFileName;
% Create and write header to output file
header = {'StimulationCondition','HerdType','FramingType','OfferType','PlayerChoice','PlayerReactionTime'};
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
stm.transition = rampTime; % Ramp up/down time
stm.sham = false; % By defauly off, will be set to true if/when needed
if practice == true
    stm.fake     = true;
    stm.enabled  = false;

else
    stm.fake    = false;
    stm.enabled  = true;
end
stm.debug = false;
stm.path  = stimFileFolder;

% Define amplitude array functions
% Electrode Order: 1,2,3,4,5,6,7,8
% Corresponding Montage Array: [CP6 P4 C4 T8 F4 AF8 Fp2 AF4]
tacs_tpj_stim_array   =...
    @(x) [x floor(x*1/3) floor(x*1/3) ceil(x*1/3) ...
          0 0            0            0];
tacs_dlpfc_stim_array =...
    @(x) [0           0            0            0 ...
          ceil(x*1/3) floor(x*1/3) floor(x*1/3) x];
tacs_tpj_dlpfc_stim_array =...
    @(x) [x           floor(x*1/3) floor(x*1/3) ceil(x*1/3)...
          ceil(x*1/3) floor(x*1/3) floor(x*1/3) x];

%% Define All Block Types
% Condition 1 
acTPJ = design('AC_TPJ');
acTPJ.conditions(1).starstim.type      = 'tACS';
acTPJ.conditions(1).starstim.amplitude = tacs_tpj_stim_array(tacs_amplitude);
acTPJ.conditions(1).starstim.phase     = [0 180 180 180 0 0 0 0];
acTPJ.conditions(1).starstim.sham      = false;
acTpjBlock = block('acTPJ',acTPJ,'nrRepeats',TRIALS_PER_BLOCK,...
                   'beforeKeyPress',false,'afterKeyPress',false);
% Condition 2 
acDLPFC = design('AC_DLPFC');
acDLPFC.conditions(1).starstim.type      = 'tACS';
acDLPFC.conditions(1).starstim.amplitude = tacs_dlpfc_stim_array(tacs_amplitude);
acDLPFC.conditions(1).starstim.phase     = [0 0 0 0 180 180 180 0];
acDLPFC.conditions(1).starstim.sham      = false;
acDlpfcBlock = block('acDLPFC',acDLPFC,'nrRepeats',TRIALS_PER_BLOCK,...
                     'beforeKeyPress',false,'afterKeyPress',false);
% Practice 
sham = design('SHAM');
sham.conditions(1).starstim.type = 'tACS';
sham.conditions(1).starstim.amplitude = tacs_tpj_dlpfc_stim_array(tacs_amplitude);
sham.conditions(1).starstim.phase = [0 180 180 180 180 180 180 0];
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
% if practice == true
%     herdOfferTypes = [1 2; 2 3; 3 5];
% else
totalTrials = TRIALS_PER_BLOCK * NUMBER_BLOCKS;
herdOfferTypes = zeros(totalTrials,2); % [stim type, offer type]
herdingOfferPermutations = fullfact([uniqueHerds uniqueOffers]);
herdingOfferPermutations = [herdingOfferPermutations;herdingOfferPermutations;...
                            herdingOfferPermutations];
for i = 1:NUMBER_BLOCKS
    rng('shuffle');
    shuffledArray = herdingOfferPermutations(randperm(size(herdingOfferPermutations,1)),:);        
    leftIndex = ((i-1)*TRIALS_PER_BLOCK)+1;
    rightIndex = (i*TRIALS_PER_BLOCK);
    herdOfferTypes(leftIndex:rightIndex,:) = shuffledArray;
end
% end

% Assign each trial's game type (gameOrder) and each trial's stim type    
% (stimulationConditions) of each trial to our social norms games object  
% instance hug. % herdOfferTypes = [partner type, offer type]                                                          
hug.herdOfferTypes = herdOfferTypes;
hug.stimulationConditions = stimulationConditions;

%% Run the experiment
if practice == true
    c.run(shamBlock,'RANDOMIZATION','ORDERED','blockOrder', 1);
else
    c.run(blockType(1),blockType(2),...
        'RANDOMIZATION','ORDERED','blockOrder',randomizedOrder);
end

end