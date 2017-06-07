/* 

Mastermind 1.0v by Michael O'Ryan 4612450

*/

% Convert a match into 1 or 0
% (Element One, Element Two, Result)
ismatch(X, X, 1).
ismatch(X, Y, 0) :- Y \= X.

% Remove first element if it matches X
% (Element to remove, List, Result)
removehead(X, [X|A], A).

% Remove all X from a list
% (Item to remove, List, Result)
removeall(X, [X], []).
removeall(X, [H|Y], A) :- H \= X, removeall(X, Y, T), prepend(H,T,A).
removeall(X, [X|Y], A) :- Y \= [], removeall(X, Y, A).
removeall(_, [], []).

% Append A to a list B
% (New Head, List, Result)
prepend(A, [], [A]).
prepend(A, B, [A|B]).

% Count Number of X in List A
% (Element to count, List, Result)
count(X, A, C) :- removeall(X, A, B), length(A, Alen), length(B, Blen), C is Alen - Blen.

% Make the items in a list unique. [1,1,2,2,1] -> [1,2]
% (List, Result)
makeunique([X|Y], Unq) :- removeall(X, Y, T), makeunique(T, U), prepend(X, U, Unq).
makeunique([],[]).

% Find the lowest value of A and B
% (A, B, Minimum of A and B)
min(A, B, MIN) :- A =< B, MIN is A.
min(A, B, MIN) :- A > B, MIN is B.

% Return a list of size X with the minimum value of matching positions of two lists.
% Non elements count as zero (3, [1,2], [4, 1, 7]) -> [1, 1, 0].
% (Size of desired list to return, list, list, minimum values as a list)
minlist(X, L1, L2, MIN) :- count(X, L1, C1), count(X, L2, C2), min(C1, C2, MIN).

% Count the colour matches (integer matches) between two codes as lists. Matching positions are not included
% ([1, 1, 2, 3], [1, 2, 1, 3]) -> 2  [_, 2, 1, _] 
% (List one, List two, Result)
countcolours(L1, L2, C) :- makeunique(L1, Cs), countcolours(Cs, L1, L2, C1), positioncount(L1, L2, P), C is C1 - P.
countcolours([], _, _, 0).
countcolours([CH|CT], L1, L2, C) :- countcolours(CT, L1, L2, C1), minlist(CH, L1, L2, Min), C is C1 + Min.

% Number of position matches between two lists (integer matches)
% ([1, 1, 2, 3], [1, 2, 1, 3]) -> 1  [1, _, _, 3]
positioncount([X|XT], [Y|YT], C) :- positioncount(XT, YT, C1), ismatch(X, Y, C2), C is C1 + C2.
positioncount([],X,0) :- X \= [].
positioncount(X,[],0) :- X \= [].
positioncount([],[],0).

% Colour and position (int) matches between two lists
% (List one, List two, Positions matched, Colours matched)
% Results derived from countcolours, positioncount
pccount(L1, L2, P, C) :- countcolours(L1, L2, C), positioncount(L1, L2, P).

% Generate a code as a list. P positions and C different colours (0 to C - 1)
% (Number of positions, number of colours, Resulting code)
gencode(P, C, Code) :- P \= 0, NP is P - 1, gencode(NP, C, T), random(0,C,H), append([H], T, Code).
gencode(0, _, []).

% Is a number between two other numbers
% (Lower bound, number, upper bound)
between(L, N, H) :- N >= L, N =< H.

% Loop for player to guess the code.
% (Target code to guess, number of positions, number of colours, current guess attempt number, players guess)

% Player wins
guessloop(Answer, Pos, _, NumTries, Guess) :- pccount(Answer, Guess, P, C), P = Pos, C = 0, dowin(NumTries).

% Player to guess again
guessloop(Answer, Pos, Cols, NumTries, Guess) :- pccount(Answer, Guess, P, C), P \= Pos, C >= 0, printmatches(C, P), NewTries is NumTries + 1, getguess(Answer, Pos, Cols, NewTries).

% Get a guess from a player
% (Answer to guess, Number of positions, number of colours, current guess attempt number)
getguess(Answer, Pos, Cols, NumTries) :- getinput(Guess, Pos, Cols), guessloop(Answer, Pos, Cols, NumTries, Guess).

% Player has guessed the code. Print guesses taken and ask if they want to play again
% (current guess attempt number)
dowin(Guesses) :- write('You won in '), write(Guesses), write(' guess'), es(Guesses) ,write('!'), nl ,write('Play again? (y)es or (n)o :'), getyorno(YN), playagain(YN).


% Write s if a plural or nothing if it is not
% (Number of things being described)
plural(N) :- N \= 1, write('s').
plural(N) :- N = 1, write('').

% Write es if a plural or nothing if it is not
% (Number of things being described)
es(N) :- N = 1.
es(N) :- N \= 1, write('es').

% Print the number of colours and positions matched
% (Colours matched, Positions matched)
printmatches(C, P) :- write('Your guess matched '), write(C), write(' colour'), plural(C), write(' and '), write(P), write(' position'), plural(P), write('.'), nl.

% Get the code from the player
% (Resulting guess from player, Number of positions, number of colours)
getinput(Guess, P, C) :- write('Please enter your guess eg; rgr for red, green, red: '), readchar(I), parsecode(I, Guess, P, C).

% Convert player input into integers
% (code string 'rgrb', code as integer, number of positions, number of colours)
parsecode(I, Code, P, C) :- strtolist(I, Code), validcode(Code, P, C).
parsecode(I, Code, P, C) :- strtolist(I, BadCode), \+ validcode(BadCode, P, C), write('Invalid Code entered'), nl, getinput(Code, P, C).
parsecode(I, Code, P, C) :- \+strtolist(I, _), write('Invalid Code entered'), nl, getinput(Code, P, C).

% Is the code entered valid
% (Code to check as int, number of positions, number of colours)
validcode(Code, P, C) :- (length(Code, Sz)), Sz = P, lessthaninlist(Code, C).

% Are all numbers in a list LESS THAN some value (Not less than or equal comparion < not =<)
% (List, Upperbound)
lessthaninlist([H|T], Max) :- H < Max, lessthaninlist(T, Max).
lessthaninlist([], _).

% Convert a string into a list of each character
% (String or atom, Resulting list, current position in string, Number of colours so far)
strtolist([C|StrTail], Lst) :- colourcode(C, H), strtolist(StrTail, T), append([H], T, Lst).
strtolist([], []).


% Get two integers from the user
% (First integer, Second integer)
gettwoint(A, B) :- readint(A), readint(B).

% Get the size of the game from the player
% (Colour count, position count)
getgamesize(C, P) :- write('Please enter a game size. Number of colours then positions between 2 and 6: '), gettwoint(A, B), checkgamesize(A, B, C, P).

% Ensure gamesize is of a required size
% (Colours entered, Positions entered, colours, positions)
checkgamesize(A, B, C, P) :- between(2, A, 6), between(2, B, 6), C is A, P is B.
checkgamesize(A, B, C, P) :- \+  between(2, A, 6), \+ between(2, B, 6), getgamesize(C, P).
checkgamesize(A, B, C, P) :- \+  between(2, A, 6), between(2, B, 6), getgamesize(C, P).
checkgamesize(A, B, C, P) :- between(2, A, 6), \+ between(2, B, 6), getgamesize(C, P).

% Whether to print a comma or and for a list of items
% (Number of items remaining in list)
printandorcomma(Remaining) :- Remaining = 1, write(' and ').
printandorcomma(Remaining) :- Remaining >= 1, write(', ').
printandorcomma(Remaining) :- Remaining = 0, write('.').

% Print all the colours available for the player to choose from eg; Red, Green, Blue and Yellow
% (Number of colours) 
printcolours(C) :- C = 0.
printcolours(C) :- C > 0, Cur is C - 1, colourname(Cur, Colour), write(Colour), printandorcomma(Cur), printcolours(Cur), !.

% Print string telling player some info about the colours they can choose from rather than just listing colours as printcolours
% (Number of colours) 
printcolouroptions(C) :- write('The colours you can choose from are '), printcolours(C), nl.

% Get y/Y or n/N from user
% (character entered)
getyorno(YN) :- readchar(I), checkyorno(I, YN).

% Check if input is y / Y or n / N
% (Input, lower case y or n)
checkyorno(I, YN) :- I = ['Y'], YN = 'y'.
checkyorno(I, YN) :- I = ['y'], YN = 'y'.
checkyorno(I, YN) :- I = ['N'], YN = 'n'.
checkyorno(I, YN) :- I = ['n'], YN = 'n'.
checkyorno(I, YN) :- I \= ['n'], I \= 'N', I \= 'y', I \= 'Y', write('Please enter y for yes or or n for no: '), getyorno(YN).

% does the player wish to play again?
% (y or n)
playagain(A) :- A = 'y', gameloop.
playagain(A) :- A = 'n', write('Thanks for playing :D'), nl, halt.

% Read some characters from input
% (Input)
readchar(I) :- clearwhitespace, catch(get_string(I), error(syntax_error(_),_), (write('Please enter a character:'), readint(_), readchar(I)) ).

% Read an integer from input
% (Input)
readint(I) :- catch(read_integer('$stream'(0), I), error(syntax_error(_),_), (write('Please enter a number:'), read_token('$stream'(0), _), readint(I)) ).

% clear any white space
clearwhitespace :- peek_char(C), C = ' ', get_char(_), clearwhitespace.
clearwhitespace :- peek_char(C), C = '\n', get_char(_), clearwhitespace.
clearwhitespace.

% return a string as a list ['S', 'o', 'm', 'E', 'S', 'T', 'r', 'i', 'n', 'G', ]
% Stop at first whitespace character
get_string([]) :- peek_char(C), C = ' ', get_char(_).
get_string([]) :- peek_char(C), C = '\n', get_char(_).
get_string(S) :- peek_char(N), N \= ' ', N \= '\n', get_char(H), get_string(T), append([H], T, S).

% Letter and number codes relationships
colourcode('r', 0).
colourcode('R', 0).

colourcode('g', 1).
colourcode('G', 1).

colourcode('b', 2).
colourcode('B', 2).

colourcode('y', 3).
colourcode('Y', 3).

colourcode('p', 4).
colourcode('P', 4).

colourcode('w', 5).
colourcode('W', 5).

colourcode('e', 6).
colourcode('E', 6).

colourname(0, '(r)ed').
colourname(1, '(g)reen').
colourname(2, '(b)lue').
colourname(3, '(y)ellow').
colourname(4, '(p)urple').
colourname(5, '(w)hite').
colourname(6, '(e)bony').

% Start game loop for guessing code
gameloop :- getgamesize(C, P), gencode(P, C, Answer), printcolouroptions(C), getguess(Answer, P, C, 1).

% Point of entry for game
intro :- write('Welcome to Mastermind'), nl, gameloop, halt.

:- initialization(intro).
