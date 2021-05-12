:- module(proylcc,
	[  
		put/8
	]).

:-use_module(library(lists)).
:-use_module(library(clpfd)).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% replace(?X, +XIndex, +Y, +Xs, -XsY)
%
% XsY es el resultado de reemplazar la ocurrencia de X en la posición XIndex de Xs por Y.

replace(X, 0, Y, [X|Xs], [Y|Xs]).

replace(X, XIndex, Y, [Xi|Xs], [Xi|XsY]):-
    XIndex > 0,
    XIndexS is XIndex - 1,
    replace(X, XIndexS, Y, Xs, XsY).


verSubcadena(0,[],[]).
verSubcadena(0,[X|Xs],Xs):- X\='#'.
verSubcadena(Cant,[X|Xs],XRes):- 
	X='#',
	CantAux is Cant-1,
	verSubcadena(CantAux,Xs,XRes).
%CB
check([],[],1).
check([],[X|_Xs],0):-X='#'.
check([],[X|Xs],0):- X\='#', member('#',Xs).
%CR1
check([P|Ps],[X|Xs],Res):- X\='#', check([P|Ps],Xs,Res).
%CR2
check([P|Ps],[X|Xs],Res):- X='#',
	Cant is P-1,
	verSubcadena(Cant,Xs,XRes),
	check(Ps,XRes,Res).
check([_P|_Ps],[X|_Xs],0):- X='#'.

checkearFila(RowN,Pistas,Filas,Res):-
	nth0(RowN,Pistas,PistaF),
	nth0(RowN,Filas,Fila).
	%check(PistaF,Fila,Res).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% put(+Contenido, +Pos, +PistasFilas, +PistasColumnas, +Grilla, -GrillaRes, -FilaSat, -ColSat).
%

put(Contenido, [RowN, ColN], PistasFilas, PistasColumnas, Grilla, NewGrilla, 0, 0):-
	replace(Row, RowN, NewRow, Grilla, NewGrilla),
	(replace(Cell, ColN, "_" , Row, NewRow),
	Cell == Contenido;
	replace(_Cell, ColN, Contenido, Row, NewRow)),
    
	checkearFila(RowN,PistasFilas,NewGrilla,FilaSat),
    transpose(NewGrilla,Columns),
	checkearFila(ColN,PistasColumnas,Columns,ColSat).
