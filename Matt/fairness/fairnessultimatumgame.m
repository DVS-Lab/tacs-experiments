classdef fairnessultimatumgame < neurostim.stimulus
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
        partnerOfferTypes = [];
        
    end
    
    methods
        %% Constructor
        function o=fairnessultimatumgame(c,name)
            % Create stimulus object
            o = o@neurostim.stimulus(c,name);
            % Define properties that will be logged.
            o.addProperty('file', NaN);
            o.addProperty('ratingsFile', NaN);
            o.addProperty('fileName', NaN);
            o.addProperty('ratingsFileName', NaN);
            o.addProperty('perceivedFairnessPartnerOfferTypes', NaN);
            o.addProperty('gameType', NaN);
            o.addProperty('gameTypeText', NaN);      
            o.addProperty('partnerType', NaN);
            o.addProperty('partnerFile', NaN);
            o.addProperty('partnerImage', NaN);
            o.addProperty('partnerTexture', NaN);
            o.addProperty('partnerTypeText', NaN);
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
                o.addProperty('one', 49);
                o.addProperty('two', 50);
                o.addProperty('three', 51);
                o.addProperty('four', 52);
                o.addProperty('fKey', 70);
                o.addProperty('gKey', 71);
            elseif ismac 
                o.addProperty('one', 31);
                o.addProperty('two', 32);
                o.addProperty('three', 33);
                o.addProperty('four', 34);
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
            if o.partnerOfferTypes(o.trialCounter) == 1 % Low Rated
                o.partnerTypeText = 'Rating: 3/5';
                o.partnerFile = 'person.jpg';
            elseif o.partnerOfferTypes(o.trialCounter) == 2 % High Rated
                o.partnerTypeText = 'Rating 5/5';
                o.partnerFile = 'person.jpg';
            elseif o.partnerOfferTypes(o.trialCounter) == 3 % PC
                o.partnerTypeText = ' ';
                o.partnerFile = 'person.jpg';
            elseif o.partnerOfferTypes(o.trialCounter) == 6 % For rating
                o.partnerTypeText = 'Rating: 3/5';
                o.partnerFile = 'person.jpg';
            elseif o.partnerOfferTypes(o.trialCounter) == 7 % For rating
                o.partnerTypeText = 'Rating 5/5';
                o.partnerFile = 'person.jpg';
            elseif o.partnerOfferTypes(o.trialCounter) == 8 % For rating
                o.partnerTypeText = ' ';
                o.partnerFile = 'person.jpg';
                
            end
            
            % Assign Offer Type Condition
            if o.partnerOfferTypes(o.trialCounter,2) == 1
                o.offerType = 'Keep $9, Give $1';
            elseif o.partnerOfferTypes(o.trialCounter,2) == 2
                o.offerType = 'Keep $8, Give $2';
            elseif o.partnerOfferTypes(o.trialCounter,2) == 3
                o.offerType = 'Keep $7, Give $3';
            elseif o.partnerOfferTypes(o.trialCounter,2) == 4
                o.offerType = 'Keep $6, Give $4';
            elseif o.partnerOfferTypes(o.trialCounter,2) == 5
                o.offerType = 'Keep $5, Give $5';
            elseif o.partnerOfferTypes(o.trialCounter,2) == 6
                o.offerType = 'Keep $9, Give $1';
            elseif o.partnerOfferTypes(o.trialCounter,2) == 7
                o.offerType = 'Keep $8, Give $2';
            elseif o.partnerOfferTypes(o.trialCounter,2) == 8
                o.offerType = 'Keep $7, Give $3';
            elseif o.partnerOfferTypes(o.trialCounter,2) == 9
                o.offerType = 'Keep $6, Give $4';
            elseif o.partnerOfferTypes(o.trialCounter,2) == 10
                o.offerType = 'Keep $5, Give $5';
            end
            
            o.partnerImage = imread(o.partnerFile);
            o.partnerTexture = Screen('MakeTexture',o.window,...
                o.partnerImage);       
            
            Screen('TextFont',o.window, 'Courier New');
            Screen('TextSize',o.window, o.fontSize);
            Screen('TextStyle', o.window, 1+2);
            Screen('glLoadIdentity', o.window);
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
                    if o.partnerOfferTypes(o.trialCounter) < 4
                        % Mark reaction time
                        o.playerReactionTime =...
                            now - o.itiDuration;
                        o.playerChoice = 'Accept'; % Player chooses to give 10.
                        o.chose = true; % Update trial state
                    end
                elseif ch == o.gKey
                    if o.partnerOfferTypes(o.trialCounter) < 4
                        o.playerReactionTime =...
                            now - o.itiDuration;
                        o.playerChoice = 'Reject';
                        o.chose = true;
                    end
                elseif ch == o.one
                    % Mark reaction time
                    o.playerReactionTime =...
                        now - o.itiDuration;
                    o.playerChoice = 1; % Player chooses to give 10.
                    o.chose = true; % Update trial state    
                elseif ch == o.two
                    o.playerReactionTime =...
                        now - o.itiDuration;
                    o.playerChoice = 2;
                    o.chose = true;
                elseif ch == o.three
                    % Mark reaction time
                    o.playerReactionTime =...
                        now - o.itiDuration;
                    o.playerChoice = 3; % Player chooses to give 10.
                    o.chose = true; % Update trial state     
                elseif ch == o.four
                    o.playerReactionTime =...
                        now - o.itiDuration;
                    o.playerChoice = 4;
                    o.chose = true;
                end
            end
            
            % (Main) Still no guess since preround screen,
            % list as n/a
            if ~o.chose && (now > 0.99*(o.itiDuration + o.decisionDuration))...
                        && o.partnerOfferTypes(o.trialCounter) < 4
                o.trialLogged = true;
                    trialData =...
                        {num2str(o.stimulationConditions(o.trialCounter)),...
                                 o.partnerTypeText,...
                                 o.offerType,...
                                 o.playerChoice,...
                                 num2str(o.playerReactionTime)};
                trialData = trialData.';
                file = fopen(o.fileName,'a');
                fprintf(file,'%s\t%s\t%s\t%s\t%s\r\n',...
                    trialData{:});
                fclose(file);
            end
            
            % (Perceived Fairness) Still no guess since preround screen,
            % list as n/a
            if ~o.chose && (now > 0.99*(o.itiDuration + o.decisionDuration))...
                        && o.partnerOfferTypes(o.trialCounter) > 3
                o.chose = true;
                o.playerChoice = 'n/a';
                o.playerReactionTime = 'n/a';
                o.trialLogged = true;
                trialData =...
                    {num2str(o.stimulationConditions(o.trialCounter)),...
                             o.partnerTypeText,...
                             o.offerType,...
                             o.playerChoice};
                trialData = trialData.';
                file = fopen(o.ratingsFileName,'a');
                fprintf(file,'%s\t%s\t%s\t%s\r\n',...
                    trialData{:});
                fclose(file);
            end
            
            % Diplay ITI Screen. t = [0s,1s)
            if now < o.itiDuration
                Screen('TextFont',o.window, 'Courier New');
                Screen('TextSize',o.window, o.fontSize);
                Screen('TextStyle', o.window, 1+2);
                Screen('glLoadIdentity', o.window);
                % Draw fixation star
                DrawFormattedText(o.window, '*', 'center', 'center',...
                    o.defaultTextColor);
            % UltimatumDecision Screen. t = [1s, 4s)
            elseif now < o.itiDuration + o.decisionDuration ...
                    && now > o.itiDuration...
                    && o.partnerOfferTypes(o.trialCounter) < 4 ...
                    && ~o.chose
                % Draw bars
                acceptOptionX = 0.15 * [-50 -50 -25 -25];
                acceptOptionY = 0.15 * o.barY;
                rejectOptionX = 0.15 * [25 25 50 50];
                rejectOptionY = 0.15 * o.barY;
                
                o.acceptBoxColor = o.defaultBoxColor;
                o.acceptBoxTextColor = o.defaultBoxTextColor;
                o.rejectBoxColor = o.defaultBoxColor;
                o.rejectBoxTextColor = o.defaultBoxTextColor;
                    
                % Draw Accept, Reject boxes
                Screen('FillPoly',o.window, o.acceptBoxColor,[acceptOptionX',acceptOptionY'],1); 
                Screen('FillPoly',o.window, o.rejectBoxColor,[rejectOptionX',rejectOptionY'],1); 

                % Set up screen parameters
                Screen('TextFont',o.window, 'Courier New');
                Screen('TextSize',o.window, o.fontSize);
                Screen('TextStyle', o.window, 1+2);
                Screen('glLoadIdentity', o.window);
                % Draw partner image
                Screen('DrawTexture',o.window,o.partnerTexture);
                % Draw Accept, Reject text in boxes
                DrawFormattedText(o.window, 'Accept', 1920/2 - 335,...
                        o.boxTextY, o.acceptBoxTextColor);
                DrawFormattedText(o.window, 'Reject', 1920/2 + 180,...
                    o.boxTextY, o.rejectBoxTextColor);
                DrawFormattedText(o.window, o.offerType, 'center',...
                    745, o.defaultTextColor);
                DrawFormattedText(o.window, o.partnerTypeText, 'center',...
                    350, o.defaultTextColor);

            elseif now < o.itiDuration + o.decisionDuration ...
                    && now > o.itiDuration...
                    && o.partnerOfferTypes(o.trialCounter) < 4 ...
                    && isequal(o.playerChoice,'Accept')
                % Draw bars
                acceptOptionX = 0.15 * [-50 -50 -25 -25];
                acceptOptionY = 0.15 * o.barY;
                rejectOptionX = 0.15 * [25 25 50 50];
                rejectOptionY = 0.15 * o.barY;
                
                o.acceptBoxColor = o.defaultBoxColor;
                o.acceptBoxTextColor = o.defaultBoxTextColor;
                o.rejectBoxColor = o.unselectedBoxColor;
                o.rejectBoxTextColor = o.unselectedBoxTextColor;

                % Draw Accept, Reject boxes
                Screen('FillPoly',o.window, o.acceptBoxColor,[acceptOptionX',acceptOptionY'],1); 
                Screen('FillPoly',o.window, o.rejectBoxColor,[rejectOptionX',rejectOptionY'],1); 

                % Set up screen parameters
                Screen('TextFont',o.window, 'Courier New');
                Screen('TextSize',o.window, o.fontSize);
                Screen('TextStyle', o.window, 1+2);
                Screen('glLoadIdentity', o.window);
                % Draw partner image
                Screen('DrawTexture',o.window,o.partnerTexture);
                % Draw Accept, Reject text in boxes
                DrawFormattedText(o.window, 'Accept', 1920/2 - 335,...
                        o.boxTextY, o.acceptBoxTextColor);
                DrawFormattedText(o.window, 'Reject', 1920/2 + 180,...
                    o.boxTextY, o.rejectBoxTextColor);
                DrawFormattedText(o.window, o.offerType, 'center',...
                    745, o.defaultTextColor);
                DrawFormattedText(o.window, o.partnerTypeText, 'center',...
                    350, o.defaultTextColor);

                % Log Data, only runs once per trial
                if ~o.trialLogged && o.chose
                    o.trialLogged = true;
                    trialData =...
                        {num2str(o.stimulationConditions(o.trialCounter)),...
                                 o.partnerTypeText,...
                                 o.offerType,...
                                 o.playerChoice,...
                                 num2str(o.playerReactionTime)};
                    trialData = trialData.';
                    file = fopen(o.fileName,'a');
                    fprintf(file,'%s\t%s\t%s\t%s\t%s\r\n',...
                        trialData{:});
                    fclose(file);
                end
            elseif now < o.itiDuration + o.decisionDuration ...
                    && now > o.itiDuration...
                    && o.partnerOfferTypes(o.trialCounter) < 4 ...
                    && isequal(o.playerChoice,'Reject')
                % Draw bars
                acceptOptionX = 0.15 * [-50 -50 -25 -25];
                acceptOptionY = 0.15 * o.barY;
                rejectOptionX = 0.15 * [25 25 50 50];
                rejectOptionY = 0.15 * o.barY;
                
                o.acceptBoxColor = o.unselectedBoxColor;
                o.acceptBoxTextColor = o.unselectedBoxTextColor;
                o.rejectBoxColor = o.defaultBoxColor;
                o.rejectBoxTextColor = o.defaultBoxTextColor;

                % Draw Accept, Reject boxes
                Screen('FillPoly',o.window, o.acceptBoxColor,[acceptOptionX',acceptOptionY'],1); 
                Screen('FillPoly',o.window, o.rejectBoxColor,[rejectOptionX',rejectOptionY'],1); 

                % Set up screen parameters
                Screen('TextFont',o.window, 'Courier New');
                Screen('TextSize',o.window, o.fontSize);
                Screen('TextStyle', o.window, 1+2);
                Screen('glLoadIdentity', o.window);
                % Draw partner image
                Screen('DrawTexture',o.window,o.partnerTexture);
                % Draw Accept, Reject text in boxes
                DrawFormattedText(o.window, 'Accept', 1920/2 - 335,...
                    o.boxTextY, o.acceptBoxTextColor);
                DrawFormattedText(o.window, 'Reject', 1920/2 + 180,...
                    o.boxTextY, o.rejectBoxTextColor);
                DrawFormattedText(o.window, o.offerType, 'center',...
                    745, o.defaultTextColor);
                DrawFormattedText(o.window, o.partnerTypeText, 'center',...
                    350, o.defaultTextColor);

                % Log Data, only runs once per trial
                if ~o.trialLogged && o.chose
                    o.trialLogged = true;
                    trialData =...
                        {num2str(o.stimulationConditions(o.trialCounter)),...
                                 o.partnerTypeText,...
                                 o.offerType,...
                                 o.playerChoice,...
                                 num2str(o.playerReactionTime)};
                    trialData = trialData.';
                    file = fopen(o.fileName,'a');
                    fprintf(file,'%s\t%s\t%s\t%s\t%s\r\n',...
                        trialData{:});
                    fclose(file);
                end
            elseif now < o.itiDuration + o.decisionDuration...
                    && now > o.itiDuration...
                    && o.partnerOfferTypes(o.trialCounter) > 3
                % Set up screen parameters
                Screen('TextFont',o.window, 'Courier New');
                Screen('TextSize',o.window, o.fontSize);
                Screen('TextStyle', o.window, 1+2);
                Screen('glLoadIdentity', o.window);

                % Draw partner image
                Screen('DrawTexture',o.window,o.partnerTexture);
                % Draw Fairness prompt and other elements
                DrawFormattedText(o.window, 'Rate the fairness of this offer', 'center',...
                        o.boxTextY, o.defaultTextColor);
                DrawFormattedText(o.window, o.offerType, 'center',...
                    745, o.defaultTextColor);
                DrawFormattedText(o.window, o.partnerTypeText, 'center',...
                    350, o.defaultTextColor);

                % Log Data, only runs once per trial
                if ~o.trialLogged && o.chose
                    o.trialLogged = true;
                    trialData =...
                        {num2str(o.stimulationConditions(o.trialCounter)),...
                                 o.partnerTypeText,...
                                 o.offerType,...
                                 num2str(o.playerChoice)};
                    trialData = trialData.';
                    file = fopen(o.ratingsFileName,'a');
                    fprintf(file,'%s\t%s\t%s\t%s\r\n',...
                        trialData{:});
                    fclose(file);
                end
            end
        end     
    end
end