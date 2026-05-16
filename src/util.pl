head([H | _], H).
tail([_ | T], T).

% Menambah elemen di head
appendHead(X, List, [X|List]).

% Menambah elemen di akhir
appendTail(X,[],[X]):- !.
appendTail(X,[H|T], [H|Result]):- appendTail(X, T, Result).

% Menambah elemen pada Index Idx
appendAtN(X,0,List,[X|List]):- !.
appendAtN(X,Idx,[H|T], [H|Result]):- Idx>0, !, NextIdx is Idx-1, appendAtN(X, NextIdx, T, Result).

% Menghapus elemen ke Idx dari list dan menyimpannya dalam Variabel Element
deleteAtN(1, [H|T], H, T) :- !.
deleteAtN(Idx, [H|T], Element, [H|Rest]) :-
    Idx > 1,
    NextId is Idx - 1,
    deleteAtN(NextId, T, Element, Rest).


lengthList([], 0):- !.
lengthList([_|T], X):- lengthList(T,X1), X is X1+1.

% Mengambil elemen pada list berdasarkan idx, idx pertama adalah 1
getElementAtIndex([H | _], 1, H) :- !.              % Untuk mengambil kartu sesuai dengan gilirannya.

getElementAtIndex([_ | T], Index, Element) :-
    Index > 1,
    NextIndex is Index - 1,
    getElementAtIndex(T, NextIndex, Element).

%Menampilkan List
printList([]):- nl, !.
printList([H|T]):- write(H), nl, printList(T).

printListWithIndex(List) :-                         
    printListWithIndexHelper(List, 1).

printListWithIndexHelper([], _) :- !.
printListWithIndexHelper(List, StartIndex) :-
    List \== [],
    head(List, Element),
    write(StartIndex), write('. '), write(Element), nl,
    NextIndex is StartIndex + 1,
    tail(List, NextList),
    printListWithIndexHelper(NextList, NextIndex).

printCard(Warna, Jenis):- format('~w-~w~n', [Warna,Jenis]).


% isMember --> Lihat apakah X ada di List
isMember(X, [X|_]):- !.
isMember(X, [_|T]):- isMember(X,T).