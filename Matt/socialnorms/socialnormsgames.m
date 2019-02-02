classdef socialnormsgames < neurostim.stimulus
% tACS Social Norms Game
% Participants play modified ultimatum game with chance of punishment.
% Participants have a binary choice of which option to accept.
% When there is punishment, the (medium or high) chance for punishment is
% displayed.
%
% Controls:
% - 'f'       left option
% - 'g'       right option
% Screen Order:   
% - Inform Screen:       2s
% - Decision Screen:     3s
% - Outcome Sc reen:     1s
% - ITI Fixation Screen: 1s
%
% BK - Mar 2017, MS - modified Jan. 2019
    properties
        % State variables - mostly for logging/display purposes
        chose@logical = false;
        punished@logical = false; 
        trialLogged@logical = false; 
        trialCounter = 0; % Incremented before each trial
        stimConditions = []; % Filled in run.m
        catchTrialCounter = 0;
    end
    
    methods
        %% Constructor
        function o=socialnormsgames(c,name)
            % Create stimulus object
            o = o@neurostim.stimulus(c,name);
            % Define properties that will be logged.
            o.addProperty('fileName', NaN);
            o.addProperty('trialConditionData', NaN);
            o.addProperty('leftOption', NaN);
            o.addProperty('rightOption', NaN);
            o.addProperty('punishmentMultiplier', 2);
            o.addProperty('chancePunishment', NaN);
            o.addProperty('mediumChance', .33);
            o.addProperty('highChance', .66);
            o.addProperty('punishmentType', NaN);
            o.addProperty('punishmentTypeText', NaN);      
            o.addProperty('opponentType', NaN);
            o.addProperty('opponentFile', NaN);
            o.addProperty('opponentImage', NaN);
            o.addProperty('opponentTexture', NaN);
            o.addProperty('punishment', NaN);
            o.addProperty('playerChoice', NaN);
            o.addProperty('playerMoney', NaN);
            o.addProperty('playerReactionTime', NaN);
            o.addProperty('itiDuration',NaN);
            o.addProperty('informDuration',NaN);
            o.addProperty('decisionDuration',NaN);
            o.addProperty('outcomeDuration',NaN);
            o.addProperty('textColor',[1 1 1]);
            o.addProperty('borderColor', [1 1 1]);
            o.addProperty('fontSize',32);
            o.addProperty('defaultBoxTextColor',[0.1 0.1 0.1]);
            o.addProperty('defaultBoxColor', [1 1 1]);
            o.addProperty('unselectedBoxTextColor', [0.15 0.15 0.15]);
            o.addProperty('unselectedBoxColor', [0.15 0.15 0.15]);
            o.addProperty('acceptBoxTextColor',[0.1 0.1 0.1]);
            o.addProperty('acceptBoxColor', [1 1 1]);
            o.addProperty('rejectBoxTextColor',[0.1 0.1 0.1]);
            o.addProperty('rejectBoxColor', [1 1 1]);
            o.addProperty('barY', [-55 -45 -45 -55]);
            o.addProperty('boxTextY', 895);
            
            % Define keyCodes respective to system
            % Find keycode values in the kbName class. 
            % right click on kbName and go to open "kbName"
            if ispc
                o.addProperty('oneKey', 97);
                o.addProperty('zeroKey', 96);
            elseif ismac 
                o.addProperty('oneKey', 89);
                o.addProperty('zeroKey', 98);
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
            o.punished = false;
            o.playerChoice = NaN; 
            o.playerReactionTime = NaN;
            o.playerMoney = 20; 
            o.punishment = NaN; 
            
            % Determine Social/Non-Social
            if o.trialConditionData(o.trialCounter) == 1
                o.opponentType = 'Person';
                o.opponentFile = 'person.jpg';
            elseif o.trialConditionData(o.trialCounter) == 1
                o.opponentType = 'PC';
                o.opponentFile = 'pc.jpg';
            else
                o.opponentType = 'break';
                o.opponentFile = 'pc.jpg';
            end
            
            % Determine Punishment Type
            if o.trialConditionData(o.trialCounter,2) == 1 % No Punishment
                o.punishmentType = 'None';
                o.punishmentTypeText = 'NO PUNISHMENT';
                o.chancePunishment = 0;
            elseif o.trialConditionData(o.trialCounter,2) == 2 % 33% Punishment
                o.punishmentType = 'Medium';
                o.punishmentTypeText = 'MEDIUM CHANCE OF PUNISHMENT';
                o.chancePunishment = o.mediumChance;
            elseif o.trialConditionData(o.trialCounter,2) == 3 % 66% Punishment
                o.punishmentType = 'High';
                o.punishmentTypeText = 'HIGH CHANCE OF PUNISHMENT';
                o.chancePunishment = o.highChance;
            else
                o.punishmentType = 'Break';
            end
            
            % Determine Offer Type
            if o.trialConditionData(o.trialCounter,3) == 1
                if rand() < .5
                    o.leftOption = 0;
                    o.rightOption = 2;
                else
                    o.leftOption = 2;
                    o.rightOption = 0;
                end
            elseif o.trialConditionData(o.trialCounter,3) == 2
                if rand() < .5
                    o.leftOption = 0;
                    o.rightOption = 5;
                else
                    o.leftOption = 5;
                    o.rightOption = 0;
                end
            elseif o.trialConditionData(o.trialCounter,3) == 3
                if rand() < .5
                    o.leftOption = 0;
                    o.rightOption = 10;
                else
                    o.leftOption = 10;
                    o.rightOption = 0;
                end
            elseif o.trialConditionData(o.trialCounter,3) == 4
                if rand() < .5
                    o.leftOption = 2;
                    o.rightOption = 5;
                else
                    o.leftOption = 5;
                    o.rightOption = 2;
                end
            elseif o.trialConditionData(o.trialCounter,3) == 5
                if rand() < .5
                    o.leftOption = 2;
                    o.rightOption = 10;
                else
                    o.leftOption = 10;
                    o.rightOption = 2;
                end
            elseif o.trialConditionData(o.trialCounter,3) == 6
                if rand() < .5
                    o.leftOption = 5;
                    o.rightOption = 10;
                else
                    o.leftOption = 10;
                    o.rightOption = 5;
                end
            end
            
            % Set Opponent Image
            o.opponentImage = imread(o.opponentFile);
            o.opponentTexture = Screen('MakeTexture',o.window,o.opponentImage);        
        end
        
        %% Executes every frame
        function beforeFrame(o,~,~)      
            % Mark trial time
            now  = o.cic.trialTime;
            
            %% Collect User Response
            % Check for response if decision has yet to be made and the
            % guess duration has not elapsed.
            [~,~,keyCode] = KbCheck;  
            ch = find(keyCode); % Translate key press to corresponding
                                %  keyCode. List of key codes in KbName.m.
            if now < o.informDuration + o.decisionDuration...
                    && now > o.informDuration...
                    && ~o.chose
                if ch == o.oneKey % Left Option
                    % Mark reaction time
                    o.playerReactionTime =...
                        now - o.informDuration;
                    o.playerChoice = o.leftOption; % Player chooses to give 10.
                    o.playerMoney = o.playerMoney - o.playerChoice;
                    o.chose = true; % Update trial state
                    % Update UI properties
                    o.acceptBoxColor = o.defaultBoxColor;
                    o.acceptBoxTextColor = o.defaultBoxTextColor;
                    o.rejectBoxColor = o.unselectedBoxColor;
                    o.rejectBoxTextColor = o.unselectedBoxTextColor;
                elseif ch == o.zeroKey % Right Option
                    o.playerReactionTime =...
                        now - o.informDuration;
                    o.playerChoice = o.rightOption;
                    o.playerMoney = o.playerMoney - o.playerChoice;
                    o.chose = true;
                    % Update UI properties
                    o.acceptBoxColor = o.unselectedBoxColor;
                    o.acceptBoxTextColor = o.unselectedBoxTextColor;
                    o.rejectBoxColor = o.defaultBoxColor;
                    o.rejectBoxTextColor = o.defaultBoxTextColor;
                end
            end
            
            %% No Response Check
            % Still no guess, set choice as n/a
            if ~o.chose && (now > 0.99*(o.decisionDuration + o.informDuration))
                o.chose = true;
                o.playerChoice = 'n/a';
                o.punishment = 0;
                o.playerMoney = 0;
                o.playerReactionTime = 'n/a';
                output = strcat(num2str(o.stimConditions(o.trialCounter)),'\t',...
                            num2str(o.trialConditionData(o.trialCounter)),'\t',...
                            num2str(o.trialConditionData(o.trialCounter),2),'\t',...
                            num2str(o.trialConditionData(o.trialCounter),3),'\t',...
                            num2str(o.playerChoice),'\t',num2str(o.punishment),'\r\n');
                outputFile = fopen(o.fileName,'a');
                fprintf(outputFile,output);
                fclose(outputFile);
                o.trialLogged = true;
            end
            
            %% Break Screen
            if o.trialConditionData(o.trialCounter) == 9 ...
                    && o.trialConditionData(o.trialCounter,2) == 9 ...
                    && o.trialConditionData(o.trialCounter,3) == 9
                % Break Screen. Displayed for 1:59 mins.
                Screen('TextFont',o.window, 'Courier New');
                Screen('TextSize',o.window, o.fontSize);
                Screen('TextStyle', o.window, 1+2);
                Screen('glLoadIdentity', o.window);
                DrawFormattedText(o.window, '2 Minute Break', 'center', 350,...
                     o.textColor);
            else
            %% Game
                % Inform Screen. t = [0s, 2s)
                % To be shown before guess duration runs out and before guess
                % is made. time < 3s.
                if now < o.informDuration
                    % Display the punishmentTypeText (0:0 or 5:1)
                    Screen('TextFont',o.window, 'Courier New');
                    Screen('TextSize',o.window, o.fontSize);
                    Screen('TextStyle', o.window, 1+2);
                    Screen('glLoadIdentity', o.window);
                    % Display the Punishment Type
                    DrawFormattedText(o.window, o.punishmentTypeText, 'center', 350, o.textColor);
                    % Display Opponent Image
                    Screen('DrawTexture',o.window,o.opponentTexture);

                % Decision Screen. t = [2s,5s)
                elseif now < o.informDuration + o.decisionDuration
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
                    Screen('DrawTexture',o.window,o.opponentTexture);
                    % Draw Accept, Reject text in boxes
                    DrawFormattedText(o.window, strcat('$',num2str(o.leftOption)), 1920/2 - 335,...
                            o.boxTextY, o.acceptBoxTextColor);
                    DrawFormattedText(o.window, strcat('$',num2str(o.rightOption)), 1920/2 + 180,...
                            o.boxTextY, o.rejectBoxTextColor);
                   % Display the Punishment Type
                    DrawFormattedText(o.window, o.punishmentTypeText, 'center', 350, o.textColor);

                % Outcome Screen t = [5s,6s]
                % This determines the opponent punishment and displays the
                %  correpsonding result for ultimatum game type trials.
                elseif now < o.informDuration + o.decisionDuration...
                        + o.outcomeDuration
                    % Calculate Punishment and update player money
                    if o.punished == false
                        if o.trialConditionData(o.trialCounter,2) == 1 % No punishment
                            o.punishment = 0;
                            o.punished = true;
                        else % Determine punishment
                            if o.trialConditionData(o.trialCounter,3) == 1
                                if o.playerChoice == 0
                                    if rand() < o.chancePunishment
                                        o.punishment =...
                                            o.punishmentMultiplier * randi(5)+5;
                                    else
                                        o.punishment = 0;
                                    end
                                else
                                    o.punishment = 0;
                                end
                            elseif o.trialConditionData(o.trialCounter,3) == 2
                                if o.playerChoice == 0
                                    if rand() < o.chancePunishment
                                        o.punishment =...
                                            o.punishmentMultiplier * randi(5)+5;
                                    else
                                        o.punishment = 0;
                                    end
                                else
                                    o.punishment = 0;
                                end
                            elseif o.trialConditionData(o.trialCounter,3) == 3
                                if o.playerChoice == 0
                                    if rand() < o.chancePunishment
                                        o.punishment =...
                                            o.punishmentMultiplier * randi(5)+5;
                                    else
                                        o.punishment = 0;
                                    end
                                else
                                    o.punishment = 0;
                                end
                            elseif o.trialConditionData(o.trialCounter,3) == 4
                                if o.playerChoice == 2
                                    if rand() < o.chancePunishment
                                        o.punishment =...
                                            o.punishmentMultiplier * randi(5)+5;
                                    else
                                        o.punishment = 0;
                                    end
                                else
                                    o.punishment = 0;
                                end
                            elseif o.trialConditionData(o.trialCounter,3) == 5
                                if o.playerChoice == 2
                                    if rand() < o.chancePunishment
                                        o.punishment =...
                                            o.punishmentMultiplier * randi(5)+5;
                                    else
                                        o.punishment = 0;
                                    end
                                else
                                    o.punishment = 0;
                                end
                            elseif o.trialConditionData(o.trialCounter,3) == 6
                                if o.playerChoice == 5
                                    if rand() < o.chancePunishment
                                        o.punishment =...
                                            o.punishmentMultiplier * randi(5)+5;
                                    else
                                        o.punishment = 0;
                                    end
                                else
                                    o.punishment = 0;
                                end
                            end
                            % Update player's money after punishment.
                            o.playerMoney  = o.playerMoney - o.punishment;
                            o.punished = true;
                        end        
                    end

                    % Setup screen parameters
                    Screen('TextFont',o.window, 'Courier New');
                    Screen('TextSize',o.window, o.fontSize);
                    Screen('TextStyle', o.window, 1+2);
                    Screen('glLoadIdentity', o.window);
                    Screen('DrawTexture',o.window,o.opponentTexture);

                    % Draw Game Type Text
                    DrawFormattedText(o.window, strcat('Punishment:                        $', num2str(o.punishment)), 'center',...
                        745, o.textColor);
                    DrawFormattedText(o.window, strcat('Earnings:                         $', num2str(o.playerMoney)), 'center',...
                        800, o.textColor);

                    % Log Data
                    if ~o.trialLogged
                        output = strcat(num2str(o.stimConditions(o.trialCounter)),'\t',...
                            num2str(o.trialConditionData(o.trialCounter)),'\t',...
                            num2str(o.trialConditionData(o.trialCounter),2),'\t',...
                            num2str(o.trialConditionData(o.trialCounter),3),'\t',...
                            num2str(o.playerChoice),'\t',num2str(o.punishment),'\r\n');
                        outputFile = fopen(o.fileName,'a');
                        fprintf(outputFile,output);
                        fclose(outputFile);
                        o.trialLogged = true;
                    end
                end
            end
        end     
    end
end