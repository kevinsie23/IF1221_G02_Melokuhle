loadKartu(Filename, ListKartu) :-
    open(Filename, read, Stream),
    processRead(Stream, ListKartu),
    close(Stream).

processRead(Stream, []) :-
    at_end_of_stream(Stream), !.

processRead(Stream, [Kartu | T]) :-
    \+ at_end_of_stream(Stream),
    read(Stream, Kartu),
    processRead(Stream, T).

/* Split card's color and number */
kartuParser(Color-Number, [Color, Number]) :- !.
