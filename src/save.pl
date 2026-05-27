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
    printNamaKartu(S, T).

printKartu(S, []):-
    format(S, '].~n', []), !.
printKartu(S, [kartu(Warna, Jenis)]):-
    format(S, '~w-~w].~n', [Warna, Jenis]), !.
printKartu(S, [kartu(Warna, Jenis)|T]):-
    format(S, '~w-~w,', [Warna, Jenis]),
    printKartu(S, T).





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
