% Menambah elemen di head
appendHead(X, List, [X|List]).

% Menambah elemen di akhir
appendTail(X,[],[X]):- !.
appendTail(X,[H|T], [H|Result]):- appendTail(X, T, Result).

% Menambah elemen pada Index Idx
appendAtN(X,0,List,[X|List]):- !.
appendAtN(X,Idx,[H|T], [H|Result]):- Idx>0, !, NextIdx is Idx-1, appendAtN(X, NextIdx, T, Result).

% Menghapus elemen ke Idx dari list dan menyimpannya dalam Variabel Element
deleteAtN(0, [H|T], H, T). % BaseCase Idx 0.
deleteAtN(Idx, [H|T], Element, [H|Rest]):- 
    Idx>0,
    NextId is Idx - 1,
    removeAt(NextId, T, Element, Rest).


lengthList([], 0):- !.
lengthList([_|T], X):- lengthList(T,X1), X is X1+1.


%Menampilkan List
printList([]):- nl, !.
printList([H|T]):- write(H), nl, printList(T).

printCard(Warna, Jenis):- format('~w-~w~n', [Warna,Jenis]).
