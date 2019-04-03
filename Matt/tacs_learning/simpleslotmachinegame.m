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
        trialCounter = 0; 
        stimulationConditions = [];
        positions = [];
        blockNumber = []
    end
    
    methods
        %% Constructor
        function o=simpleslotmachinegame(c,name)
            % Create stimulus object
            o = o@neurostim.stimulus(c,name);
            % Define properties that will be logged.
            o.addProperty('file', NaN);
            o.addProperty('fileName', NaN);
            o.addProperty('imageFiles', NaN);
            o.addProperty('leftMachinePosition', [609 405 879 675]);
            o.addProperty('rightMachinePosition', [1041 405 1311 675]);
            o.addProperty('highPayoutMachineTexture', NaN);
            o.addProperty('lowPayoutMachineTexture', NaN);
            o.addProperty('highPayoutMachineImageTexture', NaN);
            o.addProperty('lowPayoutMachineImageTexture', NaN);
            o.addProperty('highPayoutMachineDownImage', NaN);
            o.addProperty('lowPayoutMachineDownImage', NaN); 
            o.addProperty('highPayoutMachineUpImage', NaN);
            o.addProperty('lowPayoutMachineUpImage', NaN);   
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
                o.addProperty('oneKey', 49);
                o.addProperty('zeroKey', 48);
            elseif ismac 
                o.addProperty('oneKey', 30);
                o.addProperty('zeroKey', 39);
            end
        end
        
        %% Before Trial
        % Called before each trial to log data from previous trial and 
        % reset appropriate fields.
        function beforeTrial(o,~,~)
            o.trialCounter = o.trialCounter + 1;
            if o.trialCounter == 321
                quit;
            end
            % Reset Fields
            o.trialLogged = false;
            o.chose = false; 
            o.payout = false;
            o.playerChoice = NaN;
            o.playerReactionTime = NaN;
            
            % Update machine images
            o.highPayoutMachineDownImage = imread(o.imageFiles{o.trialCounter,1});
            o.highPayoutMachineUpImage = imread(o.imageFiles{o.trialCounter,2});
            o.lowPayoutMachineDownImage = imread(o.imageFiles{o.trialCounter,3});
            o.lowPayoutMachineUpImage = imread(o.imageFiles{o.trialCounter,4});
            
            % Machine's start at default 'down' position
            o.highPayoutMachineTexture = Screen('MakeTexture',o.window,...
                o.highPayoutMachineUpImage);
            o.lowPayoutMachineTexture = Screen('MakeTexture',o.window,...
                o.lowPayoutMachineUpImage);
        end
        
        %% Executes every frame
        function beforeFrame(o,~,~)
            % Mark trial time
            now  = o.cic.trialTime;
            %% Collect User Response
            % Check for response if decision has yet to be made and the
            % decision duration has not elapsed.
            [~,~,keyCode] = KbCheck;  
            ch = find(keyCode); % Translate key press to corresponding
                                %  keyCode. List of key codes in KbName.m.
            if now < o.itiDuration + o.decisionDuration...
                    && now > o.itiDuration...
                    && ~o.chose
                if ch == o.oneKey
                    % Mark reaction time
                    o.playerReactionTime =...
                        now - o.itiDuration;
                    o.chose = true; % Update trial state
                    % Update UI properties
                    if o.positions(o.trialCounter) == 1
                        o.highPayoutMachineTexture = Screen('MakeTexture',o.window,...
                            o.highPayoutMachineDownImage);
                        if rand > .25
                            o.payout = true;
                        end
                        o.playerChoice = 'High'; % Player chooses to give 10.
                    else
                        o.lowPayoutMachineTexture = Screen('MakeTexture',o.window,...
                            o.lowPayoutMachineDownImage);
                        if rand <= .5
                            o.payout = true;
                        end
                        o.playerChoice = 'Low';
                    end
                elseif ch == o.zeroKey
                    o.playerReactionTime =...
                        now - o.itiDuration;
                    o.chose = true;
                    % Update UI properties
                    if o.positions(o.trialCounter) == 1
                        o.lowPayoutMachineTexture = Screen('MakeTexture',o.window,...
                            o.lowPayoutMachineDownImage);
                        if rand <= .5
                            o.payout = true;
                        end
                        o.playerChoice = 'Low';
                    else
                        o.highPayoutMachineTexture = Screen('MakeTexture',o.window,...
                            o.highPayoutMachineDownImage);
                        if rand > .25
                            o.payout = true;
                        end
                        o.playerChoice = 'High';
                    end
                end
            end
            
            %% No Response Check
            % Still no guess since preround screen, list as n/a
            if ~o.trialLogged && ~o.chose && (now > 0.99*(o.itiDuration + o.decisionDuration))
                o.playerChoice = 'n/a';
                gotPayout = 0;
                % Log choice(machine type), outcome(if got money), 
                trialData =...
                    {num2str(o.trialCounter),num2str(o.blockNumber(o.trialCounter)),...
                       num2str(o.stimulationConditions(o.trialCounter)),...
                       o.playerChoice, num2str(gotPayout), num2str(o.playerReactionTime)};
                trialData = trialData.';
                file = fopen(o.fileName,'a');
                fprintf(file,'%s\t%s\t%s\t%s\t%s\t%s\r\n',...
                    trialData{:});
                fclose(file);
                % Update data fields
                o.trialLogged = true;
            end
            
            %% Break Screen
            if o.blockNumber(o.trialCounter) == 9
                % Break Screen. Displayed for 1:59 mins.
                Screen('TextFont',o.window, 'Courier New');
                Screen('TextSize',o.window, o.fontSize);
                Screen('TextStyle', o.window, 1+2);
                Screen('glLoadIdentity', o.window);
                % Display break screen
                DrawFormattedText(o.window, '2 Minute Break', 'center', 350,...
                     o.defaultTextColor);
            else 
            %% Game
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
                    % beforeTrial.
                    % - the texture is updated to the down position
                    %   when subject responds with 1 or 0 key
                    if o.positions(o.trialCounter) == 1
                        Screen('DrawTexture',o.window,o.highPayoutMachineTexture, [], o.leftMachinePosition);
                        Screen('DrawTexture',o.window,o.lowPayoutMachineTexture, [], o.rightMachinePosition);
                    else % o.positions(o.trialCounter) == 2
                        Screen('DrawTexture',o.window,o.highPayoutMachineTexture, [], o.rightMachinePosition);
                        Screen('DrawTexture',o.window,o.lowPayoutMachineTexture, [], o.leftMachinePosition);
                    end


                    if o.payout == true
                        o.moneyTexture = Screen('MakeTexture',o.window,o.moneyImage);
                        Screen('DrawTexture',o.window,o.moneyTexture);
                    end

                    % Log Data, only runs once per trial
                    if ~o.trialLogged && o.chose  
                        if o.payout == true
                            gotPayout = 1;
                        else
                            gotPayout = 0;
                        end
                        % Log choice(machine type), outcome(if got money), 
                        trialData =...
                            {num2str(o.trialCounter),num2str(o.blockNumber(o.trialCounter)),...
                               num2str(o.stimulationConditions(o.trialCounter)),...
                               o.playerChoice, num2str(gotPayout), num2str(o.playerReactionTime)};
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
end
