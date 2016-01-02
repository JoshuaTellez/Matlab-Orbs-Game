% Driver function
function matlabOrbs()
    gameEngine()
end % end function matlabOrbs()

% Holds characteristics of the game and loops the program for continuos play 
function gameEngine()

clearvars;

% Show the rules of the game
    startMenu()
    
% Declaration of global variables that are used for naming purposes only
    global PLAYER;
    global ENEMY;
    global ORB;
    global EMPTY;
    
% Declaration of global variables that are characteristcs of the game
    global NUMENEMIES;
    global ORBS;
    global LIVES;
    global GRIDSIZE;
    global INFINITEKINFE;
    
% Declaration of global variables that are used and changed during gameplay     
    global MOVED;
    global KNIFE;
    global ORBSLOC;
    global ENEMIESLOC;
    
% Following can be changed but will not change the game 
% (Condition: cannot be 0)
    PLAYER = 1;
    ENEMY = 2;
    ORB = 3;
    
% Following cannot be changed or game will not work
    MOVED = false;
    KNIFE = true;
    ORBSLOC(1:ORBS) = -1;
    ENEMIESLOC(1:NUMENEMIES) = -1;
    EMPTY = 0;
    
% User can select game difficulty
selectSettings();

% Initialize grid    
    Grid = setGrid(GRIDSIZE);
   
% Loops through the game until out of lives, all orbs collected, or player
% quits game
    while LIVES > 0 && ORBS > 0
        Grid = play(Grid);  % Player chooses actions 
        
    %If player has moved, lives, and orbs to be collected, then moveEnemies
        if MOVED && LIVES ~= 0 && ORBS ~=0
            Grid = moveEnemies(Grid);
            
    % Sometimes enemies erase the orbs when they walk over them. 
    % This spawns them back in.         
            Grid = respawnOrbs(Grid);
            
    % Resets MOVED switch 
            MOVED = false;
            
        end % end if(MOVED && LIVES ~= 0 && ORBS ~=0)
        
    % As long as player does not lose the game continue printing the grid
        if LIVES ~= 0
            printGrid(Grid)
        end % end if(LIVES ~= 0)
        
    end % end while(LIVES > 0 && ORBS > 0)
    
% Checks to see if player has won or lost the game    
    if ORBS == 0
        winGame()
    elseif LIVES <= 0
        loseGame()
    end % end if(ORBS == 0)
    
end % end function gameEngine()

% Shows the rules of the game
function startMenu()
    home;
    fprintf('Welcome to MATLAB Orbs!\n\n')
    fprintf('Collect all of the orbs to win the game but be careful\n')
    fprintf('because your enemies have a nasty bite!\n\n')
    fprintf('Rules: \nYou always start at the top left corner.\n')
    fprintf('The orbs and enemies spawn randomly.\n')
    fprintf('If you are in an enemy''s line of sight it will move towards you.\n')
    fprintf('You are given one throwing knife per life.\n')
    fprintf('Enemies can hide behind each other(multiple enemies in one square).\n')
    fprintf('If hidden enemies attack, you will lose extra lives.\n')
    fprintf('Throwing your knife will kill all hidden enemies.\n\n')
    input('Press Enter to continue...','s');
    home;
end % end function startMenu()

function selectSettings() 
    global NUMENEMIES;
    global ORBS;
    global LIVES;
    global GRIDSIZE;
    global INFINITEKNIFE;
    fprintf('Select Difficulty: 1 = Easy, 2 = Medium, 3 = Hard\n');
    user = input('Difficulty: ','s');
    
    valid = false;
    % Loops until a valid action is chosen
    while ~valid
        
        % If user just clicks enter, program will crash without assigning
        % something to 'user'
        if isempty(user)
            user = 'Invalid Input';
        end
        
        % Switch statement for difficulty chosen
        switch user
            case '1'
                valid = true;
                NUMENEMIES = 3;
                ORBS = 3;
                LIVES = 5;
                GRIDSIZE = 7;
                fprintf('Easy Difficulty selected\n');
                
            case '2'
                valid = true;
                NUMENEMIES = 6;
                ORBS = 3;
                LIVES = 3;
                GRIDSIZE = 9;
                fprintf('Medium Difficulty selected\n');
                
            case '3' 
                valid = true;
                NUMENEMIES = 17;
                ORBS = 7;
                LIVES = 3;
                GRIDSIZE = 12;
                fprintf('Hard Difficulty selected\n');
                
            otherwise % If player chooses an invalid input
                fprintf('Invalid input: Please try again\n');
                fprintf('1 = Easy, 2 = Medium, 3 = Hard\n');
                user = input('Difficulty: ','s');
        
        end % end switch user
        
    end 
        
        fprintf('\nCheat Mode?\n');
        question = randi(4);
        switch question
            case 1
                fprintf('What is the air-speed velocity of an unladen swallow?\n');
                cheatcode = input('','s');
                if strcmpi('An African or European swallow?', cheatcode)
                    fprintf('\nInfinite Knife unlocked\n');
                    input('Press Enter to continue','s');
                    INFINITEKNIFE = true;
                end
            case 2 
                fprintf('A witch weighs the same as a ____\n');
                cheatcode = input('','s');
                if strcmpi('Duck', cheatcode)
                    fprintf('\nInfinite Knife unlocked\n');
                    input('Press Enter to continue','s');
                    INFINITEKNIFE = true;
                end
            case 3
                fprintf('Your mother was a hamster and your father\n');
                fprintf('smelt of ____________\n');
                cheatcode = input('','s');
                if strcmpi('elderberries', cheatcode)
                    fprintf('\nInfinite Knife unlocked\n');
                    input('Press Enter to continue','s');
                    INFINITEKNIFE = true;
                end
            case 4 
                fprintf('What number shalt thou count after the holy pin ');
                fprintf('of \nthe Holy Hand Grenade of Antioch is pulled?\n');
                cheatcode = input('','s');
                if strcmpi('three', cheatcode) || strcmp('3', cheatcode)
                    fprintf('\nInfinite Knife unlocked\n');
                    input('Press Enter to continue','s');
                    INFINITEKNIFE = true;
                end
        end
        home;
end % end function selectSettings()

% Initialized the grid with PLAYER, ENEMIES, and ORBS
function Grid = setGrid(gridSize)
    global PLAYER;    
    % Creates an empty nxn matrix
    Grid = zeros(gridSize);
    
    % Spawn player at the top left
    Grid(1) = PLAYER;
    
    % Spawns the enemies
    Grid = spawnEnemies(Grid,1);
    
    % Spawns the orbs
    Grid = spawnOrbs(Grid,1);
    
    printGrid(Grid)
end % end function Grid = setGrid(gridSize)

%Recursively spawn in the enemies starting at 1 until base case(NUMENEMIES)
%is passed
function newGrid = spawnEnemies(Grid,enemiesSpawned)
    global GRIDSIZE;
    global ENEMY;
    global EMPTY;
    global ENEMIESLOC;
    global NUMENEMIES;
    
    % A random number between 1 - number of squares in the grid
    enemyPosition = randi(numel(Grid));
    
    enemySpawned = false;
    
    % Loop that checks to see enemy can be spawned in that postion
    while ~enemySpawned
        
        % The enemy cannot be spawned within 3 squares of the player
        if Grid(enemyPosition) == EMPTY && ~(enemyPosition == 2 ...
                || enemyPosition == 3 || enemyPosition == GRIDSIZE+1 ...
                || enemyPosition == GRIDSIZE+2 ...
                || enemyPosition == GRIDSIZE+3 ...
                || enemyPosition == 1+(GRIDSIZE*2) ...
                || enemyPosition == 2 +(GRIDSIZE*2) ...
                || enemyPosition == 3+(GRIDSIZE*2))
            
            % Set the enemy position on the grid
            Grid(enemyPosition) = ENEMY;
            
            % Add the position of the enemy to the ENEMIESLOC vector
            ENEMIESLOC(enemiesSpawned) = enemyPosition;
            
            % Allows to exit the while loop
            enemySpawned = true;
            
            % Increment the number of enemies spawned 
            enemiesSpawned = enemiesSpawned + 1;
            
        else % If the enemyPosition was invalid change the enemyPosition
            enemyPosition = randi(numel(Grid));
            
        end % end if
        
    end % end while ~enemySpawned
    
    % Recursively call the function until all of the enemies have spawned
    if enemiesSpawned <= NUMENEMIES
        Grid = spawnEnemies(Grid,enemiesSpawned);
    end
    
    newGrid = Grid;
end % end function newGrid = spawnEnemies(Grid,enemiesSpawned)

%Recursively spawn in the orbs starting at 1 until base case(ORBS)is passed
function newGrid = spawnOrbs(Grid,orbsSpawned)
    global ORB;
    global EMPTY
    global ORBSLOC;
    global ORBS;
    
    % A random number between 1 - number of squares in the grid
    orbPosition = randi(numel(Grid));
    orbSpawned = false;
    
    % Loops until orbPostion is valid
    while ~orbSpawned
        if Grid(orbPosition) == EMPTY 
            
            % Add the orb to the grid
            Grid(orbPosition) = ORB;
            
            % Save the position of the orb
            ORBSLOC(orbsSpawned) = orbPosition;
            
            % Increment number of orbs spawned in
            orbsSpawned = orbsSpawned + 1;
            
            % Allows to exit the while loop
            orbSpawned = true;
        else % if the orbPosition was invalid change it and loop through
            orbPosition = randi(numel(Grid));
        end % end if Grid(orbPosition) == EMPTY 

    end % end while ~orbSpawned
    
    % Recursively call the function until all of the orbs have spawned
    if orbsSpawned <= ORBS;
        Grid = spawnOrbs(Grid,orbsSpawned);
    end
    
    newGrid = Grid;
end % end function newGrid = spawnOrbs(Grid,orbsSpawned)

% Prints the grid
function printGrid(Grid)
% NOTE: The grid is printed as the transpose of the actual grid so the
% user will see the transpose. The player movement functions take that into
% account

    global PLAYER;
    global ENEMY;
    global ORB;
    global GRIDSIZE;
    global EMPTY;
    global LIVES;
    global NUMENEMIES;
    global ORBS;
    global KNIFE;
    global INFINITEKNIFE;
    
    % For each element in the grid 
    for i = 1:numel(Grid)
        
        % If square is the player, print p
        if Grid(i) == PLAYER
            fprintf('P ')
            
        % If square is an enemy, print e
        elseif Grid(i) == ENEMY
            fprintf('E ')
            
        % If square is an orb, print o
        elseif Grid(i) == ORB
            fprintf('O ')
            elseif Grid(i) == EMPTY
            fprintf('* ')
            
        end % end if Grid(i) == PLAYER
        
        
        % Following are used to print out the legend and real-time game
        % characteristics 
        
        % About a third of the way down print the legend
        if mod(i,GRIDSIZE) == 0 && i == GRIDSIZE*floor(GRIDSIZE*(1/3))
            fprintf('\tP: Player   E: Enemy   O: Orb')
        end
        
        %About a third of the way down + 1 print: LIVES, ENEMIES, and ORBS
        if mod(i,GRIDSIZE) == 0 && i == GRIDSIZE*(floor(GRIDSIZE*(1/3))+1)
            fprintf('\tLives: %d   Enemies: %d   Orbs: %d', LIVES, NUMENEMIES, ORBS);
        end
        
        % About a third of the way down + 2 print throwing knife availabilty
        if mod(i,GRIDSIZE) == 0 && i == GRIDSIZE*(floor(GRIDSIZE*(1/3))+2)
            if KNIFE
                fprintf('\tThrowing Knife: 1')
            elseif INFINITEKNIFE
                fprintf('\tThrowing Knife: NaN')
            else
                fprintf('\tThrowing Knife: 0')
            end
        end
        
        % At the end of column start a new line
        if mod(i,GRIDSIZE) == 0
            fprintf('\n')
        end
        
    end % end for i = 1:numel(Grid)
    fprintf('\n')
    
end % end function printGrid(Grid)

% Asks user for input and executes correct action
function newGrid = play(Grid)
    global KNIFE;
    global INFINITEKNIFE;
    fprintf('Choose an action then hit Enter\n')
    fprintf('w: Move up, ')
    fprintf('s: Move down ')
    fprintf('a: Move left, ')
    fprintf('d: Move right,\n')
    fprintf('k: Throw knife, ')
    fprintf('q: Quit   ')
    
    % Holds the action chosen by the user
    user = input('','s');
    
    valid = false;
    
    % Loops until a valid action is chosen
    while ~valid
        
        % If user just clicks enter, program will crash without assigning
        % something to 'user'
        if isempty(user)
            user = 'Invalid Input';
        end
        
        % Switch statement for action chosen
        switch user
            case 'w' % If player chooses to move up
                Grid = moveUp(Grid);
                valid = true;
                
            case 's' % If player chooses to move down
                Grid = moveDown(Grid);
                valid = true;
                
            case 'a' % If player chooses to move left
                Grid = moveLeft(Grid);
                valid = true;
                
            case 'd' % If player chooses to move right
                Grid = moveRight(Grid);
                valid = true;
                
            case 'k' % If player chooses to throw knife
                
                % If knife is available or inf knife is on
                if KNIFE || INFINITEKNIFE
                    Grid = throwKnife(Grid);
                else
                    fprintf('You already used your knife\n')
                end
                valid = true;
                
            case 'q' % If player chooses to quit game
                Grid = quitGame();
                valid = true;
                
            otherwise % If player chooses an invalid input
                fprintf('Invalid input: Please try again\n')
                fprintf('w: Move up, ')
                fprintf('s: Move down ')
                fprintf('a: Move left, ')
                fprintf('d: Move right,\n')
                fprintf('k: Throw knife, ')
                fprintf('q: Quit   ')
                user = input('','s');
        end % end switch user
        
    end  %end while ~valid
    
    home;
    newGrid = Grid;
end % end function newGrid = play(Grid)

% Move the player up
function newGrid = moveUp(Grid)
% Note: Printed grid is the tranpose of actual grid
% If the player wants to move up, have the player move left on actual grid
    global GRIDSIZE;
    global EMPTY;
    global PLAYER;
    global ENEMY;
    global ORB;
    global ORBS;
    global ORBSLOC;
    global MOVED;
    
    % For each element in the grid
    for i = 1:numel(Grid)
        
        % If the player is located on this square
        if Grid(i) == PLAYER
            
            % Actual Grid Indecies      Printed Grid Indecies
            %  1  6   11  16  21          1   2   3   4   5
            %  2  7   12  17  22          6   7   8   9   10
            %  3  8   13  18  23          11  12  13  14  15
            %  4  9   14  19  24          16  17  18  19  20
            %  5  10  15  20  25          21  22  23  24  25
            
            % 	Actual Grid                  Printed Grid 
            %  *  *  E  *  *                *  *  *  P  * 
            %  *  *  *  *  *                *  *  E  *  * 
            %  *  E  *  *  *                E  *  *  *  * 
            %  P  *  *  O  *                *  *  *  O  * 
            %  *  *  *  *  *                *  *  *  *  * 
                        
            % If the player is on the far left of the actual grid, then the
            % player cannot move up on printed grid
            % Example above: GRIDSIZE = 5, i = 4
            
            if i > GRIDSIZE % If player is not on the far left of actual
                
                MOVED = true; % Player has/will move
                
                % i - GRIDSIZE = move player to the left of actual grid
                
                % If player moves onto a square where enemy is located
                if Grid(i-GRIDSIZE) == ENEMY 
                    Grid = playerDied(Grid,i);
                    
                % If player moves onto an orb
                elseif Grid(i-GRIDSIZE) == ORB
                    
                    % Locate the index of Orb that is saved in ORBSLOC and
                    % set the value to -1
                    for j = 1:numel(ORBSLOC)
                        
                        if ORBSLOC(j) == (i-GRIDSIZE)
                            ORBSLOC(j) = -1;
                        end % end if ORBSLOC(j) == (i-GRIDSIZE)
                        
                    end %end for j = 1:numel(ORBSLOC)
                    
                    % Set previous location of player to empty 
                    Grid(i) = EMPTY;
                    
                    % Move the player to the left of the actual grid
                    Grid(i-GRIDSIZE) = PLAYER;
                    
                    % Decrement number of orbs
                    ORBS = ORBS - 1;
                
                % Player moves onto an empty square
                else 
                    % Set previous location of player to empty 
                    Grid(i) = EMPTY;
                    
                    % Move the player to the left of the actual grid
                    Grid(i-GRIDSIZE) = PLAYER;
                    
                end % end if Grid(i-GRIDSIZE) == ENEMY
                
            end % end if i > GRIDSIZE
            
            % If player is located, no need to continue traversing the grid
            break; 
            
        end % end if Grid(i) == PLAYER
     
    end % end for i = 1:numel(Grid)
    
    newGrid = Grid;
    
end % end function newGrid = moveUp(Grid)
    
% Move the player down
function newGrid = moveDown(Grid)
% Note: Printed grid is the tranpose of actual grid
% If the player wants to move down,have player move right on actual grid
    global GRIDSIZE;
    global EMPTY;
    global PLAYER;
    global ENEMY;
    global ORB;
    global ORBS;
    global MOVED;
    global ORBSLOC;
    
    % For each element in the grid
    for i = 1:numel(Grid)
        
        % If the player is located on this square
        if Grid(i) == PLAYER
            
            % Actual Grid Indecies      Printed Grid Indecies
            %  1  6   11  16  21          1   2   3   4   5
            %  2  7   12  17  22          6   7   8   9   10
            %  3  8   13  18  23          11  12  13  14  15
            %  4  9   14  19  24          16  17  18  19  20
            %  5  10  15  20  25          21  22  23  24  25
            
            % 	Actual Grid                  Printed Grid 
            %  *  *  E  *  *                *  *  *  *  * 
            %  *  *  *  *  *                *  *  E  *  * 
            %  *  E  *  *  *                E  *  *  *  * 
            %  *  *  *  O  P                *  *  *  O  * 
            %  *  *  *  *  *                *  *  *  P  * 
                        
            % If player is on the far right of the actual grid, then the
            % player cannot move
            % Example above: i = 24, GRIDSIZE = 5
            
            if i <= GRIDSIZE*GRIDSIZE - GRIDSIZE %If player not far right
                
                MOVED = true; % Player has/will move
                
                % i + GRIDSIZE = move player to right on actual grid
                
                % If player moves onto a square where enemy is located
                if Grid(i+GRIDSIZE) == ENEMY
                    Grid = playerDied(Grid,i);
                
                % If player moves onto an orb
                elseif Grid(i+GRIDSIZE) == ORB
                    
                    % Locate the index of Orb that is saved in ORBSLOC and
                    % set the value to -1
                    for j = 1:numel(ORBSLOC)
                        if ORBSLOC(j) == (i+GRIDSIZE)
                            ORBSLOC(j) = -1;
                        end % end if ORBSLOC(j) == (i+GRIDSIZE)
                        
                    end % end for j = 1:numel(ORBSLOC)
                    
                    % Set previous location of player to empty 
                    Grid(i) = EMPTY;
                    
                    % Move the player to the right of the actual grid
                    Grid(i+GRIDSIZE) = PLAYER;
                    
                    % Decrement number of orbs
                    ORBS = ORBS - 1;
                
                % Player moves onto an empty square
                else
                    Grid(i) = EMPTY;
                    Grid(i+GRIDSIZE) = PLAYER;
                end % end if Grid(i+GRIDSIZE) == ENEMY
                
            end % end if i <= GRIDSIZE*GRIDSIZE - GRIDSIZE 
            
            % If player is located, no need to continue traversing the grid
            break; 
            
        end % end if Grid(i) == PLAYER
        
    end % end for i = 1:numel(Grid)
    newGrid = Grid;
    
end % end function newGrid = moveDown(Grid)

% Move the player left
function newGrid = moveLeft(Grid)
% Note: Printed grid is the tranpose of actual grid
% If the player wants to move left, have the player move up on actual grid
    global GRIDSIZE;
    global EMPTY;
    global PLAYER;
    global ENEMY;
    global ORB;
    global ORBS;
    global ORBSLOC;
    global MOVED;
    
    
    % For each element in the grid
    for i = 1:numel(Grid)
        
        % If the player is located on this square
        if Grid(i) == PLAYER
            
            % Actual Grid Indecies      Printed Grid Indecies
            %  1  6   11  16  21          1   2   3   4   5
            %  2  7   12  17  22          6   7   8   9   10
            %  3  8   13  18  23          11  12  13  14  15
            %  4  9   14  19  24          16  17  18  19  20
            %  5  10  15  20  25          21  22  23  24  25
            
            % 	Actual Grid                  Printed Grid 
            %  *  *  *  P  *                *  *  *  *  * 
            %  *  *  *  *  *                *  *  E  *  * 
            %  *  E  *  *  *                *  *  *  *  * 
            %  *  *  *  O  *                P  *  *  O  * 
            %  *  *  *  *  *                *  *  *  *  * 
                        
            % If the player is at the top of the actual grid, then the
            % player cannot move
            % Example above: i = 16, GRIDSIZE = 5
            
            if mod(i,GRIDSIZE) ~= 1 % If player is not at the top
                
                MOVED = true; % Player has/will move
                
                % i - 1 = move player up on actual grid
                
                % If player moves onto a square where enemy is located
                if Grid(i-1) == ENEMY
                    Grid = playerDied(Grid,i);
                    
                % If player moves onto an orb
                elseif Grid(i-1) == ORB
                    
                    % Locate the index of Orb that is saved in ORBSLOC and
                    % set the value to -1
                    for j = 1:numel(ORBSLOC)
                        if ORBSLOC(j) == (i-1)
                            ORBSLOC(j) = -1;
                        end % if ORBSLOC(j) == (i-1)
                    end % end for j = 1:numel(ORBSLOC)
                    
                    % Set previous location of player to empty 
                    Grid(i) = EMPTY;
                    
                    % Move the player up on the actual grid
                    Grid(i-1) = PLAYER;
                    
                    % Decrement number of orbs
                    ORBS = ORBS - 1;
                    
                % Player moves onto an empty square
                else
                    % Set previous location of player to empty 
                    Grid(i) = EMPTY;
                    
                    % Move the player up on the actual grid
                    Grid(i-1) = PLAYER;
                    
                end % end if Grid(i-1) == ENEMY
                
            end % end if mod(i,GRIDSIZE) ~= 1
            
            % If player is located, no need to continue traversing the grid
            break;
            
        end % end if Grid(i) == PLAYER
        
    end % end for i = 1:numel(Grid)
    newGrid = Grid;
end % end function newGrid = moveLeft(Grid)

% Move the plater right
function newGrid = moveRight(Grid)
% Note: Printed grid is the tranpose of actual grid
% If player wants to move right, have the player move down on actual grid
    global GRIDSIZE;
    global EMPTY;
    global PLAYER;
    global ENEMY;
    global ORB;
    global ORBS;
    global ORBSLOC;
    global MOVED;
    % For each element in the grid
    for i = 1:numel(Grid)
        
        % If the player is located on this square
        if Grid(i) == PLAYER
            
            % Actual Grid Indecies      Printed Grid Indecies
            %  1  6   11  16  21          1   2   3   4   5
            %  2  7   12  17  22          6   7   8   9   10
            %  3  8   13  18  23          11  12  13  14  15
            %  4  9   14  19  24          16  17  18  19  20
            %  5  10  15  20  25          21  22  23  24  25
            
            % 	Actual Grid                  Printed Grid 
            %  *  *  *  *  *                *  *  *  *  * 
            %  *  *  *  *  *                *  *  E  *  * 
            %  *  E  *  *  *                *  *  *  *  * 
            %  *  *  *  O  *                *  *  *  O  P 
            %  *  *  *  P  *                *  *  *  *  * 
                        
            % If the player is at the bottom of the actual grid, then the
            % player cannot move
            % Example above: i = 20, GRIDSIZE = 5
            
            if mod(i,GRIDSIZE) ~= 0 % If player is not at the bottom
                
                MOVED = true; % Player has/will move
                
                % i + 1 = move player down on actual grid
                
                % If player moves onto a square where enemy is located
                if Grid(i+1) == ENEMY
                    Grid = playerDied(Grid,i);
                    
                % If player moves onto an orb
                elseif Grid(i+1) == ORB
                    % Locate the index of Orb that is saved in ORBSLOC and
                    % set the value to -1
                    for j = 1:numel(ORBSLOC)
                        if ORBSLOC(j) == (i+1)
                            ORBSLOC(j) = -1;
                        end % end if ORBSLOC(j) == (i+1)
                    end % end for j = 1:numel(ORBSLOC)
                    
                    % Set previous location of player to empty 
                    Grid(i) = EMPTY;
                    
                    % Move the player to the right of the actual grid
                    Grid(i+1) = PLAYER;
                    
                    % Decrement number of orbs
                    ORBS = ORBS - 1;
                    
                % Player moves onto an empty square
                else
                    % Set previous location of player to empty 
                    Grid(i) = EMPTY;
                    
                    % Move the player to the right of the actual grid
                    Grid(i+1) = PLAYER;
                end % end if Grid(i+1) == ENEMY
                
            end % end if mod(i,GRIDSIZE) ~= 0
            
            % If player is located, no need to continue traversing the grid
            break;
            
        end % end if Grid(i) == PLAYER
        
    end % end for i = 1:numel(Grid)
    
    newGrid = Grid;
end % end function newGrid = moveRight(Grid)

% Asks which direction to throw knife and executes
function newGrid = throwKnife(Grid)
% Note: Printed grid is the tranpose of actual grid
% Ex: If the player wants to throw knife up, have the player throw knife
% left on actual grid
    global PLAYER;
    global ENEMY;
    global GRIDSIZE;
    global EMPTY;
    global KNIFE;
    global NUMENEMIES;
    global ENEMIESLOC;
    fprintf('Choose a direction to throw your knife then hit Enter\n')
    fprintf('w:up  s:down  a:left  d:right   ')
    
    % Holds user's choice of direction
    user = input('','s');
    
    % One knife per life. Once this function is called, knife set to false
    KNIFE = false;
    
    % True once an enemy is hit, false otherwise.
    hit = false;
    
    % True whenever user chooses valid option( 'a','w','s','d')
    valid = false;
    while ~valid
        
        % If user just clicks enter, program will crash without assigning
        % something to 'user'
        if isempty(user)
            user = 'Invalid Input';
        end
        
        % Switch statement for direction chosen
        switch user
            case 'w' % Throw knife upwards
                valid = true;
                
                % Locate the player
                for i = 1:numel(Grid)
                    if Grid(i) == PLAYER % Player found at position i
                        
                    % Actual Grid Indecies      Printed Grid Indecies
                    %  1  6   11  16  21          1   2   3   4   5
                    %  2  7   12  17  22          6   7   8   9   10
                    %  3  8   13  18  23          11  12  13  14  15
                    %  4  9   14  19  24          16  17  18  19  20
                    %  5  10  15  20  25          21  22  23  24  25
            
                    % 	Actual Grid                Printed Grid 
                    %  *  *  E  *  *              *  *  *  *  * 
                    %  *  *  *  *  *              *  *  E  *  * 
                    %  *  E  *  P  *              E  *  *  *  * 
                    %  *  *  *  O  *              *  *  P  O  * 
                    %  *  *  *  *  *              *  *  *  *  * 
                    
                    % Example above: i = 18, GRIDSIZE = 5, ENEMY = 8
                        
                        % Temporary variable used to traverse the grid
                        t = i;
                        
                        while t > 0
                            
                            % If enemy is found during grid traversal 
                            if Grid(t) == ENEMY
                                
                                % Kill all enemies on that square 
                                Grid(t) = EMPTY;
                                
                                %Multiple enemies in one square is possible
                                % Find which enemies are on that square and
                                % kill them.
                                for j = 1:numel(ENEMIESLOC)
                                    
                                    if ENEMIESLOC(j) == t
                                        NUMENEMIES = NUMENEMIES - 1;
                                        ENEMIESLOC(j) = -1;
                                    end % end if ENEMIESLOC(j) == t
                                    
                                end % end for j = 1:numel(ENEMIESLOC)
                                
                                fprintf('\nYou got`em!\n')
                                
                                % Enemy has been hit
                                hit = true;
                                
                                % Exit while loop if enemy is found
                                break;
                                
                            end % end if Grid(t) == ENEMY
                            
                            % t - GRIDSIZE = Traverse actual grid leftward
                            t = t - GRIDSIZE;
                            
                        end % end while t > 0
                        
                        % Exit for loop if player is found
                        break;
                        
                    end % end if Grid(i) == PLAYER
                    
                end % end for i = 1:numel(Grid)
                
            case 's' % Throw knife downwards
                valid = true;
                
                % Locate the player
                for i = 1:numel(Grid)
                    if Grid(i) == PLAYER % Player found at position i
                        
                    % Actual Grid Indecies      Printed Grid Indecies
                    %  1  6   11  16  21          1   2   3   4   5
                    %  2  7   12  17  22          6   7   8   9   10
                    %  3  8   13  18  23          11  12  13  14  15
                    %  4  9   14  19  24          16  17  18  19  20
                    %  5  10  15  20  25          21  22  23  24  25
            
                    % 	Actual Grid                Printed Grid 
                    %  *  *  E  *  *              *  *  *  *  * 
                    %  *  *  *  *  *              *  *  P  *  * 
                    %  *  P  *  E  *              E  *  *  *  * 
                    %  *  *  *  O  *              *  *  E  O  * 
                    %  *  *  *  *  *              *  *  *  *  * 
                    
                    % Example above: i = 8, GRIDSIZE = 5, ENEMY = 18
                        
                        % Temporary variable used to traverse the grid
                        t = i;
                        
                        while t < numel(Grid)
                            
                            % If enemy found during grid traversal
                            if Grid(t) == ENEMY
                                
                                % Kill all enemies on that square 
                                Grid(t) = EMPTY;
                                
                                %Multiple enemies in one square is possible
                                % Find which enemies are on that square and
                                % kill them.
                                for j = 1:numel(ENEMIESLOC)
                                    
                                    if ENEMIESLOC(j) == t
                                        NUMENEMIES = NUMENEMIES - 1;
                                        ENEMIESLOC(j) = -1;
                                    end % end if ENEMIESLOC(j) == t
                                    
                                end % end for j = 1:numel(ENEMIESLOC)
                                
                                fprintf('\nYou got`em!\n')
                                
                                % Enemy has been hit
                                hit = true;
                                
                                % Exit while loop if enemy is found
                                break;
                                
                            end % end if Grid(t) == ENEMY
                            
                            % t + GRIDSIZE = Traverse actual grid rightward
                            t = t + GRIDSIZE;
                        end % end while t < numel(Grid)
                        
                        % Exit for loop if player is found
                        break;
                        
                    end % end if Grid(i) == PLAYER
                    
                end % end for i = 1:numel(Grid)
                
                
            case 'a' % Throw knife to the left
                valid = true;
                
                % Locate the player
                for i = 1:numel(Grid)
                    if Grid(i) == PLAYER % Player found at position i
                        
                    % Actual Grid Indecies      Printed Grid Indecies
                    %  1  6   11  16  21          1   2   3   4   5
                    %  2  7   12  17  22          6   7   8   9   10
                    %  3  8   13  18  23          11  12  13  14  15
                    %  4  9   14  19  24          16  17  18  19  20
                    %  5  10  15  20  25          21  22  23  24  25
            
                    % 	Actual Grid                Printed Grid 
                    %  *  *  E  *  *              *  *  *  *  * 
                    %  *  *  *  *  *              *  *  *  *  * 
                    %  *  *  *  E  *              E  *  *  *  * 
                    %  *  *  *  O  *              *  *  E  O  P 
                    %  *  *  *  P  *              *  *  *  *  * 
                    
                    % Example above: i = 20, GRIDSIZE = 5, ENEMY = 18
                        
                        % Temporary variable used to traverse the grid
                        t = i;
                        
                        % s = The number of times needed to traverse the
                        % column dependending on where the player is 
                        % located on the actual grid. 
                        % Example above: s = GRIDSIZE = 5. 
                        % Move cursor 't' 4 times
                        if mod(t,GRIDSIZE) == 0
                            s = GRIDSIZE;
                        else
                            s = mod(t,GRIDSIZE);
                        end
                        
                        while s > 0
                            % If enemy found during grid traversal
                            if Grid(t) == ENEMY
                                
                                % Kill all enemies on that square 
                                Grid(t) = EMPTY;
                                
                                %Multiple enemies in one square is possible
                                % Find which enemies are on that square and
                                % kill them.
                                for j = 1:numel(ENEMIESLOC)
                                    
                                    if ENEMIESLOC(j) == t
                                        NUMENEMIES = NUMENEMIES - 1;
                                        ENEMIESLOC(j) = -1;
                                    end % end if ENEMIESLOC(j) == t
                                    
                                end % end for j = 1:numel(ENEMIESLOC)
                                
                                fprintf('\nYou got`em!\n')
                                
                                % Enemy has been hit
                                hit = true;
                                
                                % Exit while loop if enemy is found
                                break;
                                
                            end % end if Grid(t) == ENEMY
                            
                            % t - 1 = Traverse actual grid upwards
                            t = t - 1;
                            
                            % Decrement traversal counter 
                            s = s - 1;
                        end % end while s > 0
                        
                        % Exit for loop if player is found
                        break;
                        
                    end % end if Grid(i) == PLAYER
                    
                end % end for i = 1:numel(Grid)
                
            case 'd' % Throw knife to the right
                valid = true;
                
                % Locate the player
                for i = 1:numel(Grid)
                    if Grid(i) == PLAYER % Player found at position i
                        
                    % Actual Grid Indecies      Printed Grid Indecies
                    %  1  6   11  16  21          1   2   3   4   5
                    %  2  7   12  17  22          6   7   8   9   10
                    %  3  8   13  18  23          11  12  13  14  15
                    %  4  9   14  19  24          16  17  18  19  20
                    %  5  10  15  20  25          21  22  23  24  25
            
                    % 	Actual Grid                Printed Grid 
                    %  *  *  E  *  *              *  *  *  *  * 
                    %  *  *  *  *  *              *  *  *  *  * 
                    %  *  *  *  P  *              E  *  *  *  * 
                    %  *  *  *  O  *              *  *  P  O  E 
                    %  *  *  *  E  *              *  *  *  *  * 
                    
                    % Example above: i = 18, GRIDSIZE = 5, ENEMY = 20
                        
                        % Temporary variable used to traverse the grid
                        t = i;
                        
                        % s = The number of times needed to traverse the
                        % column dependending on where the player is 
                        % located on the actual grid. 
                        % Example above: s = mod(t,GRIDSIZE) = 3 
                        % Move cursor 't' 2 times
                        
                        % If player at bottom of actual grid, knife wasted
                        if mod(t,GRIDSIZE) == 0 % Player at bottom
                            s = GRIDSIZE + 1; % Do not enter while loop
                        else
                            s = mod(t,GRIDSIZE);
                        end
                        
                        while s <= GRIDSIZE
                            % If enemy found during grid traversal
                            if Grid(t) == ENEMY
                                
                                % Kill all enemies on that square 
                                Grid(t) = EMPTY;
                                
                                %Multiple enemies in one square is possible
                                % Find which enemies are on that square and
                                % kill them.
                                for j = 1:numel(ENEMIESLOC)
                                    
                                    if ENEMIESLOC(j) == t
                                        NUMENEMIES = NUMENEMIES - 1;
                                        ENEMIESLOC(j) = -1;
                                    end % end if ENEMIESLOC(j) == t
                                    
                                end % end for j = 1:numel(ENEMIESLOC)
                                
                                fprintf('\nYou got`em!\n')
                                
                                % Enemy has been hit
                                hit = true;
                                
                                % Exit while loop if enemy is found
                                break;
                                
                            end % end if Grid(t) == ENEMY
                            
                            % t + 1 = Traverse actual grid upwards
                            t = t + 1;
                            
                            % Increment traversal counter 
                            s = s + 1;
                        end % end while s <= GRIDSIZE
                        
                        % Exit for loop if player is found
                        break;
                        
                    end % end if Grid(i) == PLAYER
                    
                end % end for i = 1:numel(Grid)
       
            otherwise
                fprintf('Invalid input: w:up  s:down  a:left  d:right   ')
                user = input('','s');
        end % end switch user
        
    end % end while ~valid
    
    if ~hit
        fprintf('\nYou missed :(\n')
    end
    
    % If enemy is on orb and dies, orb respawns
    Grid = respawnOrbs(Grid); 
    newGrid = Grid;
    
end % end function newGrid = throwKnife(Grid)

% Enemy movement function
function newGrid = moveEnemies(Grid)
% Enemies have some sort of AI so that if the player is in an enemy's line
% of sight, the enemy will move towards the player
    global GRIDSIZE;
    global EMPTY;
    global PLAYER;
    global ENEMY;
    global ENEMIESLOC;
    
    % For all enemies, determine direction and execute movement
    for i = 1:numel(ENEMIESLOC)
        
        % If that enemy is not dead
        if ENEMIESLOC(i) ~= -1
            
            % direction = direction the enemy will move
            % 1 = up, 2 = down, 3 = left, 4 = right, 0 = random
            direction = 0;
            
            enemyMoved = false;
            
            % The following while loop is used so that if a direction is
            % determined (i.e the player is in enemy's line of sight), the
            % rest of the code to continue checking if player is in enemy's  
            % line of sight will not be executed.
            while true
                
                % up = cursor to traverse grid upwards
                up = ENEMIESLOC(i);
                
                % Traverse the actual grid leftwards
                while up > 0
                    
                    % If player is found during traversal
                    if Grid(up) == PLAYER
                        % This enemy will move up
                        direction = 1;
                        break; % exit while up > 0
                    end
                    
                    % up - GRIDSIZE = traverse actual grid leftwards
                    up = up - GRIDSIZE;
                    
                end % end while up > 0
                
                % If direction determined no need to continue searching for
                % player
                if direction ~= 0
                    break; % exit while true
                end
                
                % down = cursor to traverse grid downwards
                down = ENEMIESLOC(i);
                
                % Traverse the actual grid rightwards
                while down <= numel(Grid)
                    
                    % If player is found during traversal
                    if Grid(down) == PLAYER
                        % This enemy will move down
                        direction = 2;
                        break; % exit while down <= numel(Grid)
                    end
                    
                    % down + GRIDSIZE = traverse actual grid rightwards
                    down = down + GRIDSIZE;
                    
                end % end while down < numel(Grid)
                
                % If direction determined no need to continue searching for
                % player
                if direction ~= 0
                    break; % exit while true
                end
                
                % left = cursor to traverse grid leftwards
                left = ENEMIESLOC(i);
                
                if mod(left,GRIDSIZE) == 0
                    % left1 = The number of times needed to traverse the
                    % column dependending on where the player is 
                    % located on the actual grid.
                    left1 = GRIDSIZE;
                else
                    left1 = mod(left,GRIDSIZE);
                end
                
                % Traverse the actual grid upwards
                while left1 > 0
                    % If player is found during traversal
                    if Grid(left) == PLAYER
                        % This enemy will move down
                        direction = 3;
                        break; % exit while left1 > 0
                    end
                    
                    % left - 1 = traverse actual grid upwards
                    left = left - 1;
                    
                    % decrement traversal counter
                    left1 = left1 - 1;
                    
                end % end while left1 > 0
                
                % If direction determined no need to continue searching for
                % player
                if direction ~= 0
                    break; % exit while true
                end
                
                % right = cursor to traverse grid rightwards
                right = ENEMIESLOC(i);
                
                % right1 = The number of times needed to traverse the
                % column dependending on where the player is located on 
                % the actual grid. 
                % If enemy at bottom of actual grid, cant move this way
                if mod(right,GRIDSIZE) == 0 % Enemy at bottom
                    right1 = GRIDSIZE + 1; % Do not enter while loop
                else
                    right1 = mod(right,GRIDSIZE);
                end
                
                % Traverse the actual grid downwards
                while right1 < GRIDSIZE + 1
                    % If player is found during traversal
                    if Grid(right) == PLAYER
                        % This enemy will move down
                        direction = 4;
                        break; % exit while right1 < GRIDSIZE + 1
                    end
                    
                    % right + 1 = traverse actual grid downwards
                    right = right + 1;
                    
                    % increment traversal counter
                    right1 = right1 + 1;
                    
                end % end while right1 < GRIDSIZE + 1
                
                % If no direction determined (i.e Player not in line of
                % sight) Select a random direction to turn 
                if direction == 0
                    direction = randi(4);
                end
                
                % Ensures no infinite loop 
                break; % exit while true 
                
            end % end while true
            
            % Counter to prevent infinite loop in case enemy movement
            % cannot be determined
            count = 0;
            
            while ~enemyMoved
                if count > 100 % After 100 tries, exit loop
                    break;
                end
                
                % Update ENEMIESLOC depending on the direction chosen 
                switch direction
                    
                    % Direction up, left on actual grid
                    case 1
                        
                        % If enemy can move left on actual grid
                        if ENEMIESLOC(i) > GRIDSIZE
                            % Enemy can/will be moved
                            enemyMoved = true;
                            
                            % If enemy will block player spawn(i.e Grid(1)
                            if ENEMIESLOC(i)-GRIDSIZE == 1
                                %Enemy cannot move here
                                enemyMoved = false;
                                
                            % If enemy moves onto  player
                            elseif Grid(ENEMIESLOC(i)-GRIDSIZE) == PLAYER
                                
                                % Kill player
                                Grid = playerDied(Grid,ENEMIESLOC(i));
                                
                                % Update ENEMIESLOC
                                ENEMIESLOC(i) = ENEMIESLOC(i)-GRIDSIZE;
                            
                            % Enemy moves onto emtpy or orb square
                            else
                                % Empty previous position
                                Grid(ENEMIESLOC(i)) = EMPTY;
                                
                                % Update ENEMIESLOC
                                ENEMIESLOC(i) = ENEMIESLOC(i)-GRIDSIZE;
                            end % end if ENEMIESLOC(i)-GRIDSIZE == 1
                            
                        end % end if ENEMIESLOC(i) > GRIDSIZE
                        
                    % Direction down, right on actual grid
                    case 2
                        
                        % If enemy can move right on actual grid
                        if ENEMIESLOC(i) <= GRIDSIZE*GRIDSIZE - GRIDSIZE
                            
                            % Enemy can/will be moved
                            enemyMoved = true;
                            
                            % If enemy will block player spawn(i.e Grid(1)
                            if ENEMIESLOC(i)+GRIDSIZE == 1
                                % Enemy cannot move here
                                enemyMoved = false;
                                
                            % If enemy moves onto  player
                            elseif Grid(ENEMIESLOC(i)+GRIDSIZE) == PLAYER
                                
                                % Kill player
                                Grid = playerDied(Grid,ENEMIESLOC(i));
                                
                                % Update ENEMIESLOC
                                ENEMIESLOC(i) = ENEMIESLOC(i)+GRIDSIZE;
                                
                            % Enemy moves onto emtpy or orb square
                            else
                                % Empty previous position
                                Grid(ENEMIESLOC(i)) = EMPTY;
                                
                                % Update ENEMIESLOC
                                ENEMIESLOC(i) = ENEMIESLOC(i)+GRIDSIZE;
                            end % end if ENEMIESLOC(i)+GRIDSIZE == 1
                            
                        end % end if ENEMIESLOC(i) <= GRIDSIZE*GRIDSIZE ...
                        
                    % Direction left, up on actual grid
                    case 3
                        
                        % If enemy can move up on actual grid
                        if mod(ENEMIESLOC(i),GRIDSIZE) ~= 1
                            
                            % Enemy can/will be moved
                            enemyMoved = true;
                            
                            % If enemy will block player spawn(i.e Grid(1)
                            if ENEMIESLOC(i)-1 == 1
                                % Enemy cannot move here
                                enemyMoved = false;
                                
                            % If enemy moves onto  player
                            elseif Grid(ENEMIESLOC(i)-1) == PLAYER
                                
                                % Kill player
                                Grid = playerDied(Grid,ENEMIESLOC(i));
                                
                                % Update ENEMIESLOC
                                ENEMIESLOC(i) = ENEMIESLOC(i)-1;
                                
                            % Enemy moves onto emtpy or orb square
                            else
                                
                                % Empty previous position
                                Grid(ENEMIESLOC(i)) = EMPTY;
                                
                                % Update ENEMIESLOC
                                ENEMIESLOC(i) = ENEMIESLOC(i)-1;
                            end % end if ENEMIESLOC(i)-1 == 1
                            
                        end % end if mod(ENEMIESLOC(i),GRIDSIZE) ~= 1
                        
                    % Direction right, down on actual grid
                    case 4
                        
                        % If enemy can move down on actual grid
                        if mod(ENEMIESLOC(i),GRIDSIZE) ~= 0
                            
                            % Enemy can/will be move
                            enemyMoved = true;
                            
                             % If enemy will block player spawn(i.e Grid(1)
                            if ENEMIESLOC(i)+1 == 1
                                %Enemy cannot move here
                                enemyMoved = false;
                                
                            % If enemy moves onto  player
                            elseif Grid(ENEMIESLOC(i)+1) == PLAYER
                                
                                % Kill player
                                Grid = playerDied(Grid,ENEMIESLOC(i));
                                
                                % Update ENEMIESLOC
                                ENEMIESLOC(i) = ENEMIESLOC(i)+1;
                                
                            % Enemy moves onto emtpy or orb square
                            else
                                Grid(ENEMIESLOC(i)) = EMPTY;
                                
                                % Update ENEMIESLOC
                                ENEMIESLOC(i) = ENEMIESLOC(i)+1;
                            end % end if ENEMIESLOC(i)+1 == 1
                            
                        end % end if mod(ENEMIESLOC(i),GRIDSIZE) ~= 0
    
                end % end switch direction
                
                % If enemy has not moved try different direction
                if ~enemyMoved
                    count = count + 1;
                    direction = randi(4);
                end
                
            end % end while ~enemyMoved
            
        end % end if ENEMIESLOC(i) ~= -1
        
    end % end for i = 1:numel(ENEMIESLOC)
    
    % Update the grid with new enemy locations
    for r = 1:numel(ENEMIESLOC)
        if ENEMIESLOC(r) ~= -1
            Grid(ENEMIESLOC(r)) = ENEMY;
        end
    end
    
    newGrid = Grid;
    
end % end function newGrid = moveEnemies(Grid)

% Player has died
function newGrid = playerDied(Grid,i)
    global PLAYER;
    global LIVES;
    global EMPTY;
    global KNIFE;
    % Empty out square where player is located
    Grid(i) = EMPTY;
    
    % Respawn player
    Grid(1) = PLAYER;
    
    % Decrement lives
    LIVES = LIVES - 1;
    
    % One knife per life
    KNIFE = true;
    
    fprintf('\nYou lost a life :(\n')
    newGrid = Grid;
end % end function newGrid = playerDied(Grid,i)

% User quits the game
function newGrid = quitGame()
    global ORBS;
    ORBS = -1;
    home;
    fprintf('Thank you for playing\n')
    newGrid = -1;
end % end function newGrid = quitGame()

function winGame()
    home;
    fprintf('Congratulations!!! You won the game :)\n')
    user = input('Would you like to play again? y: Yes   n: No  ','s');
    valid = false;
    while ~valid
        if isempty(user)
            user = 'Invalid Input';
        end
        switch user
            case 'y'
                gameEngine()
                valid = true;
            case 'n'
                quitGame();
                valid = true;
            otherwise
                user = input('Invalid input: y: Yes   n: No  ','s');
        end
    end
end % end function winGame()

function loseGame()
    home;
    fprintf('You lost all your lives, sad face :(\n')
    user = input('Would you like to play again? y: Yes   n: No  ','s');
    valid = false;
    while ~valid
        if isempty(user)
            user = 'Invalid Input';
        end
        switch user
            case 'y'
                gameEngine()
                valid = true;
            case 'n'
                home;
                fprintf('Thank you for playing\n')
                valid = true;
            otherwise
                user = input('Invalid input: y: Yes   n: No  ','s');
        end
    end
end % end function loseGame()

function newGrid = respawnOrbs(Grid)
% Sometimes enemies erase the orbs when they walk over them. 
% This function spawns them back in.
    global ORBSLOC;
    global ORB;
    global EMPTY;
    
    % For all the orbs
    for i = 1:numel(ORBSLOC)
        % If the orb has not been collected
        if ORBSLOC(i) ~= -1
            % If that square is empty
            if Grid(ORBSLOC(i)) == EMPTY
                % Spawn in that orb
                Grid(ORBSLOC(i)) = ORB;
            end
        end
    end
    newGrid = Grid;
end % end function respawnOrbs(Grid)
