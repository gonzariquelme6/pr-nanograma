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


/*Check(Pista,Fila,Satisface)
 * Caso base
 *	La pista es una
 		si la pista es 0 entonces
        	compruebo que no hayan mas "#".
        si la pista no es 0 entonces
        	busco el primer "#" y decremento en 1 hasta llegar a cero.        
 */
check([0],[],1).
check([X],[],0):-X\=0.
check([0],[X|Xs],1):- X\="#", not(member("#",Xs)).
check([0],[X|Xs],0):- X\="#", member("#",Xs).
check([0],[X|_Xs],0):- X="#".
check([0|Ps],[X|Xs],Satif):-X\="#",check(Ps,Xs,Satif).
check([0|_Ps],[X|_Xs],0):-X="#".
check([P|Ps],[X|Xs],Satif):-X\="#",check([P|Ps],Xs,Satif).
check([P|Ps],[X|Xs],Satif):-X="#",Pdec is P-1,check([Pdec|Ps],Xs,Satif).

obtener(0,[X|_Xs],X).
obtener(RowN,[_X|Xs],Pista):-
    RowN>0,
    Aux is RowN-1,
    obtener(Aux,Xs,Pista).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% put(+Contenido, +Pos, +PistasFilas, +PistasColumnas, +Grilla, -GrillaRes, -FilaSat, -ColSat).
%

put(Contenido, [RowN, ColN], _PistasFilas, _PistasColumnas, Grilla, NewGrilla, 0, 0):-
	% NewGrilla es el resultado de reemplazar la fila Row en la posición RowN de Grilla
	% (RowN-ésima fila de Grilla), por una fila nueva NewRow.
	
	replace(Row, RowN, NewRow, Grilla, NewGrilla),

	% NewRow es el resultado de reemplazar la celda Cell en la posición ColN de Row por _,
	% siempre y cuando Cell coincida con Contenido (Cell se instancia en la llamada al replace/5).
	% En caso contrario (;)
	% NewRow es el resultado de reemplazar lo que se que haya (_Cell) en la posición ColN de Row por Contenido.	 
	
	(replace(Cell, ColN, _, Row, NewRow),
	Cell == Contenido 
		;
	replace(_Cell, ColN, Contenido, Row, NewRow)),
    
    obtener(RowN,PistasFilas,PistaF),
    obtener(RowN,NewGrilla,Fila),
    check(PistaF,Fila,FilaSat),
    
    transpose(NewGrilla,Columns),
	obtener(ColN,PistasColumnas,PistaC),
	obtener(ColN,Columns,Columna),
	check(PistaC,Columna,ColSat).
