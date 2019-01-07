classdef herdingultimatumgame < neurostim.stimulus
    % Stimulus to play either a dictator or ultimatum game at random on a 
    % per trial basis. The following represents a single trial:
    
    % 1st screen: -Display gameType (text) and opponent type (image).
    % 2nd screen: -Display bars representing the partipant's money, the
    %              opponent's money, the $100 awarded to the participant. 
    %             -Display gameType (text) and opponent type (image).
    % Then the player presses a key corresponding to the amount the player
    % wishes to give their opponent.
    % Unbeknownst to the subject, the outcome is rigged such that a fixed
    % fraction of trials is always correct and a fixed fraction is
    % incorrect.
    % 
    % BK - Mar 2017 
    properties
        chose@logical = false; % Keep track of whether the subject has
                               % chose in current trial.
        punishmentSelected@logical = false;
        trialLogged@logical = false;
        trialCounter = 0; 
        stimulationConditions = [];
        herdOfferTypes = [];
    end
    
    methods
        %% Constructor
        function o=herdingultimatumgame(c,name)
            % Create stimulus object
            o = o@neurostim.stimulus(c,name);
            % Define properties that will be logged.
            o.addProperty('file', NaN);
            o.addProperty('fileName', NaN);
            o.addProperty('herdSize', NaN);
            o.addProperty('herdFrame', NaN);
            o.addProperty('gameType', NaN);
            o.addProperty('gameTypeText', NaN);      
            o.addProperty('partnerType', NaN);
            o.addProperty('partnerFile', NaN);
            o.addProperty('partnerImage', NaN);
            o.addProperty('partnerTexture', NaN);
            o.addProperty('herdTypeText', NaN);
            o.addProperty('offerType', NaN);
            o.addProperty('perceivedFairness', NaN);
            o.addProperty('playerChoice', NaN);
            o.addProperty('playerReactionTime', NaN);
            o.addProperty('decisionDuration',NaN);
            o.addProperty('itiDuration', NaN);
            o.addProperty('defaultTextColor',[1 1 1]);
            o.addProperty('defaultBoxTextColor',[0.1 0.1 0.1]);
            o.addProperty('defaultBoxColor',[1 1 1]);
            o.addProperty('unselectedBoxTextColor',[0.15 0.15 0.15]);
            o.addProperty('unselectedBoxColor', [0.15 0.15 0.15]);
            o.addProperty('acceptBoxTextColor',[0.1 0.1 0.1]);
            o.addProperty('acceptBoxColor', [1 1 1]);
            o.addProperty('rejectBoxTextColor',[0.1 0.1 0.1]);
            o.addProperty('rejectBoxColor', [1 1 1]);
            o.addProperty('fontSize',32);
            o.addProperty('barY', [-55 -45 -45 -55]);
            o.addProperty('boxTextY', 895);
            
            % Define keyCodes respective to system
            % Find keycode values in the kbName class. 
            % right click on kbName and go to open "kbName"
            if ispc
                o.addProperty('fKey', 70);
                o.addProperty('gKey', 71);
            elseif ismac 
                o.addProperty('fKey', 9);
                o.addProperty('gKey', 10);
            end
        end
        
        %% Before Trial
        % Called before each trial to log data from previous trial and 
        % reset appropriate fields.
        function beforeTrial(o,~,~)
            % Reset Fields
            o.trialCounter = o.trialCounter + 1;
            o.trialLogged = false;
            o.chose = false; 
            o.playerChoice = NaN;
            o.playerReactionTime = NaN;
            
            % Assign Partner Type Condition
            if o.herdOfferTypes(o.trialCounter) == 1 % Low Herd
                o.herdSize = randi([0 33],1);
                o.herdFrame = 'Accepted';
                o.herdTypeText = strcat(num2str(o.herdSize),...
                    '% of participants accepted');
                o.partnerFile = 'person.jpg';
            elseif o.herdOfferTypes(o.trialCounter) == 2 % Medium Herd
                o.herdSize = randi([34 66],1);
                o.herdFrame = 'Accepted';
                o.herdTypeText = strcat(num2str(o.herdSize),...
                    '% of Participants Accepted');
                o.partnerFile = 'person.jpg';
            elseif o.herdOfferTypes(o.trialCounter) == 3 % High Herd
                o.herdSize = randi([67 99],1);
                o.herdFrame = 'Accepted';
                o.herdTypeText = strcat(num2str(o.herdSize),...
                    '% of participants accepted');
                o.partnerFile = 'person.jpg';
            elseif o.herdOfferTypes(o.trialCounter) == 4 % Low Herd
                o.herdSize = randi([0 33],1);
                o.herdFrame = 'Rejected';
                o.herdTypeText = strcat(num2str(o.herdSize),...
                    '% of participants rejected');
                o.partnerFile = 'person.jpg';
            elseif o.herdOfferTypes(o.trialCounter) == 5 % Medium Herd
                o.herdSize = randi([34 66],1);
                o.herdFrame = 'Rejected';
                o.herdTypeText = strcat(num2str(o.herdSize),...
                    '% of participants rejected');
                o.partnerFile = 'person.jpg';
            elseif o.herdOfferTypes(o.trialCounter) == 6 % High Herd
                o.herdSize = randi([67 99],1);
                o.herdFrame = 'Rejected';
                o.herdTypeText = strcat(num2str(o.herdSize),...
                    '% of participants rejected');
                o.partnerFile = 'person.jpg';
            end
            
            % Assign Offer Type Condition
            if o.herdOfferTypes(o.trialCounter,2) == 1
                o.offerType = 'Keep $9, Give $1';
            elseif o.herdOfferTypes(o.trialCounter,2) == 2
                o.offerType = 'Keep $8, Give $2';
            elseif o.herdOfferTypes(o.trialCounter,2) == 3
                o.offerType = 'Keep $7, Give $3';
            elseif o.herdOfferTypes(o.trialCounter,2) == 4
                o.offerType = 'Keep $6, Give $4';
            elseif o.herdOfferTypes(o.trialCounter,2) == 5
                o.offerType = 'Keep $5, Give $5';
            end
            
            % Set Respective Partner Image
            o.partnerImage = imread(o.partnerFile);
            o.partnerTexture = Screen('MakeTexture',o.window,...
                o.partnerImage);   
            
            % Reset UI properties
            o.acceptBoxColor = o.defaultBoxColor;
            o.acceptBoxTextColor = o.defaultBoxTextColor;
            o.rejectBoxColor = o.defaultBoxColor;
            o.rejectBoxTextColor = o.defaultBoxTextColor;
        end
        
        %% Executes every frame
        function beforeFrame(o,~,~)      
            % Mark trial time
            now  = o.cic.trialTime;

            % Check for response if decision has yet to be made and the
            % decision duration has not elapsed.
            [~,~,keyCode] = KbCheck;  
            ch = find(keyCode); % Translate key press to corresponding
                                %  keyCode. List of key codes in KbName.m.
            if now < o.itiDuration + o.decisionDuration...
                    && now > o.itiDuration...
                    && ~o.chose
                if ch == o.fKey
                    % Mark reaction time
                    o.playerReactionTime =...
                        now - o.itiDuration;
                    o.playerChoice = 'Accept'; % Player chooses to give 10.
                    o.chose = true; % Update trial state
                    % Update UI properties
                    o.acceptBoxColor = o.defaultBoxColor;
                    o.acceptBoxTextColor = o.defaultBoxTextColor;
                    o.rejectBoxColor = o.unselectedBoxColor;
                    o.rejectBoxTextColor = o.unselectedBoxTextColor;
                elseif ch == o.gKey
                    o.playerReactionTime =...
                        now - o.itiDuration;
                    o.playerChoice = 'Reject';
                    o.chose = true;
                    % Update UI properties
                    o.acceptBoxColor = o.unselectedBoxColor;
                    o.acceptBoxTextColor = o.unselectedBoxTextColor;
                    o.rejectBoxColor = o.defaultBoxColor;
                    o.rejectBoxTextColor = o.defaultBoxTextColor;
                end
            end
            
            % Still no guess since preround screen, list as n/a
            if ~o.chose && (now > 0.99*(o.itiDuration + o.decisionDuration))
                o.chose = true;
                o.playerChoice = 'n/a';
                o.playerReactionTime = 'n/a';
                % Write trial results
                trialData =...
                        {num2str(o.stimulationConditions(o.trialCounter)),...
                                 num2str(o.herdSize),...
                                 o.herdFrame,...
                                 o.offerType,...
                                 o.playerChoice,...
                                 o.playerReactionTime};
                trialData = trialData.';
                file = fopen(o.fileName,'a');
                fprintf(file,'%s\t%s\t%s\t%s\t%s\t%s\r\n',...
                    trialData{:});
                fclose(file);
                % Update
                o.trialLogged = true;
            end
            
            % Diplay ITI Screen. t = [0s,1s)
            if now < o.itiDuration
                Screen('TextFont',o.window, 'Courier New');
                Screen('TextSize',o.window, o.fontSize);
                Screen('TextStyle', o.window, 1+2);
                Screen('glLoadIdentity', o.window);
                
                DrawFormattedText(o.window, '*', 'center', 'center',...
                    o.defaultTextColor);
            % UltimatumDecision Screen. t = [1s, 4s)
            elseif now < o.itiDuration + o.decisionDuration...
                % Draw bars
                acceptOptionX = 0.15 * [-50 -50 -25 -25];
                acceptOptionY = 0.15 * o.barY;
                rejectOptionX = 0.15 * [25 25 50 50];
                rejectOptionY = 0.15 * o.barY;
                
                % Draw Accept, Reject boxes
                Screen('FillPoly',o.window, o.acceptBoxColor,[acceptOptionX',acceptOptionY'],1); 
                Screen('FillPoly',o.window, o.rejectBoxColor,[rejectOptionX',rejectOptionY'],1); 

                % Set up screen parameters
                Screen('TextFont',o.window, 'Courier New');
                Screen('TextSize',o.window, o.fontSize);
                Screen('TextStyle', o.window, 1+2);
                Screen('glLoadIdentity', o.window);

                % Draw partner image from texture object made in
                % beforeTrial
                Screen('DrawTexture',o.window,o.partnerTexture);
                % Draw Accept, Reject text in boxes
                DrawFormattedText(o.window, 'Accept', 1920/2 - 335,...
                        o.boxTextY, o.acceptBoxTextColor);
                DrawFormattedText(o.window, 'Reject', 1920/2 + 180,...
                    o.boxTextY, o.rejectBoxTextColor);
                DrawFormattedText(o.window, o.offerType, 'center',...
                    745, o.defaultTextColor);
                DrawFormattedText(o.window, o.herdTypeText, 'center',...
                    350, o.defaultTextColor);
                % Log Data, only runs once per trial
                if ~o.trialLogged && o.chose
                    trialData =...
                        {num2str(o.stimulationConditions(o.trialCounter)),...
                                 num2str(o.herdSize),...
                                 o.herdFrame,...
                                 o.offerType,...
                                 o.playerChoice,...
                                 num2str(o.playerReactionTime)};
                    trialData = trialData.';
                    file = fopen(o.fileName,'a');
                    fprintf(file,'%s\t%s\t%s\t%s\t%s\t%s\r\n',...
                        trialData{:});
                    fclose(file);
                    % Update data fields
                    o.trialLogged = true;
                end                
            end            
        end     
    end
end