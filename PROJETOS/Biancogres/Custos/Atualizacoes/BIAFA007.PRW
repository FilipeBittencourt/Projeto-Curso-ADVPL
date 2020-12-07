#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFA007
@author Artur Antunes
@since 19/05/2017
@version 1.0
@description Cadastro de Consumo de Gas
@obs 1683-17
@type function
/*/

User function BIAFA007()

	Local aArea       := GetArea()

	Local oBrowse     := nil
	private aRotina   := fMenuDef()
	private cCadastro := "Consumo de Gas"    

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('Z91')
	oBrowse:SetDescription(cCadastro)
	oBrowse:Activate()

	RestArea(aArea)

Return   

// funcao para o menu                                 
Static Function fMenuDef()

	local aRotina := {} 
	aRotina := {{"Pesquisar"   	,"AxPesqui"   , 0, 1},;     
	{            "Visualizar"  	,"U_BIAFA7ME" , 0, 2},; 
	Iif(cEmpAnt == "01",{            "Incluir"		,"U_BIAFA7ME" , 0, 3},{            "Processar"		,"U_BIAFA7IC" , 0, 3}),;
	{            "Alterar"		,"U_BIAFA7ME" , 0, 4},;
	{            "Excluir"		,"U_BIAFA7ME" , 0, 5},;
	{            "Rel. Excel"	,"U_BIAFG027" , 0, 6} }


return aRotina

User Function BIAFA7ME(cAlias,nReg,nOpc)

	If nOpc == 4 .Or. nOpc == 5
		If  Z91->Z91_DATA <= GetMV("MV_YULRAC") 
			If !U_VALOPER("059") //Ticket 24605 - Cadastrado VALOPER 059 para esta tratativa fora da data.
				MsgSTOP("Não será possível alterar o registro selecionado, pois está fora do período de fechamento de estoque.", "OP 059 - Data de Fechamento!")
				Return
			EndIf			
		EndIf
	EndIf

	fMontaTela(cAlias,nReg,nOpc)

return  

//Monta Tela
Static Function fMontaTela(cAlias,nReg,nOpc)

	local nTamRod		:= 5
	Local _aSize :=	{} 
	Local _aObjects :=	{}
	Local _aInfo :=	{}
	Local _aPosObj		:=	{}		
	private aCamposCab  := {}
	private aCamposAch  := {}
	Private lRefresh 	:= .T.
	Private nUsado 		:= 0
	private aCampAlt 	:= {}
	private cAliasCab 	:= 'Z91'
	private cAliasIt	:= 'Z91'
	private cChaveRel	:= '_DATA'
	Private aHeader 	:= {}
	Private aCols 		:= {}
	Private aTELA[0][0]
	Private aGETS[0]
	Private GrdRegCabec   

	_aSize := MsAdvSize(.T.)

	aAdd(_aObjects, {100, 20, .T. , .T. })
	aAdd(_aObjects, {100, 80, .T. , .T. })                      

	_aInfo := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	oDlg := MSDialog():New(_aSize[7], 0, _aSize[6], _aSize[5], cCadastro,,,,,CLR_BLACK,,,,.T.)
	oDlg:lMaximized := .T. 

	RegToMemory(cAliasCab,If(nOpc==3,.T.,.F.)) 
	fLoadCab(cAliasCab,nOpc)
	oCab := MsMGet():New(cAliasCab, nReg,nOpc,,,,aCamposAch,{_aPosObj[1,1], _aPosObj[1,2], _aPosObj[1,3], _aPosObj[1,4]},aCamposCab,,,,,oDlg)    

	fLoadItens(cAliasIt,nOpc) 
	oGetDados := MsGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], nOpc,'U_BIAF7LOK','U_BIAF7TOK',,.T.,aCampAlt,,.F.,9999,'U_BIAF7FOK','U_BIAF7SDE',,'U_BIAF7DEL',oDlg)

	fAjustaHelp()

	oDlg:Activate(,,,.T.,,,EnchoiceBar(oDlg,{|| fConfirma(nOpc) },{|| oDlg:End()} )) 

return

//Load Cabeçalho
Static Function fLoadCab(cAlias,nOpc)

	local ny := 0

	aCamposCab := {"Z91_DATA"}
	aCamposAch := {"Z91_DATA","NOUSER"}

return

//Load Itens
Static Function fLoadItens(cAlias,nOpc)

	local ny := 0
	local nPosRecurs	:= 0
	local nPosMedidor	:= 0
	local nPosDMed		:= 0
	local nPosDRec		:= 0
	local nPosVNM3		:= 0
	local nPosPCI		:= 0
	local nPosPCS		:= 0	

	Local nI

	DbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	SX3->(DbSeek(cAlias))

	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
		If !(SUBSTR(Alltrim(SX3->X3_CAMPO),At("_",SX3->X3_CAMPO)) $ "_FILIAL/_DATA") .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO)       
			nUsado++     
			AADD(aCampAlt,SX3->X3_CAMPO)   
			Aadd(aHeader,{AllTrim(X3Titulo()),;
			SX3->X3_CAMPO   	 ,;                      
			SX3->X3_PICTURE 	 ,;                      
			SX3->X3_TAMANHO 	 ,;                      
			SX3->X3_DECIMAL 	 ,;                      
			SX3->X3_VALID   	 ,;                      
			SX3->X3_USADO    	 ,;                      
			SX3->X3_TIPO    	 ,;                      
			SX3->X3_ARQUIVO  	 ,;                      
			SX3->X3_CONTEXT  	 })

		EndIf
		SX3->(DbSkip())
	End  

	if nOpc == 3
		nPosRecurs	:=	aScan(aHeader,{|x| AllTrim(x[2]) == "Z91_RECURS"})
		nPosMedidor	:=	aScan(aHeader,{|x| AllTrim(x[2]) == "Z91_MEDIDO"})
		nPosDMed	:=	aScan(aHeader,{|x| AllTrim(x[2]) == "Z91_MEDDES"})
		nPosDRec	:=	aScan(aHeader,{|x| AllTrim(x[2]) == "Z91_RECDES"})
		nPosVNM3	:=	aScan(aHeader,{|x| AllTrim(x[2]) == "Z91_VAZNM3"})
		nPosPCI		:=	aScan(aHeader,{|x| AllTrim(x[2]) == "Z91_PCI"})
		nPosPCS		:=	aScan(aHeader,{|x| AllTrim(x[2]) == "Z91_FATCOR"})	 	

		Aadd(aCols,Array(nUsado+1))
		Aadd(aCols,Array(nUsado+1))
		Aadd(aCols,Array(nUsado+1))
		Aadd(aCols,Array(nUsado+1))
		For nI := 1 To nUsado
			Do Case
				Case nI == nPosReCurs
				aCols[1,nPosRecurs] := PADR("EST001",TAMSX3("Z91_RECURS")[1])
				aCols[2,nPosRecurs] := PADR("EST001",TAMSX3("Z91_RECURS")[1])
				aCols[3,nPosRecurs] := PADR("EST001",TAMSX3("Z91_RECURS")[1])
				aCols[4,nPosRecurs] := PADR("EST001",TAMSX3("Z91_RECURS")[1])
				Case nI == nPosDRec
				aCols[1,nPosDRec] 	:= Posicione("SH1", 1, xFilial("SH1") + aCols[1,nPosRecurs], "H1_DESCRI")
				aCols[2,nPosDRec] 	:= Posicione("SH1", 1, xFilial("SH1") + aCols[2,nPosRecurs], "H1_DESCRI")
				aCols[3,nPosDRec] 	:= Posicione("SH1", 1, xFilial("SH1") + aCols[3,nPosRecurs], "H1_DESCRI")
				aCols[4,nPosDRec] 	:= Posicione("SH1", 1, xFilial("SH1") + aCols[4,nPosRecurs], "H1_DESCRI")				
				Case nI == nPosMedidor
				aCols[1,nPosMedidor] := PADR("MED003",TAMSX3("Z91_MEDIDO")[1])
				aCols[2,nPosMedidor] := PADR("MED004",TAMSX3("Z91_MEDIDO")[1])
				aCols[3,nPosMedidor] := PADR("MED005",TAMSX3("Z91_MEDIDO")[1])
				aCols[4,nPosMedidor] := PADR("MED006",TAMSX3("Z91_MEDIDO")[1])
				Case nI == nPosDMed
				aCols[1,nPosDMed]	 := Posicione("SH4", 1, xFilial("SH4") + aCols[1,nPosMedidor], "H4_DESCRI")
				aCols[2,nPosDMed]	 := Posicione("SH4", 1, xFilial("SH4") + aCols[2,nPosMedidor], "H4_DESCRI")
				aCols[3,nPosDMed]	 := Posicione("SH4", 1, xFilial("SH4") + aCols[3,nPosMedidor], "H4_DESCRI")
				aCols[4,nPosDMed]	 := Posicione("SH4", 1, xFilial("SH4") + aCols[4,nPosMedidor], "H4_DESCRI")
				Case nI == nPosVNM3
				aCols[1,nPosVNM3]	 := -1
				aCols[2,nPosVNM3]	 := -1
				aCols[3,nPosVNM3]	 := -1
				aCols[4,nPosVNM3]	 := -1
				Case nI == nPosPCI
				aCols[1,nPosPCI]	 := 1
				aCols[2,nPosPCI]	 := 1
				aCols[3,nPosPCI]	 := 1
				aCols[4,nPosPCI]	 := 1
				Case nI == nPosPCS
				aCols[1,nPosPCS]	 := 1
				aCols[2,nPosPCS]	 := 1
				aCols[3,nPosPCS]	 := 1
				aCols[4,nPosPCS]	 := 1				
				OtherWise
				aCols[1][nI] := CriaVar(aHeader[nI][2])
				aCols[2][nI] := CriaVar(aHeader[nI][2])
				aCols[3][nI] := CriaVar(aHeader[nI][2])
				aCols[4][nI] := CriaVar(aHeader[nI][2])
			EndCase
		Next nI
		aCols[1][nUsado+1] := .F.
		aCols[2][nUsado+1] := .F.
		aCols[3][nUsado+1] := .F.
		aCols[4][nUsado+1] := .F.
	else

		GrdRegCabec := DTOS((cAliasCab)->&(cAliasCab+cChaveRel))
		dbselectarea(cAliasIt) 
		(cAliasIt)->(DbSetOrder(1))

		if (cAliasIt)->(DbSeek(xFilial(cAliasIt) + GrdRegCabec))

			fqRegAtu := (cAliasIt)->(Recno()) 

			while !(cAliasIt)->(EOF()) .and. xFilial(cAliasIt) + GrdRegCabec == xFilial(cAliasIt) + DTOS((cAliasIt)->&(cAliasIt+cChaveRel))

				Aadd(aCols,Array(nUsado+1))
				For nI := 1 To nUsado    
					aCols[LEN(aCols)][nI] := (cAliasIt)->&(aHeader[nI,2])
				Next nI
				aCols[LEN(aCols)][nUsado+1] := .F.

				(cAliasIt)->(DbSkip())

			End

			(cAliasIt)->(dbGoTo(fqRegAtu))

		endif

	endif

return

//Grid - Linha OK
User Function BIAF7LOK(o,nLin)

	local lRet			:= .T.
	local nx  			:= 0
	local nPosFormat	:= aScan(aHeader,{|x| AllTrim(x[2]) == "Z91_FORMAT"})
	local nPosRecurs	:= aScan(aHeader,{|x| AllTrim(x[2]) == "Z91_RECURS"})
	local nPosMedidor	:= aScan(aHeader,{|x| AllTrim(x[2]) == "Z91_MEDIDO"})
	default nLin 		:= 0

	if nLin == 0
		nLin := n
	endif

	If !GDdeleted(nLin)
		If lRet
			lRet:=MaCheckCols(aHeader,aCols,nLin)
		EndIf

		dbselectarea(cAliasIt) 
		(cAliasIt)->(DbSetOrder(1))

		if lRet
			For nx:=1 to Len(aCols)
				if !GDdeleted(nx) .and. nx <> nLin 
					if lRet .and. ;
					xFilial(cAliasIt) + DTOS(M->&(cAliasCab+cChaveRel)) + aCols[nx,nPosFormat] + aCols[nx,nPosRecurs] + aCols[nx,nPosMedidor] ;
					== xFilial(cAliasIt) + DTOS(M->&(cAliasCab+cChaveRel)) + aCols[nLin,nPosFormat] + aCols[nLin,nPosRecurs] + aCols[nLin,nPosMedidor] ;

						Help(" ",1,"BIAFA00701")
						lRet := .F.
						Exit
					endif
				endif	
			Next nx
		endif
	endif	

Return lRet


//Grid - Tudo OK
User Function BIAF7TOK(o)

	local nx   := 0
	local lRet := .T.
	For nx:=1 to Len(aCols)
		if !GDdeleted(nx)
			lRet := U_BIAF7LOK(o,nx)
			if !lRet
				Exit
			endif 
		endif	
	Next nx

Return lRet

//valida edicao dos campos do grid
User Function BIAF7FOK()

	Local vfArea    := GetArea()
	Local lRet      := .T.
	Local cMenVar   := ReadVar()
	Local _nI		:=	0
	Local _cAlias	:=	""
	Local _cAlias2	:=	""
	Local _cFormat	:=	""
	Local _nQuant	:=	0
	Private vfDtRef := dtos(M->Z91_DATA)

	If (Alltrim(cMenVar) $ "M->Z91_MEDIDO/M->Z91_RECURS" .And.  Alltrim(GdFieldGet("Z91_MEDIDO",n)) $ "MED003/MED004/MED005/MED006" .AND. Alltrim(GdFieldGet("Z91_RECURS",n)) == 'EST001') .OR. Alltrim(GdFieldGet("Z91_RECURS",n)) == 'ATM000'
		MsgInfo("Dado não poderá ser alterado!")
		Return .F.
	EndIf

	If Alltrim(GdFieldGet("Z91_MEDIDO",n)) == "MED006" 
		MsgInfo("Linha não poderá ser Editada!")
		Return .F.
	endIf

	If Alltrim(cMenVar) == "M->Z91_FORMAT"

		vfDFormato   := Posicione("ZZ6", 1, xFilial("ZZ6") + M->Z91_FORMAT, "ZZ6_DESC")
		GdFieldPut("Z91_FORDES", vfDFormato, n)


	ElseIf Alltrim(cMenVar) == "M->Z91_RECURS"

		vfDRecurso   := Posicione("SH1", 1, xFilial("SH1") + M->Z91_RECURS, "H1_DESCRI")
		GdFieldPut("Z91_RECDES", vfDRecurso, n)

		For _nI	:=	1 to Len(aCols)
			If n <> _nI .And. Alltrim(GdFieldGet("Z91_MEDIDO",_nI)) == 'MED003' .And. Alltrim(GdFieldGet("Z91_RECURS",_nI)) == 'EST001'
				GdFieldPut("Z91_PCI",GdFieldGet("Z91_PCI",_nI),n)
				GdFieldPut("Z91_FATCOR",GdFieldGet("Z91_FATCOR",_nI),n)
			EndIf
		Next

		RG004 := " SELECT Z88_META, Z88_METATN "
		RG004 += "   FROM " + RetSqlName("Z88") + " Z88 (NOLOCK) "
		RG004 += "  WHERE Z88_FILIAL = '" + xFilial("Z88") + "' "
		RG004 += "    AND Z88_FORMAT = '" + GdFieldGet("Z91_FORMAT",n) + "' "
		RG004 += "    AND Z88_RECURS = '" + M->Z91_RECURS + "' "
		RG004 += "    AND '" + vfDtRef + "' >= Z88_DTDE "
		RG004 += "    AND '" + vfDtRef + "' <= Z88_DTATE "
		RG004 += "    AND Z88.D_E_L_E_T_ = ' ' "
		RGcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,RG004),'RG04',.F.,.T.)
		dbSelectArea("RG04")
		dbGoTop()
		vfMeta   	:= RG04->Z88_META
		vfMetaTn	:= RG04->Z88_METATN  
		RG04->(dbCloseArea())
		Ferase(RGcIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(RGcIndex+OrdBagExt())          //indice gerado

		RestArea( vfArea )
		GdFieldPut("Z91_META", vfMeta, n)
		GdFieldPut("Z91_METATN", vfMetaTn, n)

		_cFormat	:=	GdFieldGet("Z91_FORMAT", n)
		If _cFormat $ "C6/BO"
			_cFormat := "C1"
		EndIf
		If !Empty(_cFormat)
			do case
				case Alltrim(M->Z91_RECURS) $ "SEC003/FOR003"
				_cAlias	:=	GetNextAlias()

				BeginSql Alias _cAlias
					SELECT  ISNULL(SUM(Z75_QUANT),0) QUANT
					FROM    %TABLE:Z75% Z75
					INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = %xFilial:SB1%
					AND B1_COD = Z75_PRODUT
					AND B1_YFORMAT =	%Exp:_cFormat% 
					AND SB1.%NotDel%
					WHERE   Z75_FILIAL = %xFilial:Z75%
					AND Z75_DATARF = %Exp:vfDtRef%
					AND Z75_TPMOV IN ('ETQ','RET')
					AND Z75_TPPROD = 'PP'
					AND Z75.%NotDel%			
				EndSql

				_nQuant	:=	(_cAlias)->QUANT
				(_cAlias)->(DbCloseArea())
				RestArea( vfArea )
				GdFieldPut("Z91_PORDM2", _nQuant, n)


				case Alltrim(M->Z91_RECURS) $ "SEC001/FOR001/SEC002/FOR002/SEC004/SEC005/FOR004/FOR005"
				_cAlias	:=	GetNextAlias()

				BeginSql Alias _cAlias
					SELECT  ISNULL(SUM(Z75_QUANT),0) QUANT
					FROM    %TABLE:Z75% Z75
					INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = %XFILIAL:SB1%
					AND B1_COD = Z75_PRODUT
					AND B1_YFORMAT = %Exp:_cFormat%
					AND SB1.%NotDel%
					WHERE   Z75_FILIAL = %xFilial:Z75%
					AND Z75_DATARF = %Exp:vfDtRef%
					AND Z75_TPMOV IN ('ETQ','RET')
					AND Z75_TPPROD <> 'PP'
					AND Z75.%NotDel%
				EndSql

				_nQuant	:=	(_cAlias)->QUANT
				RestArea( vfArea )
				(_cAlias)->(DbCloseArea())
				GdFieldPut("Z91_PORDM2", _nQuant, n)

				OtherWise
				GdFieldPut("Z91_PORDM2", 0, n)
			endcase
		ElseIf Alltrim(M->Z91_RECURS) $ "ATM090/ATM140"
			_cAlias		:=	GetNextAlias()
			_cAlias2	:=	GetNextAlias()
			If vfDtRef >= '20201023'
				BeginSql Alias _cAlias
					%NoParser%
					WITH PORCELANATO
					AS (
					SELECT B1_COD PRODUT
					FROM %TABLE:SB1%
					WHERE B1_FILIAL = %XFILIAL:SB1%
					AND B1_YSTATUS = '1'
					AND B1_YCLASSE = ' '
					AND B1_YTPPROD <> 'RP'
					AND B1_YFORMAT NOT IN (
					'BN'
					,'BP'
					,'AL'
					)
					AND %NotDel%
					)
					SELECT ISNULL(SUM(PESO)/SUM(PRODUC),0) QUANT FROM (
					SELECT PRODUT
					,SUM(D3_QUANT) PRODUC
					,SUM(D3_QUANT) * (
					SELECT ISNULL(AVG(G1_QUANT), 0)
					FROM %TABLE:SG1% SG1
					INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = %XFILIAL:SB1%
					AND B1_COD = G1_COMP
					AND B1_COD IN (
									SELECT  SD3M.D3_COD
									FROM    %TABLE:SD3% SD3M
									INNER JOIN %TABLE:SB1% SB1M ON SB1M.B1_FILIAL = %XFILIAL:SB1%
									AND SB1M.B1_COD = SD3M.D3_COD
									AND SB1M.B1_DESC NOT LIKE 'PBI%'
									AND SB1M.B1_GRUPO = 'PI01'
									AND SB1M.%NotDel%
									WHERE   SD3M.D3_FILIAL = %XFILIAL:SD3%
									AND SD3M.D3_EMISSAO = %Exp:vfDtRef%
									AND SD3M.D3_TM = '010'
									AND SD3M.D3_YRECURS	= %Exp:M->Z91_RECURS%
									AND SD3M.D3_ESTORNO = ' '
									AND SD3M.%NotDel%
									)
					AND B1_GRUPO = 'PI01'
					AND SB1.%NotDel%
					WHERE G1_FILIAL = %XFILIAL:SG1%
					AND G1_COD = PRODUT
					AND SG1.%NotDel%
					) PESO
					FROM PORCELANATO PRC
					INNER JOIN %TABLE:SD3% SD3 ON SD3.D3_FILIAL = %XFILIAL:SD3%
					AND SD3.D3_COD = PRODUT
					AND SD3.D3_TM = '010'
					AND SD3.D3_ESTORNO <> 'S'
					AND SD3.%NotDel%
					AND SD3.D3_EMISSAO = %Exp:vfDtRef%
					GROUP BY PRODUT
					)PRODUC
					WHERE PESO > 0
				EndSql
	
				If (_cAlias)->QUANT <= 0
					(_cAlias)->(DbCloseArea())
					_cAlias	:=	GetNextAlias()
					
					BeginSql Alias _cAlias
						%NoParser%
						WITH    PORCELANATO
						AS ( SELECT   B1_COD PRODUT
						FROM     %TABLE:SB1%
						WHERE    B1_FILIAL = %XFILIAL:SB1%
						AND B1_YSTATUS = '1'
						AND B1_YCLASSE = ' '
						AND B1_YTPPROD <> 'RP'
						AND B1_YFORMAT NOT IN ('BN','BP','AL')
						AND %NotDel%
						)
						SELECT  ISNULL(AVG(G1_QUANT),0) QUANT
						FROM    PORCELANATO PRC
						INNER JOIN %TABLE:SG1% SG1 ON G1_FILIAL = %XFILIAL:SG1%
						AND G1_COD = PRODUT
						AND SG1.%NotDel%
						INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = %XFILIAL:SB1%
						AND B1_COD = G1_COMP
						AND B1_COD IN (
										SELECT  SD3M.D3_COD
										FROM    %TABLE:SD3% SD3M
										INNER JOIN %TABLE:SB1% SB1M ON SB1M.B1_FILIAL = %XFILIAL:SB1%
										AND SB1M.B1_COD = SD3M.D3_COD
										AND SB1M.B1_DESC NOT LIKE 'PBI%'
										AND SB1M.B1_GRUPO = 'PI01'
										AND SB1M.%NotDel%
										WHERE   SD3M.D3_FILIAL = %XFILIAL:SD3%
										AND SD3M.D3_EMISSAO = %Exp:vfDtRef%
										AND SD3M.D3_TM = '010'
										AND SD3M.D3_ESTORNO = ' '
										AND SD3M.%NotDel%
										)
						AND B1_GRUPO = 'PI01'
						AND SB1.%NotDel%
					EndSql
				
				EndIf
	
				BeginSql Alias _cAlias2
					SELECT  ISNULL(SUM(D3_QUANT),0) QUANT
					FROM    %TABLE:SD3% SD3
					INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = %XFILIAL:SB1%
					AND B1_COD = D3_COD
					AND B1_DESC NOT LIKE 'PBI%'
					AND B1_GRUPO = 'PI01'
					AND SB1.%NotDel%
					WHERE   D3_FILIAL = %XFILIAL:SD3%
					AND D3_EMISSAO = %Exp:vfDtRef%
					AND D3_TM = '010'
					AND D3_YRECURS	= %Exp:M->Z91_RECURS%
					AND D3_ESTORNO = ' '
					AND SD3.%NotDel%					
				EndSql
			Else

				BeginSql Alias _cAlias
					%NoParser%
					WITH PORCELANATO
					AS (
					SELECT B1_COD PRODUT
					FROM %TABLE:SB1%
					WHERE B1_FILIAL = %XFILIAL:SB1%
					AND B1_YSTATUS = '1'
					AND B1_YCLASSE = ' '
					AND B1_YTPPROD <> 'RP'
					AND B1_YFORMAT NOT IN (
					'BN'
					,'BP'
					,'AL'
					)
					AND %NotDel%
					)
					SELECT ISNULL(SUM(PESO)/SUM(PRODUC),0) QUANT FROM (
					SELECT PRODUT
					,SUM(D3_QUANT) PRODUC
					,SUM(D3_QUANT) * (
					SELECT ISNULL(AVG(G1_QUANT), 0)
					FROM %TABLE:SG1% SG1
					INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = %XFILIAL:SB1%
					AND B1_COD = G1_COMP
					AND B1_GRUPO = 'PI01'
					AND SB1.%NotDel%
					WHERE G1_FILIAL = %XFILIAL:SG1%
					AND G1_COD = PRODUT
					AND SG1.%NotDel%
					) PESO
					FROM PORCELANATO PRC
					INNER JOIN %TABLE:SD3% SD3 ON SD3.D3_FILIAL = %XFILIAL:SD3%
					AND SD3.D3_COD = PRODUT
					AND SD3.D3_TM = '010'
					AND SD3.D3_ESTORNO <> 'S'
					AND SD3.%NotDel%
					AND SD3.D3_EMISSAO = %Exp:vfDtRef%
					GROUP BY PRODUT
					)PRODUC
					WHERE PESO > 0
				EndSql
	
				If (_cAlias)->QUANT <= 0
					(_cAlias)->(DbCloseArea())
					_cAlias	:=	GetNextAlias()
					
					BeginSql Alias _cAlias
						%NoParser%
						WITH    PORCELANATO
						AS ( SELECT   B1_COD PRODUT
						FROM     %TABLE:SB1%
						WHERE    B1_FILIAL = %XFILIAL:SB1%
						AND B1_YSTATUS = '1'
						AND B1_YCLASSE = ' '
						AND B1_YTPPROD <> 'RP'
						AND B1_YFORMAT NOT IN ('BN','BP','AL')
						AND %NotDel%
						)
						SELECT  ISNULL(AVG(G1_QUANT),0) QUANT
						FROM    PORCELANATO PRC
						INNER JOIN %TABLE:SG1% SG1 ON G1_FILIAL = %XFILIAL:SG1%
						AND G1_COD = PRODUT
						AND SG1.%NotDel%
						INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = %XFILIAL:SB1%
						AND B1_COD = G1_COMP
						AND B1_GRUPO = 'PI01'
						AND SB1.%NotDel%
					EndSql
				
				EndIf
	
				BeginSql Alias _cAlias2
					SELECT  ISNULL(SUM(D3_QUANT),0) QUANT
					FROM    %TABLE:SD3% SD3
					INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = %XFILIAL:SB1%
					AND B1_COD = D3_COD
					AND B1_DESC NOT LIKE 'PBI%'
					AND B1_GRUPO = 'PI01'
					AND SB1.%NotDel%
					WHERE   D3_FILIAL = %XFILIAL:SD3%
					AND D3_EMISSAO = %Exp:vfDtRef%
					AND D3_TM = '010'
					AND D3_ESTORNO = ' '
					AND SD3.%NotDel%					
				EndSql
			EndIf



			GdFieldPut("Z91_INDCAL", (_cAlias)->QUANT, n)
			GdFieldPut("Z91_PRODUC", (_cAlias2)->QUANT, n)

			_nQuant	:=	(_cAlias2)->QUANT / (_cAlias)->QUANT
			(_cAlias)->(DbCloseArea())
			(_cAlias2)->(DbCloseArea())					
			RestArea( vfArea )
			GdFieldPut("Z91_PORDM2", _nQuant, n)
		ElseIf Alltrim(M->Z91_RECURS) $ "FLS001/LB0001/LB0002/FLS002"
			_cAlias		:=	GetNextAlias()
			_cAlias2	:=	GetNextAlias()

			BeginSql Alias _cAlias
				%NoParser%
				WITH PORCELANATO
				AS (
				SELECT B1_COD PRODUT
				FROM %TABLE:SB1%
				WHERE B1_FILIAL = %XFILIAL:SB1%
				AND B1_YSTATUS = '1'
				AND B1_YCLASSE = ' '
				AND B1_YTPPROD <> 'RP'
				AND B1_YFORMAT IN (
				'BN'
				,'BP'
				,'AL'
				)
				AND %NotDel%
				)
				SELECT SUM(PESO)/SUM(PRODUC) QUANT FROM (
				SELECT PRODUT
				,SUM(D3_QUANT) PRODUC
				,SUM(D3_QUANT) * (
				SELECT ISNULL(AVG(G1_QUANT), 0)
				FROM %TABLE:SG1% SG1
				INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = %XFILIAL:SB1%
				AND B1_COD = G1_COMP
				AND B1_GRUPO = 'PI01'
				AND SB1.%NotDel%
				WHERE G1_FILIAL = %XFILIAL:SG1%
				AND G1_COD = PRODUT
				AND SG1.%NotDel%
				) PESO
				FROM PORCELANATO PRC
				INNER JOIN %TABLE:SD3% SD3 ON SD3.D3_FILIAL = %XFILIAL:SD3%
				AND SD3.D3_COD = PRODUT
				AND SD3.D3_TM = '010'
				AND SD3.D3_ESTORNO <> 'S'
				AND SD3.%NotDel%
				AND SD3.D3_EMISSAO = %Exp:vfDtRef%
				GROUP BY PRODUT
				)PRODUC
			EndSql

			If (_cAlias)->QUANT <= 0
				(_cAlias)->(DbCloseArea())
				_cAlias	:=	GetNextAlias()
				
				BeginSql Alias _cAlias
					%NoParser%
					WITH    PORCELANATO
					AS ( SELECT   B1_COD PRODUT
					FROM     %TABLE:SB1%
					WHERE    B1_FILIAL = %XFILIAL:SB1%
					AND B1_YSTATUS = '1'
					AND B1_YCLASSE = ' '
					AND B1_YTPPROD <> 'RP'
					AND B1_YFORMAT IN ('BN','BP','AL')
					AND %NotDel%
					)
					SELECT  ISNULL(AVG(G1_QUANT),0) QUANT
					FROM    PORCELANATO PRC
					INNER JOIN %TABLE:SG1% SG1 ON G1_FILIAL = %XFILIAL:SG1%
					AND G1_COD = PRODUT
					AND SG1.%NotDel%
					INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = %XFILIAL:SB1%
					AND B1_COD = G1_COMP
					AND B1_GRUPO = 'PI01'
					AND SB1.%NotDel%
				EndSql
			
			EndIf

			BeginSql Alias _cAlias2
				SELECT  ISNULL(SUM(D3_YQTUMID),0) QUANTSM, ISNULL(SUM(D3_QUANT),0) QUANTLB
				FROM    %TABLE:SD3% SD3
				INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = %XFILIAL:SB1%
				AND B1_COD = D3_COD
				AND B1_GRUPO = 'PI01'
				AND SB1.%NotDel%
				WHERE   D3_FILIAL = %XFILIAL:SD3%
				AND D3_EMISSAO = %Exp:vfDtRef%
				AND D3_TM = '010'
				AND D3_ESTORNO = ' '
				AND D3_LOCAL = '20'
				AND SD3.%NotDel%					
			EndSql

			GdFieldPut("Z91_INDCAL", (_cAlias)->QUANT, n)
			If Alltrim(M->Z91_RECURS) == "FLS001
				GdFieldPut("Z91_PRODUC", (_cAlias2)->QUANTSM, n)
			Elseif Alltrim(M->Z91_RECURS) <> 'LB0001'
				GdFieldPut("Z91_PRODUC", (_cAlias2)->QUANTLB, n)
			EndIf

			If Alltrim(M->Z91_RECURS) == "FLS001
				_nQuant	:=	(_cAlias2)->QUANTSM / (_cAlias)->QUANT

			ElseIf Alltrim(M->Z91_RECURS) <> 'LB0001'
				_nQuant := (_cAlias2)->QUANTLB /  (_cAlias)->QUANT
			Else
				_nQuant := GdFieldGet("Z91_PRODUC",n) / (_cAlias)->QUANT
			EndIf



			(_cAlias)->(DbCloseArea())
			(_cAlias2)->(DbCloseArea())					
			RestArea( vfArea )
			GdFieldPut("Z91_PORDM2", _nQuant, n)
		EndIf

	ElseIf Alltrim(cMenVar) == "M->Z91_PRODUC"
		GdFieldPut("Z91_PORDM2", M->Z91_PRODUC/gdFieldGet("Z91_INDCAL",n), n)
	ElseIf Alltrim(cMenVar) == "M->Z91_MEDIDO"

		vfDMedidor   := Posicione("SH4", 1, xFilial("SH4") + M->Z91_MEDIDO, "H4_DESCRI")
		GdFieldPut("Z91_MEDDES", vfDMedidor, n)

		RK002 := " SELECT Z91_QTOFIM "
		RK002 += "   FROM " + RetSqlName("Z91") + " Z91 (NOLOCK)"
		RK002 += "  WHERE Z91_FILIAL = '" + xFilial("Z91") + "' "
		RK002 += "    AND Z91_DATA IN(SELECT MAX(Z91_DATA) "
		RK002 += "                      FROM " + RetSqlName("Z91") + " XZ91 (NOLOCK)"
		RK002 += "                     WHERE Z91_FILIAL = '" + xFilial("Z91") + "' "
		RK002 += "                       AND Z91_DATA < '" + vfDtRef + "' "
		//RK002 += "                       AND Z91_FORMAT = '" + GdFieldGet("Z91_FORMAT",n) + "' "
		RK002 += "                       AND Z91_RECURS = '" + GdFieldGet("Z91_RECURS",n) + "' "
		RK002 += "                       AND Z91_MEDIDO = '" + M->Z91_MEDIDO + "' "
		RK002 += "                       AND XZ91.D_E_L_E_T_ = ' ') "
		//RK002 += "    AND Z91_FORMAT = '" + GdFieldGet("Z91_FORMAT",n) + "' "
		RK002 += "    AND Z91_RECURS = '" + GdFieldGet("Z91_RECURS",n) + "' "
		RK002 += "    AND Z91_MEDIDO = '" + M->Z91_MEDIDO + "' "
		RK002 += "    AND Z91.D_E_L_E_T_ = ' ' "
		RKcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,RK002),'RK02',.F.,.T.)
		dbSelectArea("RK02")
		dbGoTop()
		vfQtoIni := Iif(Alltrim(GdFieldGet("Z91_FORMAT",n)) == 'EST001',0 ,RK02->Z91_QTOFIM)
		RK02->(dbCloseArea())
		Ferase(RKcIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(RKcIndex+OrdBagExt())          //indice gerado

		RestArea( vfArea )
		GdFieldPut("Z91_QTOINI", vfQtoIni, n)

		fCValAj(GdFieldGet("Z91_RECURS",n),M->Z91_MEDIDO)

	ElseIf Alltrim(cMenVar) == "M->Z91_QTOINI"

		vfVazm3 := GdFieldGet("Z91_QTOFIM",n) - M->Z91_QTOINI
		GdFieldPut("Z91_VAZM3", vfVazm3, n)
		calcM3Med(vfVazm3, GdFieldGet("Z91_FATCOR",n))

	ElseIf Alltrim(cMenVar) == "M->Z91_QTOFIM"

		vfVazm3 :=  M->Z91_QTOFIM - GdFieldGet("Z91_QTOINI",n) 
		GdFieldPut("Z91_VAZM3", vfVazm3, n)


		vfVazNm3 := BgvVazNm3( GdFieldGet("Z91_VAZAJU",n), GdFieldGet("Z91_PRESTR",n), GdFieldGet("Z91_TEMPTR",n), GdFieldGet("Z91_FATCOR",n),GdFieldGet("Z91_RECURS",n), GdFieldGet("Z91_DENSID",n) )	

		RestArea( vfArea )
		GdFieldPut("Z91_VAZNM3", vfVazNm3, n)

		vfConsumo := 0	
		If GdFieldGet("Z91_PORDM2",n) <> 0 .and. vfVazNm3 <> 0
			vfConsumo := vfVazNm3 / GdFieldGet("Z91_PORDM2",n)
		EndIf
		GdFieldPut("Z91_CONSUM", vfConsumo, n)

		vfConsumo := 0
		If Alltrim(GdFieldGet("Z91_RECURS",n)) $ "ATM090/ATM140"
			If GdFieldGet("Z91_PRODUC",n) <> 0 .and. vfVazNm3 <> 0
				vfConsumo := vfVazNm3 / GdFieldGet("Z91_PRODUC",n)
			EndIf
			GdFieldPut("Z91_CONNMT", vfConsumo, n)		
		EndIf	
		calcM3Med(vfVazm3, GdFieldGet("Z91_FATCOR",n))

	ElseIf Alltrim(cMenVar) == "M->Z91_PRESTR"

		vfVazNm3 := BgvVazNm3( GdFieldGet("Z91_VAZAJU",n), M->Z91_PRESTR, GdFieldGet("Z91_TEMPTR",n), GdFieldGet("Z91_FATCOR",n),GdFieldGet("Z91_RECURS",n), GdFieldGet("Z91_DENSID",n) )	

		RestArea( vfArea )
		GdFieldPut("Z91_VAZNM3", vfVazNm3, n)

		vfConsumo := 0	
		If GdFieldGet("Z91_PORDM2",n) <> 0 .and. vfVazNm3 <> 0
			vfConsumo := vfVazNm3 / GdFieldGet("Z91_PORDM2",n)
		EndIf
		GdFieldPut("Z91_CONSUM", vfConsumo, n)

		vfConsumo := 0
		If Alltrim(GdFieldGet("Z91_RECURS",n)) $ "ATM090/ATM140"
			If GdFieldGet("Z91_PRODUC",n) <> 0 .and. vfVazNm3 <> 0
				vfConsumo := vfVazNm3 / GdFieldGet("Z91_PRODUC",n)
			EndIf
			GdFieldPut("Z91_CONNMT", vfConsumo, n)		
		EndIf	


	ElseIf Alltrim(cMenVar) == "M->Z91_TEMPTR"

		vfVazNm3 := BgvVazNm3( GdFieldGet("Z91_VAZAJU",n), GdFieldGet("Z91_PRESTR",n), M->Z91_TEMPTR, GdFieldGet("Z91_FATCOR",n),GdFieldGet("Z91_RECURS",n),GdFieldGet("Z91_DENSID",n) )	

		RestArea( vfArea )
		GdFieldPut("Z91_VAZNM3", vfVazNm3, n)
		vfConsumo := 0
		If Alltrim(GdFieldGet("Z91_RECURS",n)) $ "ATM090/ATM140"
			If GdFieldGet("Z91_PRODUC",n) <> 0 .and. vfVazNm3 <> 0
				vfConsumo := vfVazNm3 / GdFieldGet("Z91_PRODUC",n)
			EndIf
			GdFieldPut("Z91_CONSUM", 0, n)
			GdFieldPut("Z91_CONNMT", vfConsumo, n)		
		Else
			If GdFieldGet("Z91_PORDM2",n) <> 0 .and. vfVazNm3 <> 0
				vfConsumo := vfVazNm3 / GdFieldGet("Z91_PORDM2",n)
			EndIf
			GdFieldPut("Z91_CONNMT", 0, n)		
			GdFieldPut("Z91_CONSUM", vfConsumo, n)
		EndIf

	ElseIf Alltrim(cMenVar) == "M->Z91_DENSID"

		vfVazNm3 := BgvVazNm3( GdFieldGet("Z91_VAZAJU",n), GdFieldGet("Z91_PRESTR",n), GdFieldGet("Z91_TEMPTR",n), GdFieldGet("Z91_FATCOR",n),GdFieldGet("Z91_RECURS",n),M->Z91_DENSID )

		RestArea( vfArea )
		GdFieldPut("Z91_VAZNM3", vfVazNm3, n)
		vfConsumo := 0
		If Alltrim(GdFieldGet("Z91_RECURS",n)) $ "ATM090/ATM140"
			If GdFieldGet("Z91_PRODUC",n) <> 0 .and. vfVazNm3 <> 0
				vfConsumo := vfVazNm3 / GdFieldGet("Z91_PRODUC",n)
			EndIf
			GdFieldPut("Z91_CONSUM", 0, n)
			GdFieldPut("Z91_CONNMT", vfConsumo, n)		
		Else
			If GdFieldGet("Z91_PORDM2",n) <> 0 .and. vfVazNm3 <> 0
				vfConsumo := vfVazNm3 / GdFieldGet("Z91_PORDM2",n)
			EndIf
			GdFieldPut("Z91_CONNMT", 0, n)		
			GdFieldPut("Z91_CONSUM", vfConsumo, n)
		EndIf

	ElseIf Alltrim(cMenVar) == "M->Z91_FATCOR"

		for _nI := 1 to Len(aCols)
			if _nI	<> n
				GdFieldPut("Z91_FATCOR", M->Z91_FATCOR, _nI)
			endIf

			/*vfVazNm3 := BgvVazNm3( GdFieldGet("Z91_VAZAJU",_nI), GdFieldGet("Z91_PRESTR",_nI), GdFieldGet("Z91_TEMPTR",_nI), Iif(_nI == n,M->Z91_FATCOR, GdFieldGet("Z91_FATCOR",_nI)),GdFieldGet("Z91_RECURS",_nI),GdFieldGet("Z91_DENSID",_nI) )	

			RestArea( vfArea )
			GdFieldPut("Z91_VAZNM3", vfVazNm3, _nI)
			vfConsumo := 0
			If Alltrim(GdFieldGet("Z91_RECURS",_nI)) $ "ATM090/ATM140"
			If GdFieldGet("Z91_PRODUC",_nI) <> 0 .and. vfVazNm3 <> 0
			vfConsumo := vfVazNm3 / GdFieldGet("Z91_PRODUC",_nI)
			EndIf
			GdFieldPut("Z91_CONNMT", vfConsumo, _nI)
			If GdFieldGet("Z91_PORDM2",_nI) <> 0 .and. vfVazNm3 <> 0
			vfConsumo := vfVazNm3 / GdFieldGet("Z91_PORDM2",_nI)
			EndIf
			GdFieldPut("Z91_CONSUM", vfConsumo, _nI)		
			Else
			If GdFieldGet("Z91_PORDM2",_nI) <> 0 .and. vfVazNm3 <> 0
			vfConsumo := vfVazNm3 / GdFieldGet("Z91_PORDM2",_nI) * GdFieldGet("Z91_PERVAZ",_nI)
			EndIf
			GdFieldPut("Z91_CONNMT", 0, _nI)		
			GdFieldPut("Z91_CONSUM", vfConsumo, _nI)
			EndIf
			*/
		next
		calcM3Med(GdFieldGet("Z91_VAZM3",n),M->Z91_FATCOR)
	ElseIf Alltrim(cMenVar) == "M->Z91_PCI"

		For _nI := 1 to Len(aCols)
			If n <> _nI
				GdFieldPut("Z91_PCI", M->Z91_PCI, _nI)
			EndIf
			vfkCalm2 := GdFieldGet("Z91_CONSUM",_nI) * M->Z91_PCI
			vfKgm2   := fCalcPeso(GdFieldGet("Z91_FORMAT",_nI)) //Posicione("ZZ6", 1, xFilial("ZZ6") + GdFieldGet("Z91_FORMAT",_nI), "ZZ6_KGM2") //  
			vfkCalkg := 0
			If vfKgm2 <> 0   
				vfkCalkg := vfkCalm2 / vfKgm2
			EndIf     
			RestArea( vfArea )
			GdFieldPut("Z91_PESO", vfKgm2, _nI)
			GdFieldPut("Z91_KCALM2", vfkCalm2, _nI)
			GdFieldPut("Z91_KCALKG", vfkCalkg, _nI)

		Next
	EndIf

	oGetDados:Refresh()

	fPondProd() //Pondera a Vazão e o Consumo

Return lRet

Static Function BgvVazNm3( vfVazaom3, vfPresTr, vfTempTr, vfFatCor, vfRecur, vfDensid )

	RI008 := " WITH CONDIC1BR AS (SELECT '1' REF, Z90_CONDIC COD001 "
	RI008 += "                      FROM " + RetSqlName("Z90") + " (NOLOCK) "
	RI008 += "                     WHERE Z90_FILIAL = '" + xFilial("Z90") + "' "
	RI008 += "                       AND Z90_CODIGO = '000001' "
	RI008 += "                       AND '" + vfDtRef + "' >= Z90_DTDE "
	RI008 += "                       AND '" + vfDtRef + "' <= Z90_DTATE "
	RI008 += "                       AND D_E_L_E_T_ = ' '), "
	RI008 += "      CONDIC2BR AS (SELECT '1' REF, Z90_CONDIC COD002 "
	RI008 += "                      FROM " + RetSqlName("Z90") + " (NOLOCK) "
	RI008 += "                     WHERE Z90_FILIAL = '" + xFilial("Z90") + "' "
	RI008 += "                       AND Z90_CODIGO = '000002' "
	RI008 += "                       AND '" + vfDtRef + "' >= Z90_DTDE "
	RI008 += "                       AND '" + vfDtRef + "' <= Z90_DTATE "
	RI008 += "                       AND D_E_L_E_T_ = ' '), "
	RI008 += "      CONDIC3BR AS (SELECT '1' REF, Z90_CONDIC COD003 "
	RI008 += "                      FROM " + RetSqlName("Z90") + " (NOLOCK) "
	RI008 += "                     WHERE Z90_FILIAL = '" + xFilial("Z90") + "' "
	RI008 += "                       AND Z90_CODIGO = '000003' "
	RI008 += "                       AND '" + vfDtRef + "' >= Z90_DTDE "
	RI008 += "                       AND '" + vfDtRef + "' <= Z90_DTATE "
	RI008 += "                       AND D_E_L_E_T_ = ' ') "
	RI008 += " SELECT COD001, COD002, COD003 "
	RI008 += "   FROM CONDIC1BR C1B "
	RI008 += "   JOIN CONDIC2BR C2B ON C2B.REF = C1B.REF "
	RI008 += "   JOIN CONDIC3BR C3B ON C3B.REF = C1B.REF  "
	RIcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RI008),'RI08',.F.,.T.)
	dbSelectArea("RI08")
	dbGoTop()
	vfCod001 := RI08->COD001
	vfCod002 := RI08->COD002
	vfCod003 := RI08->COD003
	RI08->(dbCloseArea())
	Ferase(RIcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(RIcIndex+OrdBagExt())          //indice gerado

	lzVazNm3 := 0
	If vfPresTr <> 0 .and. vfTempTr <> 0 .and. vfFatCor <> 0

		lzVazNm3 := ( ( ( vfCod001 + (vfPresTr / 1000 * vfCod003) ) * vfVazaom3 * (273 + vfCod002) ) / ( (273 + vfTempTr) * vfCod001 ) ) * vfFatCor

	ElseIf vfPresTr = 0 .and. vfTempTr = 0

		lzVazNm3 := vfVazaom3 * vfFatCor

	EndIf

	If Alltrim(vfRecur) == 'ATM090'
		lzVazNm3	:= vfVazaom3 / vfDensid * vfFatCor 	
	EndIf

Return ( lzVazNm3 )

//valida se a linha pode ser deletada
User Function BIAF7DEL()

	Local lRet      := .T.

	If oGetDados:NOPC == 2
		Return .F.
	EndIf

	If (Alltrim(GdFieldGet("Z91_MEDIDO",n)) $ "MED003/MED004/MED005/MED006" .AND. Alltrim(GdFieldGet("Z91_RECURS",n)) == 'EST001') .Or. Alltrim(GdFieldGet("Z91_RECURS",n)) == 'ATM000' 
		lRet	:=	.F.
	endIf

Return lRet

User Function BIAF7SDE()

	Local _lRet	:=	.T.

Return _lRet 

//Confirmar operação
Static Function fConfirma(nOpc)

	Do case
		case nOpc==2
		oDlg:End()
		case nOpc==3 .or. nOpc==4	
		if fTudoOK(nOpc)
			fUpdateReg(nOpc)
			oDlg:End()
		endif
		case nOpc==5 	
		fUpdateReg(nOpc)
		oDlg:End()
	endcase			

return


//Rotina - Tudo OK
Static Function fTudoOK(nOpc)

	local lRet      := .T.
	Local nRecno	:= (cAliasCab)->(Recno())

	If nOpc == 3 .and. lRet
		dbselectarea(cAliasCab) 
		(cAliasCab)->(DbSetOrder(1))

		if (cAliasCab)->(DbSeek(xFilial(cAliasCab)+ DTOS(M->&(cAliasCab+cChaveRel)))) 
			lRet := .F.
			Help(" ",1,"BIAFA00601")
		endif
		(cAliasCab)->(dbSetOrder(1))
		(cAliasCab)->(DbGoTo(nRecno))
	endif

	lRet :=  Obrigatorio(aGets,aTela)
	if lRet
		lRet := oGetDados:TudoOk()
	endif	

return lRet


// Atualiza registros
Static Function fUpdateReg(nOpc)     

	Local aArea	 		:= GetArea()
	Local lLock	 		:= .T.   
	local lGrvIt 		:= .F.
	local ny	 		:= 0   
	local nx	 		:= 0
	local cSeek	 		:= ''
	local cSeek2 		:= ''
	local lExist		:= .F.
	local nPosFormat	:= aScan(aHeader,{|x| AllTrim(x[2]) == "Z91_FORMAT"})
	local nPosRecurs	:= aScan(aHeader,{|x| AllTrim(x[2]) == "Z91_RECURS"})
	local nPosMedidor	:= aScan(aHeader,{|x| AllTrim(x[2]) == "Z91_MEDIDO"})

	BEGIN TRANSACTION

		dbselectarea(cAliasIt) 
		(cAliasIt)->(DbSetOrder(1))

		if (cAliasIt)->(DbSeek(xFilial(cAliasIt)+ DTOS(M->&(cAliasCab+cChaveRel)))) .and. nOpc == 4	

			while !(cAliasIt)->(EOF()) .and. xFilial(cAliasIt)+ DTOS(M->&(cAliasCab+cChaveRel)) == xFilial(cAliasIt)+ DTOS((cAliasIt)->&(cAliasIt+cChaveRel))

				lExist := .F.
				for ny:=1 to Len(aCols) 
					cSeek  := xFilial(cAliasIt) + DTOS(M->&(cAliasCab+cChaveRel)) + aCols[ny,nPosFormat] + aCols[ny,nPosRecurs] + aCols[ny,nPosMedidor]
					cSeek2 := xFilial(cAliasIt) + DTOS((cAliasIt)->&(cAliasIt+cChaveRel)) + (cAliasIt)->Z91_FORMAT + (cAliasIt)->Z91_RECURS + (cAliasIt)->Z91_MEDIDO

					if cSeek == cSeek2
						lExist := .T.
					endif
				next ny

				if !lExist
					(cAliasIt)->(RecLock(cAliasIt,.F.))  
					(cAliasIt)->(DbDelete())
					(cAliasIt)->(MsUnlock())  			
				endif
				(cAliasIt)->(DbSkip())
			end	
		endif

		for ny:=1 to Len(aCols) 

			cSeek := xFilial(cAliasIt) + DTOS(M->&(cAliasCab+cChaveRel)) + aCols[ny,nPosFormat] + aCols[ny,nPosRecurs] + aCols[ny,nPosMedidor]

			if !aCols[ny,len(aCols[ny])]

				if nOpc == 3 
					lGrvIt := .T.
					lLock  := .T.
				else
					if (cAliasIt)->(DbSeek(cSeek))	
						lGrvIt := .T.
						lLock  := .F.				
					elseif nOpc == 4
						lGrvIt := .T.	
						lLock  := .T.
					endif
				endif

				if lGrvIt 
					(cAliasIt)->(RecLock(cAliasIt,lLock))  
					if nOpc == 5
						(cAliasIt)->(DbDelete())
					else
						(cAliasIt)->&(cAliasIt+'_FILIAL') := xFilial(cAliasIt)
						for nx:=1 to Len(aCamposCab) 
							(cAliasCab)->&(aCamposCab[nx]) := M->&(aCamposCab[nx]) 
						next nx 

						for nx := 1 to Len(aHeader)
							(cAliasIt)->&(aHeader[nx,2]) := aCols[ny,nx]
						next nx			
					endif				
					(cAliasIt)->(MsUnlock())   
				endif	
			elseif nOpc == 4 .or. nOpc == 5
				if (cAliasIt)->(DbSeek(cSeek))	
					(cAliasIt)->(RecLock(cAliasIt,.F.))  
					(cAliasIt)->(DbDelete())
					(cAliasIt)->(MsUnlock())  
				endif
			endif
		next ny

		U_BIAFG026(DTOS((cAliasCab)->&(cAliasCab+cChaveRel)))

	END TRANSACTION

	fContrato(DTOS((cAliasCab)->&(cAliasCab+cChaveRel)))

	RestArea(aArea)


return .T.


//Help customizado
Static Function fAjustaHelp()

	local aHlpP  := {}

	aHlpP  := {}
	aAdd(aHlpP, " Linha em Duplicidade!! ")
	PutHelp("PBIAFA00701", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd(aHlpP, " A combinação dos campos " )
	aAdd(aHlpP, " Formato + Recurso + Medidor, " )
	aAdd(aHlpP, " não podem existir em mais " )
	aAdd(aHlpP, " de uma linha!! " )
	PutHelp("SBIAFA00701", aHlpP, aHlpP, aHlpP, .T.)

	aHlpP  := {}
	aAdd(aHlpP, " Esta Data ja esta cadsatrada! ")
	PutHelp("PBIAFA00702", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd(aHlpP, " Informe outra Data! " )
	PutHelp("SBIAFA00702", aHlpP, aHlpP, aHlpP, .T.)

return

static function calcM3Med(_nVazao, _nFatCor)

	Local nPosRecurs	:=	aScan(aHeader,{|x| AllTrim(x[2]) == "Z91_RECURS"})
	Local nPosMedidor	:=	aScan(aHeader,{|x| AllTrim(x[2]) == "Z91_MEDIDO"})
	Local nValor		:=	0
	Local _nI			:=	0
	Local nPosMED6	:=	0


	GdFieldPut("Z91_VAZNM3",_nVazao * _nFatCor  ,n)
	For _nI	:= 1 to Len(aCols)
		If _nI<> n
			GdFieldPut("Z91_VAZNM3",GdFieldGet("Z91_VAZM3",_nI) * _nFatCor  ,_nI)
		EndIf
	Next


	If Alltrim(GdFieldGet("Z91_RECURS",n)) == "EST001" .And. Alltrim(GdFieldGet("Z91_MEDIDO",n)) $ "MED004/MED005"
		For _nI	:=	1 to Len(aCols)
			If Alltrim(GdFieldGet("Z91_RECURS",_nI)) == "EST001"
				If Alltrim(GdFieldGet("Z91_MEDIDO",_nI)) == "MED004"
					nValor	+=  GdFieldGet("Z91_VAZM3",_nI)
				Elseif Alltrim(GdFieldGet("Z91_MEDIDO",_nI)) == "MED005"
					nValor	-=	GdFieldGet("Z91_VAZM3",_nI)
				Elseif Alltrim(GdFieldGet("Z91_MEDIDO",_nI)) == "MED006"
					nPosMed6	:=	_nI
				endIf		
			EndIf
		Next
		If nPosMed6 > 0
			GdFieldPut("Z91_VAZM3",nValor ,nPosMed6)
			GdFieldPut("Z91_VAZNM3",nValor * _nFatCor,nPosMed6)
		endif
	EndIf

return

Static Function fCalcPeso(_cFormat)

	Local 	_nPeso	:=	0
	Local	_cAlias
	Local	_aLotes	:=	{}
	Local 	_cProdut	:=	""
	Local 	_nTotal	:=	0
	Local 	_nLotes	:=	0
	Local	_nPesoPad	:=	0
	Local	_ntotGer	:=	0
	Local	_nI

	If !Empty(_cFormat)
		_cAlias	:=	GetNextAlias()

		BeginSql Alias _cAlias
			%NoParser%
			WITH Z75
			AS (
			SELECT Z75_PRODUT
			,SUM(Z75_QUANT) Z75_QUANT
			FROM %TABLE:Z75% Z75
			INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = ''
			AND B1_COD = Z75_PRODUT
			AND B1_YFORMAT = %Exp:_cFormat%
			AND SB1.%NotDel%
			WHERE Z75_FILIAL = %XFILIAL:Z75%
			AND Z75_DATARF = %Exp:vfDtRef%
			AND Z75_TPMOV IN (
			'ETQ'
			,'RET'
			)
			AND Z75_TPPROD <> 'PP'
			AND Z75.%NotDel%
			GROUP BY Z75_PRODUT
			,SB1.B1_YFORMAT
			,SB1.B1_TIPO
			)
			SELECT Z75_PRODUT
			,ISNULL(D3_LOTECTL, '') LOTE
			,ISNULL(SUM(D3_QUANT), 0) QUANT
			,Z75_QUANT
			,ZZ9_PESO
			FROM Z75
			LEFT JOIN %TABLE:SD3% SD3 ON Z75.Z75_PRODUT = SD3.D3_COD
			AND D3_EMISSAO = %Exp:vfDtRef%
			AND SD3.D3_ESTORNO <> 'S'
			AND SD3.%NotDel%
			AND D3_TM = '010'
			LEFT JOIN %TABLE:ZZ9% ZZ9 ON ZZ9.ZZ9_FILIAL = %XFILIAL:ZZ9%
			AND ZZ9.ZZ9_LOTE = SD3.D3_LOTECTL
			AND ZZ9.ZZ9_PRODUT = SD3.D3_COD
			AND ZZ9.%NotDel%
			GROUP BY Z75_PRODUT
			,D3_LOTECTL
			,Z75_QUANT
			,ZZ9_PESO
			ORDER BY Z75_PRODUT			
		EndSql

		If (_cAlias)->(!EOF())

			_cProdut	:=	(_cAlias)->Z75_PRODUT	
			_ntotal		:=	(_cAlias)->Z75_QUANT
			_nLotes		:=	0
			_nPesoPad	:=	POSICIONE("SB1",1,xFilial("SB1")+_cProdut,"B1_PESO")
			While (_cAlias)->(!EOF())	

				If  _cProdut	<>	(_cAlias)->Z75_PRODUT 

					If _nTotal <> _nLotes

						aAdd(_aLotes,{;
						_cProdut,;
						_ntotal,;
						_nPesoPad,;
						"",;
						_ntotal - _nLotes;
						})

					EndIf
					_ntotGer	+=	_nTotal
					_cProdut	:=	(_cAlias)->Z75_PRODUT	
					_nPesoPad	:=	POSICIONE("SB1",1,xFilial("SB1")+_cProdut,"B1_PESO")
					_ntotal		:=	(_cAlias)->Z75_QUANT
					_nLotes		:=	0					

				EndIf

				(_cAlias)->(aAdd(_aLotes,{;
				(_cAlias)->Z75_PRODUT,;
				(_cAlias)->Z75_QUANT,;
				Iif((_cAlias)->ZZ9_PESO == 0, _nPesoPad, (_cAlias)->ZZ9_PESO),;
				(_cAlias)->LOTE,;
				(_cAlias)->QUANT;
				}))

				_nLotes	+=	(_cAlias)->QUANT

				(_cAlias)->(DbSkip())	
			EndDo

			_ntotGer	+=	_ntotal

			If _nTotal <> _nLotes

				aAdd(_aLotes,{;
				_cProdut,;
				_ntotal,;
				POSICIONE("SB1",1,xFilial("SB1")+_cProdut,"B1_PESO"),;
				"",;
				_ntotal - _nLotes;
				})

			EndIf

			For _nI	:=	1 to Len(_aLotes)

				_nPeso += _aLotes[_nI,3] * _aLotes[_nI,5]

			Next

			_nPeso	:=	_nPeso/_nTotGer
		Else
			(_cAlias)->(DbCloseArea())
			_cAlias	:=	GetNextAlias()
			
			BeginSql Alias _cAlias
				SELECT ISNULL(AVG(B1_PESO),0) PESO
				FROM %TABLE:SB1%
				WHERE B1_YFORMAT = %Exp:_cFormat%
					AND B1_YCLASSE = '1'
					AND B1_TIPO = 'PA'
					AND B1_YSTATUS = '1'
					AND %NotDel%
			EndSql

			_nPeso	:=	(_cAlias)->PESO

		endIf

		(_cAlias)->(DbCloseArea())
	ENDIF		


Return _nPeso


Static Function fCValAj(cRecurs,cMedid)

	Local nLin			:=	n
	Local _aArea		:=	GetArea()
	Local lnx
	Local nx

	For nx:=1 to Len(aCols)
		if !GDdeleted(nx) .and. nx <> nLin 
			if 	xFilial(cAliasIt) + DTOS(M->&(cAliasCab+cChaveRel)) + GdFieldGet("Z91_RECURS",nx) + GdFieldGet("Z91_MEDIDO",nx) ;
			== xFilial(cAliasIt) + DTOS(M->&(cAliasCab+cChaveRel)) + cRecurs + cMedid

				RestArea(_aArea)
				GdFieldPut("Z91_QTOINI", GdFieldGet("Z91_QTOINI",nx), nLin)
				GdFieldPut("Z91_QTOFIM", GdFieldGet("Z91_QTOFIM",nx), nLin)
				GdFieldPut("Z91_VAZM3", GdFieldGet("Z91_VAZM3",nx), nLin)
				GdFieldPut("Z91_VAZNM3", GdFieldGet("Z91_VAZNM3",nx), nLin)
				GdFieldPut("Z91_PRESTR", GdFieldGet("Z91_PRESTR",nx), nLin)
				GdFieldPut("Z91_TEMPTR", GdFieldGet("Z91_TEMPTR",nx), nLin)
				Exit
			endif
		endif	
	Next nx

Return


Static Function fPondProd()

	Local cMenVar   :=	ReadVar()
	Local aArea		:=	GetArea()
	Local nProdM2	:=	Iif(cMenVar == 	"M->Z91_PORDM2", M->Z91_PORDM2,GdFieldGet("Z91_PORDM2",n))
	Local nVazao	:=	GdFieldGet("Z91_VAZM3",n)
	Local nTotPrd	:=	nProdM2
	Local _nI		:=	0
	Local vfVazNm3



	Local nPrestr	:=	Iif(cMenVar == 	"M->Z91_PRESTR", M->Z91_PRESTR,GdFieldGet("Z91_PRESTR",n))	
	Local nTemptr	:=	Iif(cMenVar == 	"M->Z91_TEMPTR", M->Z91_TEMPTR,GdFieldGet("Z91_TEMPTR",n))
	Local nFatcor	:=	Iif(cMenVar == 	"M->Z91_FATCOR", M->Z91_FATCOR,GdFieldGet("Z91_FATCOR",n))
	Local nDensid	:=	Iif(cMenVar == 	"M->Z91_DENSID", M->Z91_DENSID,GdFieldGet("Z91_DENSID",n))

	Local cRecurs	:=	Iif(cMenVar == 	"M->Z91_RECURS", M->Z91_RECURS,GdFieldGet("Z91_RECURS",n))
	Local cMedido	:=	Iif(cMenVar == 	"M->Z91_MEDIDO", M->Z91_MEDIDO,GdFieldGet("Z91_MEDIDO",n))
	Local cFormato	:=	Iif(cMenVar == 	"M->Z91_FORMAT", M->Z91_FORMAT,GdFieldGet("Z91_FORMAT",n))



	If !Empty(cFormato)

		For _nI	:=	1 to Len(aCols)
			If !GDdeleted(_nI) .And. n <> _nI .And. GdFieldGet("Z91_RECURS",_nI) == cRecurs .And. GdFieldGet("Z91_MEDIDO",_nI) == cMedido  
				nTotPrd	+=	GdFieldGet("Z91_PORDM2",_nI)	
			EndIf	
		Next
		vfVazNm3 := BgvVazNm3( (nProdM2/nTotPrd) * nVazao , nPrestr, nTemptr, nFatcor ,cRecurs, nDensid )
		RestArea(aArea)
		GdFieldPut("Z91_PERVAZ",nProdM2/nTotPrd,n)
		GdFieldPut("Z91_VAZAJU",(nProdM2/nTotPrd) * nVazao,n)
		GdFieldPut("Z91_VAZNM3",vfVazNm3,n)
		GdFieldPut("Z91_CONSUM",ROUND(nProdM2/nTotPrd * vfVazNm3/nProdM2,TAMSX3("Z91_CONSUM")[2]),n)
		For _nI	:=	1 to Len(aCols)
			If !GDdeleted(_nI) .And. _nI <> n .And. GdFieldGet("Z91_RECURS",_nI) == cRecurs .And. GdFieldGet("Z91_MEDIDO",_nI) == cMedido  
				GdFieldPut("Z91_PERVAZ",GdFieldGet("Z91_PORDM2",_nI)/nTotPrd,_nI)
				GdFieldPut("Z91_VAZAJU",(GdFieldGet("Z91_PORDM2",_nI)/nTotPrd) * nVazao,_nI)

				vfVazNm3 := BgvVazNm3( GdFieldGet("Z91_PORDM2",_nI)/nTotPrd * nVazao , GdFieldGet("Z91_PRESTR",_nI), GdFieldGet("Z91_TEMPTR",_nI), If(Readvar() == "M->Z91_FATCOR", M->Z91_FATCOR,GdFieldGet("Z91_FATCOR",_nI)),GdFieldGet("Z91_RECURS",_nI), GdFieldGet("Z91_DENSID",_nI) )
				RestArea(aArea)
				GdFieldPut("Z91_VAZNM3",vfVazNm3,_nI)
				GdFieldPut("Z91_CONSUM",ROUND(vFVazNm3/GdFieldGet("Z91_PORDM2",_nI) * GdFieldGet("Z91_PORDM2",_nI)/nTotPrd,TAMSX3("Z91_CONSUM")[2]) ,_nI)

			EndIf	
		Next	
	ElseIf cRecurs <> "EST001"
		vfVazNm3 := BgvVazNm3( nVazao , nPrestr, nTemptr, nFatcor ,cRecurs, nDensid )
		RestArea(aArea)
		GdFieldPut("Z91_PERVAZ",1,n)
		GdFieldPut("Z91_VAZAJU", nVazao ,n)
		GdFieldPut("Z91_CONMT",)
		Iif(vfVazNm3 <> 0 .And. GdFieldGet("Z91_PRODUC",n) <> 0,vfVazNm3/GdFieldGet("Z91_PRODUC",n),0)
		RestArea(aArea)

	EndIf
Return

User Function BIAFA7IC()

	If !ValidPerg()
		Return
	EndIf

	U_BIAFG026(DtoS(DaySum(MV_PAR01,1)), .T.)

	Z91->(DbSeek(xFilial("Z91")+ Dtos(MV_PAR01)))

Return

Static Function ValidPerg()

	local cLoad	    := "BIAFA007" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 := Stod("")
	MV_PAR02 := 0

	aAdd( aPergs ,{1,"Data Base? " 	   		,MV_PAR01 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Fator PCS " 	   		,MV_PAR02 ,"@E 999.999"  ,"",''  ,'.T.',50,.F.})

	If ParamBox(aPergs ,"Relatório de Log de Solicitações",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01)
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)


	EndIf

Return lRet

User Function BFA7VLDT()

	If  M->Z91_DATA <= GetMV("MV_YULRAC")
		MsgSTOP("Não será possível incluir o registro , pois está fora do período de fechamento de estoque.", "OP 049 - Data de Fechamento!!!")
		Return .F.		
	EndIf

Return .T.

Static Function fContrato(_cData)

	Local _cAlias
	Local _cAnoMes	:=	Substr(_cData,1,6) + '%'
	Local _cMsg	:=	"<div><div>Seguem dados do consumo Diário, Acumulado e Acumulado Mensal</div>"
	Local _lGestor	:=	.F.


	_cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias

		SELECT ROUND(ISNULL(SUM(Z91_VAZNM3) / 105000 * 100,0),2) PERC
		FROM Z91010 Z91
		WHERE Z91_FILIAL = %xFilial:Z91%
		AND Z91_DATA = %Exp:_cData%
		AND Z91_RECURS = 'EST001'
		AND Z91_MEDIDO <> 'MED004'
		AND Z91.%NotDel%
	EndSql

	If (_cAlias)->PERC < 85
		_lGestor	:=	.T.
		_cMsg += "<div style='color:red'>"
		_cMsg += "Consumo acumulado diário: "+Alltrim(Str((_cAlias)->PERC))+"% "

	Else
		_cMsg += "<div>"
		_cMsg += "Consumo acumulado diário: "+Alltrim(Str((_cAlias)->PERC))+"% " 

	EndIf

	_cMsg	+=	"</div>"


	(_cAlias)->(DbCloseArea())

	_cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias
		%NoParser%

		WITH REGMES
		AS (SELECT '1' CHV, 
		Z91_DATA DTMES, 
		SUM(Z91_VAZNM3) VLRMES
		FROM Z91010 Z91
		WHERE Z91_FILIAL = %xFilial:Z91%
		AND Z91_DATA LIKE %Exp:_cAnoMes%
		AND Z91_RECURS = 'EST001'
		AND Z91_MEDIDO <> 'MED004'
		AND Z91.%NotDel%
		GROUP BY Z91_DATA),
		ULTDIAS
		AS (SELECT '1' CHV, 
		SUM(Z91_VAZNM3) VLRDIAS
		FROM Z91010 Z91
		WHERE Z91_FILIAL = %xFilial:Z91%
		AND Z91_DATA BETWEEN (SELECT DATEADD(DAY, -7 + 1, CONVERT(DATE, MAX(DTMES))) FROM REGMES) AND (SELECT MAX(DTMES) FROM REGMES)
		AND Z91_RECURS = 'EST001'
		AND Z91_MEDIDO <> 'MED004'
		AND Z91.%NotDel%)
		SELECT TABLG.DAPONT, 
		TABLG.PERAPON, 
		TABLG.DTOT, 
		ROUND(((ACUMUL + (B.VLRDIAS / 7 * DIASREST)) / (105000 * DTOT)) * 100, 2) PERTOT
		FROM
		(
		SELECT MAX(CHV) CHV, 
		DAY(CAST(MAX(DTMES) AS DATETIME)) DAPONT, 
		ROUND(ISNULL(SUM(VLRMES) / (105000 * DAY(CAST(MAX(DTMES) AS DATETIME))) * 100, 0), 2) PERAPON, 
		DAY(EOMONTH(CAST(MAX(DTMES) AS DATETIME))) DTOT, 
		(DAY(EOMONTH(CAST(MAX(DTMES) AS DATETIME))) - DAY(CAST(MAX(DTMES) AS DATETIME))) * (1) DIASREST, 
		SUM(VLRMES) ACUMUL
		FROM REGMES A
		) AS TABLG
		INNER JOIN ULTDIAS B ON B.CHV = TABLG.CHV

	EndSql


	If (_cAlias)->PERAPON < 85
		_lGestor	:=	.T.
		_cMsg += "<div style='color:red'>"
		_cMsg	+=	"Consumo acumulado de " + Alltrim(Str((_cAlias)->DAPONT)) + " dias: " + Alltrim(Str((_cAlias)->PERAPON)) + "%" 
	Else
		_cMsg += "<div>"
		_cMsg	+=	"Consumo acumulado de " + Alltrim(Str((_cAlias)->DAPONT)) + " dias: " + Alltrim(Str((_cAlias)->PERAPON)) + "%"
	EndIf

	_cMsg	+=	"</div>"

	If (_cAlias)->PERTOT < 85
		_lGestor	:=	.T.
		_cMsg += "<div style='color:red'>"
		_cMsg	+=	"Consumo acumulado de " + Alltrim(Str((_cAlias)->DTOT)) + " dias: " + Alltrim(Str((_cAlias)->PERTOT)) + "%"
	Else
		_cMsg += "<div>"
		_cMsg	+=	"Consumo acumulado de " + Alltrim(Str((_cAlias)->DTOT)) + " dias: " + Alltrim(Str((_cAlias)->PERTOT)) + "%"
	EndIf

	_cMsg	+=	"</div>"

	If _lGestor
		_cMsg += "<div style='color:red;font-size:25'><b>O Gestor do Contrato deverá ser procurado!</b></div>"
	EndIf

	_cMsg	+=	"</div>"

	MsgAlert(_cMsg)

	(_cAlias)->(DbCloseArea())
Return