/* Main Command */
mainkanKartu(IdxKartu) :-
    urutanPemain(ListPemain),
    idxGiliran(CurrGiliran),
    getElementAtIndex(ListPemain, CurrGiliran, NamaPemain),
    playCard(NamaPemain, IdxKartu).

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
    useEffect(kartu(Warna, Angka)),   
    infoPemain(NamaPemain, ListKartu),                             
    deleteAtN(IdxKartu, ListKartu, _, NewListKartu),
    discardPile(ListDiscard),
    appendHead(kartu(Warna, Angka), ListDiscard, NewListDiscard),
    retract(infoPemain(NamaPemain, _)),
    assertz(infoPemain(NamaPemain, NewListKartu)),
    retract(discardPile(_)),
    assertz(discardPile(NewListDiscard)), 
    nextGiliran, !.

/* Helper Rules */
returnCard(NamaPemain, IdxKartu, Kartu) :-
    infoPemain(NamaPemain, ListKartu),
    getElementAtIndex(ListKartu, IdxKartu, Kartu).

% useEffect untuk draw_two dan wild card belum diimplementasikan
useEffect(kartu(Warna, Angka)) :-
    \+ (Angka = reverse ; Angka = skip),
    Warna \= hitam, !.

useEffect(kartu(_, Angka)) :-                           % useEffect untuk reverse
    Angka = reverse,
    reverseGiliran(ReverseGiliran),
    NewReverseGiliran is ReverseGiliran * -1,
    retract(reverseGiliran(_)),
    assertz(reverseGiliran(NewReverseGiliran)), !.

useEffect(kartu(_, Angka)) :-                           % useEffect untuk skip
    Angka = skip,
    nextGiliran, !.

nextGiliran :-
    jumlahPemain(JumlahPemain),
    idxGiliran(Giliran),
    reverseGiliran(GiliranIncrement),
    NewGiliran is ((Giliran + GiliranIncrement - 1) mod JumlahPemain) + 1, 
    retract(idxGiliran(_)),
    assertz(idxGiliran(NewGiliran)), !.