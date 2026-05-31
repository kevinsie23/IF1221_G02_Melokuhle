:- include('dynamic.pl').
:- include('save.pl').
:- include('load.pl').
:- include('state.pl').
:- include('kartu.pl').
:- include('util.pl').
:- include('pemain.pl').
startedGame(0).
startGame:- startedGame(1), !, write('Game sudah dimulai').
startGame:- 
    write('Tersedia 2 mode permainan.'), nl,
    write('1. Mode Klasik'), nl,
    write('2. Mode Turnamen'), nl,
    inputMode(X),
    assertz(gameType(X)),
    startMode(X), !.

modeValid(1).
modeValid(2).
inputMode(X):- 
    write('Pilih mode permainan: '),
    read(Input),
    modeValid(Input), !, X = Input.
inputMode(X):- 
    write('Input hanya bisa 1 atau 2. Masukkan kembali input yang valid.'), nl,
    inputMode(X).

% Mode Klasik
startMode(1):-
    \+ startedGame(1),!,
    assertz(urutanPemain([])),
    getPlayerCount(Num),
    assertz(jumlahPemain(Num)),
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
    write('Giliran '), write(Pemain1), write('.'),
    retract(startedGame(0)), 
    assertz(startedGame(1)), !. 

%Mode Turnamen
startMode(2):- 
    \+ startedGame(1),!,
    assertz(urutanPemain([])),
    assertz(jumlahPemain(4)),
    inputName(4),
    % bentukTim
    formTeam,
    write('Membentuk tim secara acak ...'), nl, nl,
    % PrintTeam
    printTeam, nl,
    % Penentuan Urutan
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
    write('Giliran '), write(Pemain1), write('.'),
    retract(startedGame(0)), 
    assertz(startedGame(1)), !. 

findOther(Player, [H|_], H):-
    Player \= H, !.

findOther(Player, [_|T],Teamate):-
    findOther(Player,T,Teamate), !.

getTeamate(Player,Teamate):-
    team(_, List),
    isMember(Player,List),
    findOther(Player,List,Teamate), !.

splitList([First,Second|Rest], [First,Second], Rest).
formTeam:- 
    randomiseOrder,
    urutanPemain(List),
    splitList(List, [P1|[P2]], [P3|[P4]]),
    assertz(team(1,[P1,P3])),
    assertz(team(2,[P2,P4])), !.

printTeam:-
    team(1,[P1|[P2]]),
    team(2,[P3|[P4]]),
    format('Tim ~d: ~w,~w.~n', [1,P1,P2]), 
    format('Tim ~d: ~w,~w.~n',[2,P3,P4]), !.

% Predikat untuk check apakah list kartu pemain setelah memainkan kartu kosong dan 
checkEndGame([]):- gameType(X), endGame(X), !.
checkEndGame(_):- nextGiliran, printGiliran, !.

% End Game Klasik
endGame(1):- 
    idxGiliran(X),
    urutanPemain(ListPemain),
    getElementAtIndex(ListPemain, X, Winner),
    write('Permainan Selesai! '), write(Winner), write(' menghabiskan semua kartunya! '),
    write('Berikut perhitungan poin sisa kartu'), nl, 
    printPoin(1), nl, nl,
    printRanking, 
    format('Selamat, ~w menjadi pemenang', [Winner]),
    retractall(startedGame(_)),
    assertz(startedGame(0)), 
    retractall(jumlahPemain(_)),
    retractall(urutanPemain(_)),
    retractall(infoPemain(_,_)),
    retractall(idxGiliran(_)),
    retractall(reverseGiliran(_)),
    retractall(discardPile(_)),
    retractall(drawPile(_)),
    retractall(playedDraw),
    retractall(playedDrawFour),
    retractall(uniCalled(_)),
    retractall(warnaActive(_)),
    retractall(prevWarnaActive(_)),
    retractall(kartuAksiTerakhir(_)), !.

endGame(2):- 
    idxGiliran(X),
    urutanPemain(ListPemain),
    getElementAtIndex(ListPemain, X, P1),
    write('Permainan Selesai! '), write(P1), write(' menghabiskan semua kartunya! '),
    write('Berikut perhitungan poin sisa kartu'), nl, 
    printPoin(1), nl, nl,
    write('Berikut perhitungan poin untuk masing-masing team'), nl,
    % Perhitungan Tim 1
    getTeamate(P1,P2),
    infoPemain(P1, Poin1),
    infoPemain(P2, Poin2),
    Total1 is Poin1+Poin2,
    format('Tim 1 (~w,~w): ~d + ~d = ~d poin~n', [P1,P2,Poin1,Poin2,Total1]),
    % Perhitungan Tim 2
    Temp is X+1,
    getElementAtIndex(ListPemain, Temp, P3),
    getTeamate(P3,P4),
    infoPemain(P3, Poin3),
    infoPemain(P4, Poin4),
    Total2 is Poin3+Poin4,
    format('Tim 1 (~w,~w): ~d + ~d = ~d poin', [P3,P4,Poin3,Poin4,Total2]),
    printWinner(Total1, Total2), !.

printWinner(Total1, Total2):- 
    Total1 > Total2, !,
    write('Selamat, Tim 2 menjadi pemenang!'), !.
printWinner(Total1, Total2):- 
    Total1 < Total2, !,
    write('Selamat, Tim 1 menjadi pemenang!'), !.
printWinner(Total1, Total2):- 
    Total1 =:= Total2, !,
    write('Game berakhir dalam seri!'), !.

printPoin(IdxPlayer):- 
    jumlahPemain(X), IdxPlayer =< X, !,
    urutanPemain(ListPemain),
    getElementAtIndex(ListPemain, IdxPlayer, Name),
    infoPemain(Name, ListKartu),
    hitungPoinHelper(ListKartu, Poin),
    printPoinHelper(Name, ListKartu, Poin),
    retractall(infoPemain(Name, _)), 
    assertz(infoPemain(Name,Poin)),
    Idx is IdxPlayer+1,
    printPoin(Idx).
printPoin(_):- !.

printPoinHelper(Name, ListKartu, Poin):- 
    write(Name), write(':'),
    printJumlahKartu(ListKartu, Poin).

printJumlahKartu([], _):- !, write(' kartu habis = 0 poin'), nl.
printJumlahKartu([kartu(Warna,Jenis)|T], Poin):- 
    format(' ~w-~w ', [Warna,Jenis]), printJumlahKartuHelper(T),
    write(' = '), printJumlahPoin([kartu(Warna,Jenis)|T]), write('= '), write(Poin), write(' poin'), nl.

printJumlahKartuHelper([]):- !.
printJumlahKartuHelper([kartu(Warna,Jenis)|T]):- 
    format('+ ~w-~w ', [Warna,Jenis]), 
    printJumlahKartuHelper(T), !.

printJumlahPoin([H|T]):- 
    poinKartu(H,Poin), format(' ~d ', [Poin]), 
    printJumlahPoinHelper(T).

printJumlahPoinHelper([]):- !.
printJumlahPoinHelper([H|T]):- 
    poinKartu(H,Poin), format('+ ~d ', [Poin]), 
    printJumlahPoinHelper(T), !.

hitungPoinHelper([], 0):- !. 
hitungPoinHelper(ListKartu, Poin):-
    deleteAtN(1, ListKartu, Kartu, NewListKartu), poinKartu(Kartu, PoinKartu), 
    hitungPoinHelper(NewListKartu, PoinNext),
    Poin is PoinKartu + PoinNext.
    
% Predikat menentukan poin sebuah kartu
poinKartu(kartu(hitam,_), 20):- !.
poinKartu(kartu(_,Jenis), 10):- isMember(Jenis, [reverse, skip, draw_two]), !.
poinKartu(kartu(_,Angka), Angka):- !.

printRanking:- 
    urutanPemain(ListPemain),
    insertSort(ListPemain, Ranked),
    write('Urutan Pemenang:'), nl,
    printRankingHelper(Ranked, 1).

printRankingHelper([],_):- !.
printRankingHelper(_,Count):- jumlahPemain(X), Count > X, !.
printRankingHelper([H|T], Count):- 
    jumlahPemain(X),
    Count =< X, !,
    infoPemain(H, Poin),
    format('~d. ~w (~d poin)~n',[Count, H, Poin]),
    NewCount is Count+1,
    printRankingHelper(T, NewCount).

insertSort([],[]):- !.
insertSort([H|T], Sorted) :- 
    insertSort(T, SortedTail),
    insert(H, SortedTail, Sorted).

insert(X,[],[X]).
insert(X, [H|T], [X, H|T]) :- infoPemain(X,PoinX), infoPemain(H, PoinH), PoinX =< PoinH, !.
insert(X, [H|T], [H|Result]):- infoPemain(X,PoinX), infoPemain(H, PoinH), PoinX > PoinH, !, insert(X, T, Result).


getPlayerCount(Num):- 
    write('Masukkan jumlah pemain: '), 
    read(Input), nl,
    checkPlayerCount(Input, Num).

checkPlayerCount(2,2):- !.
checkPlayerCount(3,3):- !.
checkPlayerCount(4,4):- !.
checkPlayerCount(_,Num):- write('Mohon masukkan angka antara 2-4.'), nl, getPlayerCount(Num).

inputName(PlayerNumber):- inputNameHelper(PlayerNumber,1).

% Fail Case
checkUpperCase(Name):- atom_codes(Name, [First|_]), First < 65, !, fail.
checkUpperCase(Name):- atom_codes(Name, [First|_]), First > 90, !, fail.
% Success
checkUpperCase(Input) :- atom_codes(Input, _).
% Base Case
inputNameHelper(0,_):- !.
% Case Sucess
inputNameHelper(X,Count):- 
    X>0,
    write('Masukkan Nama pemain '), write(Count), write(': '),
    read(Name),
    urutanPemain(List),
    \+ isMember(Name, List), % Cek apakah Name ada di List urutan pemain
    checkUpperCase(Name), !, % Cek apakah dimulai huruf kapital
    retract(urutanPemain(List)),
    assertz(urutanPemain([Name|List])), % Append Name ke List Urutan Pemain
    assertz(infoPemain(Name, [])), % Inisialisasi Info Pemain dgn Name valid dan list kartu kosong
    NextX is X-1, NextCount is Count+1,
    inputNameHelper(NextX, NextCount).
% Case Fail
inputNameHelper(X,Count):- 
    X>0,
    write('Nama sudah digunakan atau Nama tidak dimulai huruf kapital. Masukkan Nama lain: '), 
    retryInput(X,Count).

% retryInput Sucess
retryInput(X, Count):-
    read(Name),
    urutanPemain(List),
    \+ isMember(Name, List), 
    checkUpperCase(Name), !,
    retract(urutanPemain(List)),
    assertz(urutanPemain([Name|List])), % Append Name ke List Urutan Pemain
    assertz(infoPemain(Name, [])), % Inisialisasi Info Pemain dgn Name valid dan list kartu kosong
    NextX is X-1, NextCount is Count+1,
    inputNameHelper(NextX, NextCount).
% retryInput Fail
retryInput(X, Count):-     
    write('Nama sudah digunakan atau Nama tidak dimulai huruf kapital. Masukkan Nama lain:  '), 
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

discardPileTop(DrawList, [Card], OutputDrawList):- 
    takeN(1, DrawList, [DrawnCard], TempDrawList), 
    validateTop(DrawnCard, TempDrawList, Card, OutputDrawList).

validateTop(DrawnCard, TempDrawList, DrawnCard, TempDrawList):-
    checkDiscard(DrawnCard), !.
validateTop(DrawnCard, TempDeck, Card, OutputDrawList):-
    \+ checkDiscard(DrawnCard), !,
    appendTail(DrawnCard, TempDeck, UpdatedDeck),
    discardPileTop(UpdatedDeck, [Card], OutputDrawList).

checkDiscard(kartu(_, Jenis)):- 
    \+ isMember(Jenis, [wild, wild_draw_four, skip, reverse, draw_two, mimic]), !.
