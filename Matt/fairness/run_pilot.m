function  c = run_pilot
% tacs Fairness Game
% Subjects play the dictator or ultimatum game and decide how much money
% (0-100) to alot to a 'human' or pc opponent.
% Controls:
% - '1' through '4':  Likert Scale - perceivedFairness
% - 'f':              Accept
% - 'g':              Reject
% Screen Order:
% - ITI Fixation Screen: 1s
% - Inform Screen:       2.5s
% - Decision Screen:     3s
% - Outcome Screen:      1s
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
subjectID    = '023';
hostNameOrIP = '10.109.9.205';
practice     = true;
tacs_amplitude    = 1999; % mA

%% Trial Duration Parameters
decisionDuration = 3000; % milliseconds
itiDuration      = 1000;

%% Behavioral Paradigm 
uniquePartners      = 3;
uniqueOffers        = 8;
uniquePartnerOffers = uniquePartners * uniqueOffers;
numberRepeats       = 4; % 3 trials, 1 rating

if practice == true
    subjectID        = '999';
    NUMBER_BLOCKS    = 1;
    TRIALS_PER_BLOCK = uniquePartnerOffers * numberRepeats;  
else
    NUMBER_BLOCKS    = 3;
    TRIALS_PER_BLOCK = uniquePartnerOffers * numberRepeats;   
end
%% Stimulation Parameters
protocolName = 'rDLPFCrTPJ';
 % Update with actual IP address of starstim PC.
stimFileFolder = 'c:/temp/'; % Folder on the starstim machine where data
                             % are saved (must exist)
stimFrequency = 10; % Hz
rampTime      = 500; % milliseconds
debugFlag     = false;
eyelinkFlag   = false;

%% Setup CIC and the stimuli.
c = klabRig('debug',debugFlag,'eyelink', eyelinkFlag);
c.screen.colorMode        = 'RGB'; 
c.screen.color.text       = [1 1 1];  % Block/Start text
c.screen.color.background = [0.15 0.15 0.15];
c.dirs.output = 'c:/temp/';
c.screen.type = 'GENERIC';
c.itiClear      = 0;
c.iti           = 0;
c.paradigm      = 'tacs-fairness';
% Define total trial duration
c.trialDuration = '@game.decisionDuration + game.itiDuration';

%% Setup the social norms games(Ultimatum & Dictator) stimulus
fug = fairnessultimatumgame(c,'game');
fug.decisionDuration = decisionDuration;
fug.itiDuration      = itiDuration;

%% Setup the output file
% Main Output File
outputFileName = strcat(subjectID,'_results.tsv');
outputFileName =...
    strcat('tacs-social-norms\experiments-master\Matt\fairness\output\',...
    outputFileName);
fug.fileName = outputFileName; % Pass output file name
% Save main header to main output file
header = {'StimulationCondition','PartnerType','OfferType','PlayerChoice',...
    'PlayerReactionTime'};
header = header.';
outputFile = fopen(outputFileName,'a');
fug.file = outputFile; % Pass file object
fprintf(outputFile,'%s\t%s\t%s\t%s\t%s\r\n',header{:});
fclose(outputFile);

% Perceived Fairness Output File
outputFileName2 = strcat(subjectID,'_perceived_fairness_results.tsv');
outputFileName2 =...
    strcat('tacs-social-norms\experiments-master\Matt\fairness\output\',...
    outputFileName2);
fug.ratingsFileName = outputFileName2; % Pass output file name
% Save perceived fairness header to perceived fairness output file
header = {'StimulationCondition','PartnerType','OfferType','PerceviedFairness'};
header = header.';
outputFile2 = fopen(outputFileName2,'a');
fug.ratingsFile = outputFile2; % Pass file object
fprintf(outputFile2,'%s\t%s\t%s\t%s\r\n',header{:});
fclose(outputFile2);

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
    stm.fake     = true;
    stm.enabled  = false;
else
    stm.fake     = false;
    stm.enabled  = true;
end
stm.debug    = false;
stm.path     = stimFileFolder;

% Define amplitude array functions
tacs_tpj_stim_array   =...
    @(x) [x floor(x*1/3) floor(x*1/3) ceil(x*1/3) 0 0 0 0];
tacs_dlpfc_stim_array =...
    @(x) [0 0 0 0 ceil(x*1/3) floor(x*1/3) floor(x*1/3) x];
tacs_tpj_dlpfc_stim_array = @(x) [x floor(x*1/3) floor(x*1/3) ceil(x*1/3)...
                                  ceil(x*1/3) floor(x*1/3) floor(x*1/3) x];

%% Define All Block Types
% Corresponding Montage Array: [CP6 P4 C4 T8 F4 AF8 Fp2 AF4]
% Referene: CMS- left cheek bone area DRL- behind left ear area
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
% Condition 3 
acSYNC = design('AC_DLPFC_TPJ_SYNC');
acSYNC.conditions(1).starstim.type      = 'tACS';
acSYNC.conditions(1).starstim.amplitude = tacs_tpj_dlpfc_stim_array(tacs_amplitude);
acSYNC.conditions(1).starstim.phase     = [0 180 180 180 180 180 180 0];
acSYNC.conditions(1).starstim.sham      = false;
acSyncBlock = block('acSYNC',acSYNC,'nrRepeats',TRIALS_PER_BLOCK,...
                    'beforeKeyPress',false,'afterKeyPress',false);
% Practice 
sham = design('SHAM');
acSYNC.conditions(1).starstim.type      = 'tACS';
acSYNC.conditions(1).starstim.amplitude = tacs_tpj_dlpfc_stim_array(tacs_amplitude);
acSYNC.conditions(1).starstim.phase     = [0 180 180 180 180 180 180 0];
sham.conditions(1).starstim.sham = true;
shamBlock = block('sham',sham,'nrRepeats',uniquePartnerOffers,...
    'beforeKeyPress',false,'afterKeyPress',false);

%% Condition Order
%  acTpjBlock = 1, acDlpfcBlock = 2, acSyncBlock = 3
blockType = block.empty(0,NUMBER_BLOCKS); % 1x10
stimulationConditions = int16.empty(0,NUMBER_BLOCKS*TRIALS_PER_BLOCK); % 1x400
randomizedOrder = randperm(NUMBER_BLOCKS); % Randomized order of stim
                                           % condition blocks.
% Populate blockOrder array based on randomizedOrder.
for blockTypeIndex = 1:NUMBER_BLOCKS
    switch randomizedOrder(blockTypeIndex)
        case 1
            blockType(blockTypeIndex) = acTpjBlock;
            leftIndex = ((blockTypeIndex-1)*TRIALS_PER_BLOCK)+1;
            rightIndex = (blockTypeIndex*TRIALS_PER_BLOCK);
            stimulationConditions(leftIndex:rightIndex) =...
                randomizedOrder(blockTypeIndex) * ones(1,TRIALS_PER_BLOCK);
        case 2
            blockType(blockTypeIndex) = acDlpfcBlock;
            leftIndex = ((blockTypeIndex-1)*TRIALS_PER_BLOCK)+1;
            rightIndex = (blockTypeIndex*TRIALS_PER_BLOCK);
            stimulationConditions(leftIndex:rightIndex) =...
                randomizedOrder(blockTypeIndex) * ones(1,TRIALS_PER_BLOCK);
        case 3
            blockType(blockTypeIndex) = acSyncBlock;
            leftIndex = ((blockTypeIndex-1)*TRIALS_PER_BLOCK)+1;
            rightIndex = (blockTypeIndex*TRIALS_PER_BLOCK);
            stimulationConditions(leftIndex:rightIndex) =...
                randomizedOrder(blockTypeIndex) * ones(1,TRIALS_PER_BLOCK);
    end
end

% Determine order of conditions per trial
totalTrials = TRIALS_PER_BLOCK * NUMBER_BLOCKS;
partnerOfferTypes = zeros(totalTrials,2); % [stim type, offer type]
ratingOfferPermutations = fullfact([3 5]);
perceivedFairnessPartnerOfferTypes = fullfact([3 5]);
ratingTrials = perceivedFairnessPartnerOfferTypes + 5*ones(15,2);
ratingOfferPermutations =...
    [ratingOfferPermutations;ratingOfferPermutations;...
     ratingOfferPermutations;ratingTrials];
for i = 1:NUMBER_BLOCKS
    % Shuffle array
    shuffledArray = ratingOfferPermutations(randperm(size(ratingOfferPermutations,1)),:);        
    leftIndex = ((i-1)*TRIALS_PER_BLOCK)+1; 
    rightIndex = (i*TRIALS_PER_BLOCK); 
    partnerOfferTypes(leftIndex:rightIndex,:) = shuffledArray;
end

% Assign each trial's game type (gameOrder) and each trial's stim type    
% (stimulationConditions) of each trial to our social norms games object  
% instance fug. % partnerOfferTypes = [partner type, offer type]
fug.partnerOfferTypes = partnerOfferTypes;
fug.stimulationConditions = stimulationConditions;

%% Run the experiment
if practice == true
    c.run(shamBlock,'RANDOMIZATION','ORDERED','blockOrder', 1);
else
    c.run(blockType(1),blockType(2),blockType(3),'RANDOMIZATION',...
        'ORDERED','blockOrder',randomizedOrder);
end

end