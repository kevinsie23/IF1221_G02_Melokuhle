% List predikat
% Append
% ParseCard
% LengthList
% PrintList
% PrintCard

appendHead(X, List, [X|List]).

appendTail(X,[],[X]).
appendTail(X,[H|T], [H|Result]):- appendTail(X, T, ResultTail).

appendAtN(X,0,List,[X|List]).
appendAtN(X,Idx,[H|T], [H|Result]):- I>0, !, NextIdx is Idx-1, appendAtN(X, NextI, T, Result).

lengthList([], 0):- !.
lengthList([_|T], X):- lengthList(T,X1), X is X1+1.

printList([]):- nl, !.
printList([H|T]):- write(H), nl, printList(T).

parseCard(kartu(Warna, Jenis), Warna, Jenis).
printCard(Warna, Jenis):- format('~w-~w~n', [Warna,Jenis]).
