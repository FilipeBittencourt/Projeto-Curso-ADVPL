#Include "rwmake.ch"

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � F240FIL    � Autor � Ranisses / Wanisay    � Data � 08/10/07 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Acrescenta filtro na montagem do bordero a pagar             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � SIGAFIN                                                      潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

User Function F240FIL()

	Local _aArea :=	GetArea()

	wAlias  := Alias()
	wFiltro := ""
	cPar01  := MV_PAR01
	cPar02  := MV_PAR02
	cPar03  := MV_PAR03
	cPar04  := MV_PAR04
	cPar05  := MV_PAR05
	cPar06  := MV_PAR06
 
	Pergunte("FNA240", .T.)
	
	MV_PAR01 := PADR(MV_PAR01, TamSX3("E2_FORNECE")[1], " ")
	
	MV_PAR02 := PADR(MV_PAR02, TamSX3("E2_LOJA")[1], " ")

	MV_PAR03 := PADR(MV_PAR03, TamSX3("E2_FORNECE")[1], " ")
	
	MV_PAR04 := PADR(MV_PAR04, TamSX3("E2_LOJA")[1], " ")
		
	wFiltro :=  " E2_FORNECE >= '" + MV_PAR01 + "' .AND. E2_FORNECE <= '" + MV_PAR03 + "' .AND. "
	
	wFiltro +=  " E2_LOJA	 >= '" + MV_PAR02 + "' .AND. E2_LOJA	<= '" + MV_PAR04 + "' .AND. "
	
	If MV_PAR05 == 1
	
		wFiltro += " ( Alltrim(E2_TIPO) == 'ST' .OR. SUBST(E2_FORNECE, 1, 4) == 'GNRE' ) "
		
	ElseIf MV_PAR05 == 2
	
		wFiltro += " Alltrim(E2_TIPO) <> 'ST' "
		
	EndIf

	If MV_PAR06 == 1
	
		wFiltro += " .AND. (!Empty(E2_CODBAR) .OR. !Empty(E2_YLINDIG) .OR. !Empty(E2_LINDIG)) "
		
	EndIf

	DbSelectArea(wAlias)
	
	MV_PAR01 := cPar01
	MV_PAR02 := cPar02
	MV_PAR03 := cPar03
	MV_PAR04 := cPar04
	MV_PAR05 := cPar05
	MV_PAR06 := cPar06

	RestArea(_aArea)

Return(wFiltro)