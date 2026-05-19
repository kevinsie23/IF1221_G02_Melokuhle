uni(_):-
    idxGiliran(Giliran),
    urutanPemain(ListPemain),
    getElementAtIndex(ListPemain, Giliran, Nama),
    uniCalled(Nama),
    format('~w telah menyerukan UNI sebelumnya.', [Nama]).

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
    format('~w gagal melakukan UNI dan mendapatkan 1 kartu!', [Nama]).    


uni(IdxKartu):-
    idxGiliran(Giliran),
    urutanPemain(ListPemain),
    getElementAtIndex(ListPemain, Giliran, Nama),
    infoPemain(Nama, ListKartu),
    \+ uniCalled(Nama),
    lengthList(ListKartu, Length),
    Length =:= 2,
    asserta(uniCalled(Nama)),
    unikanKartu(IdxKartu, Nama).

unikanKartu(_, Nama) :-
    playedDraw,
    retract(uniCalled(Nama)),
    write('Pemain sebelumnya memainkan draw_two! Silahkan ambilKartu'), !.

unikanKartu(_, Nama) :-
    playedDrawFour,
    retract(uniCalled(Nama)),
    write('Pemain sebelumnya memainkan wild_draw_four! Silahkan ambilKartu'), !.

unikanKartu(IdxKartu, Nama) :-
    \+ playedDraw,
    \+ playedDrawFour,
    format('~w menyerukan UNI!', [Nama]),
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