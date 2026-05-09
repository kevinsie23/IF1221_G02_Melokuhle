loadKartu(Filename, ListKartu) :-
    open(Filename, read, Stream),
    processRead(Stream, ListKartu),
    close(Stream).

processRead(Stream, []) :-
    at_end_of_stream(Stream), !.

processRead(Stream, [H | T]) :-
    \+ at_end_of_stream(Stream),
    read(Stream, H),
    processRead(Stream, T).

