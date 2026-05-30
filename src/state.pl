/* -----LOAD GAME----- */
loadGame:-
    startedGame(1), !,
    write('Permainan sudah dimulai dan tidak bisa melakukan load.'), nl.

loadGame:-
    startedGame(0), !,

    write('Masukkan nama file yang akan dimuat: '),
    read(Name),
    toTxt(Name, File),

    loadFile(File).

loadFile(File):-
    file_exists(File), !,
    open(File, read, S),

    retractall(discardPile(_)),
    retractall(urutanPemain(_)),
    retractall(jumlahPemain(_)),
    retractall(reverseGiliran(_)),
    retractall(infoPemain(_, _)),
    retractall(idxGiliran(_)),
    retractall(playedDraw),
    retractall(playedDrawFour),
    retractall(uniCalled(_)), 
    retractall(drawPile(_)),
    retractall(warnaActive(_)),
    retractall(startedGame(_)),
    retractall(hide(_, _)),

    loadUrutan(S),
    loadGiliran(S),
    loadTopDiscard(S),
    loadWarnaAktif(S),
    loadArahPermainan(S),
    loadStatusUni(S),
    loadKartuPemain(S),
    close(S),

    urutanPemain(ListPemain),
    idxGiliran(Giliran),
    grabNamaPemain(ListPemain, Giliran, Nama),
    format('Status permainan berhasil dimuat dari ~w.~n', [File]),
    format('Melanjutkan giliran ~w.~n', [Nama]),

    asserta(startedGame(1)),
    asserta(drawPile([])).

loadFile(File):-
    \+ file_exists(File), !,
    write('File tidak ditemukan.'), nl.


/* -----SAVE GAME----- */
saveGame:-
    \+ playedDraw,
    \+ playedDrawFour, 
    startedGame(1), !,
    write('Masukkan nama file penyimpanan: '),
    read(Name),
    toTxt(Name, File),
    open(File, write, S),
    
    writeUrutan(S),
    writeGiliran(S),
    writeTopDiscard(S),
    writeWarnaAktif(S),
    writeArahPermainan(S),
    writeStatusUni(S),
    writeKartuPemain(S),
    close(S),

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
    retractall(hide(_, _)),
    retractall(startedGame(_)),
    asserta(startedGame(0)),

    format('Status permainan berhasil disimpan ke ~w.~n', [File]).

saveGame:-
    startedGame(0), !,
    write('Tidak dapat melakukan save karena permainan belum dimulai.'), nl.

saveGame:-
    playedDraw, !,
    idxGiliran(Giliran),
    urutanPemain(ListPemain),
    getElementAtIndex(ListPemain, Giliran, Nama),
    format('~w terkena draw_two dan harus melakukan aksi ambilKartu terlebih dahulu.', [Nama]).

saveGame:-
    playedDrawFour, !,
    idxGiliran(Giliran),
    urutanPemain(ListPemain),
    getElementAtIndex(ListPemain, Giliran, Nama),
    format('~w terkena draw_four dan harus melakukan aksi ambilKartu atau tantang terlebih dahulu.', [Nama]).




/* -----LIHAT KARTU----- */
lihatKartu:-
    startedGame(1),
    write('Berikut kartu yang anda miliki: '), nl,
    urutanPemain(ListPemain),
    idxGiliran(Giliran),
    grabNamaPemain(ListPemain, Giliran, Nama),
    infoPemain(Nama, ListKartu),    
    printListKartuPemain(Nama, ListKartu, 1).

/* ---Helper Predikat: Print Kartu Pemain sesuai Urutan--- */
printListKartuPemain(_, [], _):- !.
printListKartuPemain(Nama, [kartu(Warna, Jenis)|T], No):-
    hide(Nama, IdxKartu),
    IdxKartu =:= No,
    format('~w. ~w-~w (disembunyikan)', [No, Warna, Jenis]), nl,
    NextNo is No + 1,
    printListKartuPemain(Nama, T, NextNo), !.
printListKartuPemain(Nama, [kartu(Warna, Jenis)|T], No):-
    hide(Nama, IdxKartu),
    IdxKartu =\= No,
    format('~w. ~w-~w', [No, Warna, Jenis]), nl,
    NextNo is No + 1,
    printListKartuPemain(Nama, T, NextNo), !.
printListKartuPemain(Nama, [kartu(Warna, Jenis)|T], No):-
    \+ hide(Nama, _),
    format('~w. ~w-~w', [No, Warna, Jenis]), nl,
    NextNo is No + 1,
    printListKartuPemain(Nama, T, NextNo), ! .






/* -----LIHAT COMMAND----- */
lihatCommand:-
    startedGame(1),
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
    printTangkap(No4, No5),
    printSembunyi(No5, No6),
    printTampilkan(No6,No7),
    printSwapKartu(No7).

printSembunyi(CurNo, NextNo):-
    \+ playedDraw,
    \+ playedDrawFour,
    urutanPemain(ListPemain),
    idxGiliran(CurrGiliran),
    getElementAtIndex(ListPemain, CurrGiliran, NamaPemain),
    \+ hide(NamaPemain, _),
    format('~w. sembunyikanKartu', [CurNo]), nl, !,
    NextNo is CurNo + 1.
printSembunyi(CurNo, NextNo):-
    urutanPemain(ListPemain),
    idxGiliran(CurrGiliran),
    getElementAtIndex(ListPemain, CurrGiliran, NamaPemain),
    hide(NamaPemain, _), !,
    NextNo is CurNo.
printSembunyi(CurNo, NextNo):-
    playedDraw, !,
    NextNo is CurNo.
printSembunyi(CurNo, NextNo):-
    playedDrawFour, !,
    NextNo is CurNo.

printTampilkan(CurNo,NextNo):-
    \+ playedDraw,
    \+ playedDrawFour,
    urutanPemain(ListPemain),
    idxGiliran(CurrGiliran),
    getElementAtIndex(ListPemain, CurrGiliran, NamaPemain),
    hide(NamaPemain, _),    
    format('~w. tampilkanKartu', [CurNo]), nl,
    NextNo is CurNo+1, !.
printTampilkan(CurNo,NextNo):-
    urutanPemain(ListPemain),
    idxGiliran(CurrGiliran),
    getElementAtIndex(ListPemain, CurrGiliran, NamaPemain),
    \+ hide(NamaPemain, _), !.
    NextNo is CurNo+1, !.
printTampilkan(CurNo,NextNo):-
    playedDraw, 
    NextNo is CurNo, !.
printTampilkan(CurNo,NextNo):-
    playedDrawFour, 
    NextNo is CurNo, !.

printSwapKartu(CurNo):-
    \+ playedDraw,
    \+ playedDrawFour,
    format('~w. swapKartu~n',[CurNo]), !.
printSwapKartu(CurNo):-
    playedDraw, !.
printSwapKartu(CurNo):-
    playedDrawFour, !.

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
    hide(H, _), !,
    infoPemain(H, ListKartu),
    lengthList(ListKartu, Length),
    format('Nama pemain ~w: ~w', [NoUrut, H]),
    nl,
    HideLength is Length - 1,
    format('Jumlah kartu: ~w', [HideLength]),
    nl, nl, !.
printNamaJumlahKartu([H], NoUrut):-
    \+ hide(H, _), !,
    infoPemain(H, ListKartu),
    lengthList(ListKartu, Length),
    format('Nama pemain ~w: ~w', [NoUrut, H]),
    nl,
    format('Jumlah kartu: ~w', [Length]),
    nl, nl, !.
printNamaJumlahKartu([H|T], NoUrut):-
    hide(H, _), !,
    infoPemain(H, ListKartu),
    lengthList(ListKartu, Length),
    format('Nama pemain ~w: ~w', [NoUrut, H]),
    nl,
    HideLength is Length - 1,
    format('Jumlah kartu: ~w', [HideLength]),
    nl, nl,
    NewNoUrut is NoUrut + 1,
    printNamaJumlahKartu(T, NewNoUrut), !.
printNamaJumlahKartu([H|T], NoUrut):-
    \+ hide(H, _), !,
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
















