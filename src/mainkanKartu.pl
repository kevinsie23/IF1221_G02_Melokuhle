:- include('loadKartu.pl').
:- dynamic(beforeDraw/1). %Implementasi masih nunggu ambilKartu

/* ---------MAIN HELPER PREDIKAT--------- */
/* Kondisi kartu yang dimainkan valid (sesuai indeks dan sesuai discard pile) */
mainkanKartuHelper(N, Hand, Discard, Giliran):-
    ambilPemain(Giliran, Hand, [Nama|ListKartu]),     %Ngembaliin sublist isi nama pemain dan kartu-kartunya
    ambilKartu(N, ListKartu, Kartu),                    %Ngambil kartu dari pemain sesuai indeks
    validasiKartu(Kartu, Discard), !,                   %Cek kalo kartu bisa dimainin atau tidak (warna sama/angka sama/wildcard)
    format('~w memainkan kartu: ~w. ~n', [Nama, Kartu]),
    kartuParser(Kartu, [_, Angka]),                     %Parse kartu buat diambil angkanya biar bisa cek efek
    retractall(giliranPemain(_)),                       %giliranPemain diupdate
    efekKartu(Angka, Giliran),                          %Nentuin efek dari kartu beserta perubahan giliran
    tambahDiscardPile(Kartu, Discard, NewDiscard),      %Masukin kartu yang dimainin ke Discard Pile
    retractall(discardPile(_)),                         %discardPile yang lama dihapus
    assertz(discardPile(NewDiscard)),                   %discardPile berisi kartu yang sudah ditambah dari tangan
    buangKartuTangan(N, ListKartu, NewListKartu),       %Hilangin kartu yang sudah dimainin dari list tangan
    NewPlayer = [Nama|NewListKartu],         
    updateTangan(Giliran, Hand, NewPlayer, NewHand),    %Update list tangan agar kartu yang dimainkan tidak ada lagi
    retractall(handPile(_)),                            %handPile yang lama dihapus
    assertz(handPile(NewHand)).                         %handPile berisi list tanpa kartu yang sudah dimainkan

/* Kondisi kartu yang dimainkan tidak valid (tidak sesuai indeks) */
mainkanKartuHelper(N, Hand, _, Giliran):-
    ambilPemain(Giliran, Hand, [Nama|ListKartu]),
    \+ ambilKartu(N, ListKartu, _), !,
    lengthTangan(ListKartu, Length),
    format('Jumlah kartu ~w hanya ~w. ~n', [Nama, Length]),
    write('Input ulang sesuai range.'), nl,
    fail.

/* Kondisi kartu yang dimainkan tidak valid (tidak sesuai discard pile) */
mainkanKartuHelper(N, Hand, [H|_], Giliran):-
    ambilPemain(Giliran, Hand, [_|ListKartu]),
    ambilKartu(N, ListKartu, Kartu), 
    \+ validasiKartu(Kartu, [H|_]), !,
    format('Kartu paling atas saat ini adalah ~w. ~n', [H]),
    write('Input ulang sesuai ketentuan.'), nl,
    fail.





/* ---HELPER UNTUK AMBIL LIST PEMAIN DAN KARTU--- */
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



/* ---HELPER UNTUK HITUNG BANYAK KARTU--- */
lengthTangan([], 0).
lengthTangan([_|T], Length):-
    lengthTangan(T, NewLength),
    Length is NewLength + 1.



/* ---VALIDASI KARTU YANG DIMAINKAN--- */
cekKartu(Warna, _, Warna, _):- !.
cekKartu(_, Angka, _, Angka):- !.
cekKartu(hitam, _, _, _):- !.

validasiKartu(Kartu, [H|_]):-
    kartuParser(Kartu, [WarnaTangan, AngkaTangan]),
    kartuParser(H, [WarnaDiscard, AngkaDiscard]),
    cekKartu(WarnaTangan, AngkaTangan, WarnaDiscard, AngkaDiscard).



/* ---EFEK TIAP KARTU--- */
efekKartu(Kartu, Giliran):-
    jumlahPemain(Jum),
    integer(Kartu), !,
    reverseGiliran(Geser),
    NewGiliran is (Giliran - 1 + Geser) mod Jum + 1,
    assertz(giliranPemain(NewGiliran)), !.
efekKartu(reverse, Giliran):-
    jumlahPemain(Jum),
    retract(reverseGiliran(Geser)),
    NewGeser is Geser * -1,
    assertz(reverseGiliran(NewGeser)),
    NewGiliran is (Giliran - 1 + NewGeser) mod Jum + 1,
    assertz(giliranPemain(NewGiliran)),
    write('Giliran permainan diputar balik.'), nl, !.
efekKartu(skip, Giliran):-
    jumlahPemain(Jum),
    reverseGiliran(Geser),
    NewGiliran is (Giliran - 1 + (Geser * 2)) mod Jum + 1,
    assertz(giliranPemain(NewGiliran)),
    write('Pemain berikutnya kehilangan giliran.'), nl, !.
efekKartu(draw_two, Giliran):-
    jumlahPemain(Jum),
    reverseGiliran(Geser),
    NewGiliran is (Giliran - 1 + (Geser * 2)) mod Jum + 1,
    assertz(giliranPemain(NewGiliran)),
    assertz(beforeDraw(2)),
    write('Pemain berikutnya harus mengambil 2 kartu dan kehilangan giliran.'), nl, !.
efekKartu(wild_draw_four, Giliran):-
    jumlahPemain(Jum),
    reverseGiliran(Geser),
    NewGiliran is (Giliran - 1 + (Geser * 2)) mod Jum + 1,
    assertz(giliranPemain(NewGiliran)),
    assertz(beforeDraw(4)),
    write('Pemain berikutnya harus mengambil 4 kartu dan kehilangan giliran.'), nl, !.



/* ---NEW DISCARD PILE--- */
tambahDiscardPile(Kartu, Discard, [Kartu|Discard]).



/* ---PRINT NEXT PLAYER--- */
nextPemain(NewGiliran, Hand):-
    ambilPemain(NewGiliran, Hand, [Nama|_]),
    format('Giliran ~w. ~n', [Nama]),!.



/* ---UPDATE TANGAN PLAYER--- */
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




printHand([]).
printHand([H|T]):-
    write(H), nl,
    printHand(T).


/*
Bolehkah pake integer()
jumlah pemain tunggu Wimar
Akses discard pile tunggu Wimar
Mekanisme ambil buat draw 2/4 tunggu Hanif (Yang ngurusin nambahnya siapa yak? harus kah dipanggil dulu?)
Update database draw pile tunggu Hanif
*/    