/* -----LOAD GAME----- */
loadGame:-
    retractall(discardPile(_)),
    retractall(urutanPemain(_)),
    retractall(jumlahPemain(_)),
    retractall(reverseGiliran(_)),
    retractall(infoPemain(_, _)),
    retractall(idxGiliran(_)),
    retractall(playedDraw),
    retractall(eplayedDrawFour),
    retractall(uniCalled(_)), 
    retractall(drawPile(_)),
    retractall(warnaActive(_)),
    retractall(startedGame(_)),

    write('Masukkan nama file yang akan dimuat: '),
    read(Name),
    toTxt(Name, File),
    open(File, read, S),

    loadUrutan(S),
    loadGiliran(S),
    loadTopDiscard(S),
    loadWarnaAktif(S),
    loadKartuPemain(S),
    loadArahPermainan(S),
    loadStatusUni(S),
    close(S),
    asserta(startedGame(1)),
    asserta(drawPile([])).





/* -----SAVE GAME----- */
saveGame:-
    write('Masukkan nama file penyimpanan: '),
    read(Name),
    toTxt(Name, File),
    open(File, write, S),
    
    writeUrutan(S),
    writeGiliran(S),
    writeTopDiscard(S),
    writeWarnaAktif(S),
    writeKartuPemain(S),
    writeArahPermainan(S),
    writeStatusUni(S),
    close(S).





/* -----LIHAT KARTU----- */
lihatKartu:-
    write('Berikut kartu yang anda miliki: '), nl,
    urutanPemain(ListPemain),
    idxGiliran(Giliran),
    grabNamaPemain(ListPemain, Giliran, Nama),
    infoPemain(Nama, ListKartu),    
    printListKartuPemain(ListKartu, 1).

/* ---Helper Predikat: Print Kartu Pemain sesuai Urutan--- */
printListKartuPemain([], _):- !.
printListKartuPemain([kartu(Warna, Jenis)|T], No):-
    format('~w. ~w-~w', [No, Warna, Jenis]), nl,
    NextNo is No + 1,
    printListKartuPemain(T, NextNo).







/* -----LIHAT COMMAND----- */
lihatCommand:-
    write('Aksi utama yang tersedia:'), nl,
    printAksiUtama(1),
    nl,
    write('Aksi pendukung yang tersedia:'), nl,
    printAksiPendukung,
    nl.


/* ---Helper Predikat: Print semua aksi utama yang possible sesuai state permainan--- */
printAksiUtama(No):-
    printMainkanKartu(No, No1),
    printAmbilKartu(No1, No2),
    printTantang(No2, No3),
    printUni(No3, No4),
    printTangkap(No4, _).

/*Print mainkanKartu hanya jika tidak ada yang memainkan draw_two atau draw_four*/
printMainkanKartu(CurNo, NextNo):-
    \+ playedDraw,
    \+ playedDrawFour,
    format('~w. mainkanKartu', [CurNo]), nl, !,
    NextNo is CurNo + 1.
printMainkanKartu(CurNo, NextNo):-
    playedDraw, !,
    NextNo is CurNo.
printMainkanKartu(CurNo, NextNo):-
    playedDrawFour, !,
    NextNo is CurNo.

/*Print ambilKartu dalam state apapun*/
printAmbilKartu(CurNo, NextNo):-
    format('~w. ambilKartu', [CurNo]), nl,
    NextNo is CurNo + 1.

/*Print tantang hanya jika pemain sebelumnya memainkan draw_four*/
printTantang(CurNo, NextNo):-
    playedDrawFour,
    format('~w. tantang', [CurNo]), nl, !,
    NextNo is CurNo + 1.
printTantang(CurNo, NextNo):-
    \+ playedDrawFour, !,
    NextNo is CurNo.

/*Print uni hanya jika kartu di tangan tersisa 1*/
printUni(CurNo, NextNo):-
    \+ playedDraw,
    \+ playedDrawFour,
    format('~w. uni', [CurNo]), nl, !,
    NextNo is CurNo + 1.
printUni(CurNo, NextNo):-
    playedDraw, !,
    NextNo is CurNo.
printUni(CurNo, NextNo):-
    playedDrawFour, !,
    NextNo is CurNo.


/*Print tangkap hanya jika ada pemain yang tinggal 1 kartu tapi belum memanggil uni*/
printTangkap(CurNo, NextNo):-
    \+ playedDraw,
    \+ playedDrawFour,
    format('~w. tangkap', [CurNo]), nl, !,
    NextNo is CurNo + 1.
printTangkap(CurNo, NextNo):-
    playedDraw, !,
    NextNo is CurNo.
printTangkap(CurNo, NextNo):-
    playedDrawFour, !,
    NextNo is CurNo.


checkTangkap(Total):-
    urutanPemain(ListPemain),
    idxGiliran(Giliran),
    grabNamaPemain(ListPemain, Giliran, Nama),
    checkTiapTangkap(ListPemain, Nama, Total).


checkTiapTangkap([], _, 0).
checkTiapTangkap([H|T], Nama, Total):-
    H == Nama,
    checkTiapTangkap(T, Nama, Total).

checkTiapTangkap([H|T], Nama, Total):-
    H \== Nama,
    infoPemain(H, ListKartu),
    lengthList(ListKartu, Length),
    checkLength(Length, Possible),
    checkTiapTangkap(T, Nama, NewTotal),
    Total is Possible + NewTotal.

checkLength(1, 1):- !.
checkLength(_, 0).


/* ---Helper Predikat: Print semua aksi pendukung--- */
printAksiPendukung:-
    write('1. lihatCommand'), nl,
    write('2. lihatKartu'), nl,
    write('3. cekInfo'), nl.



/* -----Helper Predikat: Mengambil pemain sesuai giliran----- */
grabNamaPemain([H|_], 1, H):- !.
grabNamaPemain([_|T], Giliran, Nama):-
    NextGiliran is Giliran - 1,
    grabNamaPemain(T, NextGiliran, Nama).









/* -----CEK INFO----- */
cekInfo:-
    printTopDiscardCard,
    nl, nl,
    printUrutanPemain,
    nl, nl,
    printInfoPemain.



/* ---Helper Predikat: Print Urutan Nama dan Jumlah Kartu sesuai Arah---*/
printInfoPemain:-
    urutanPemain(ListPemain),
    printNamaJumlahKartu(ListPemain, 1).

printNamaJumlahKartu([H], NoUrut):-
    infoPemain(H, ListKartu),
    lengthList(ListKartu, Length),
    format('Nama pemain ~w: ~w', [NoUrut, H]),
    nl,
    format('Jumlah kartu: ~w', [Length]),
    nl, nl, !.
printNamaJumlahKartu([H|T], NoUrut):-
    infoPemain(H, ListKartu),
    lengthList(ListKartu, Length),
    format('Nama pemain ~w: ~w', [NoUrut, H]),
    nl,
    format('Jumlah kartu: ~w', [Length]),
    nl, nl,
    NewNoUrut is NoUrut + 1,
    printNamaJumlahKartu(T, NewNoUrut), !.

lengthList([], 0).              %Util.pl
lengthList([_|T], Count):-      %Util.pl
    lengthList(T, NewCount),
    Count is NewCount + 1.



/* ---Helper Predikat: Print Kartu Discard Pile Paling Atas--- */
topDiscardPile([H|_], H).
printTopDiscardCard:-
    discardPile(DiscardPile),
    write('Kartu discard top: '),
    topDiscardPile(DiscardPile, kartu(Warna, Jenis)),
    format('~w-~w.', [Warna, Jenis]).

/* ---Helper Predikat: Print Urutan Pemain--- */
printUrutanPemain:-
    urutanPemain(ListPemain),
    write('Urutan pemain: '),
    printNamaUrutan(ListPemain).

printNamaUrutan([H]):-
    format('~w.', [H]), !.
printNamaUrutan([H|T]):-
    format('~w - ', [H]),
    printNamaUrutan(T).
















