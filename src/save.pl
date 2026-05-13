/* ---WRITE URUTAN--- */
writeUrutan(S):-
    urutanPemain(ListPemain),
    format(S, 'urutan_pemain:~w~n', [ListPemain]).





/* ---WRITE GILIRAN--- */
writeGiliran(S):-
    urutanPemain(ListPemain),
    idxGiliran(Giliran),
    grabNamaPemain(ListPemain, Giliran, Nama),
    format(S, 'giliran:~w~n', [Nama]).





/* ---WRITE TOP DISCARD CARD--- */
writeTopDiscard(S):-
    discardPile(DiscardPile),
    topDiscardPile(DiscardPile, kartu(Warna, Jenis)),
    format(S, 'discard_top:~w-~w~n', [Warna, Jenis]).





/* ---WRITE PEMAIN DAN KARTU--- */
writeKartuPemain(S):-
    urutanPemain(ListPemain),
    printNamaKartu(S, ListPemain).

printNamaKartu(_, []):- !.
printNamaKartu(S, [H|T]):-
    infoPemain(H, ListKartu),
    format(S, 'kartu_~w:[', [H]),
    printKartu(S, ListKartu),
    printNamaKartu(S, T).

printKartu(S, []):-
    format(S, ']~n', []), !.
printKartu(S, [kartu(Warna, Jenis)]):-
    format(S, '~w-~w]~n', [Warna, Jenis]), !.
printKartu(S, [kartu(Warna, Jenis)|T]):-
    format(S, '~w-~w,', [Warna, Jenis]),
    printKartu(S, T).





/* ---WRITE ARAH PERMAINAN--- */
writeArahPermainan(S):-
    reverseGiliran(Arah),
    Arah =:= 1, !,
    format(S, 'arah_permainan:kanan~n', []).
writeArahPermainan(S):-
    reverseGiliran(Arah),
    Arah =:= -1, !,
    format(S, 'arah_permainan:kiri~n', []).





/* ---WRITE UNI--- */
writeStatusUni(S):-
    urutanPemain(ListPemain),
    possibleUni(ListPemain, ListUni),
    format(S, 'status_UNI:~w~n', [ListUni]).

possibleUni([], []):- !.
possibleUni([H|T], [H|T2]):-
    uniCalled(H), !,
    possibleUni(T, T2).
possibleUni([H|T], ListUni):-
    \+ uniCalled(H), !,
    possibleUni(T, ListUni).
