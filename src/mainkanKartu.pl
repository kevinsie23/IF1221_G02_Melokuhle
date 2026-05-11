:- dynamic(giliranPemain/1).
:- dynamic(reverseGiliran/1).
:- dynamic(discardPile/1).
:- dynamic(beforeDraw/1).
:- dynamic(handPile/1).

/*Initial State, run saat start*/
giliranPemain(1).
reverseGiliran(1).

/*DATA DUMMY*/
contohMain(Hand, Discard):-
    Hand = [
        ['Najib', [merah-3, hijau-5, biru-2]],
        ['Hanif', [hijau-reverse, biru-3, kuning-9]],
        ['Kevin', [kuning-3, biru-skip, merah-5]],
        ['Wimar', [merah-draw_two, hijau-1, kuning-7]]
        ],
    Discard = [merah-7, biru-2].



/*HELPER UNTUK AMBIL PEMAIN DAN KARTU*/
ambilPemain(1, [H|_], H).
ambilPemain(N, [_|T], TanganPemain):-
    N > 1,
    N1 is N - 1,
    ambilPemain(N1, T, TanganPemain).

ambilKartu(1, [H|_], H).
ambilKartu(N, [_|T], Kartu):-
    N > 1,
    N1 is N - 1,
    ambilKartu(N1, T, Kartu).



/*HELPER UNTUK AMBIL BANYAK KARTU*/
lengthTangan([], 0).
lengthTangan([_|T], Length):-
    lengthTangan(T, NewLength),
    Length is NewLength + 1.



/*VALIDASI KARTU YANG DIMAINKAN*/
parseKartu(Warna-Angka, Warna, Angka).
cekKartu(Warna, _, Warna, _):- !.
cekKartu(_, Angka, _, Angka):- !.
cekKartu(hitam, _, _, _):- !.

validasiKartu(Kartu, [H|_]):-
    parseKartu(Kartu, WarnaTangan, AngkaTangan),
    parseKartu(H, WarnaDiscard, AngkaDiscard),
    cekKartu(WarnaTangan, AngkaTangan, WarnaDiscard, AngkaDiscard).



/*EFEK TIAP KARTU*/
efekKartu(Kartu, Giliran):-
    integer(Kartu), !,
    reverseGiliran(Geser),
    NewGiliran is (Giliran - 1 + Geser) mod 4 + 1,
    assertz(giliranPemain(NewGiliran)), !.
efekKartu(reverse, Giliran):-
    retract(reverseGiliran(Geser)),
    NewGeser is Geser * -1,
    assertz(reverseGiliran(NewGeser)),
    NewGiliran is (Giliran - 1 + NewGeser) mod 4 + 1,
    assertz(giliranPemain(NewGiliran)),
    write('Giliran permainan diputar balik.'), nl, !.
efekKartu(skip, Giliran):-
    reverseGiliran(Geser),
    NewGiliran is (Giliran - 1 + (Geser * 2)) mod 4 + 1,
    assertz(giliranPemain(NewGiliran)),
    write('Pemain berikutnya kehilangan giliran.'), nl, !.
efekKartu(draw_two, Giliran):-
    reverseGiliran(Geser),
    NewGiliran is (Giliran - 1 + (Geser * 2)) mod 4 + 1,
    assertz(giliranPemain(NewGiliran)),
    assertz(beforeDraw(2)),
    write('Pemain berikutnya harus mengambil 2 kartu dan kehilangan giliran.'), nl, !.
efekKartu(wild_draw_four, Giliran):-
    reverseGiliran(Geser),
    NewGiliran is (Giliran - 1 + (Geser * 2)) mod 4 + 1,
    assertz(giliranPemain(NewGiliran)),
    assertz(beforeDraw(4)),
    write('Pemain berikutnya harus mengambil 4 kartu dan kehilangan giliran.'), nl, !.



/*NEW DISCARD PILE*/
tambahDiscardPile(Kartu, Discard, [Kartu|Discard]).

/*NEXT PLAYER */
nextPemain(NewGiliran, Hand):-
    ambilPemain(NewGiliran, Hand, [Nama|[_]]),
    format('Giliran ~w. ~n', [Nama]),!.


/*UPDATE TANGAN PLAYER*/
buangKartuTangan(1, [_|T], T).
buangKartuTangan(N, [H|T], [H|T2]):-
    N > 1,
    N1 is N - 1,
    buangKartuTangan(N1, T, T2).

updateTangan(1, [_|T], NewPlayer, [NewPlayer|T]).
updateTangan(N, [H|T], NewPlayer, [H|T2]):-
    N > 1,
    N1 is N - 1,
    updateTangan(N1, T, NewPlayer, T2).

/*MAIN PROGRAM*/
mainkanKartuHelper(N, Hand, Discard, Giliran):-
    ambilPemain(Giliran, Hand, [Nama|[ListKartu]]),
    ambilKartu(N, ListKartu, Kartu), 
    validasiKartu(Kartu, Discard), !,
    format('~w memainkan kartu: ~w. ~n', [Nama, Kartu]),
    parseKartu(Kartu, _, Angka),
    retractall(giliranPemain(_)),
    efekKartu(Angka, Giliran),
    tambahDiscardPile(Kartu, Discard, NewDiscard),
    retractall(discardPile(_)),
    assertz(discardPile(NewDiscard)),
    buangKartuTangan(N, ListKartu, NewListKartu),
    NewPlayer = [Nama, NewListKartu],
    updateTangan(Giliran, Hand, NewPlayer, NewHand),
    retractall(handPile(_)),
    assertz(handPile(NewHand)).

mainkanKartuHelper(N, Hand, _, Giliran):-
    ambilPemain(Giliran, Hand, [Nama|[ListKartu]]),
    \+ ambilKartu(N, ListKartu, _), !,
    lengthTangan(ListKartu, Length),
    format('Jumlah kartu ~w hanya ~w. ~n', [Nama, Length]),
    write('Input ulang sesuai range.'), nl,
    fail.

mainkanKartuHelper(N, Hand, [H|_], Giliran):-
    ambilPemain(Giliran, Hand, [_|[ListKartu]]),
    ambilKartu(N, ListKartu, Kartu), 
    \+ validasiKartu(Kartu, [H|_]), !,
    format('Kartu paling atas saat ini adalah ~w. ~n', [H]),
    write('Input ulang sesuai ketentuan.'), nl,
    fail.
    
lihatKartu:-
    handPile(Hand),
    write(Hand).


start:-
    contohMain(Hand, Discard), % mungkin ini bisa pake getList dari part Wimar nanti
    assertz(discardPile(Discard)),
    assertz(handPile(Hand)).

mainkanKartu(N):-
    \+ beforeDraw(_),
    handPile(Hand),
    discardPile(Discard),
    giliranPemain(Giliran),
    mainkanKartuHelper(N, Hand, Discard, Giliran),
    giliranPemain(NewGiliran),
    nextPemain(NewGiliran, Hand),
    discardPile(NewDiscard),
    write(NewDiscard), !.

/*
Bolehkah pake integer()
jumlah pemain tunggu Wimar
Akses discard pile tunggu Wimar
Mekanisme ambil buat draw 2/4 tunggu Hanif (Yang ngurusin nambahnya siapa yak? harus kah dipanggil dulu?)
Update database draw pile tunggu Hanif
*/    