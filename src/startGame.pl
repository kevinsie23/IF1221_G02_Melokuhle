:- include('loadKartu.pl').
:- include('mainkanKartu.pl').
:- include('log.pl').
:- dynamic(giliranPemain/1).
:- dynamic(reverseGiliran/1).
:- dynamic(discardPile/1).
:- dynamic(handPile/1).
:- dynamic(jumlahPemain/1).

giliranPemain(1).
reverseGiliran(1).

startGame:- 
    write('Masukkan jumlah pemain: '), read(Num), nl, 
    checkPlayerCount(Num), inputName(Num,1,ListData), !, 
    % Ordered List = Urutan sdh dirandom
    % FinalList = Uurtan sdh dirandom + dikasi kartu
    % DiscardPile -> List Kartu yang sudah dimainkan
    % RemainingDeck -> List kartu yang belum diambil
    randomOrder(ListData, OrderedList), nl, printOrder(OrderedList), nl,
    giveCards(OrderedList, RemainingDeck, FinalList), 
    % FinalDeck -> Deck Kartu setelah diambil satu untuk discardPile
    makeDiscardPile(RemainingDeck, DiscardPile, FinalDeck),
    nl, write('Kartu discard top: '), printDiscard(DiscardPile), write('.'),
    % printList(DiscardPile), nl, printList(FinalList),
    % Variabel Penting ==> DiscardPile, FinalDeck, Final List
    assertz(discardPile(DiscardPile)),
    assertz(handPile(FinalList)), 
    assertz(jumlahPemain(Num)), !.

% 
printDiscard([H]):- write(H).

%Predikat Debugging Liat list
printList([]):- !.
printList([H|T]):- write(H), nl, printList(T).

%Validasi jumlah pemain
checkPlayerCount(X):- X>=2, X=<4, !.
checkPlayerCount(_):- write('Mohon masukkan angka antara 2-4.'), nl, startGame.

inputName(X, Count, Result):- getName(X, Count, [], Result), !.

%Base Case saat X sudah 0 mulaih input list
getName(0, _,  _, []). 
%getName Sukses Nama Unik
getName(X,Count, Seen, [[Input|_]|Rest]) :-
    X>0,
    write('Masukkan nama pemain '), write(Count), write(': '),
    read(Input), 
    \+ member(Input, Seen), !, %Cek apakah Input ada di dalam List Seen
    NextX is X-1,
    NextCount is Count+1,
    getName(NextX, NextCount, [Input|Seen], Rest). % [Name|Seen] Masukin Name ke Dalam Seen
%Get Name gagal Nama tidak unik
getName(X, Count, Seen, Rest):- 
    X>0, 
    write('Nama sudah digunakan. Masukkan nama lain:  '), 
    retryInput(X, Count, Seen, Rest).

%Retry Sukses
retryInput(X, Count, Seen, [[Input|_]|Rest]) :-
    read(Input),
    \+ member(Input, Seen), !, %Cek apakah Input ada di dalam List Seen
    NextX is X-1,
    NextCount is Count+1,
    getName(NextX, NextCount, [Input|Seen], Rest). % [Name|Seen] Masukin Name ke Dalam Seen
%Retry Fail
retryInput(X, Count, Seen, Rest):-     
    write('Nama sudah digunakan. Masukkan nama lain:  '), 
    retryInput(X, Count, Seen, Rest).

% Buang elemen list ke idx dan dimasukkin ke Element
removeAt(0, [H|T], H, T). % BaseCase Idx 0.
removeAt(Idx, [H|T], Element, [H|Rest]):- 
    Idx>0,
    NextId is Idx - 1,
    removeAt(NextId, T, Element, Rest).

%Hitung Panjang List
lengthList([], 0):- !.
lengthList([_|T], X):- lengthList(T,X1), X is X1+1.

%Urutan bermain sesuai dengan urutan muncul pada list. Jadi di index 0 main dulu stlh itu index 1, ...
randomOrder([],[]):- !.
randomOrder(List, [Random|Rest]):- 
    lengthList(List, L), 
    random(0,L,Index),
    removeAt(Index, List, Random, Remaining),
    randomOrder(Remaining, Rest).

% Menampilkan urutan pemain saat game dimulai
printOrder([[H|_]| Rest]):- write('Urutan pemain: '), write(H), printRest(Rest), write('.'), !.
printRest([]):- !. % Base Case =  List Sudah Habis
printRest([[H|_] | T]):- write(' - '), write(H), printRest(T). % Rekursi Print Urutan

%Predikat untuk bagi 7 kartu ke setiap pemain
giveCards(OrderedList, RemainingDeck, FinalList):- 
    write('Setiap pemain mendapatkan 7 kartu acak.'), nl,
    % CardDeck -> Deck kartu lengkap
    % RemainingDeck -> Sisa Deck kartu setelah dibagi-bagi
    loadKartu('kartu.txt', CardDeck), 
    giveCardsHelper(OrderedList, CardDeck, RemainingDeck, FinalList). 

giveCardsHelper([], FinalDeck, FinalDeck, []):- !.
giveCardsHelper([[Name|_]|RestPlayer], CurrentDeck, FinalRemainingDeck, [PlayerHand|Rest]):-
    takeSeven(CurrentDeck, SevenCards, RemainingDeck),
    PlayerHand = [Name | SevenCards],
    giveCardsHelper(RestPlayer, RemainingDeck, FinalRemainingDeck, Rest).

takeSeven(CurrentDeck, SevenCards, RemainingDeck) :- takeN(7, CurrentDeck, SevenCards, RemainingDeck).

takeN(0, Deck, [], Deck):- !. %Base Case: Sudah diambil 7 kartu
takeN(N, Deck, [SelectedCard|RestHand], RemainingDeck):-
    N>0, !,
    lengthList(Deck, L),
    random(0,L,Idx),
    removeAt(Idx, Deck, SelectedCard, TempDeck),
    NextN is N - 1,
    takeN(NextN, TempDeck, RestHand, RemainingDeck), !.

makeDiscardPile(RemainingDeck, DiscardPile, FinalDeck):- 
    takeN(1, RemainingDeck, DiscardPile, FinalDeck), 
    checkAngka(DiscardPile), !.

makeDiscardPile(RemainingDeck, DiscardPile, FinalDeck):- 
    takeN(1, RemainingDeck, DiscardPile, FinalDeck), 
    \+ checkAngka(DiscardPile), !, makeDiscardPile(RemainingDeck, DiscardPile, FinalDeck).

checkAngka([H|_]):- 
    kartuParser(H, [_, Number]), 
    \+ member(Number, [wild, wild_draw_four, skip, reverse, draw_two, wild, mimic]).





/* ---------MAIN PREDIKAT--------- */
mainkanKartu(N):-
    \+ beforeDraw(_),       %Kalo semisal pemain sebelumnya mainin kartu draw 2/4, proses mainkanKartu biasa ga dijalanin

    handPile(Hand),         %grab List Nama+Kartu dan List Discard Pile
    discardPile(Discard),

    giliranPemain(Giliran), %grab urutan saat ini

    mainkanKartuHelper(N, Hand, Discard, Giliran),
    
    giliranPemain(NewGiliran),  %grab urutan pemain selanjutnya
    nextPemain(NewGiliran, Hand),
    discardPile(NewDiscard),
    write(NewDiscard), !.



lihatSemuaKartu:-
    discardPile(Discard),
    write(Discard), nl,
    handPile(Hand),
    write(Hand).