/* Main Command */
lihatCommand :- 
    write('Aksi utama yang tersedia:'), nl, write('1. ambilKartu.'), nl, nl,
    write('Aksi pendukung yang tersedia:'), nl,
    write('1. lihatCommand.'), nl, write('2. lihatKartu.'), nl, 
    write('3. cekInfo.'), nl.

lihatKartu :-
    handPile(Hand),
    giliranPemain(Giliran),
    getElementAtIndex(Hand, Giliran, NamaDanKartu),
    tail(NamaDanKartu, Kartu),
    printListBernomor(Kartu).

cekInfo :-
    discardPile(Discard),
    head(Discard, DiscardTop),
    write('Kartu discard top: '), write(DiscardTop), nl, nl,
    handPile(Hand),
    printJumlahKartuPemain(Hand).

/* Main Helper Rules */
printJumlahKartuPemain(Hand) :-                           % Fungsi untuk dipakai di cekInfo
    printJumlahKartuPemainHelper(Hand, 1).

printJumlahKartuPemainHelper(Hand, CurrentIndex) :-
    lengthList(Hand, LengthPemain),
    CurrentIndex > LengthPemain, !.

printJumlahKartuPemainHelper(Hand, CurrentIndex) :-
    lengthList(Hand, LengthPemain),
    CurrentIndex =< LengthPemain, 
    getElementAtIndex(Hand, CurrentIndex, NamaDanKartu),
    head(NamaDanKartu, NamaPemain),
    tail(NamaDanKartu, Kartu),
    write('Nama pemain '), write(CurrentIndex), write(': '), write(NamaPemain), nl,
    lengthList(Kartu, BanyakKartu),
    write('Jumlah kartu: '), write(BanyakKartu), nl, nl,
    NextIndex is CurrentIndex + 1,
    printJumlahKartuPemainHelper(Hand, NextIndex).

/* Helper Rules */
head([H | _], H).
tail([_ | T], T).

getElementAtIndex([H | _], 1, H) :- !.              % Untuk mengambil kartu sesuai dengan gilirannya.

getElementAtIndex([_ | T], Index, Element) :-
    Index > 1,
    NextIndex is Index - 1,
    getElementAtIndex(T, NextIndex, Element).

/* 
    Untuk print list dengan format:
    1. namaEl
    2. namaEl
    3. dst

    digunakan di lihatKartu
*/
printListBernomor(List) :-                         
    printListBernomorHelper(List, 1).

printListBernomorHelper([], _) :- !.
printListBernomorHelper(List, StartIndex) :-
    List \== [],
    head(List, Element),
    write(StartIndex), write('. '), write(Element), nl,
    NextIndex is StartIndex + 1,
    tail(List, NextList),
    printListBernomorHelper(NextList, NextIndex).
