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