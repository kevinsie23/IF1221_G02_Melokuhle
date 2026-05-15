/* For Test Case */

discardPile([kartu(merah, 5)]).
drawPile([kartu(merah, 6), kartu(merah, 7), kartu(kuning, reverse), kartu(hijau, skip)]).
infoPemain('Tes1', [kartu(kuning, 1), kartu(kuning, 2)]).
infoPemain('Tes2', [kartu(merah, 2), kartu(merah, 3)]).

/* Main Rules */
giveNCard(_, 0) :- !.                                   % Base Case
giveNCard(NamaPemain, N) :-
    N > 0,
    infoPemain(NamaPemain, ListKartu),
    drawPile([H | T]),
    retract(drawPile(_)),
    assertz(drawPile(T)),
    appendTail(H, ListKartu, NewListKartu),
    retract(infoPemain(NamaPemain, _)),
    assertz(infoPemain(NamaPemain, NewListKartu)),
    NewN is N - 1,
    giveNCard(NamaPemain, NewN).

playCard(NamaPemain, IdxKartu) :-                           % Case if kartu is not matched with on the discard
    discardPile([kartu(WarnaDiscard, AngkaDiscard) | _]),
    returnCard(NamaPemain, IdxKartu, kartu(Warna, Angka)),
    \+ (Warna = WarnaDiscard ; Angka = AngkaDiscard), 
    Warna \= hitam,
    write('Kartu tidak cocok!'), !.

playCard(NamaPemain, IdxKartu) :-
    discardPile([kartu(WarnaDiscard, AngkaDiscard) | _]),
    returnCard(NamaPemain, IdxKartu, kartu(Warna, Angka)),
    (Warna = WarnaDiscard ; Angka = AngkaDiscard),
/*    useEffect(kartu(Warna, Angka)),   Belum dipakai */
    infoPemain(NamaPemain, ListKartu),                             
    deleteAtN(IdxKartu, ListKartu, _, NewListKartu),
    discardPile(ListDiscard),
    appendHead(kartu(Warna, Angka), ListDiscard, NewListDiscard),
    retract(infoPemain(NamaPemain, _)),
    assertz(infoPemain(NamaPemain, NewListKartu)),
    retract(discardPile(_)),
    assertz(discardPile(NewListDiscard)), !.

/* Helper Rules */
returnCard(NamaPemain, IdxKartu, Kartu) :-
    infoPemain(NamaPemain, ListKartu),
    getElementAtIndex(ListKartu, IdxKartu, Kartu).