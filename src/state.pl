:- dynamic(discardPile/1).
:- dynamic(urutanPemain/1).
:- dynamic(reverseGiliran/1).
:- dynamic(infoPemain/2).
:- dynamic(idxGiliran/1).

:- dynamic(playedDraw/0).
:- dynamic(playedDrawFour/0).
:- dynamic(uniCalled/0).

start:-
    retractall(discardPile(_)),
    retractall(urutanPemain(_)),
    retractall(reverseGiliran(_)),
    asserta(discardPile([kartu(merah, 7), kartu(biru, 2), kartu(kuning, skip)])),
    asserta(urutanPemain(['Najib', 'Kevin', 'Wimar'])),
    asserta(reverseGiliran(1)),
    asserta(infoPemain('Najib', [kartu(merah, 4), kartu(hitam, wild_card)])),
    asserta(infoPemain('Kevin', [kartu(hijau, reverse), kartu(biru, 9), kartu(merah, draw_two), kartu(kuning, 4)])),
    asserta(infoPemain('Wimar', [kartu(biru, skip)])),
    asserta(uniCalled),
    asserta(idxGiliran(2)).


lihatKartu:-
    write('Berikut kartu yang anda miliki: '), nl,
    urutanPemain(UrutanPemain),
    idxGiliran(Giliran),
    grabPlayer(UrutanPemain, Giliran, Nama),
    infoPemain(Nama, ListKartu),    
    printKartu(ListKartu, 1).


printKartu([], _), !.
printKartu([H|T], No):-
    parseCard(H, Warna, Jenis),
    format('~w. ~w-~w', [No, Warna, Jenis]), nl,
    NextNo is No + 1,
    printKartu(T, NextNo).
















lihatCommand:-
    write('Aksi utama yang tersedia:'), nl,
    printAksiUtama(1),
    nl,
    write('Aksi pendukung yang tersedia:'), nl,
    printAksiPendukung,
    nl.


printAksiUtama(No):-
    printMainkanKartu(No, No1),
    printAmbilKartu(No1, No2),
    printTantang(No2, No3),
    printUni(No3, No4),
    printTangkap(No4, _).

printMainkanKartu(CurNo, NextNo):-
    \+ playedDraw,
    format('~w. mainkanKartu', [CurNo]), nl, !,
    NextNo is CurNo + 1.
printMainkanKartu(CurNo, NextNo):-
    playedDraw, !,
    NextNo is CurNo.

printAmbilKartu(CurNo, NextNo):-
    format('~w. ambilKartu', [CurNo]), nl,
    NextNo is CurNo + 1.

printTantang(CurNo, NextNo):-
    playedDrawFour,
    format('~w. tantang', [CurNo]), nl, !,
    NextNo is CurNo + 1.
printTantang(CurNo, NextNo):-
    \+ playedDrawFour, !,
    NextNo is CurNo.

printUni(CurNo, NextNo):-
    checkUni(Length),
    Length =:= 1,
    format('~w. uni', [CurNo]), nl, !,
    NextNo is CurNo + 1.
printUni(CurNo, NextNo):-
    checkUni(Length),
    Length > 1, !,
    NextNo is CurNo.

printTangkap(CurNo, NextNo):-
    uniCalled,
    format('~w. tangkap', [CurNo]), nl, !,
    NextNo is CurNo + 1.
printTangkap(CurNo, NextNo):-
    \+ uniCalled, !,
    NextNo is CurNo.

checkUni(Length):-
    urutanPemain(UrutanPemain),
    idxGiliran(Giliran),
    grabPlayer(UrutanPemain, Giliran, Nama),
    infoPemain(Nama, ListKartu),
    lengthList(ListKartu, Length).

grabPlayer([H|_], 1, H).
grabPlayer([_|T], Giliran, Nama):-
    NextGiliran is Giliran - 1,
    grabPlayer(T, NextGiliran, Nama).



printAksiPendukung:-
    write('1. lihatCommand'), nl,
    write('2. lihatKartu'), nl,
    write('3. cekInfo'), nl.


















/* -----CEK INFO----- */
cekInfo:-
    printTopDiscardCard,
    nl, nl,
    printUrutanPemain,
    nl, nl,
    printInfoPemain.



/* ---Helper Predikat: Print Urutan Nama dan Jumlah Kartu---*/
printInfoPemain:-
    urutanPemain(UrutanPemain),
    reverseGiliran(Arah),
    printNamaKartu(UrutanPemain, 1, Arah).

printNamaKartu([H], NoUrut, Arah):-
    Arah =:= 1,
    infoPemain(H, ListKartu),
    lengthList(ListKartu, Length),
    format('Nama pemain ~w: ~w', [NoUrut, H]),
    nl,
    format('Jumlah kartu: ~w', [Length]),
    nl, nl, !.
printNamaKartu([H|T], NoUrut, Arah):-
    Arah =:= 1,
    infoPemain(H, ListKartu),
    lengthList(ListKartu, Length),
    format('Nama pemain ~w: ~w', [NoUrut, H]),
    nl,
    format('Jumlah kartu: ~w', [Length]),
    nl, nl,
    NewNoUrut is NoUrut + 1,
    printNamaKartu(T, NewNoUrut, Arah), !.
printNamaKartu([H], NoUrut, Arah):-
    Arah =:= -1,
    infoPemain(H, ListKartu),
    lengthList(ListKartu, Length),
    urutanPemain(UrutanPemain),
    lengthList(UrutanPemain, MaxNoUrut),
    CurNoUrut is MaxNoUrut - NoUrut + 1,
    format('Nama pemain ~w: ~w', [CurNoUrut, H]),
    nl,
    format('Jumlah kartu: ~w', [Length]),
    nl, nl, !.
printNamaKartu([H|T], NoUrut, Arah):-
    Arah =:= -1,
    NewNoUrut is NoUrut + 1,
    printNamaKartu(T, NewNoUrut, Arah),
    infoPemain(H, ListKartu),
    lengthList(ListKartu, Length),
    urutanPemain(UrutanPemain),
    lengthList(UrutanPemain, MaxNoUrut),
    CurNoUrut is MaxNoUrut - NoUrut + 1,
    format('Nama pemain ~w: ~w', [CurNoUrut, H]),
    nl,
    format('Jumlah kartu: ~w', [Length]),
    nl, nl, !.

lengthList([], 0).              %Util.pl
lengthList([_|T], Count):-      %Util.pl
    lengthList(T, NewCount),
    Count is NewCount + 1.



/* ---Helper Predikat: Print Kartu Discard Pile Paling Atas--- */
printTopDiscardCard:-
    discardPile(DiscardPile),
    write('Kartu discard top: '),
    topDiscardPile(DiscardPile, TopDiscardCard),
    parseCard(TopDiscardCard, Warna, Jenis),
    format('~w-~w.', [Warna, Jenis]).

topDiscardPile([H|_], H).
parseCard(kartu(Warna, Jenis), Warna, Jenis).       %Util.pl



/* ---Helper Predikat: Print Urutan Pemain--- */
printUrutanPemain:-
    urutanPemain(UrutanPemain),
    reverseGiliran(Arah),
    write('Urutan pemain: '),
    printNamaUrutan(UrutanPemain, Arah),
    write('.').

printNamaUrutan([H], _):-
    format('~w', [H]).
printNamaUrutan([H|T], Arah):-
    Arah =:= 1,
    format('~w - ', [H]),
    printNamaUrutan(T, Arah), !.
printNamaUrutan([H|T], Arah):-
    Arah =:= -1,
    printNamaUrutan(T, Arah),
    format(' - ~w', [H]), !.
















