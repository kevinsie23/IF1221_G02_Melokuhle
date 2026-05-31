/* Main Command */
mainkanKartu(_) :-
    playedDraw,
    write('Pemain sebelumnya memainkan draw_two! Silahkan ambilKartu'), !.

mainkanKartu(_) :-
    playedDrawFour,
    write('Pemain sebelumnya memainkan wild_draw_four! Silahkan ambilKartu'), !.

mainkanKartu(IdxKartu) :-
    \+ playedDraw,
    \+ playedDrawFour,
    urutanPemain(ListPemain),
    idxGiliran(CurrGiliran),
    getElementAtIndex(ListPemain, CurrGiliran, NamaPemain),
    playCard(NamaPemain, IdxKartu), !.

ambilKartu :-
    playedDraw,
    urutanPemain(ListPemain),
    idxGiliran(CurrGiliran),
    getElementAtIndex(ListPemain, CurrGiliran, NamaPemain),
    giveNCard(NamaPemain, 2),
    retractall(playedDraw),
    retractall(playedDrawFour),
    checkUni(NamaPemain),
    nextGiliran, 
    printGiliran, !. 

ambilKartu :-
    playedDrawFour,
    urutanPemain(ListPemain),
    idxGiliran(CurrGiliran),
    getElementAtIndex(ListPemain, CurrGiliran, NamaPemain),
    giveNCard(NamaPemain, 4),
    retractall(playedDraw),
    retractall(playedDrawFour),
    checkUni(NamaPemain),
    nextGiliran,
    printGiliran, !.   

ambilKartu :-
    \+ playedDraw,
    \+ playedDrawFour,
    urutanPemain(ListPemain),
    idxGiliran(CurrGiliran),
    getElementAtIndex(ListPemain, CurrGiliran, NamaPemain),
    giveNCard(NamaPemain, 1),
    checkUni(NamaPemain),
    nextGiliran, 
    printGiliran, !.


/* Main Rules */
giveNCard(_, 0) :- !.                                   % Base Case
giveNCard(NamaPemain, N) :-
    N > 0,
    checkDrawEmpty(N), 
    infoPemain(NamaPemain, ListKartu),
    drawPile([H | T]),
    retract(drawPile(_)),
    assertz(drawPile(T)),
    appendTail(H, ListKartu, NewListKartu),
    retract(infoPemain(NamaPemain, _)),
    assertz(infoPemain(NamaPemain, NewListKartu)),
    NewN is N - 1,
    giveNCard(NamaPemain, NewN).

playCard(NamaPemain, IdxKartu) :-
    infoPemain(NamaPemain, ListKartu),
    lengthList(ListKartu, LengthKartu),
    IdxKartu > LengthKartu, 
    write('Indeks kartu tidak valid!'), nl, !.

playCard(NamaPemain, IdxKartu) :-                           % Case if kartu is not matched with on the discard
    discardPile([kartu(_, AngkaDiscard) | _]),
    returnCard(NamaPemain, IdxKartu, kartu(Warna, Angka)),
    warnaActive(WarnaActive),
    ((\+ (Warna = WarnaActive ; Angka = AngkaDiscard), 
    Warna \= hitam) ; (Angka = wild, AngkaDiscard = wild)),
    write('Kartu tidak cocok!'), nl, !.

playCard(NamaPemain, IdxKartu) :-
    discardPile([kartu(_, AngkaDiscard) | _]),
    returnCard(NamaPemain, IdxKartu, kartu(Warna, Angka)),
    warnaActive(WarnaActive),
    (Warna = WarnaActive ; Angka = AngkaDiscard ; Warna = hitam),
    useEffect(kartu(Warna, Angka)),   
    infoPemain(NamaPemain, ListKartu),                             
    deleteAtN(IdxKartu, ListKartu, _, NewListKartu),
    discardPile(ListDiscard),
    appendHead(kartu(Warna, Angka), ListDiscard, NewListDiscard),
    retract(infoPemain(NamaPemain, _)),
    assertz(infoPemain(NamaPemain, NewListKartu)),
    retract(discardPile(_)),
    assertz(discardPile(NewListDiscard)),  
    shiftHide(IdxKartu),
    lengthList(NewListKartu, Length),
    checkLength(Length),
    checkEndGame(NewListKartu), !.

/* Helper Rules */

shiftHide(_):-
    urutanPemain(ListPemain),
    idxGiliran(CurrGiliran),
    getElementAtIndex(ListPemain, CurrGiliran, NamaPemain),
    \+ hide(NamaPemain, _), !.
shiftHide(IdxKartu):-
    urutanPemain(ListPemain),
    idxGiliran(CurrGiliran),
    getElementAtIndex(ListPemain, CurrGiliran, NamaPemain),
    hide(NamaPemain, IdxHideKartu),
    IdxKartu < IdxHideKartu, !,
    NewIdxHideKartu is IdxHideKartu - 1,
    retract(hide(NamaPemain, IdxHideKartu)),
    assertz(hide(NamaPemain, NewIdxHideKartu)).
shiftHide(IdxKartu):-
    urutanPemain(ListPemain),
    idxGiliran(CurrGiliran),
    getElementAtIndex(ListPemain, CurrGiliran, NamaPemain),
    hide(NamaPemain, IdxHideKartu),
    IdxKartu =:= IdxHideKartu, !,
    retract(hide(NamaPemain, IdxKartu)).
shiftHide(IdxKartu):-
    urutanPemain(ListPemain),
    idxGiliran(CurrGiliran),
    getElementAtIndex(ListPemain, CurrGiliran, NamaPemain),
    hide(NamaPemain, IdxHideKartu),
    IdxKartu >= IdxHideKartu, !.


checkUni(NamaPemain):-
    uniCalled(NamaPemain), !,
    retract(uniCalled(NamaPemain)).

checkUni(NamaPemain):-
    \+ uniCalled(NamaPemain), !.

returnCard(NamaPemain, IdxKartu, Kartu) :-
    infoPemain(NamaPemain, ListKartu),
    getElementAtIndex(ListKartu, IdxKartu, Kartu).

% useEffect untuk wild card belum diimplementasikan
useEffect(kartu(Warna, Angka)) :-
    \+ (Angka = reverse ; Angka = skip ; Angka = draw_two),
    Warna \= hitam, 
    warnaActive(CurrWarna),
    retractall(prevWarnaActive(_)),
    assertz(prevWarnaActive(CurrWarna)),
    retractall(warnaActive(_)),
    assertz(warnaActive(Warna)), !.

useEffect(kartu(Warna, Angka)) :-                           % useEffect untuk reverse
    Angka = reverse,
    reverseGiliran(ReverseGiliran),
    NewReverseGiliran is ReverseGiliran * -1,
    retract(reverseGiliran(_)),
    assertz(reverseGiliran(NewReverseGiliran)), 
    warnaActive(CurrWarna),
    retractall(prevWarnaActive(_)),
    assertz(prevWarnaActive(CurrWarna)),
    retractall(warnaActive(_)),
    assertz(warnaActive(Warna)), 
    retractall(kartuAksiTerakhir(_)),
    assertz(kartuAksiTerakhir(kartu(Warna, Angka))),
    write('Kartu reverse dimainkan!'), nl, !.

useEffect(kartu(Warna, Angka)) :-                           % useEffect untuk skip
    Angka = skip,
    nextGiliran,
    warnaActive(CurrWarna),
    retractall(prevWarnaActive(_)),
    assertz(prevWarnaActive(CurrWarna)),
    retractall(warnaActive(_)),
    assertz(warnaActive(Warna)),
    retractall(kartuAksiTerakhir(_)),
    assertz(kartuAksiTerakhir(kartu(Warna, Angka))),
    urutanPemain(ListPemain),
    idxGiliran(CurrGiliran),
    getElementAtIndex(ListPemain, CurrGiliran, NamaPemain), 
    write('Kartu skip dimainkan!, Giliran '), write(NamaPemain), write(' diskip'), nl, !.

useEffect(kartu(Warna, Angka)) :-                           % useEffect untuk draw_two
    Angka = draw_two,
    assertz(playedDraw),
    warnaActive(CurrWarna),
    retractall(prevWarnaActive(_)),
    assertz(prevWarnaActive(CurrWarna)),
    retractall(warnaActive(_)),
    assertz(warnaActive(Warna)),
    retractall(kartuAksiTerakhir(_)),
    assertz(kartuAksiTerakhir(kartu(Warna, Angka))), !.

useEffect(kartu(hitam, wild)) :-                        % useEffect untuk kartu wild
    write('Kartu wild dimainkan!'), nl, nl,
    printListWithIndex([merah, kuning, biru, hijau]), nl,
    repeat,
    write('Pilihlah angka sesuai dengan warna pilihanmu: '),
    read(IdxWarna),
    ((IdxWarna > 0, IdxWarna < 5, !) ; 
    ((IdxWarna < 1 ; IdxWarna > 4), write('Input tidak valid!'), nl)),
    getElementAtIndex([merah, kuning, biru, hijau], IdxWarna, Warna),
    warnaActive(CurrWarna),
    retractall(prevWarnaActive(_)),
    assertz(prevWarnaActive(CurrWarna)),
    retractall(warnaActive(_)),
    assertz(warnaActive(Warna)),
    retractall(kartuAksiTerakhir(_)),
    assertz(kartuAksiTerakhir(kartu(hitam, wild))), !.

useEffect(kartu(hitam, wild_draw_four)) :-                        % useEffect untuk kartu wild
    write('Kartu wild_draw_four dimainkan!'), nl, nl,
    printListWithIndex([merah, kuning, biru, hijau]), nl,
    repeat,
    write('Pilihlah angka sesuai dengan warna pilihanmu: '),
    read(IdxWarna),
    ((IdxWarna > 0, IdxWarna < 5, !) ; 
    ((IdxWarna < 1 ; IdxWarna > 4), write('Input tidak valid!'), nl)),
    getElementAtIndex([merah, kuning, biru, hijau], IdxWarna, Warna),
    warnaActive(CurrWarna),
    retractall(prevWarnaActive(_)),
    assertz(prevWarnaActive(CurrWarna)),
    retractall(warnaActive(_)),
    assertz(warnaActive(Warna)),
    retractall(playedDrawFour),
    assertz(playedDrawFour), 
    retractall(kartuAksiTerakhir(_)),
    assertz(kartuAksiTerakhir(kartu(hitam, wild_draw_four))), !.

useEffect(kartu(hitam, mimic)) :-                                           % Jika tidak ada kartu aksi terkahir
    ((\+ kartuAksiTerakhir(_)) ; kartuAksiTerakhir(kartu(tidak, ada))),
    write('Kartu mimic dimainkan!'), nl,
    write('Tidak ada kartu aksi terakhir!'), nl,
    write('Kartu mimic otomatis menyalin kartu wild...'), nl, nl,
    printListWithIndex([merah, kuning, biru, hijau]), nl,
    repeat,
    write('Pilihlah angka sesuai dengan warna pilihanmu: '),
    read(IdxWarna),
    ((IdxWarna > 0, IdxWarna < 5, !) ; 
    ((IdxWarna < 1 ; IdxWarna > 4), write('Input tidak valid!'), nl)),
    getElementAtIndex([merah, kuning, biru, hijau], IdxWarna, Warna),
    warnaActive(CurrWarna),
    retractall(prevWarnaActive(_)),
    assertz(prevWarnaActive(CurrWarna)),
    retractall(warnaActive(_)),
    assertz(warnaActive(Warna)),
    retractall(kartuAksiTerakhir(_)),
    assertz(kartuAksiTerakhir(kartu(hitam, mimic))), !.

useEffect(kartu(hitam, mimic)) :-                                           % Jika kartu aksi terkahir adalah mimic
    kartuAksiTerakhir(kartu(hitam, mimic)),
    write('Kartu mimic dimainkan!'), nl,
    write('Kartu aksi terakhir: hitam-mimic'),
    write('Kartu mimic otomatis menyalin efek kartu wild...'), nl, nl,
    printListWithIndex([merah, kuning, biru, hijau]), nl,
    repeat,
    write('Pilihlah angka sesuai dengan warna pilihanmu: '),
    read(IdxWarna),
    ((IdxWarna > 0, IdxWarna < 5, !) ; 
    ((IdxWarna < 1 ; IdxWarna > 4), write('Input tidak valid!'), nl)),
    getElementAtIndex([merah, kuning, biru, hijau], IdxWarna, Warna),
    warnaActive(CurrWarna),
    retractall(prevWarnaActive(_)),
    assertz(prevWarnaActive(CurrWarna)),
    retractall(warnaActive(_)),
    assertz(warnaActive(Warna)),
    retractall(kartuAksiTerakhir(_)),
    assertz(kartuAksiTerakhir(kartu(hitam, mimic))), !.

useEffect(kartu(hitam, mimic)) :-                                       % Jika kartu aksi terakhir adalah kartu hitam
    kartuAksiTerakhir(kartu(hitam, Angka)),
    write('Kartu mimic dimainkan!'), nl,
    write('menyalin efek kartu '), write(Angka), write('...'), nl, nl,
    useEffect(kartu(hitam, Angka)),
    assertz(kartuAksiTerakhir(kartu(hitam, mimic))), !.

useEffect(kartu(hitam, mimic)) :-                                       % Jika kartu aksi terakhir adalah yang lainnya
    kartuAksiTerakhir(kartu(WarnaAksi, AngkaAksi)),
    WarnaAksi \= hitam,
    write('Kartu mimic dimainkan!'), nl,
    write('menyalin efek kartu '), write(AngkaAksi), write('...'), nl, nl,
    warnaActive(CurrWarna),
    useEffect(kartu(WarnaAksi, AngkaAksi)),
    printListWithIndex([merah, kuning, biru, hijau]), nl,
    repeat,
    write('Pilihlah angka sesuai dengan warna pilihanmu: '),
    read(IdxWarna),
    ((IdxWarna > 0, IdxWarna < 5, !) ; 
    ((IdxWarna < 1 ; IdxWarna > 4), write('Input tidak valid!'), nl)),
    getElementAtIndex([merah, kuning, biru, hijau], IdxWarna, Warna),
    retractall(prevWarnaActive(_)),
    assertz(prevWarnaActive(CurrWarna)),
    retractall(warnaActive(_)),
    assertz(warnaActive(Warna)),
    retractall(kartuAksiTerakhir(_)),
    assertz(kartuAksiTerakhir(kartu(hitam, mimic))), !.

nextGiliran :-
    jumlahPemain(JumlahPemain),
    idxGiliran(Giliran),
    reverseGiliran(GiliranIncrement),
    NewGiliran is ((Giliran + GiliranIncrement - 1) mod JumlahPemain) + 1, 
    retract(idxGiliran(_)),
    assertz(idxGiliran(NewGiliran)), !.

checkDrawEmpty(N) :-                            % Init draw pile jika draw pile kurang
    drawPile(ListDraw),
    lengthList(ListDraw, Length),
    N > Length, initDrawPile, !.
checkDrawEmpty(N) :-
    drawPile(ListDraw),
    lengthList(ListDraw, Length),
    N =< Length, !.

printGiliran :-
    discardPile([kartu(Warna, Angka) | _]),
    urutanPemain(ListPemain),
    idxGiliran(Giliran),
    getElementAtIndex(ListPemain, Giliran, Pemain), nl,
    write('Giliran '), write(Pemain), nl,
    write('Kartu discard top: '), write(Warna-Angka), nl, !.