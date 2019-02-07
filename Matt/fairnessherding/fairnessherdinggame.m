classdef fairnessherdinggame < neurostim.stimulus
% tACS Fairness Herding Game
% Participants play modified ultimatum game with social information.
% Participants have choice to accept or reject offer.
% When there is social information, the ratio of participants who
% accepted the offer is displayed.
%
% Controls:
% - '1'       left option
% - '0'       right option
% Screen Order:
% - Inform Screen:       1.5s
% - Decision Screen:     3s
% - Outcome Screen:      1s
% - ITI Fixation Screen: 1s
% 
% BK - Mar 2017, MS - modified Jan. 2019
    properties
        chose@logical = false;
        trialLogged@logical = false;
        trialCounter = 0; 
        stimConditions = [];
    end
    
    methods
        %% Constructor
        function o=fairnessherdinggame(c,name)
            % Create stimulus object
            o = o@neurostim.stimulus(c,name);
            % Define properties that will be logged.
            o.addProperty('offerType', NaN);
            o.addProperty('chancePunishment', NaN);
            o.addProperty('mediumChance', .33);
            o.addProperty('highChance', .66);
            o.addProperty('trialConditionData', NaN);
            o.addProperty('leftOption', NaN);
            o.addProperty('rightOption', NaN);
            o.addProperty('fileName', NaN);
            o.addProperty('herdType', NaN);
            o.addProperty('herdTypeText', NaN);      
            o.addProperty('opponentType', NaN);
            o.addProperty('opponentFile', NaN);
            o.addProperty('opponentImage', NaN);
            o.addProperty('opponentTexture', NaN);
            o.addProperty('punishment', NaN);
            o.addProperty('playerChoice', NaN);
            o.addProperty('playerMoney', NaN);
            o.addProperty('playerReactionTime', NaN);
            o.addProperty('informDuration',NaN);
            o.addProperty('decisionDuration',NaN);
            o.addProperty('outcomeDuration',NaN);
            o.addProperty('itiDuration', NaN);
            o.addProperty('textColor',[1 1 1]);
            o.addProperty('fontSize',32);
            o.addProperty('barHeight', [-55 -45 -45 -55]);
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
            % Reset Fields
            o.trialCounter = o.trialCounter + 1;
            o.trialLogged = false;
            o.chose = false; 
            o.playerChoice = NaN; 
            o.playerReactionTime = NaN;
            o.playerMoney = 20; 
            o.punishment = NaN; 
            
            % Determine Social/Non-Social
            if o.trialConditionData(o.trialCounter) == 1
                o.opponentType = 'Person';
                o.opponentFile = 'person.jpg';
            elseif o.trialConditionData(o.trialCounter) == 2
                o.opponentType = 'PC';
                o.opponentFile = 'pc.jpg';
            else
                o.opponentType = 'break';
                o.opponentFile = 'pc.jpg';
            end
            
            % Determine Herd Type
            if o.trialConditionData(o.trialCounter,2) == 1 % No Punishment
                o.herdType = 'None';
                o.herdTypeText = ' ';
            elseif o.trialConditionData(o.trialCounter,2) == 2 % Low size
                size = randsample([3 4 5 6],1);
                if size == 3
                    o.herdType = '1/3';
                    o.herdTypeText = strcat(o.herdType,' Particiants Accepted');
                elseif size == 4
                    o.herdType = '1/4';
                    o.herdTypeText = strcat(o.herdType,' Particiants Accepted');
                elseif size == 5
                    o.herdType = '1/5';
                    o.herdTypeText = strcat(o.herdType,' Particiants Accepted');
                elseif size == 6
                    o.herdType = '1/6';
                    o.herdTypeText = strcat(o.herdType,' Particiants Accepted');
                end
            elseif o.trialConditionData(o.trialCounter,2) == 3 % High size
                size = randsample([3 4 5 6],1);
                if size == 3
                    o.herdType = '2/3';
                    o.herdTypeText = strcat(o.herdType,' Particiants Accepted');
                elseif size == 4
                    o.herdType = '3/4';
                    o.herdTypeText = strcat(o.herdType,' Particiants Accepted');
                elseif size == 5
                    o.herdType = '4/5';
                    o.herdTypeText = strcat(o.herdType,' Particiants Accepted');
                elseif size == 6
                    o.herdType = '5/6';
                    o.herdTypeText = strcat(o.herdType,' Particiants Accepted');
                end
            else
                o.herdType = 'break';
            end
            
            if rand() < .5
                    o.leftOption = 'Accept';
                    o.rightOption = 'Reject';
            else
                o.leftOption = 'Reject';
                o.rightOption = 'Accept';
            end
            
            % Determine Offer Type
            if o.trialConditionData(o.trialCounter,3) == 1
                o.offerType = 'I get $10, You get $10';
            elseif o.trialConditionData(o.trialCounter,3) == 2
                o.offerType = 'I get $11, You get $9';
            elseif o.trialConditionData(o.trialCounter,3) == 3
                o.offerType = 'I get $12, You get $8';
            elseif o.trialConditionData(o.trialCounter,3) == 4
                o.offerType = 'I get $13, You get $7';
            elseif o.trialConditionData(o.trialCounter,3) == 5
                o.offerType = 'I get $16, You get $4';
            elseif o.trialConditionData(o.trialCounter,3) == 6
                o.offerType = 'I get $17, You get $3';
            elseif o.trialConditionData(o.trialCounter,3) == 7
                o.offerType = 'I get $18, You get $2';
            elseif o.trialConditionData(o.trialCounter,3) == 8
                o.offerType = 'I get $19, You get $1';
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
                    && now >  o.informDuration...
                    && ~o.chose
                if ch == o.oneKey % Left Option
                    % Mark reaction time
                    o.playerReactionTime =...
                        now - o.informDuration;
                    o.playerChoice = o.leftOption; % Player chooses to give 10.
                    o.chose = true; % Update trial state
                    % Update UI properties
                    o.acceptBoxColor = o.defaultBoxColor;
                    o.acceptBoxTextColor = o.defaultBoxTextColor;
                    o.rejectBoxColor = o.unselectedBoxColor;
                    o.rejectBoxTextColor = o.unselectedBoxTextColor;
                    % Log Choice
                    output = strcat(num2str(o.stimConditions(o.trialCounter)),'\t',...
                        num2str(o.trialConditionData(o.trialCounter)),'\t',...
                        o.herdType,'\t',...
                        num2str(o.trialConditionData(o.trialCounter),3),'\t',...
                        num2str(o.playerChoice),'\r\n');
                    outputFile = fopen(o.fileName,'a');
                    fprintf(outputFile,output);
                    fclose(outputFile);
                    o.trialLogged = true;
                elseif ch == o.zeroKey % Right Option
                    o.playerReactionTime =...
                        now - o.informDuration;
                    o.playerChoice = o.rightOption;
                    o.chose = true;
                    % Update UI properties
                    o.acceptBoxColor = o.unselectedBoxColor;
                    o.acceptBoxTextColor = o.unselectedBoxTextColor;
                    o.rejectBoxColor = o.defaultBoxColor;
                    o.rejectBoxTextColor = o.defaultBoxTextColor;
                    % Log Choice
                    output = strcat(num2str(o.stimConditions(o.trialCounter)),'\t',...
                        num2str(o.trialConditionData(o.trialCounter)),'\t',...
                        o.herdType,'\t',...
                        num2str(o.trialConditionData(o.trialCounter),3),'\t',...
                        num2str(o.playerChoice),'\r\n');
                    outputFile = fopen(o.fileName,'a');
                    fprintf(outputFile,output);
                    fclose(outputFile);
                    o.trialLogged = true;
                end
            end
            
            %% No Response Check
            % Still no guess, set choice as n/a
            if ~o.chose && (now > 0.99*( o.decisionDuration + o.informDuration))
                o.chose = true;
                o.playerChoice = 'n/a';
                output = strcat(num2str(o.stimConditions(o.trialCounter)),'\t',...
                        num2str(o.trialConditionData(o.trialCounter)),'\t',...
                        o.herdType,'\t',...
                        num2str(o.trialConditionData(o.trialCounter),3),'\t',...
                        num2str(o.playerChoice),'\r\n');
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
                % Display break screen
                DrawFormattedText(o.window, '2 Minute Break', 'center', 350,...
                     o.textColor);
            else 
            %% Game
                % Inform Screen. t = [1s, 3s)
                % To be shown before guess duration runs out and before guess
                % is made. time < 3s.
                if now < o.informDuration
                    % Display the herdTypeText (0:0 or 5:1)
                    Screen('TextFont',o.window, 'Courier New');
                    Screen('TextSize',o.window, o.fontSize);
                    Screen('TextStyle', o.window, 1+2);
                    Screen('glLoadIdentity', o.window);
                    % Display the Punishment Type
                    DrawFormattedText(o.window, o.herdTypeText, 'center', 350, o.textColor);
                    % Display Opponent Image
                    Screen('DrawTexture',o.window,o.opponentTexture);

                % Decision Screen. t = [3s,6s)
                elseif now < o.informDuration + o.decisionDuration...
                        && ~o.chose
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
                    DrawFormattedText(o.window, o.leftOption, 1920/2 - 335,...
                            o.boxTextY, o.acceptBoxTextColor);
                    DrawFormattedText(o.window, o.rightOption, 1920/2 + 180,...
                            o.boxTextY, o.rejectBoxTextColor);
                   % Display the Punishment Type
                    DrawFormattedText(o.window, o.offerType, 'center',...
                        745, o.textColor);
                    DrawFormattedText(o.window, o.herdTypeText, 'center',...
                        350, o.textColor);
                end
            end            
        end     
    end
end