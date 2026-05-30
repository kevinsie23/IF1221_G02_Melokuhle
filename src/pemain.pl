uni(_):-
    playedDraw,
    write('Pemain sebelumnya memainkan draw_two! Silahkan ambilKartu'), !.

uni(_):-
    playedDrawFour,
    write('Pemain sebelumnya memainkan wild_draw_four! Silahkan ambilKartu'), !.


uni(_):-
    idxGiliran(Giliran),
    urutanPemain(ListPemain),
    getElementAtIndex(ListPemain, Giliran, Nama),
    uniCalled(Nama),
    format('~w telah menyerukan UNI sebelumnya.', [Nama]), !.

uni(_):-
    idxGiliran(Giliran),
    urutanPemain(ListPemain),
    getElementAtIndex(ListPemain, Giliran, Nama),
    infoPemain(Nama, ListKartu),
    \+ uniCalled(Nama),
    lengthList(ListKartu, Length),
    Length \== 2,
    giveNCard(Nama, 1),
    nextGiliran,
    format('~w gagal melakukan UNI dan mendapatkan 1 kartu!~n', [Nama]),
    printGiliran, !.    


uni(IdxKartu):-
    startedGame(1),
    idxGiliran(Giliran),
    urutanPemain(ListPemain),
    getElementAtIndex(ListPemain, Giliran, Nama),
    infoPemain(Nama, ListKartu),
    \+ uniCalled(Nama),
    lengthList(ListKartu, Length),
    Length =:= 2,
    asserta(uniCalled(Nama)),
    unikanKartu(IdxKartu, Nama), !.


unikanKartu(IdxKartu, Nama) :-
    format('~w menyerukan UNI!~n', [Nama]),
    playCard(Nama, IdxKartu), !.

% Benar jika Pemain mengikuti aturan 
% yaitu kartu lebih dari satu atau sudah memanggil uni
checkAturanTangkap(Nama):- 
    infoPemain(Nama, List), lengthList(List, L), L > 1, !.
checkAturanTangkap(Nama):- uniCalled(Nama), !.

% Tangkap diri sendiri
tangkap(Nama):- 
    idxGiliran(Idx), urutanPemain(Giliran),
    getElementAtIndex(Giliran, Idx, Pemain), Nama == Pemain, !,
    write('Tidak dapat menangkap diri sendiri. Gunakan nama pemain lain yang valid'), nl.

% Tangkap Gagal pemain diberi sanksi
tangkap(Nama):-
    % Sudah uni atau kartu lebih dari 1
    checkAturanTangkap(Nama), !,

    % Yang memanggil diberi
    urutanPemain(Giliran),
    idxGiliran(Idx), getElementAtIndex(Giliran, Idx, Pemain),
    giveNCard(Pemain,1), 
    format('~w tidak melanggar aturan~n', [Nama]),
    format('~w mendapat 1 kartu pinalti', [Pemain]),
    nextGiliran, 
    printGiliran, !.

% Tangkap Sukses
tangkap(Nama):-
    \+ checkAturanTangkap(Nama),

    % Nama diberi sanksi 2 kartu
    giveNCard(Nama, 2),
    format('~w tertangkap tidak menyeruhkan UNI~n', [Nama]),
    format('~w mendapat 2 kartu pinalti~n', [Nama]),
    nextGiliran, 
    printGiliran, !.

% Input nama invalid
tangkap(_):-
    write('Nama ditemukan. Jalankan ulang perintah dengan nama yang valid'), nl, !.

%tantang
tantang :-
    playedDrawFour,
    getPrevPlayer(PrevPemain),
    cekValidDrawFour(PrevPemain, Hasil),
    Hasil =:= 0,
    giveNCard(PrevPemain, 4),
    retractall(playedDrawFour),
    write('Tantangan berhasil! '), write(PrevPemain), 
    write(' mendapatkan 4 kartu'), nl, !.

tantang :-
    playedDrawFour,
    getPrevPlayer(PrevPemain),
    cekValidDrawFour(PrevPemain, Hasil),
    Hasil =:= 1,
    urutanPemain(ListPemain),
    idxGiliran(CurrGiliran),
    getElementAtIndex(ListPemain, CurrGiliran, CurrPemain),
    giveNCard(CurrPemain, 6),
    retractall(playedDrawFour),
    write('Tantangan tidak berhasil! '), write(CurrPemain), 
    write(' mendapatkan 6 kartu'), !.

cekValidDrawFour(NamaPemain, Hasil) :-            % Hasil 0 jika draw four tidak valid, 1 jika valid.
    cekValidDrawFourHelper(NamaPemain, 1, Hasil).

cekValidDrawFourHelper(NamaPemain, Idx, 1) :-     % Case jika semua kartu sudah dicek.
    infoPemain(NamaPemain, ListKartu),
    lengthList(ListKartu, Length),
    Idx > Length, !.
cekValidDrawFourHelper(NamaPemain, Idx, 0) :-    % Case jika ada kartu yang dapat dimainkan. 
    infoPemain(NamaPemain, ListKartu),
    getElementAtIndex(ListKartu, Idx, kartu(Warna, Angka)),
    discardPile([_ | TDiscard]),
    head(TDiscard, kartu(WarnaDiscard, AngkaDiscard)),
    prevWarnaActive(PrevWarna),
    (Warna = PrevWarna ; (WarnaDiscard \= hitam, Angka = AngkaDiscard)), !.
cekValidDrawFourHelper(NamaPemain, Idx, Hasil) :-   % Case jika kartu pada saat itu tidak dapat dimainkan.
    infoPemain(NamaPemain, ListKartu),
    lengthList(ListKartu, Length),
    Idx =< Length,
    getElementAtIndex(ListKartu, Idx, kartu(Warna, Angka)),
    discardPile([_ | TDiscard]),
    head(TDiscard, kartu(WarnaDiscard, AngkaDiscard)),
    prevWarnaActive(PrevWarna),
    (\+ (Warna = PrevWarna ; (WarnaDiscard \= hitam, Angka = AngkaDiscard))), 
    !, NextIdx is Idx + 1,
    cekValidDrawFourHelper(NamaPemain, NextIdx, Hasil).

getPrevPlayer(NamaPemain) :-
    idxGiliran(Giliran),
    reverseGiliran(ArahGiliran),
    jumlahPemain(JumlahPemain),
    PrevGiliran is ((Giliran + (ArahGiliran * -1) - 1) mod JumlahPemain) + 1, 
    urutanPemain(ListPemain),
    getElementAtIndex(ListPemain, PrevGiliran, NamaPemain).




sembunyikanKartu(_) :-
    playedDraw,
    write('Pemain sebelumnya memainkan draw_two! Silahkan ambilKartu'), !.

sembunyikanKartu(_) :-
    playedDrawFour,
    write('Pemain sebelumnya memainkan wild_draw_four! Silahkan ambilKartu'), !.

sembunyikanKartu(_) :-
    \+ playedDraw,
    \+ playedDrawFour,
    urutanPemain(ListPemain),
    idxGiliran(CurrGiliran),
    getElementAtIndex(ListPemain, CurrGiliran, NamaPemain),
    hide(NamaPemain, _), !,
    format('~w telah memiliki kartu yang disembunyikan.~n', [NamaPemain]).

sembunyikanKartu(IdxKartu) :-
    \+ playedDraw,
    \+ playedDrawFour,
    urutanPemain(ListPemain),
    idxGiliran(CurrGiliran),
    getElementAtIndex(ListPemain, CurrGiliran, NamaPemain),
    \+ hide(NamaPemain, _), !,
    hideCard(NamaPemain, IdxKartu).  

hideCard(NamaPemain, IdxKartu) :-
    infoPemain(NamaPemain, ListKartu),
    lengthList(ListKartu, LengthKartu),
    IdxKartu > LengthKartu, 
    write('Indeks kartu tidak valid!'), nl, !.

hideCard(NamaPemain, _) :-
    infoPemain(NamaPemain, ListKartu),
    lengthList(ListKartu, LengthKartu),
    LengthKartu =:= 1, 
    write('Kartu tidak boleh disembunyikan jika jumlah kartu tersisa 1.'), nl, !.

hideCard(NamaPemain, IdxKartu) :-
    infoPemain(NamaPemain, ListKartu),
    getElementAtIndex(ListKartu, IdxKartu, kartu(Warna, Jenis)),
    format('Kartu ~w-~w berhasil disembunyikan.~n', [Warna, Jenis]),
    assertz(hide(NamaPemain, IdxKartu)),
    nextGiliran,
    printGiliran.

tampilkanKartu:-
    urutanPemain(ListPemain),
    idxGiliran(CurrGiliran),
    getElementAtIndex(ListPemain, CurrGiliran, NamaPemain),
    \+ hide(NamaPemain, _), !,
    write('Tidak ada kartu yang disembunyikan!.'), nl.

tampilkanKartu:-
    urutanPemain(ListPemain),
    idxGiliran(CurrGiliran),
    getElementAtIndex(ListPemain, CurrGiliran, NamaPemain),
    hide(NamaPemain, IdxKartu), !,
    infoPemain(NamaPemain, ListKartu),
    getElementAtIndex(ListKartu, IdxKartu, kartu(Warna, Jenis)),
    format('Kartu ~w-~w tidak disembunyikan lagi.~n', [Warna, Jenis]),
    retract(hide(NamaPemain, _)).
    
