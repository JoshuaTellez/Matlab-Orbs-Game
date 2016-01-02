function matlabOrbs()
gameEngine()
end

function gameEngine()
startMenu()
global PLAYER;
global ENEMY;
global ORB;

global NUMENEMIES;
global ORBS;
global LIVES;
global GRIDSIZE;
global INFINITEKNIFE;

global MOVED;
global KNIFE;
global ORBSLOC;
global ENEMIESLOC;
global EMPTY;

%Following can be changed to alter gameplay
NUMENEMIES = 8;
ORBS = 6;      %Must be at least 1
LIVES = 3;
GRIDSIZE = 10; %Creates nxn grid. Minimum 4 and have room for enemies
INFINITEKNIFE = false;

%Following can be changed but will not 
%change the game (Condition: cannot be 0)
PLAYER = 1;
ENEMY = 2;
ORB = 3;

%Following cannot be changed
MOVED = false;
KNIFE = true;
ORBSLOC(1:ORBS) = -1;
ENEMIESLOC(1:NUMENEMIES) = -1;
EMPTY = 0;

Grid = setGrid(GRIDSIZE);
while LIVES > 0 && ORBS > 0
    Grid = play(Grid);
    if MOVED && LIVES ~= 0 && ORBS ~=0
        Grid = moveEnemies(Grid);
        Grid = respawnOrbs(Grid);
        MOVED = false;
    end
    if LIVES ~= 0
        printGrid(Grid)
    end
end
if ORBS == 0
    winGame()
elseif LIVES <= 0
    loseGame()
end
end

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
fprintf('Here is your very own Generated Randomly Individual Domain') 
fprintf(' or G.R.I.D for you to adventure on\n')
end

function Grid = setGrid(gridSize)
global PLAYER;
global NUMENEMIES;
Grid = zeros(gridSize);
Grid(1) = PLAYER;
if NUMENEMIES ~= 0
    Grid = spawnEnemies(Grid,1);
end
Grid = spawnOrbs(Grid,1);
printGrid(Grid)
end

function newGrid = spawnEnemies(Grid,enemiesSpawned)
global GRIDSIZE;
global ENEMY;
global EMPTY;
global ENEMIESLOC;
global NUMENEMIES;
enemyPosition = randi(numel(Grid));
enemySpawned = false;
while ~enemySpawned
    if Grid(enemyPosition) == EMPTY && ~(enemyPosition == 2 || enemyPosition == 3 ...
            || enemyPosition == GRIDSIZE+1 || enemyPosition == GRIDSIZE+2 ...
            || enemyPosition == GRIDSIZE+3 || enemyPosition == 1+(GRIDSIZE*2) ...
            || enemyPosition == 2 +(GRIDSIZE*2) || enemyPosition == 3+(GRIDSIZE*2))
        Grid(enemyPosition) = ENEMY;
        ENEMIESLOC(enemiesSpawned) = enemyPosition;
        enemySpawned = true;
        enemiesSpawned = enemiesSpawned + 1;
    else
        enemyPosition = randi(numel(Grid));
    end
end
if enemiesSpawned <= NUMENEMIES
    Grid = spawnEnemies(Grid,enemiesSpawned);
end
newGrid = Grid;
end

function newGrid = spawnOrbs(Grid,orbsSpawned)
global ORB;
global EMPTY
global ORBSLOC;
global ORBS;
orbPosition = randi(numel(Grid));
orbSpawned = false;
while ~orbSpawned
    if Grid(orbPosition) == EMPTY 
        Grid(orbPosition) = ORB;
        ORBSLOC(orbsSpawned) = orbPosition;
        orbsSpawned = orbsSpawned + 1;
        orbSpawned = true;
    else
        orbPosition = randi(numel(Grid));
    end
end
if orbsSpawned <= ORBS;
    Grid = spawnOrbs(Grid,orbsSpawned);
end
newGrid = Grid;
end

function printGrid(Grid)
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
for i = 1:numel(Grid)
    if Grid(i) == PLAYER
        fprintf('P ')
    elseif Grid(i) == ENEMY
        fprintf('E ')
    elseif Grid(i) == ORB
        fprintf('O ')
    elseif Grid(i) == EMPTY
        fprintf('* ')
    end
    if mod(i,GRIDSIZE) == 0 && i == GRIDSIZE*floor(GRIDSIZE*(1/3))
        fprintf('\tP: Player   E: Enemy   O: Orb')
    end
    if mod(i,GRIDSIZE) == 0 && i == GRIDSIZE*(floor(GRIDSIZE*(1/3))+1)
        fprintf('\tLives: %d   Enemies: %d   Orbs: %d', LIVES, NUMENEMIES, ORBS);
    end
    if mod(i,GRIDSIZE) == 0 && i == GRIDSIZE*(floor(GRIDSIZE*(1/3))+2)
        if KNIFE
            fprintf('\tThrowing Knife: 1')
        elseif INFINITEKNIFE
            fprintf('\tThrowing Knife: NaN')
        else
            fprintf('\tThrowing Knife: 0')
        end
    end
    if mod(i,GRIDSIZE) == 0
        fprintf('\n')
    end
end
fprintf('\n')
end

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
user = input('','s');

valid = false;
while ~valid
    if isempty(user)
        user = 'Invalid Input';
    end
    switch user
        case 'w'
            Grid = moveUp(Grid);
            valid = true;
        case 's'
            Grid = moveDown(Grid);
            valid = true;
        case 'a'
            Grid = moveLeft(Grid);
            valid = true;
        case 'd'
            Grid = moveRight(Grid);
            valid = true;
        case 'k'
            if KNIFE || INFINITEKNIFE
                Grid = throwKnife(Grid);
            else
                fprintf('You already used your knife\n')
            end
            valid = true;
        case 'q'
            Grid = quitGame();
            valid = true;
        otherwise
            fprintf('Invalid input: Please try again\n')
            fprintf('w: Move up, ')
            fprintf('s: Move down ')
            fprintf('a: Move left, ')
            fprintf('d: Move right,\n')
            fprintf('k: Throw knife, ')
            fprintf('q: Quit   ')
            user = input('','s');
    end
end
newGrid = Grid;
end

function newGrid = moveUp(Grid)
global GRIDSIZE;
global EMPTY;
global PLAYER;
global ENEMY;
global ORB;
global ORBS;
global ORBSLOC;
global MOVED;
for i = 1:numel(Grid)
    if Grid(i) == 1
        if i > GRIDSIZE
            MOVED = true;
            if Grid(i-GRIDSIZE) == ENEMY
                Grid = playerDied(Grid,i);
            elseif Grid(i-GRIDSIZE) == ORB
                for j = 1:numel(ORBSLOC)
                    if ORBSLOC(j) == (i-GRIDSIZE)
                        ORBSLOC(j) = -1;
                    end
                end
                Grid(i) = EMPTY;
                Grid(i-GRIDSIZE) = PLAYER;
                ORBS = ORBS - 1;
            else
                Grid(i) = EMPTY;
                Grid(i-GRIDSIZE) = PLAYER;
            end
        end
        break;
    end
end
newGrid = Grid;
end 

function newGrid = moveDown(Grid)
global GRIDSIZE;
global EMPTY;
global PLAYER;
global ENEMY;
global ORB;
global ORBS;
global MOVED;
global ORBSLOC;
for i = 1:numel(Grid)
    if Grid(i) == 1
        if i <= GRIDSIZE*GRIDSIZE - GRIDSIZE
            MOVED = true;
            if Grid(i+GRIDSIZE) == ENEMY
                Grid = playerDied(Grid,i);
            elseif Grid(i+GRIDSIZE) == ORB
                for j = 1:numel(ORBSLOC)
                    if ORBSLOC(j) == (i+GRIDSIZE)
                        ORBSLOC(j) = -1;
                    end
                end
                Grid(i) = EMPTY;
                Grid(i+GRIDSIZE) = PLAYER;
                ORBS = ORBS - 1;
            else
                Grid(i) = EMPTY;
                Grid(i+GRIDSIZE) = PLAYER;
            end
        end
        break;
    end
end
newGrid = Grid;
end 

function newGrid = moveLeft(Grid)
global GRIDSIZE;
global EMPTY;
global PLAYER;
global ENEMY;
global ORB;
global ORBS;
global ORBSLOC;
global MOVED;
for i = 1:numel(Grid)
    if Grid(i) == 1
        if mod(i,GRIDSIZE) ~= 1
            MOVED = true;
            if Grid(i-1) == ENEMY
                Grid = playerDied(Grid,i);
            elseif Grid(i-1) == ORB
                for j = 1:numel(ORBSLOC)
                    if ORBSLOC(j) == (i-1)
                        ORBSLOC(j) = -1;
                    end
                end
                Grid(i) = EMPTY;
                Grid(i-1) = PLAYER;
                ORBS = ORBS - 1;
            else
                Grid(i) = EMPTY;
                Grid(i-1) = PLAYER;
            end
        end
        break;
    end
end 
newGrid = Grid;
end

function newGrid = moveRight(Grid)
global GRIDSIZE;
global EMPTY;
global PLAYER;
global ENEMY;
global ORB;
global ORBS;
global ORBSLOC;
global MOVED;
for i = 1:numel(Grid)
    if Grid(i) == PLAYER
        if mod(i,GRIDSIZE) ~= 0
            MOVED = true;
            if Grid(i+1) == ENEMY
                Grid = playerDied(Grid,i);
            elseif Grid(i+1) == ORB
                for j = 1:numel(ORBSLOC)
                    if ORBSLOC(j) == (i+1)
                        ORBSLOC(j) = -1;
                    end
                end
                Grid(i) = EMPTY;
                Grid(i+1) = PLAYER;
                ORBS = ORBS - 1;
            else
                Grid(i) = EMPTY;
                Grid(i+1) = PLAYER;
            end
        end
        break;
    end
end
newGrid = Grid;
end

function newGrid = throwKnife(Grid)
global PLAYER;
global ENEMY;
global GRIDSIZE;
global EMPTY;
global KNIFE;
global NUMENEMIES;
global ENEMIESLOC;
fprintf('Choose a direction to throw your knife then hit Enter\n')
fprintf('w:up  s:down  a:left  d:right   ')
user = input('','s');
KNIFE = false;
hit = false;
valid = false;
while ~valid
    if isempty(user)
        user = 'Invalid Input';
    end
    switch user
        case 'w'
            valid = true;
            for i = 1:numel(Grid)
                if Grid(i) == PLAYER
                    t = i;
                    while t > 0
                        if Grid(t) == ENEMY
                            Grid(t) = EMPTY;
                            for j = 1:numel(ENEMIESLOC)
                                if ENEMIESLOC(j) == t
                                    NUMENEMIES = NUMENEMIES - 1;
                                    ENEMIESLOC(j) = -1;
                                end
                            end
                            fprintf('\nYou got`em!\n')
                            hit = true;
                            break;
                        end
                        t = t - GRIDSIZE;
                    end
                    break;
                end
            end
        case 's'
            valid = true;
            for i = 1:numel(Grid)
                if Grid(i) == PLAYER
                    t = i;
                    while t < numel(Grid)
                        if Grid(t) == ENEMY
                            Grid(t) = EMPTY;
                            for j = 1:numel(ENEMIESLOC)
                                if ENEMIESLOC(j) == t
                                    ENEMIESLOC(j) = -1;
                                    NUMENEMIES = NUMENEMIES - 1;
                                end
                            end
                            fprintf('\nYou got`em!\n')
                            hit = true;
                            break;
                        end
                        t = t + GRIDSIZE;
                    end
                    break;
                end
            end
        case 'a'
            valid = true;
            for i = 1:numel(Grid)
                if Grid(i) == PLAYER
                    t = i;
                    if mod(t,GRIDSIZE) == 0
                        s = GRIDSIZE;
                    else
                        s = mod(t,GRIDSIZE);
                    end
                    while s > 0
                        if Grid(t) == ENEMY
                            Grid(t) = EMPTY;
                            for j = 1:numel(ENEMIESLOC)
                                if ENEMIESLOC(j) == t
                                    ENEMIESLOC(j) = -1;
                                    NUMENEMIES = NUMENEMIES - 1;
                                end
                            end
                            hit = true;
                            break;
                        end
                        t = t - 1;
                        s = s - 1;
                    end
                    break;
                end
            end
        case 'd'
            valid = true;
            for i = 1:numel(Grid)
                if Grid(i) == PLAYER
                    t = i;
                    if mod(t,GRIDSIZE) == 0
                        s = GRIDSIZE + 1;
                    else
                        s = mod(t,GRIDSIZE);
                    end
                    while s < GRIDSIZE + 1
                        if Grid(t) == ENEMY
                            for j = 1:numel(ENEMIESLOC)
                                if ENEMIESLOC(j) == t
                                    ENEMIESLOC(j) = -1;
                                    NUMENEMIES = NUMENEMIES - 1; 
                                end
                            end
                            Grid(t) = EMPTY;
                            fprintf('\nYou got`em!\n')
                            hit = true;
                            break;
                        end
                        t = t + 1;
                        s = s + 1;
                    end
                    break;
                end
            end
        otherwise
            fprintf('Invalid input: w:up  s:down  a:left  d:right   ')
            user = input('','s');
    end
end
if ~hit
    fprintf('\nYou missed :(\n')
end
Grid = respawnOrbs(Grid); %if enemy is on orb and dies, orb respawns
newGrid = Grid;
end

function newGrid = moveEnemies(Grid)
global GRIDSIZE;
global EMPTY;
global PLAYER;
global ENEMY;
global ENEMIESLOC;
for i = 1:numel(ENEMIESLOC)
    if ENEMIESLOC(i) ~= -1
        temp = true;
        direction = 0;
        enemyMoved = false;
        while temp
            up = ENEMIESLOC(i);
            while up > 0
                if Grid(up) == PLAYER
                    direction = 1;
                    break;
                end
                up = up - GRIDSIZE;
            end
            if direction ~= 0
                break;
            end
            down = ENEMIESLOC(i);
            while down <= numel(Grid)
                if Grid(down) == PLAYER
                    direction = 2;
                    break;
                end
                down = down + GRIDSIZE;
            end
            if direction ~= 0
                break;
            end
            left = ENEMIESLOC(i);
            if mod(left,GRIDSIZE) == 0
                left1 = GRIDSIZE;
            else
                left1 = mod(left,GRIDSIZE);
            end
            while left1 > 0
                if Grid(left) == PLAYER
                    direction = 3;
                    break;
                end
                left = left - 1;
                left1 = left1 - 1;
            end
            if direction ~= 0
                break;
            end
            right = ENEMIESLOC(i);
            if mod(right,GRIDSIZE) == 0
                right1 = GRIDSIZE + 1;
            else
                right1 = mod(right,GRIDSIZE);
            end
            while right1 < GRIDSIZE + 1
                if Grid(right) == PLAYER
                    direction = 4;
                    break;
                end
                right = right + 1;
                right1 = right1 + 1;
            end
            if direction == 0
                direction = randi(4);
                break;
            end
            break;
        end
        count = 0;
        while ~enemyMoved
            if count > 100 %Prevents infinite loop
                break;
            end
            switch direction
                case 1
                    if ENEMIESLOC(i) > GRIDSIZE
                        enemyMoved = true;
                        if ENEMIESLOC(i)-GRIDSIZE == 1
                            enemyMoved = false;
                        elseif Grid(ENEMIESLOC(i)-GRIDSIZE) == PLAYER
                            Grid = playerDied(Grid,ENEMIESLOC(i));
                            ENEMIESLOC(i) = ENEMIESLOC(i)-GRIDSIZE;
                            
                        else
                            Grid(ENEMIESLOC(i)) = EMPTY;
                            ENEMIESLOC(i) = ENEMIESLOC(i)-GRIDSIZE;
                        end
                    end
                case 2
                    if ENEMIESLOC(i) <= GRIDSIZE*GRIDSIZE - GRIDSIZE
                        enemyMoved = true;
                        if ENEMIESLOC(i)+GRIDSIZE == 1
                            enemyMoved = false;
                        elseif Grid(ENEMIESLOC(i)+GRIDSIZE) == PLAYER
                            Grid = playerDied(Grid,ENEMIESLOC(i));
                            ENEMIESLOC(i) = ENEMIESLOC(i)+GRIDSIZE;
                        else
                            Grid(ENEMIESLOC(i)) = EMPTY;
                            ENEMIESLOC(i) = ENEMIESLOC(i)+GRIDSIZE;
                        end
                    end
                case 3
                    if mod(ENEMIESLOC(i),GRIDSIZE) ~= 1
                        enemyMoved = true;
                        if ENEMIESLOC(i)-1 == 1
                            enemyMoved = false;
                        elseif Grid(ENEMIESLOC(i)-1) == PLAYER
                            Grid = playerDied(Grid,ENEMIESLOC(i));
                            ENEMIESLOC(i) = ENEMIESLOC(i)-1;
                        else
                            Grid(ENEMIESLOC(i)) = EMPTY;
                            ENEMIESLOC(i) = ENEMIESLOC(i)-1;
                        end
                    end
                case 4
                    if mod(ENEMIESLOC(i),GRIDSIZE) ~= 0
                        enemyMoved = true;
                        if ENEMIESLOC(i)+1 == 1
                            enemyMoved = false;
                        elseif Grid(ENEMIESLOC(i)+1) == PLAYER
                            Grid = playerDied(Grid,ENEMIESLOC(i));
                            ENEMIESLOC(i) = ENEMIESLOC(i)+1;
                            
                        else
                            Grid(ENEMIESLOC(i)) = EMPTY;
                            ENEMIESLOC(i) = ENEMIESLOC(i)+1;
                        end
                    end
                    
            end
            if ~enemyMoved
                count = count + 1;
                direction = randi(4);
            end
        end
    end
end
for r = 1:numel(ENEMIESLOC)
    if ENEMIESLOC(r) ~= -1
        Grid(ENEMIESLOC(r)) = ENEMY;
    end
end
newGrid = Grid;
end

function newGrid = playerDied(Grid,i)
global PLAYER;
global LIVES;
global EMPTY;
global KNIFE;
Grid(i) = EMPTY;
Grid(1) = PLAYER;
LIVES = LIVES - 1;
KNIFE = true;
fprintf('\nYou lost a life :(\n')
newGrid = Grid;
end

function newGrid = quitGame()
global ORBS;
ORBS = -1;
home;
fprintf('Thank you for playing\n')
newGrid = -1;
end

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
end

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
end

function newGrid = respawnOrbs(Grid)
global ORBSLOC;
global ORB;
global EMPTY;
for i = 1:numel(ORBSLOC)
    if ORBSLOC(i) ~= -1
        if Grid(ORBSLOC(i)) == EMPTY
            Grid(ORBSLOC(i)) = ORB;
        end
    end
end
newGrid = Grid;
end
