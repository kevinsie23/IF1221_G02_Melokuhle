/* ---Helper Predikat: Buang part awal yang bukan data--- */
skipTeksAwal(S):-
    get_code(S, Char),
    cekChar(S, Char).

cekChar(_, 58):- !.
cekChar(S, Char):-
    Char \= -1,
    skipTeksAwal(S).



/* ---LOAD URUTAN--- */
loadUrutan(S):-
    skipTeksAwal(S),
    get_code(S, 91),
    readAllNames(S, ListPemain),
    lengthList(ListPemain, Length),
    asserta(jumlahPemain(Length)),
    asserta(urutanPemain(ListPemain)).

readAllNames(S, []):- 
    peek_code(S, 93), !.
readAllNames(S, [Nama|T]):-
    readWord(S, CharNama),
    removePetik(CharNama, NoPetikCharNama),
    atom_codes(Nama, NoPetikCharNama),
    get_code(S, Char),
    skipChar(S, Char, T).

readWord(S, [Char|T]):-
    \+ peek_code(S, 46),
    \+ peek_code(S, 44),
    \+ peek_code(S, 93), 
    \+ peek_code(S, 10), 
    \+ peek_code(S, 45), !,
    get_code(S, Char),
    readWord(S, T).
readWord(_, []).

removePetik([], []).
removePetik([H|T], NoPetikCharNama):-
    H =:= 39, !,
    removePetik(T, NoPetikCharNama).
removePetik([H|T], [H|T2]):-
    H =\= 39, !,
    removePetik(T, T2).

skipChar(_, 93, []):- !.
skipChar(S, 44, T):-
    readAllNames(S, T).





/* ----LOAD GILIRAN--- */
loadGiliran(S):-
    skipTeksAwal(S),
    readWord(S, CharNama),
    removePetik(CharNama, NoPetikCharNama),
    atom_codes(Nama, NoPetikCharNama),
    urutanPemain(ListPemain),
    findGiliran(Nama, ListPemain, 1, Giliran),
    asserta(idxGiliran(Giliran)).

findGiliran(H, [H|_], Cur, Cur):- !.
findGiliran(Nama, [_|T], Cur, Giliran):-
    NextCur is Cur + 1,
    findGiliran(Nama, T, NextCur, Giliran).





/* ---LOAD TOP DISCARD--- */
loadTopDiscard(S):-
    skipTeksAwal(S),
    readCard(S, Warna, Jenis),
    asserta(discardPile([kartu(Warna, Jenis)])).
    
readCard(S, Warna, Jenis):-
    readWord(S, CharWarna),
    atom_codes(Warna, CharWarna),
    get_code(S, _),
    readWord(S, CharJenis),
    atom_codes(Jenis, CharJenis).




/* ---LOAD WARNA AKTIF--- */
loadWarnaAktif(S):-
    skipTeksAwal(S),    
    readWord(S, CharWarna),
    atom_codes(Warna, CharWarna),
    asserta(warnaActive(Warna)).




/* ---LOAD KARTU PEMAIN--- */
loadKartuPemain(S):-
    urutanPemain(ListPemain),
    mergeNameList(S, ListPemain).

mergeNameList(_, []):- !.
mergeNameList(S, [H|T]):-
    skipTeksAwal(S),
    get_code(S, 91),
    readAllCards(S, ListKartu),
    asserta(infoPemain(H, ListKartu)),
    skipTeksAwal(S),
    read(S, IdxKartu),
    cekHide(H, IdxKartu),
    mergeNameList(S, T).
    
readAllCards(S, []):- 
    peek_code(S, 93), !.
readAllCards(S, [kartu(Warna, Jenis)|T]):-
    readCard(S, Warna, Jenis),
    get_code(S, Char),
    skipCharCards(S, Char, T).

skipCharCards(_, 93, []):- !.
skipCharCards(S, 44, T):-
    readAllCards(S, T).

cekHide(H, IdxKartu):-
    IdxKartu > 0,
    assertz(hide(H, IdxKartu)), !.
cekHide(_, IdxKartu):-
    IdxKartu =:= 0, !.




/* -----LOAD ARAH PERMAINAN----- */
loadArahPermainan(S):-
    skipTeksAwal(S),
    readWord(S, CharArah),
    atom_codes(Arah, CharArah),
    defineArah(Arah).

defineArah('kanan'):-
    asserta(reverseGiliran(1)), !.
defineArah('kiri'):-
    asserta(reverseGiliran(-1)), !.





/* ---LOAD STATUS UNI--- */
loadStatusUni(S):-
    skipTeksAwal(S),
    get_code(S, 91),
    readAllNames(S, ListPemain),
    uniPlayer(ListPemain).

uniPlayer([]):- !.
uniPlayer([H|T]):-
    asserta(uniCalled(H)),
    uniPlayer(T).




/* ---LOAD RECENT KARTU AKSI--- */
loadKartuAksi(S):-
    skipTeksAwal(S),
    readCard(S, Warna, Jenis),
    assertz(kartuAksiTerakhir(kartu(Warna, Jenis))).











