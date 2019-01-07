classdef simpleslotmachinegame < neurostim.stimulus
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
        payout@logical = false; % Decide if subject won money
        punishmentSelected@logical = false;
        trialLogged@logical = false;
        trialCounter = 1; 
        stimulationConditions = [];
        positions = [];
    end
    
    methods
        %% Constructor
        function o=simpleslotmachinegame(c,name)
            % Create stimulus object
            o = o@neurostim.stimulus(c,name);
            % Define properties that will be logged.
            o.addProperty('file', NaN);
            o.addProperty('fileName', NaN);
            o.addProperty('highPayoutMachinePosition', NaN);
            o.addProperty('lowPayoutMachinePosition', NaN);
            o.addProperty('highPayoutMachineTexture', NaN);
            o.addProperty('lowPayoutMachineTexture', NaN);
            o.addProperty('highPayoutMachineDownImage', NaN);
            o.addProperty('lowPayoutMachineDownImage', NaN); 
            o.addProperty('highPayoutMachineUpImage', NaN);
            o.addProperty('lowPayoutMachineUpImage', NaN);   
            o.addProperty('highPayoutMachineImageTexture', NaN);
            o.addProperty('lowPayoutMachineImageTexture', NaN);
            o.addProperty('moneyImage', NaN);
            o.addProperty('moneyTexture', NaN);
            o.addProperty('playerChoice', NaN);
            o.addProperty('playerReactionTime', NaN); 
            o.addProperty('decisionDuration',NaN);
            o.addProperty('itiDuration', NaN);
            o.addProperty('defaultTextColor',[1 1 1]);
            o.addProperty('fontSize',32);
            
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
            o.trialLogged = false;
            o.chose = false; 
            o.payout = false;
            o.playerChoice = NaN;
            o.playerReactionTime = NaN;
            
            % Assign Partner Type Condition
            if o.positions(o.trialCounter) == 1 % Low Rated
                o.highPayoutMachinePosition = randi([0 33],1);
                o.lowPayoutMachinePosition = 'Accepted';
            else
                o.highPayoutMachinePosition = randi([0 33],1);
                o.lowPayoutMachinePosition = 'Accepted';
            end
            
            % Machine's start at default 'down' position
            o.highPayoutMachineTexture = Screen('MakeTexture',o.window,...
                o.highPayoutMachineDownImage);
            o.lowPayoutMachineTexture = Screen('MakeTexture',o.window,...
                o.lowPayoutMachineDownImage);
            
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
                    if o.positions(o.trialCounter) == 1
                        o.highPayoutMachineTexture = Screen('MakeTexture',o.window,...
                            o.highPayoutMachineUpImage);
                        if rand > .3
                            o.payout = true;
                        end
                    else
                        o.lowPayoutMachineTexture = Screen('MakeTexture',o.window,...
                            o.lowPayoutMachineUpImage);
                        if rand <= .3
                            o.payout = true;
                        end
                    end
                elseif ch == o.gKey
                    o.playerReactionTime =...
                        now - o.itiDuration;
                    o.playerChoice = 'Reject';
                    o.chose = true;
                    % Update UI properties
                    if o.positions(o.trialCounter) == 2
                        o.highPayoutMachineTexture = Screen('MakeTexture',o.window,...
                            o.highPayoutMachineUpImage);
                    else
                        o.lowPayoutMachineTexture = Screen('MakeTexture',o.window,...
                            o.lowPayoutMachineUpImage);
                    end
                end
            end
            
            % Still no guess since preround screen, list as n/a
            if ~o.chose && (now > 0.99*(o.itiDuration + o.decisionDuration))
                o.playerChoice = 'n/a';
            end
            
            % Diplay ITI Screen. t = [0s,1s)
            if now < o.itiDuration
                Screen('TextFont',o.window, 'Courier New');
                Screen('TextSize',o.window, o.fontSize);
                Screen('TextStyle', o.window, 1+2);
                Screen('glLoadIdentity', o.window);
                
                DrawFormattedText(o.window, '+', 'center', 'center',...
                    o.defaultTextColor);
            % UltimatumDecision Screen. t = [1s, 4s)
            elseif now < o.itiDuration + o.decisionDuration...
                % Set up screen parameters
                Screen('TextFont',o.window, 'Courier New');
                Screen('TextSize',o.window, o.fontSize);
                Screen('TextStyle', o.window, 1+2);
                Screen('glLoadIdentity', o.window);

                % Draw partner image from texture object made in
                % beforeTrial ,the texture is updated to the up position
                % when subject responds with f or g key
                Screen('DrawTexture',o.window,o.highPayoutMachineTexture, [0 0 3 3], [100 100 200 200], 0, 50);
                Screen('DrawTexture',o.window,o.lowPayoutMachineTexture, [0 0 3 3], [100 100 200 200], 0, -50);
                
                if o.payout == true
                    o.moneyTexture = Screen('MakeTexture',o.window,o.moneyImage);
                    Screen('DrawTexture',o.window,o.moneyTexture);
                end
                
                % Log Data, only runs once per trial
%                 if ~o.trialLogged && o.chose  
%                     % Log choice(machine type), outcome(if got money), 
%                     trialData =...
%                         {num2str(o.stimulationConditions(o.trialCounter)),...
%                                  num2str(o.herdSize),...
%                                  o.herdFrame,...
%                                  o.offerType,...
%                                  o.playerChoice,...
%                                  num2str(o.playerReactionTime)};
%                     trialData = trialData.';
%                     file = fopen(o.fileName,'a');
%                     fprintf(file,'%s\t%s\t%s\t%s\t%s\t%s\r\n',...
%                         trialData{:});
%                     fclose(file);
%                     % Update data fields
%                     o.trialLogged = true;
%                     o.trialCounter = o.trialCounter + 1;
%                 end                
            end            
        end     
    end
end