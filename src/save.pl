/* ---WRITE URUTAN--- */
writeUrutan(S):-
    urutanPemain(ListPemain),
    format(S, 'urutan_pemain:[', []),
    writePemain(S, ListPemain).


writePemain(S, []):-
    format(S, '].~n', []), !.
writePemain(S, [H]):-
    format(S, '\'~w\'].~n', [H]), !.
writePemain(S, [H|T]):-
    format(S, '\'~w\',', [H]),
    writePemain(S, T).

/* --- Save Konfigurasi Turnamen */
writeTournament(S):-
    gameType(X), X =:= 2, !,
    urutanPemain(ListPemain),
    getElementAtIndex(ListPemain, 1, P1),
    getTeamate(P1,P2),
    getElementAtIndex(ListPemain,3,P3),
    getTeamate(P3,P4),
    format(S, 'mode:turnamen.~n',[]),
    format(S, 'tim1:[~q,~q]~n',[P1,P2]),
    format(S, 'tim2:[~q,~q]~n',[P3,P4]).
writeTournament(_):- !.

/* ---WRITE GILIRAN--- */
writeGiliran(S):-
    urutanPemain(ListPemain),
    idxGiliran(Giliran),
    grabNamaPemain(ListPemain, Giliran, Nama),
    format(S, 'giliran:\'~w\'.~n', [Nama]).





/* ---WRITE TOP DISCARD CARD--- */
writeTopDiscard(S):-
    discardPile(DiscardPile),
    topDiscardPile(DiscardPile, kartu(Warna, Jenis)),
    format(S, 'discard_top:~w-~w.~n', [Warna, Jenis]).





/* ---WRITE WARNA AKTIF--- */
writeWarnaAktif(S):-
    warnaActive(Warna),
    format(S, 'warna_aktif:~w.~n', [Warna]).





/* ---WRITE PEMAIN DAN KARTU--- */
writeKartuPemain(S):-
    urutanPemain(ListPemain),
    printNamaKartu(S, ListPemain).

printNamaKartu(_, []):- !.
printNamaKartu(S, [H|T]):-
    infoPemain(H, ListKartu),
    format(S, 'kartu(\'~w\'):[', [H]),
    printKartu(S, ListKartu),
    printKartuHide(S, H),
    printNamaKartu(S, T).

printKartu(S, []):-
    format(S, '].~n', []), !.
printKartu(S, [kartu(Warna, Jenis)]):-
    format(S, '~w-~w].~n', [Warna, Jenis]), !.
printKartu(S, [kartu(Warna, Jenis)|T]):-
    format(S, '~w-~w,', [Warna, Jenis]),
    printKartu(S, T).


printKartuHide(S, H):-
    hide(H, IdxKartu),
    format(S, 'index_kartu_tersembunyi(\'~w\'):~w.~n', [H, IdxKartu]), !.
printKartuHide(S, H):-
    \+ hide(H, _), 
    format(S, 'index_kartu_tersembunyi(\'~w\'):0.~n', [H]), !.




/* ---WRITE ARAH PERMAINAN--- */
writeArahPermainan(S):-
    reverseGiliran(Arah),
    Arah =:= 1, !,
    format(S, 'arah_permainan:kanan.~n', []).
writeArahPermainan(S):-
    reverseGiliran(Arah),
    Arah =:= -1, !,
    format(S, 'arah_permainan:kiri.~n', []).





/* ---WRITE UNI--- */
writeStatusUni(S):-
    urutanPemain(ListPemain),
    possibleUni(ListPemain, ListUni),
    format(S, 'status_UNI:[', []),
    writePemain(S, ListUni).

possibleUni([], []):- !.
possibleUni([H|T], [H|T2]):-
    uniCalled(H), !,
    possibleUni(T, T2).
possibleUni([H|T], ListUni):-
    \+ uniCalled(H), !,
    possibleUni(T, ListUni).



/* ---WRITE KARTU AKSI TERAKHIR--- */
writeKartuAksi(S):-
    kartuAksiTerakhir(kartu(Warna, Jenis)),
    format(S, 'kartu_aksi_terakhir:~w-~w.~n', [Warna, Jenis]).
