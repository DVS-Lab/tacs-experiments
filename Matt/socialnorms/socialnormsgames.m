classdef socialnormsgames < neurostim.stimulus
    % Stimulus to play either a dictator or ultimatum game at random on a 
    % per trial basis. The following represents a single trial:
    
    % 1st screen: -Display gameType (text) and opponent type (image).
    % 2nd screen: -Display bars representing the partipant's money, the
    %              opponent's money, the $100 awarded to the participant. 
    %             -Display gameType (text) and opponent type (image).
    % Then the player presses a key corresponding to the amount the player wishes to give
    % their opponent.
    % 3rd Screen: The outcome is presented
    % 4th Screen: Fixation iti is shown.
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
        trialConditions = [];
        gameOrder = [];
    end
    
    methods
        %% Constructor
        function o=socialnormsgames(c,name)
            % Create stimulus object
            o = o@neurostim.stimulus(c,name);
            % Define properties that will be logged.
            o.addProperty('fileName', NaN);
            o.addProperty('gameType', NaN);
            o.addProperty('gameTypeText', NaN);      
            o.addProperty('opponentType', NaN);
            o.addProperty('opponentFile', NaN);
            o.addProperty('opponentImage', NaN);
            o.addProperty('opponentTexture', NaN);
            o.addProperty('opponentAllocation', NaN);
            o.addProperty('opponentMoney', 25);
            o.addProperty('opponentSacrifice', NaN);
            o.addProperty('scaledPunishment', NaN);
            o.addProperty('playerChoice', NaN);
            o.addProperty('playerMoney', 25);
            o.addProperty('playerAllocation', NaN);
            o.addProperty('playersGivenFunds', 100);
            o.addProperty('playerReactionTime', NaN);
            o.addProperty('informDuration',NaN);
            o.addProperty('decisionDuration',NaN);
            o.addProperty('outcomeDuration',NaN);
            o.addProperty('itiDuration', NaN);
            o.addProperty('textColor',[1 1 1]);
            o.addProperty('punishmentTextColor', [.1 .1 .1]);
            o.addProperty('sacrificeTextColor', [1 1 1]);
            o.addProperty('borderColor', [1 1 1]);
            o.addProperty('fontSize',32);
            o.addProperty('playerColor', [1 1 1]);
            o.addProperty('centerColor', [.5 .5 .5]);
            o.addProperty('opponentColor', [.1 .1 .1]);
            o.addProperty('barHeight', [-55 -45 -45 -55]);
            o.addProperty('moneyTextHeight', 895);
            
            % Define keyCodes respective to system
            % Find keycode values in the kbName class. 
            % right click on kbName and go to open "kbName"
            if ispc
                o.addProperty('zero', 48);
                o.addProperty('one', 49);
                o.addProperty('two', 50);
                o.addProperty('three', 51);
                o.addProperty('four', 52);
                o.addProperty('five', 53);
                o.addProperty('six', 54);
                o.addProperty('seven', 55);
                o.addProperty('eight', 56);
                o.addProperty('nine', 57);
                o.addProperty('all', 65);
            elseif ismac 
                o.addProperty('zero', 30);
                o.addProperty('one', 31);
                o.addProperty('two', 32);
                o.addProperty('three', 33);
                o.addProperty('four', 34);
                o.addProperty('five', 35);
                o.addProperty('six', 36);
                o.addProperty('seven', 37);
                o.addProperty('eight', 38);
                o.addProperty('nine', 39);
                o.addProperty('all', 4);
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
            o.punishmentSelected = false;
            o.playerChoice = NaN;
            o.playerReactionTime = NaN;
            o.playerAllocation = NaN;
            o.playerMoney = 25;
            o.opponentMoney = 25;
            o.opponentSacrifice = NaN;
            o.scaledPunishment = NaN;
            
            % Determine Game Type
            if o.gameOrder(o.trialCounter) == 1
                o.gameType = 'Dictator';
                o.gameTypeText = 'No Punishment';
            else
                o.gameType = 'Ultimatum';
                o.gameTypeText = 'Punishment';
            end
            
            % Determine Opponenet Type
            if o.gameOrder(o.trialCounter,2) == 1
                o.opponentType = 'Person';
                o.opponentFile = 'person.jpg';
            else 
                o.opponentType = 'PC';
                o.opponentFile = 'pc.jpg';
            end
            
            % Set Opponent Image
            o.opponentImage = imread(o.opponentFile);
            o.opponentTexture = Screen('MakeTexture',o.window,o.opponentImage);        
        end
        
        %% Executes every frame
        function beforeFrame(o,~,~)      
            % Mark trial time
            now  = o.cic.trialTime;

            % Check for response if decision has yet to be made and the
            % guess duration has not elapsed.
            [~,~,keyCode] = KbCheck;  
            ch = find(keyCode); % Translate key press to corresponding
                                %  keyCode. List of key codes in KbName.m.
            if now < o.itiDuration + o.informDuration + o.decisionDuration...
                    && now > o.itiDuration + o.informDuration...
                    && ~o.chose
                if ch == o.one
                    % Mark reaction time
                    o.playerReactionTime = now - (o.itiDuration + o.informDuration);
                    o.playerChoice = 10; % Player chooses to give 10.
                    % Calculate the amount given to player.
                    o.playerAllocation = o.playersGivenFunds - o.playerChoice;
                    % Now add the player's portion to the intial $25.
                    o.playerMoney = o.playerMoney + o.playerAllocation;
                    % Add the opponents's portion to the intial $25.
                    o.opponentMoney = o.opponentMoney + o.playerChoice;
                    o.chose = true; % Update trial state     
                elseif ch == o.two
                    o.playerReactionTime = now - (o.itiDuration + o.informDuration);
                    o.playerChoice = 20;
                    o.playerAllocation = o.playersGivenFunds - o.playerChoice;
                    o.playerMoney = o.playerMoney + o.playerAllocation;
                    o.opponentMoney = o.opponentMoney + o.playerChoice;
                    o.chose = true;
                elseif ch == o.three
                    o.playerReactionTime = now - (o.itiDuration + o.informDuration);
                    o.playerChoice = 30;
                    o.playerAllocation = o.playersGivenFunds - o.playerChoice;
                    o.playerMoney = o.playerMoney + o.playerAllocation;
                    o.opponentMoney = o.opponentMoney + o.playerChoice;
                    o.chose = true;
                elseif ch == o.four
                    o.playerReactionTime = now - (o.itiDuration + o.informDuration);
                    o.playerChoice = 40;
                    o.playerAllocation = o.playersGivenFunds - o.playerChoice;
                    o.playerMoney = o.playerMoney + o.playerAllocation;
                    o.opponentMoney = o.opponentMoney + o.playerChoice;
                    o.chose = true;
                elseif ch == o.five
                    o.playerReactionTime = now - (o.itiDuration + o.informDuration);
                    o.playerChoice = 50;
                    o.playerAllocation = o.playersGivenFunds - o.playerChoice;
                    o.playerMoney = o.playerMoney + o.playerAllocation;
                    o.opponentMoney = o.opponentMoney + o.playerChoice;
                    o.chose = true;
                elseif ch == o.six
                    o.playerReactionTime = now - (o.itiDuration + o.informDuration);
                    o.playerChoice = 60;
                    o.playerAllocation = o.playersGivenFunds - o.playerChoice;
                    o.playerMoney = o.playerMoney + o.playerAllocation;
                    o.opponentMoney = o.opponentMoney + o.playerChoice;
                    o.chose = true;
                elseif ch == o.seven
                    o.playerReactionTime = now - (o.itiDuration + o.informDuration);
                    o.playerChoice = 70;
                    o.playerAllocation = o.playersGivenFunds - o.playerChoice;
                    o.playerMoney = o.playerMoney + o.playerAllocation;
                    o.opponentMoney = o.opponentMoney + o.playerChoice;
                    o.chose = true;
                elseif ch == o.eight
                    o.playerReactionTime = now - (o.itiDuration + o.informDuration);
                    o.playerChoice = 80;
                    o.playerAllocation = o.playersGivenFunds - o.playerChoice;
                    o.playerMoney = o.playerMoney + o.playerAllocation;
                    o.opponentMoney = o.opponentMoney + o.playerChoice;
                    o.chose = true;
                elseif ch == o.nine
                    o.playerReactionTime = now - (o.itiDuration + o.informDuration);
                    o.playerChoice = 90;
                    o.playerAllocation = o.playersGivenFunds - o.playerChoice;
                    o.playerMoney = o.playerMoney + o.playerAllocation;
                    o.opponentMoney = o.opponentMoney + o.playerChoice;
                    o.chose = true;
                elseif ch == o.zero
                    o.playerReactionTime = now - (o.itiDuration + o.informDuration);
                    o.playerChoice = 0;
                    o.playerAllocation = o.playersGivenFunds - o.playerChoice;
                    o.playerMoney = o.playerMoney + o.playerAllocation;
                    o.opponentMoney = o.opponentMoney + o.playerChoice;
                    o.chose = true;
                elseif ch == o.all
                    o.playerReactionTime = now - (o.itiDuration + o.informDuration);
                    o.playerChoice = 100;
                    o.playerAllocation = o.playersGivenFunds - o.playerChoice;
                    o.playerMoney = o.playerMoney + o.playerAllocation;
                    o.opponentMoney = o.opponentMoney + o.playerChoice;
                    o.chose = true;
                end
            end
            
            % Still no guess, set choice as n/a
            if ~o.chose && (now > 0.99*(o.itiDuration + o.decisionDuration + o.informDuration))
                o.chose = true;
                o.playerChoice = 'n/a';
                o.playerReactionTime = 'n/a';
                o.opponentSacrifice = 'n/a';
                o.scaledPunishment = 'n/a';
                trialData = {num2str(o.trialConditions(o.trialCounter)),...
                        o.gameType,o.opponentType,o.playerChoice,...
                        o.playerReactionTime,o.opponentSacrifice,...
                        o.scaledPunishment};
                trialData = trialData.';
                outputFile = fopen(o.fileName,'a');
                fprintf(outputFile,'%s\t%s\t%s\t%s\t%s\t%s\t%s\r\n',trialData{:});
                fclose(outputFile);
                o.trialLogged = true;
            end
            
            % Diplay ITI Screen. t = [0s,1s)
            if now < o.itiDuration
                Screen('TextFont',o.window, 'Courier New');
                Screen('TextSize',o.window, o.fontSize);
                Screen('TextStyle', o.window, 1+2);
                Screen('glLoadIdentity', o.window);
                
                DrawFormattedText(o.window, '*', 'center', 'center',...
                    o.textColor);
            % Inform Screen. t = [1s, 3s)
            % To be shown before guess duration runs out and before guess
            % is made. time < 3s.
            elseif now < o.itiDuration + o.informDuration
                % Display the gameTypeText (0:0 or 5:1)
                Screen('TextFont',o.window, 'Courier New');
                Screen('TextSize',o.window, o.fontSize);
                Screen('TextStyle', o.window, 1+2);
                Screen('glLoadIdentity', o.window);
                % Display the gameTypeText (0:0 or 5:1)
                DrawFormattedText(o.window, o.gameTypeText, 'center', 80, o.textColor);
                % Display Opponent Image
                Screen('DrawTexture',o.window,o.opponentTexture);
            % Decision Making Screen. t = [3s, 6s)
            elseif now < o.itiDuration + o.informDuration + o.decisionDuration && ~o.chose
                % Draw bars
                playerX    = 0.15*[-75 -75 -50 -50];
                playerY    = 0.15*o.barHeight;
                centerX    = 0.15*[-50 -50 50 50];
                centerY    = 0.15*o.barHeight; 
                opponentX  = 0.15*[50 50 75 75];
                opponentY  = 0.15*o.barHeight;
                Screen('FillPoly',o.window, o.playerColor,[playerX',playerY'],1); 
                Screen('FillPoly',o.window, o.centerColor,[centerX',centerY'],1); 
                Screen('FillPoly',o.window, o.opponentColor,[opponentX',opponentY'],1); 
                
                % Set up screen parameters
                Screen('TextFont',o.window, 'Courier New');
                Screen('TextSize',o.window, o.fontSize);
                Screen('TextStyle', o.window, 1+2);
                Screen('glLoadIdentity', o.window);
                % Draw opponent image and game type
                Screen('DrawTexture',o.window,o.opponentTexture);
                DrawFormattedText(o.window, o.gameTypeText, 'center', 80, o.textColor);
            % Post Decision Screen. t = [3s,6s)
            % Screen if player has left over time in decision making phase
            % (3 now).
            % Simply keeps players choice displayed on screen
            elseif now < o.itiDuration + o.informDuration + o.decisionDuration && o.chose
                % Update Player's Bar
                playerX = 0.15*...
                    [-75 -75 (-75 + o.playerMoney) (-75 + o.playerMoney)];
                playerY = 0.15*o.barHeight;
                % Updates Opponent's Bar
                opponentX = 0.15*...
                    [(75 - o.opponentMoney) (75 - o.opponentMoney) 75 75];
                opponentY = 0.15*o.barHeight;
                
                % Draw rectangles after decision
                Screen('FillPoly',o.window, o.playerColor,[playerX',playerY'],1); 
                Screen('FillPoly',o.window, o.opponentColor,[opponentX',opponentY'],1); 
                % Set text stimuli params
                Screen('TextFont',o.window, 'Courier New');
                Screen('TextSize',o.window, o.fontSize);
                Screen('TextStyle', o.window, 1+2);
                Screen('glLoadIdentity', o.window);                
                % Draw Opponent
                Screen('DrawTexture',o.window,o.opponentTexture);
                % DrawText
                DrawFormattedText(o.window, o.gameTypeText, 'center', 80, o.textColor);
                DrawFormattedText(o.window, int2str(o.playerMoney),... 
                    1920/2 - 500, o.moneyTextHeight, [.1 .1 .1]); % Player
                DrawFormattedText(o.window, int2str(o.opponentMoney),...   
                    1920/2 + 450, o.moneyTextHeight, [1 1 1]); % Opponent
            % Dictator Outcome Screen t = [6s,7s]
            % This displays the Outcome screen in dictator game type
            %  trials.
            elseif now < o.itiDuration +  o.informDuration + o.decisionDuration...
                    + o.outcomeDuration && isequal(o.gameType,'Dictator')
                % Using BIDS convetion 'n/a' when variable not used in
                % round
                o.opponentSacrifice = 'n/a';
                o.scaledPunishment = 'n/a';
                
                % Player's Bar
                playerX = 0.15*...
                    [-75 -75 (-75 + o.playerMoney) (-75 + o.playerMoney)];
                playerY = 0.15*o.barHeight;
                
                % Opponent's Bar
                opponentX = 0.15*...
                    [(75 - o.opponentMoney) (75 - o.opponentMoney) 75 75];
                opponentY = 0.15*o.barHeight;
                
                % Draw rectangles after decision
                Screen('FillPoly',o.window, o.playerColor,[playerX',playerY'],1); 
                Screen('FillPoly',o.window, o.opponentColor,[opponentX',opponentY'],1); 
                
                % Draw text stimuli
                Screen('TextFont',o.window, 'Courier New');
                Screen('TextSize',o.window, o.fontSize);
                Screen('TextStyle', o.window, 1+2);
                Screen('glLoadIdentity', o.window);
                
                % Draw monetary values on edges corresponding to player
                Screen('DrawTexture',o.window,o.opponentTexture);
                
                % Draw Game Type Text at top of screen
                DrawFormattedText(o.window, o.gameTypeText, 'center', 80, o.textColor);
                DrawFormattedText(o.window, int2str(o.playerMoney),... 
                    1920/2 - 500, o.moneyTextHeight, [.1 .1 .1]); % Player
                DrawFormattedText(o.window, int2str(o.opponentMoney),...   
                    1920/2 + 450, o.moneyTextHeight, [1 1 1]); % Opponent
                
                % Log Data, only runs once per trial
                if ~o.trialLogged
                    trialData = {num2str(o.trialConditions(o.trialCounter)),...
                        o.gameType,o.opponentType,num2str(o.playerChoice),...
                        num2str(o.playerReactionTime),num2str(o.opponentSacrifice),...
                        num2str(o.scaledPunishment)};
                    trialData = trialData.';
                    outputFile = fopen(o.fileName,'a');
                    fprintf(outputFile,'%s\t%s\t%s\t%s\t%s\t%s\t%s\r\n',trialData{:});
                    fclose(outputFile);
                    o.trialLogged = true;
                end
            % Ultimatum Outcome Screen t = [6s,7s]
            % This determines the opponent punishment and displays the
            %  correpsonding result for ultimatum game type trials.
            elseif now < o.itiDuration + o.informDuration + o.decisionDuration...
                    + o.outcomeDuration && isequal(o.gameType,'Ultimatum')
                % Calculate Punishment and update player and opponent
                % attributes...
                if ~o.punishmentSelected
                    o.punishmentSelected = true;
                    if o.playerChoice > 49 % Opponent gets $50+   
                        o.opponentSacrifice = 0; % No punishment
                        o.scaledPunishment = 0;
                        % No punishment/sacrifice, have text blend into
                        % background.
                        o.punishmentTextColor = o.opponentColor; 
                        o.sacrificeTextColor = o.opponentColor; 
                    elseif o.playerChoice > 30 % Opponent gets $40
                        if strcmp(o.opponentType,'Person')
                            if rand < .5 % -$2 Opp. & -$10 Player
                                o.opponentSacrifice = 2; 
                                o.scaledPunishment = 5 * o.opponentSacrifice;
                            else % No punishment
                                o.opponentSacrifice = 0; 
                                o.scaledPunishment = 0;
                            end
                        else % PC 
                            if rand > .75 % -$2 Opp. & -$10 Player
                                o.opponentSacrifice = 2; 
                                o.scaledPunishment = 5 * o.opponentSacrifice;
                            else % No punishment
                                o.opponentSacrifice = 0; 
                                o.scaledPunishment = 0;
                            end
                        end
                    elseif o.playerChoice > 20 % Oponent gets $30
                        if strcmp(o.opponentType,'Person')
                            if rand < .5 % -$8 Opp. % $40 Player
                                o.opponentSacrifice = 8; 
                                o.scaledPunishment = 5 * o.opponentSacrifice;
                            else % -$7 Opp. % $35 Player
                                o.opponentSacrifice = 7; 
                                o.scaledPunishment = 5 * o.opponentSacrifice;
                            end
                        else
                           if rand > .75 % -$8 Opp. % $40 Player
                                o.opponentSacrifice = 8; 
                                o.scaledPunishment = 5 * o.opponentSacrifice;
                            else % -$7 Opp. % $35 Player
                                o.opponentSacrifice = 7; 
                                o.scaledPunishment = 5 * o.opponentSacrifice;
                            end 
                        end
                    elseif o.playerChoice > 10 % Opponent gets 20
                        if strcmp(o.opponentType,'Person')
                            if rand < .5 % -$10 Opp. & -$50 Player
                                o.opponentSacrifice = 10;
                                o.scaledPunishment = 5 * o.opponentSacrifice;
                            else % -$9 Opp. & -$45 Player
                                o.opponentSacrifice = 9;
                                o.scaledPunishment = 5 * o.opponentSacrifice;
                            end
                        else
                            if rand > .75 % -$10 Opp. & -$50 Player
                                o.opponentSacrifice = 10;
                                o.scaledPunishment = 5 * o.opponentSacrifice;
                            else % -$9 Opp. & -$45 Player
                                o.opponentSacrifice = 9;
                                o.scaledPunishment = 5 * o.opponentSacrifice;
                            end
                        end
                    elseif o.playerChoice > 0 % Oponent gets 10
                        if strcmp(o.opponentType,'Person')
                            if rand < .5 
                                o.opponentSacrifice = 15; % -$15 Opp. & -$75 Player
                                o.scaledPunishment = 5 * o.opponentSacrifice;
                            else 
                                o.opponentSacrifice = 13; % -$13 Opp. & -$65 Player
                                o.scaledPunishment = 5 * o.opponentSacrifice;
                            end
                        else
                            if rand > .75 
                                o.opponentSacrifice = 15; % -$15 Opp. & -$75 Player
                                o.scaledPunishment = 5 * o.opponentSacrifice;
                            else 
                                o.opponentSacrifice = 13; % -$13 Opp. & -$65 Player
                                o.scaledPunishment = 5 * o.opponentSacrifice;
                            end
                        end
                    elseif o.playerChoice > -1 % Oponent gets 0
                        if rand > .75 
                            o.opponentSacrifice = 18; % -$18 Opp. & -$90 Player
                            o.scaledPunishment = 5 * o.opponentSacrifice;
                        else 
                            o.opponentSacrifice = 16; % -$16 Opp. & -$80 Player
                            o.scaledPunishment = 5 * o.opponentSacrifice;
                        end
                    end
                    % Update opponent's and player's money post punishment.
                    o.opponentMoney  = o.opponentMoney - o.opponentSacrifice;
                    o.playerMoney  = o.playerMoney - o.scaledPunishment;
                end             
                if o.playerChoice == 'n/a'
                    o.playerChoice = 0;
                    o.opponentSacrifice = 0;
                    o.scaledPunishment = 0;
                end
                % Player's Bar
                playerX = 0.15*...
                    [-75 -75 (-75 + o.playerMoney) (-75 + o.playerMoney)];
                playerY = 0.15*o.barHeight;
                % Player's Punishment Bar
                playerPunishmentX = 0.15*...
                    [(-75 + o.playerMoney) (-75 + o.playerMoney)...
                    (-75 + o.playerMoney + o.scaledPunishment)...
                    (-75 + o.playerMoney + o.scaledPunishment)];
                playerPunishmentY = 0.15*o.barHeight;
                % Opponent's Sacrifice Bar
                opponentSacrificeX = 0.15*...
                    [(-75 + o.playerMoney + o.scaledPunishment)...
                    (-75 + o.playerMoney + o.scaledPunishment)...
                    (75 - o.opponentMoney) (75 - o.opponentMoney)];
                opponentSacrificeY = 0.15*o.barHeight;
                % Opponent's Bar
                opponentX = 0.15*...
                    [(75 - o.opponentMoney) (75 - o.opponentMoney) 75 75];
                opponentY = 0.15*o.barHeight;
                
                % Draw rectangles after decision
                Screen('FillPoly',o.window, o.playerColor,[playerX',playerY'],1); 
                Screen('FillPoly',o.window, o.opponentColor,[opponentX',opponentY'],1);
                Screen('FillPoly',o.window, [.5 .5 .5],[playerPunishmentX',playerPunishmentY'],1); 
                Screen('FillPoly',o.window, [.5 .5 .5],[opponentSacrificeX',opponentSacrificeY'],1);
                % Draw outlines for punishment and sacrifice bars
                Screen('FramePoly',o.window, [1 1 1],[playerPunishmentX',playerPunishmentY'],1);
                Screen('FramePoly',o.window, [1 1 1],[opponentSacrificeX',opponentSacrificeY'],1);
                Screen('DrawTexture',o.window,o.opponentTexture);
                % Setup screen parameters
                Screen('TextFont',o.window, 'Courier New');
                Screen('TextSize',o.window, o.fontSize);
                Screen('TextStyle', o.window, 1+2);
                Screen('glLoadIdentity', o.window);
                
                % Draw Game Type Text
                DrawFormattedText(o.window, o.gameTypeText, 'center',...
                    80, o.textColor);
                % Draw Player & Opponent Money
                DrawFormattedText(o.window, int2str(o.playerMoney),... 
                    1920/2 - 500, o.moneyTextHeight, [.1 .1 .1]); % Player
                DrawFormattedText(o.window, int2str(o.opponentMoney),...   
                    1920/2 + 450, o.moneyTextHeight, [1 1 1]); % Opponent
                % Draw Punishment and Sacrifice Text
                DrawFormattedText(o.window, int2str(o.scaledPunishment),... 
                    1920/2 - 500, o.moneyTextHeight - 75,...
                    o.sacrificeTextColor); % Punishment
                DrawFormattedText(o.window, int2str(o.opponentSacrifice),...   
                    1920/2 + 440, o.moneyTextHeight - 75,...
                    o.sacrificeTextColor); % Sacrifice
                
                % Log Data
                if ~o.trialLogged
                    trialData = {num2str(o.trialConditions(o.trialCounter)),...
                        o.gameType,o.opponentType,num2str(o.playerChoice),...
                        num2str(o.playerReactionTime),num2str(o.opponentSacrifice),...
                        num2str(o.scaledPunishment)};
                    trialData = trialData.';
                    outputFile = fopen(o.fileName,'a');
                    fprintf(outputFile,'%s\t%s\t%s\t%s\t%s\t%s\t%s\r\n',trialData{:});
                    fclose(outputFile);
                    o.trialLogged = true;
                end
            end            
        end     
    end
end