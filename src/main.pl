:- include('dynamic.pl').
:- include('save.pl').
:- include('load.pl').
:- include('state.pl').
:- include('kartu.pl').
:- include('util.pl').

urutanPemain([]). % Inisialisasi List Urutan Pemain
startedGame(0).
startGame:- 
    \+ startedGame(1), 
    retract(startedGame(0)), 
    assertz(startedGame(1)), !,
    write('Masukkan jumlah pemain: '), read(Num), nl,
    checkPlayerCount(Num), assertz(jumlahPemain(Num)),
    inputName(Num),
    randomiseOrder, 
    printOrder,
    % Membentuk drawpile
    initDrawPile, 
    % Membagikan kartu
    giveCards, 
    initDiscardPile,
    discardPile([kartu(Warna, Jenis)|_]),
    write('Kartu discard top: '), format('~w-~w', [Warna,Jenis]), write('.'), nl, nl,
    assertz(warnaActive(Warna)),
    assertz(idxGiliran(1)),
    assertz(reverseGiliran(1)),
    urutanPemain([Pemain1|_]),
    write('Giliran '), write(Pemain1), write('.'). 


startGame:- startedGame(1), !, write('Game sudah dimulai').

checkPlayerCount(X):- X>=2, X=< 4, !.
checkPlayerCount(_):- write('Mohon masukkan angka antara 2-4.'), nl, startGame.

inputName(PlayerNumber):- inputNameHelper(PlayerNumber,1).

% Base Case
inputNameHelper(0,_):- !.
% Case Sucess
inputNameHelper(X,Count):- 
    X>0,
    write('Masukkan Name pemain '), write(Count), write(': '),
    read(Name),
    urutanPemain(List),
    \+ isMember(Name, List), !,  % Cek apakah Name ada di List urutan pemain
    retract(urutanPemain(List)),
    assertz(urutanPemain([Name|List])), % Append Name ke List Urutan Pemain
    assertz(infoPemain(Name, [])), % Inisialisasi Info Pemain dgn Name valid dan list kartu kosong
    NextX is X-1, NextCount is Count+1,
    inputNameHelper(NextX, NextCount).
% Case Fail
inputNameHelper(X,Count):- 
    X>0,
    write('Name sudah digunakan. Masukkan Name lain:  '), 
    retryInput(X,Count).

% retryInput Sucess
retryInput(X, Count):-
    read(Name),
    urutanPemain(List),
    \+ isMember(Name, List), !,
    retract(urutanPemain(List)),
    assertz(urutanPemain([Name|List])), % Append Name ke List Urutan Pemain
    assertz(infoPemain(Name, [])), % Inisialisasi Info Pemain dgn Name valid dan list kartu kosong
    NextX is X-1, NextCount is Count+1,
    inputNameHelper(NextX, NextCount).
% retryInput Fail
retryInput(X, Count):-     
    write('Name sudah digunakan. Masukkan Name lain:  '), 
    retryInput(X, Count).

randomiseOrder:- 
    retract(urutanPemain(CurrentList)), !,
    shuffleOrder(CurrentList, RandomList),
    assertz(urutanPemain(RandomList)).

shuffleOrder([],[]):- !.
shuffleOrder(OldList, [H|T]):-
    lengthList(OldList, L),
    Top is L+1,
    random(1,Top, RandomIdx),
    deleteAtN(RandomIdx, OldList, H, Rest),
    shuffleOrder(Rest, T), !.

printOrder:- 
    nl, urutanPemain([H|T]),
    write('Urutan pemain: '), write(H),
    printRest(T).

printRest([]):- nl, nl, !.
printRest([H|T]):- write(' - '), write(H), printRest(T).
    
initDrawPile:- 
    open('kartu.txt', read, Stream),
    initDrawPileHelper(Stream, []),
    close(Stream).
initDrawPileHelper(Stream, ListKartu):- 
    at_end_of_stream(Stream), !, 
    retractall(drawPile(_)),
    assertz(drawPile(ListKartu)).

initDrawPileHelper(Stream, List):-
    \+ at_end_of_stream(Stream), !,
    read(Stream, X),
    appendTail(X, List, ListKartu),
    initDrawPileHelper(Stream, ListKartu).

giveCards:- 
    write('Setiap pemain mendapatkan 7 kartu acak.'), nl, nl,
    urutanPemain(List),
    giveCardsHelper(List).

giveCardsHelper([]):- !.
giveCardsHelper([H|T]):-
    drawPile(DrawList),

    takeSeven(DrawList, SevenCards, DrawList1),
    
    retract(infoPemain(H,_)),
    assertz(infoPemain(H,SevenCards)),

    retract(drawPile(_)),
    assertz(drawPile(DrawList1)), 
    
    giveCardsHelper(T), !.

takeSeven(DrawList, SevenCards, DrawList1):- takeN(7, DrawList, SevenCards, DrawList1), !.
takeN(0, Deck, [], Deck):- !. %Base Case: Sudah diambil 7 kartu
takeN(N, Deck, [SelectedCard|RestHand], RemainingDeck):-
    N>0, !,
    lengthList(Deck, L),
    Top is L+1,
    random(1,Top,Idx),
    deleteAtN(Idx, Deck, SelectedCard, TempDeck),
    NextN is N - 1,
    takeN(NextN, TempDeck, RestHand, RemainingDeck), !.

initDiscardPile:- 
    drawPile(DrawList),
    discardPileTop(DrawList, Card, NewDrawList),
    assertz(discardPile(Card)),
        retract(drawPile(_)),
        assertz(drawPile(NewDrawList)), !.

discardPileTop(DrawList, Card, NewDrawList):- 
    takeN(1, DrawList, Card, NewDrawList), checkDiscard(Card), !.

discardPileTop(DrawList, Card, OutputDrawList):- 
    takeN(1, DrawList, InvalidCard, NewDrawList), 
    \+ checkDiscard(InvalidCard), !, 
    appendTail(NewDrawList, InvalidCard, FinalDrawList),
    discardPileTop(FinalDrawList, Card, OutputDrawList).



checkDiscard(kartu(_, Jenis)):- 
    \+ isMember(Jenis, [wild, wild_draw_four, skip, reverse, draw_two, mimic]), !.
