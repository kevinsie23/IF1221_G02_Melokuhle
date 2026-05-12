:- include('loadKartu.pl').
:- include('mainkanKartu.pl').
:- dynamic(deck/1).
:- dynamic(beforeDraw/1).

/* Adapter handPile */
hand(Pemain, ListKartu) :-
    handPile(All),
    member([Pemain|ListKartu], All).

updateHand(Pemain, NewList) :-
    handPile(All),
    select([Pemain|_], All, Temp),
    append([[Pemain|NewList]], Temp, NewAll),
    retractall(handPile(_)),
    assertz(handPile(NewAll)).

/* Ambil satu kartu dari deck */
drawCardFromDeck(Pemain) :-
    deck(Deck),
    length(Deck, Len),
    random(0, Len, Idx),
    removeAt(Idx, Deck, Kartu, DeckOut),
    retract(deck(Deck)),
    assertz(deck(DeckOut)),
    hand(Pemain, Tangan),
    append(Tangan, [Kartu], TanganBaru),
    updateHand(Pemain, TanganBaru),
    format('~w mendapat kartu: ~w~n', [Pemain, Kartu]).

/* ===== Efek draw_two / draw_four ===== */
applyDrawEffect(Pemain, draw_two) :-
    drawCardFromDeck(Pemain),
    drawCardFromDeck(Pemain),
    format('~w terkena draw_two, mendapat 2 kartu.~n', [Pemain]).

applyDrawEffect(Pemain, draw_four) :-
    drawCardFromDeck(Pemain),
    drawCardFromDeck(Pemain),
    drawCardFromDeck(Pemain),
    drawCardFromDeck(Pemain),
    format('~w terkena draw_four, mendapat 4 kartu.~n', [Pemain]).

/* Ambil kartu */
/* Kondisi: tidak_punya_kartu / pilih_tidak_main / terkena_draw_two / terkena_draw_four */
ambilKartu(Pemain, Kondisi) :-
    giliranPemain(Pemain),
    hand(Pemain, Tangan),
    discardPile([TopDiscard|_]),
    (
        /* Tidak punya kartu valid */
        Kondisi = tidak_punya_kartu,
        \+ (member(K, Tangan), validasiKartu(K, [TopDiscard])) ->
            format('~w tidak punya kartu valid, mengambil 1 kartu.~n', [Pemain]),
            drawCardFromDeck(Pemain),
            nextTurn(Pemain)
        ;
        /* Punya kartu tapi pilih tidak main */
        Kondisi = pilih_tidak_main ->
            format('~w memilih tidak main kartu, mengambil 1 kartu.~n', [Pemain]),
            drawCardFromDeck(Pemain),
            nextTurn(Pemain)
        ;
        /* Efek kartu draw_two */
        Kondisi = terkena_draw_two ->
            applyDrawEffect(Pemain, draw_two),
            nextTurn(Pemain)
        ;
        /* Efek kartu draw_four */
        Kondisi = terkena_draw_four ->
            applyDrawEffect(Pemain, draw_four),
            nextTurn(Pemain)
    ).

/* Pindah giliran */
nextTurn(Current) :-
    giliranPemain(Current),
    retract(giliranPemain(Current)),
    handPile(AllHands),
    findall(P, member([P|_], AllHands), Players),
    nth0(Index, Players, Current),
    length(Players, Len),
    NextIndex is (Index + 1) mod Len,
    nth0(NextIndex, Players, Next),
    assertz(giliranPemain(Next)),
    format('Giliran berikutnya: ~w~n', [Next]).

/* Utility: remove elemen dari list */
removeAt(0, [H|T], H, T).
removeAt(Idx, [H|T], Element, [H|Rest]) :-
    Idx > 0,
    Next is Idx - 1,
    removeAt(Next, T, Element, Rest).

/* Fix kartuParser tanpa cut */
kartuParser(Color-Number, [Color, Number]).