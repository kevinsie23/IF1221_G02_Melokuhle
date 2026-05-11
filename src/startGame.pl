
startGame:- 
    write('Masukkan jumlah pemain: '), read(Num), nl, 
    checkPlayerCount(Num), inputName(Num,1,ListData), !, 
    %Ordered List = Urutan sdh dirandom
    %Final List = Uurtan sdh dirandom + dikasi kartu
    randomOrder(ListData, OrderedList), nl, printOrder(OrderedList), 
    write('Setiap pemain mendapatkan 7 kartu acak.'), !.


%Predikat Debugging Liat list
printList([]):- !.
printList([H|T]):- write(H), nl, printList(T).

%Validasi jumlah pemain
checkPlayerCount(X):- X>=2, X=<4, !.
checkPlayerCount(_):- write('Mohon masukkan angka antara 2-4.'), nl, startGame.

inputName(X, Count, Result):- getName(X, Count, [], Result), !.

%Base Case saat X sudah 0 mulaih input list
getName(0, _,  _, []). 
%getName Sukses Nama Unik
getName(X,Count, Seen, [[Input|_]|Rest]) :-
    X>0,
    write('Masukkan nama pemain '), write(Count), write(': '),
    read(Input), 
    \+ member(Input, Seen), !, %Cek apakah Input ada di dalam List Seen
    NextX is X-1,
    NextCount is Count+1,
    getName(NextX, NextCount, [Input|Seen], Rest). % [Name|Seen] Masukin Name ke Dalam Seen
%Get Name gagal Nama tidak unik
getName(X, Count, Seen, Rest):- 
    X>0, 
    write('Nama sudah digunakan. Masukkan nama lain:  '), 
    retryInput(X, Count, Seen, Rest).

%Retry Sukses
retryInput(X, Count, Seen, [[Input|_]|Rest]) :-
    read(Input),
    \+ member(Input, Seen), !, %Cek apakah Input ada di dalam List Seen
    NextX is X-1,
    NextCount is Count+1,
    getName(NextX, NextCount, [Input|Seen], Rest). % [Name|Seen] Masukin Name ke Dalam Seen
%Retry Fail
retryInput(X, Count, Seen, Rest):-     
    write('Nama sudah digunakan. Masukkan nama lain:  '), 
    retryInput(X, Count, Seen, Rest).

% Buang elemen list ke idx dan dimasukkin ke Element
removeAt(0, [H|T], H, T). % BaseCase Idx 0.
removeAt(Idx, [H|T], Element, [H|Rest]):- 
    Idx>0,
    NextId is Idx - 1,
    removeAt(NextId, T, Element, Rest).

%Hitung Panjang List
lengthList([], 0):- !.
lengthList([_|T], X):- lengthList(T,X1), X is X1+1.

%Urutan bermain sesuai dengan urutan muncul pada list. Jadi di index 0 main dulu stlh itu index 1, ...
randomOrder([],[]):- !.
randomOrder(List, [Random|Rest]):- 
    lengthList(List, L), 
    random(0,L,Index),
    removeAt(Index, List, Random, Remaining),
    randomOrder(Remaining, Rest).

% Menampilkan urutan pemain saat game dimulai
printOrder([[H|_]| Rest]):- write('Urutan pemain: '), write(H), printRest(Rest), write('.'), !.
printRest([]):- !. % Base Case =  List Sudah Habis
printRest([[H|_] | T]):- write(' - '), write(H), printRest(T). % Rekursi Print Urutan