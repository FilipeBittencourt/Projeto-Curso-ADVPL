#DEFINE __ITEM     1
#DEFINE __SEQUEN   2
#DEFINE __PRODUTO  3
#DEFINE __DESCRIC  4
#DEFINE __NUMOP    5
#DEFINE __QUANT    6
#DEFINE __INICIO   7
#DEFINE __ENTREG   8
#DEFINE __PRIOR    9
#DEFINE __OBS     10
#DEFINE __FORMAT  11

#include "protheus.ch"
#include "topconn.ch"
#include "vkey.ch"

/*/{Protheus.doc} BIA255
@author Marcos Alberto Soprani
@since 20/07/11
@version 1.0
@description Painel de Controle para Administração das Ordens de Produção
@type function
/*/

User Function BIA255()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local nI
	Local oDlg01
	Local nUsado := 0
	Local oDlgSC2
	Local aArea    := SC2->(GetArea())
	Local oPCadastro
	Local oPanel
	Local oChkBox
	Local aEdits

	Local _aSize 		:=	{} 
	Local _aObjects		:=	{}
	Local _aInfo		:=	{}
	Local _aPosObj		:=	{}
	Local _bKeyF5	:=	Setkey(VK_F5,{|| U_B255INC()})

	Private lRefresh := .T.
	Private aHeader   := {}
	Private aCols     := {}
	Private aVetor    := {}
	Private aRecnos   := {}
	Private oGetDados
	Private aRotina := {{"Pesquisar", "AxPesqui", 0, 1}, {"Visualizar", "AxVisual", 0, 2},{"Incluir", "AxInclui", 0, 3},{"Alterar", "AxAltera", 0, 4},{"Excluit", "AxDeleta", 0, 5}}
	Private cSeqn := Space(02)
	Private oSeqn
	Private cOpSeq := Space(15)
	Private oOpSeq
	Private cProSeq := Space(15)
	Private oProSeq
	Private cProdPA := Space(15)
	Private oProdPA
	Private cQtdaPA := 0
	Private oQtdaPA
	Private nRadioGrp1 := 1
	Private oRadioGrp1
	Private nRadio2 := 1
	Private oRadio2
	Private INCLUI := .F.
	Private aProdAlt	:=	{}

	_aSize := MsAdvSize(.T.)

	AAdd(_aObjects, {100, 100, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	cHInicio := Time()
	fPerg := "BIA255"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)

	If !ValidPerg()
		Return
	EndIf

	nCol := oMainWnd:nClientWidth
	nLin := oMainWnd:nClientHeight

	/*----- Carrega os dados das OP's para montagem do Grid do Painel Principal-----*/
	aCols := {}
	A0001 := " SELECT C2_NUM,
	A0001 += "        C2_ITEM,
	A0001 += "        C2_SEQUEN,
	A0001 += "        C2_PRODUTO,
	A0001 += "        SUBSTRING(B1_DESC,1,50) B1_DESC,
	A0001 += "        ROUND(C2_QUANT, 0) C2_QUANT,
	A0001 += "        C2_DATPRI,
	A0001 += "        C2_DATPRF,
	A0001 += "        C2_PRIOR,
	A0001 += "        C2_OBS,
	A0001 += "        ISNULL(ZZ6_DESC, ' ') ZZ6_DESC,
	A0001 += "        C2_YDTDISP,
	A0001 += "        C2_YQTRTFC	
	A0001 += "   FROM "+RetSqlName("SC2")+" SC2
	A0001 += "  INNER JOIN SB1010 SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	A0001 += "                       AND B1_COD = C2_PRODUTO
	A0001 += "                       AND B1_TIPO = 'PA'
	A0001 += "                       AND SB1.D_E_L_E_T_ = ' '
	A0001 += "   LEFT JOIN "+RetSqlName("ZZ6")+" ZZ6 ON ZZ6_FILIAL = '"+xFilial("ZZ6")+"'
	A0001 += "                       AND ZZ6_COD = B1_YFORMAT
	A0001 += "                       AND ZZ6.D_E_L_E_T_ = ' '
	A0001 += "  WHERE C2_FILIAL = '"+xFilial("SC2")+"'
	A0001 += "    AND C2_DATPRI >= '"+dtos(MV_PAR01)+"'
	A0001 += "    AND C2_DATPRI <=  '"+dtos(MV_PAR02)+"'
	A0001 += "    AND C2_LINHA = '"+MV_PAR03+"'
	A0001 += "    AND C2_PRODUTO BETWEEN " + ValtoSql(MV_PAR04)
	A0001 += "    AND " + ValtoSql(MV_PAR05)
	A0001 += "    AND C2_ITEM = '01'
	A0001 += "    AND C2_SEQUEN = '001'
	A0001 += "    AND C2_STATUS <> 'U'
	A0001 += "    AND C2_DATRF = '       '
	A0001 += "    AND SC2.D_E_L_E_T_ = ' '
	A0001 += "  ORDER BY C2_DATPRI, C2_DATPRF, C2_PRIOR
	TcQuery A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	ProcRegua(RecCount())
	df_seq := 0
	cf_Cont := 0
	kh_log := ""
	cf_Aculm := Space(8)
	While !Eof()
		cTempo := Alltrim(ElapTime(cHInicio, Time()))
		IncProc("Atualizando.... "+A001->C2_PRODUTO+"   Tempo: "+cTempo)

		df_seq ++
		aAdd(aCols, {A001->C2_ITEM,;
		A001->C2_SEQUEN,;
		A001->C2_PRODUTO,;
		A001->B1_DESC,;
		A001->C2_NUM,;
		A001->C2_QUANT,;
		stod(A001->C2_DATPRI),;
		stod(A001->C2_DATPRF),;
		StrZero(df_seq,3),;
		A001->C2_OBS,;
		A001->ZZ6_DESC,;
		stod(A001->C2_YDTDISP),;
		A001->C2_YQTRTFC,;
		.F.})

		dbSelectArea("A001")
		dbSkip()
	End

	If Select("A001") > 0
		dbSelectArea("A001")
		dbCloseArea()
		If File("A001")
			fErase(A001+GetDBExtension())
			fErase(A001+IndexExt())
			fErase(A001+OrdBagExt())
			fErase(A001+".mem")
			fErase(A001+".001")
			fErase(A001+".002")
			fErase(A001+".003")
		EndIf
	Endif

	Define FONT oFont   NAME "Arial"          SIZE 0,14 BOLD
	Define FONT oFont2  NAME "Lucida Console" SIZE 0,14 BOLD
	CursorWait()

	oDlgSC2      := MSDialog():New( _aSize[7],0,_aSize[6],_aSize[5],"Painel de Controle de OPs",,,.F.,,,,,,.T.,,,.T. )

	fHeader(aHeader)

	SetKey(VK_F4,{|| BIA255B()})
	aEdits := {"C2_QUANT","C2_DATPRI","C2_DATPRF","C2_PRIOR","C2_OBS","C2_YQTRTFC"}
	oGetDados :=   MsGetDados():New(_aPosObj[1,1], _aPosObj[1,2], _aPosObj[1,3], _aPosObj[1,4], 4       ,"U_BIA255A()",          ,          , .F.,aEdits      ,    , .F.,9999,'U_BIA255D()',             , ,          ,oDlgSC2)
	SetKey(VK_F7,{|| BIA255G()})
	SetKey(VK_F9,{|| BIA255I()})

	oDlgSC2:bInit := {||EnchoiceBar(oDlgSC2, {|| ExecBlock("BIA255F",.F.,.F.), oDlgSC2:End() }, {|| df_Fch := .F., Iif(Len(aProdalt) > 0, MSGINFO("As quantidades de alguns produtos foram alteradas, portanto somente a opção confirmar poderá ser utilizada!"), df_Fch := MsgYESNO("Confirma cancelamento das Alterações?")), IIf(df_Fch, oDlgSC2:End(), ) }, , {{"NOTE",{|| ExecBlock("BIA255J",.F.,.F.) },"Legenda"}} )}
	oDlgSC2:Activate(,,,.T.)

	If Len(aProdAlt) > 0
		wfSend()
	EndIf

	RestArea(aArea)
	SetKey(VK_F4,{||})
	SetKey(VK_F7,{||})
	SetKey(VK_F9,{||})
	Setkey(VK_F5,_bKeyF5)

Return

/*---------+----------+-------+-----------------------+------+-----------+
|Função    | fHeader  | Autor | Marcos Alberto        | Data | 20/07/11  |
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Monta o Header da tela                                      |
|          |                                                             |
+----------+------------------------------------------------------------*/
Static Function fHeader(aHeader)

	dbSelectArea("SX3")
	dbSetOrder(2)

	dbSeek("C2_ITEM")
	aAdd(aHeader,{"It"             ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("C2_SEQUEN")
	aAdd(aHeader,{"Seq"            ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("C2_PRODUTO")
	aAdd(aHeader,{x3_titulo        ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("B1_DESC")
	aAdd(aHeader,{x3_titulo        ,x3_campo   ,x3_picture         ,50        ,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("C2_NUM")
	aAdd(aHeader,{"NumOp"          ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("C2_QUANT")
	aAdd(aHeader,{x3_titulo        ,x3_campo   ,"@E 9999,999,999"  ,x3_tamanho,0         ,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("C2_DATPRI")
	aAdd(aHeader,{x3_titulo        ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("C2_DATPRF")
	aAdd(aHeader,{x3_titulo        ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("C2_PRIOR")
	aAdd(aHeader,{x3_titulo        ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("C2_OBS")
	aAdd(aHeader,{x3_titulo        ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("ZZ6_DESC")
	aAdd(aHeader,{"Formato"        ,"ZZ6DESC"  ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("C2_YDTDISP")
	aAdd(aHeader,{x3_titulo        ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})
	dbSeek("C2_YQTRTFC")
	aAdd(aHeader,{x3_titulo        ,x3_campo   ,x3_picture         ,x3_tamanho,x3_decimal,,x3_usado,x3_tipo,         ,x3_context})


Return

/*---------+----------+-------+-----------------------+------+-----------+
|Função    | BIA255A  | Autor | Marcos Alberto        | Data | 20/07/11  |
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Atualiza o label com informações de totalizadores           |
|          |                                                             |
+----------+------------------------------------------------------------*/
User Function BIA255A

Return .T.

/*---------+----------+-------+-----------------------+------+-----------+
|Função    | BIA255A  | Autor | Marcos Alberto        | Data | 20/07/11  |
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Reindexa as Ordens de Produção por Formato                  |
|          |                                                             |
+----------+------------------------------------------------------------*/
Static Function BIA255B

	local r

	If MsgYESNO("Confirma reorganização das Ordens de Produção por Formato???")

		aCols2 := aSort(aCols,,,{|x,y| x[__FORMAT] < y[__FORMAT] })
		aCols3 := {}
		df_seq := 0
		For r := 1 To Len(aCols2)
			df_seq ++
			aAdd(aCols3, {aCols2[r,1],;
			aCols2[r,2],;
			aCols2[r,3],;
			aCols2[r,4],;
			aCols2[r,5],;
			aCols2[r,6],;
			aCols2[r,7],;
			aCols2[r,8],;
			StrZero(df_seq,3),;
			aCols2[r,10],;
			aCols2[r,11],;
			aCols2[r,12],;
			aCols2[r,13],;
			.F.})
		Next r

		aCols := {}
		aCols := aCols3

	EndIf

Return .T.

/*---------+----------+-------+-----------------------+------+-----------+
|Função    | BIA255D  | Autor | Marcos Alberto        | Data | 15.03.2007|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Atualização da sequencia de prioridade das OP's             |
|          |                                                             |
+----------+------------------------------------------------------------*/
User Function BIA255D

	Local n_op,nOrd,nPasso,nX,r
	Local saArea   := GetArea()
	Local _nPSegOp	:=	0

	gk_Retn := .T.

	If Alltrim(__readvar) == "M->C2_PRIOR"
		cOld := n
		cNew := Val(M->C2_PRIOR)
		If cNew < 1 .or. cNew > Len(aCols)
			Return .F.
		EndIf
		n_op := Val(RetAsc(cOld,3,.F.))
		nOrd := Val(RetAsc(cNew,3,.F.))
		nPasso := Iif(nOrd > n_op, 1, -1)
		aColsOld := aClone(aCols[n_op])

		FOR nX := n_op TO nOrd STEP nPasso
			cNewOrder := RetAsc(Str(nX),3,.T.)
			If nX == nOrd
				aCols[nX]   := aClone(aColsOld)
				aCols[nX,__PRIOR] := cNewOrder
			Else
				aCols[nX] := aClone(aCols[nX+nPasso])
				aCols[nX,__PRIOR] := cNewOrder
			EndIf
			If nX == n_op
				GdFieldPut("C2_PRIOR",cNewOrder,nX)
				M->C2_PRIOR := cNewOrder
			EndIf
		Next nX
		aCols2 := aSort(aCols,,,{|x,y| x[__PRIOR] < y[__PRIOR] })
		aCols := {}
		aCols := aCols2

	ElseIf Alltrim(__readvar) == "M->C2_DATPRI"
		If M->C2_DATPRI < dDataBase .or. ((M->C2_DATPRI > GdFieldGet("C2_DATPRF",n) .And. !Empty(GdFieldGet("C2_NUM",n)) .Or. (Empty(GdFieldGet("C2_NUM",n)) .And. !Empty(GdFieldGet("C2_DATPRF",n)) ) ) )
			gk_Retn := .F.
		EndIf

	ElseIf Alltrim(__readvar) == "M->C2_DATPRF"
		If M->C2_DATPRF < dDataBase .or. M->C2_DATPRF < GdFieldGet("C2_DATPRI",n)
			gk_Retn := .F.
		EndIf

	ElseIf Alltrim(__readvar) == "M->C2_QUANT" 
		If aScan(aProdAlt,{|x| x[1] == GdFieldGet("C2_NUM",n) .And. x[2] == GdFieldGet("C2_ITEM",n);
			.And. x[3] == GdFieldGet("C2_SEQUEN",n) .And. x[4] == GdFieldGet("C2_PRODUTO",n)})
			MsgINFO("Não é permitido ajustar a quantidade novamente para essa OP! Para tal, utilize o botão confirmar e em seguida abra novamente a rotina e realize a alteração.")					
			gk_Retn := .F.
		Else
			If !Empty(GdFieldGet("C2_NUM",n))
				vh_Abatim :=  M->C2_QUANT - GdFieldGet("C2_QUANT",n)
	
				VL007 := "   WITH EMPENH AS (SELECT '1' CHV, SUM(PZ0_QUANT) QUANT
				VL007 += "                     FROM " + RetSqlName("PZ0")
				VL007 += "                    WHERE PZ0_FILIAL = '"+xFilial("PZ0")+"'
				VL007 += "                      AND PZ0_OPNUM = '"+GdFieldGet("C2_NUM",n)+"'
				VL007 += "                      AND PZ0_CODPRO = '"+GdFieldGet("C2_PRODUTO",n)+"'
				VL007 += "                      AND D_E_L_E_T_ = ' ')
				VL007 += "      ,
				VL007 += "        SALDOP AS (SELECT '1' CHV, C2_QUANT - C2_QUJE SALDO
				VL007 += "                     FROM " + RetSqlName("SC2")
				VL007 += "                    WHERE C2_FILIAL = '"+xFilial("SC2")+"'
				VL007 += "                      AND C2_NUM = '"+GdFieldGet("C2_NUM",n)+"'
				VL007 += "                      AND C2_PRODUTO = '"+GdFieldGet("C2_PRODUTO",n)+"'
				VL007 += "                      AND D_E_L_E_T_ = ' ')
				VL007 += " SELECT SLP.SALDO , EPH.QUANT
				VL007 += "   FROM EMPENH EPH
				VL007 += "  INNER JOIN SALDOP SLP ON SLP.CHV = EPH.CHV
				VLIndex := CriaTrab(Nil,.f.)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,VL007),'VL07',.T.,.T.)
				dbSelectArea("VL07")
				dbGoTop()
				msCartei  := VL07->QUANT
				msSaldoP  := VL07->SALDO + vh_Abatim - VL07->QUANT
				msSaldoD  := VL07->SALDO +  vh_Abatim
				VL07->(dbCloseArea())
				Ferase(VLIndex+GetDBExtension())
				Ferase(VLIndex+OrdBagExt())
				
				// Tratamento para controle de empenho de OP para Carteira de Vendas e Quantidade já entregue - Por Marcos Alberto Soprani - em 30/01/15 - conforme OS effettivo 0409-15
				If vh_Abatim < 0 .And. msSaldoP < 0
					MsgINFO("Não é permitido ajustar a quantidade da maneira que se pretende, porque irá afetar a disponibilidade do saldo versus o empenho da OP na carteira " + Transform(msCartei, "@E 999,999.99")+ "!!!")
					gk_Retn := .F.
				EndIf
				
				If gk_Retn
					_nPSegOp	:=	fGetPSeg(GdFieldGet("C2_PRODUTO",n))
						
					If _nPsegOp	== 0
						MsgInfo("O Produto " + GdFieldGet("C2_PRODUTO",n) + " e seu formato não possuem % de segurança cadastrado!")
					EndIf
					
					If msCartei/msSaldoD * 100 > _nPSegOp
						MsgInfo("Esta OP ficará com " + Alltrim(Str(Round(msCartei/msSaldoD * 100,2))) + "% de Ocupação. Sendo o percentual de segurança cadastrado de " + Alltrim(Str(_nPSegOp))+"%")
					EndIf
				EndIf
	
				If gk_Retn
	
					If MsgNOYES("Devido exigências técnicas esta alteração será gravada imediatamente na base de dados independentemente do botão <Confirmar> da tela do Painel de Controle. Confirma a alteração?")
	
						nPerc   := vh_Abatim/GdFieldGet("C2_QUANT",n)
						If Alltrim(GdFieldGet("C2_ITEM",n)) == "01" .And. Alltrim(GdFieldGet("C2_SEQUEN",n)) == "001" 
							aAdd(aProdAlt,{;
							GdFieldGet("C2_NUM",n),										;	//01-Numero da OP
							GdFieldGet("C2_ITEM",n),									;	//02-Item
							GdFieldGet("C2_SEQUEN",n),									;	//03-Sequencia
							GdFieldGet("C2_PRODUTO",n), 								;	//04-Cod Produto
							GdFieldGet("B1_DESC",n),									;	//05-Desc Produto
							GdFieldGet("C2_QUANT",n),									;	//06-Quant Original
							GdFieldGet("C2_QUANT",n)+ GdFieldGet("C2_QUANT",n) * nPerc,	;	//07-Quant Final
							GdFieldGet("C2_DATPRI",n),									;	//08-Data Inicio
							GdFieldGet("C2_DATPRI",n),									;	//09-Nova Data Inicio
							GdFieldGet("C2_DATPRF",n),									;	//10-Data Fim
							GdFieldGet("C2_DATPRF",n)})										//11-Nova Data Fim
	
						EndIf
						If nPerc <> 0
							//A0001 := " UPDATE " + RetSqlName("SC2")
							//A0001 += "    SET C2_QUANT = ROUND(C2_QUANT + (C2_QUANT * "+Alltrim(Str(nPerc))+"),2) "
							A0001 := "  SELECT R_E_C_N_O_ REG , ROUND(C2_QUANT + (C2_QUANT * "+Alltrim(Str(nPerc))+"),2) QTD "
							A0001 += "  FROM " + RetSqlName("SC2") + " WITH(NOLOCK) "
							A0001 += "  WHERE C2_FILIAL = '"+xFilial("SC2")+"' "
							A0001 += "    AND C2_NUM = '"+GdFieldGet("C2_NUM",n)+"' "
							A0001 += "    AND D_E_L_E_T_ = ' ' "
							MscIndex := CriaTrab(Nil,.f.)
							dbUseArea(.T.,"TOPCONN",TcGenQry(,,A0001),'A001',.F.,.T.)
							dbSelectArea("A001")
							dbGoTop()
							While A001->(!EOF())
								SC2->(DbGoTo(A001->REG))
								Reclock("SC2",.F.)
								SC2->C2_QUANT 	:= A001->QTD
								SC2->(MsUnlock())						
								A001->(DbSkip())
							End
							A001->(dbCloseArea())
							Ferase(MscIndex+GetDBExtension())     //arquivo de trabalho
							Ferase(MscIndex+OrdBagExt())          //indice gerado
	
							//A0003 := " UPDATE "+RetSqlName("SD4")
							A0003 := "	 SELECT R_E_C_N_O_ as REG, ROUND(D4_QUANT + (D4_QTDEORI * "+Alltrim(Str(nPerc))+"),2) QTD, "
							A0003 += "         ROUND(D4_QTDEORI + (D4_QTDEORI * "+Alltrim(Str(nPerc))+"),2) QTDORI"
							A0003 += "   FROM " + RetSqlName("SD4") + " WITH(NOLOCK) "
							A0003 += "   WHERE D4_FILIAL = '"+xFilial("SD4")+"' "
							A0003 += "     AND SUBSTRING(D4_OP,1,6) = '"+GdFieldGet("C2_NUM",n)+"'
							A0003 += "     AND D_E_L_E_T_ = ' ' "
							MscIndex := CriaTrab(Nil,.f.)
							dbUseArea(.T.,"TOPCONN",TcGenQry(,,A0003),'A003',.F.,.T.)
							dbSelectArea("A003")
							dbGoTop()
							While A003->(!EOF())
								SD4->(DbGoTo(A003->REG))
								Reclock("SD4",.F.)
								SD4->D4_QUANT 	:= A003->QTD
								SD4->D4_QTDEORI	:= A003->QTDORI
								SD4->(MsUnlock())						
								A003->(DbSkip())
							End
							A003->(dbCloseArea())
							Ferase(MscIndex+GetDBExtension())     //arquivo de trabalho
							Ferase(MscIndex+OrdBagExt())          //indice gerado
	
						EndIf
	
					Else
						gk_Retn := .F.
					EndIf
	
				EndIf
			EndIf
		EndIf
	ElseIf Alltrim(__readvar) == "M->C2_YQTRTFC" 
	
	
			A0001 := "  SELECT R_E_C_N_O_ REG "
			A0001 += "  FROM " + RetSqlName("SC2") + " WITH(NOLOCK) "
			A0001 += "  WHERE C2_FILIAL = '"+xFilial("SC2")+"' "
			A0001 += "    AND C2_NUM = '"+GdFieldGet("C2_NUM",n)+"' "
			A0001 += "    AND C2_ITEM = '"+GdFieldGet("C2_ITEM",n)+"' "
			A0001 += "    AND C2_SEQUEN = '"+GdFieldGet("C2_SEQUEN",n)+"' "		
			A0001 += "    AND D_E_L_E_T_ = ' ' "
			MscIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,A0001),'A001',.F.,.T.)
			dbSelectArea("A001")
			dbGoTop()
			While A001->(!EOF())
				SC2->(DbGoTo(A001->REG))
				Reclock("SC2",.F.)
				SC2->C2_YQTRTFC 	:= M->C2_YQTRTFC
				SC2->(MsUnlock())						
				A001->(DbSkip())
			End
			A001->(dbCloseArea())
			Ferase(MscIndex+GetDBExtension())     //arquivo de trabalho
			Ferase(MscIndex+OrdBagExt())          //indice gerado

	EndIf

	RestArea(saArea)

Return (gk_Retn)

/*---------+----------+-------+-----------------------+------+-----------+
|Função    | BIA255F  | Autor | Marcos Alberto        | Data | 09.04.2007|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Rotina responsável pela atualização das alterações na       |
|          | base de dados                                               |
+----------+------------------------------------------------------------*/
User Function BIA255F

	Processa({|| RptDetPn()})

Return

Static Function RptDetPn()

	local k
	local nPos
	Local _cNumOp
	Local aMata650
	Local _cLinha	:=	MV_PAR03 
	Local _cLocal	:=	""

	dbSelectArea("SC2")
	ProcRegua(RecCount())
	For k := 1 to Len(aCols)
		If !Empty(aCols[k,__NUMOP])
			IncProc("Atualizando.... "+aCols[k,__NUMOP]+aCols[k,__ITEM]+aCols[k,__SEQUEN])

			/*----- Atualiza informações das Ordens de Produção -----*/
			dbSelectArea("SC2")
			dbSetOrder(1)
			If dbSeek(xFilial("SC2")+aCols[k,__NUMOP]+aCols[k,__ITEM]+aCols[k,__SEQUEN])

				If (SC2->C2_DATPRI <> aCols[k,__INICIO] .Or. SC2->C2_DATPRF <> aCols[k,__ENTREG]) .And. Alltrim(SC2->C2_ITEM) == "01" .And. Alltrim(SC2->C2_SEQUEN) == "001"
					nPos	:=	aScan(aProdAlt,{|x| x[1] == aCols[k,__NUMOP] })
					If nPos	> 0
						aProdAlt[nPos,9]	:=	aCols[k,__INICIO]
						aProdAlt[nPos,11]	:=	aCols[k,__ENTREG]
					Else
						aAdd(aProdAlt,{;
						aCols[k,__NUMOP],			;	//01-Numero da OP
						aCols[k,__ITEM],			;	//02-Item
						aCols[k,__SEQUEN],			;	//03-Sequencia
						aCols[k,__PRODUTO],			;	//04-Cod Produto
						aCols[k,__DESCRIC],			;	//05-Desc Produto
						aCols[k,__QUANT],			;	//06-Quant Original
						aCols[k,__QUANT],			;	//07-Quant Final
						SC2->C2_DATPRI,				;	//08-Data Inicio
						aCols[k,__INICIO],			;	//09-Nova Data Inicio
						SC2->C2_DATPRF,				;	//10-Data Fim
						aCols[k,__ENTREG]})				//11-Nova Data Fim

					EndIf
				EndIf

				RecLock("SC2",.F.)
				SC2->C2_DATPRI := aCols[k,__INICIO]
				SC2->C2_DATPRF := aCols[k,__ENTREG]
				SC2->C2_PRIOR  := aCols[k,__PRIOR]
				SC2->C2_OBS    := aCols[k,__OBS]
				MsUnLock()

				//Fernando/Facile em 18/03/2015 -> Funcao para atualizar reservas e pedidos vinculados a OP
				U_FRRT04AO(SC2->(C2_NUM+C2_ITEM+C2_SEQUEN), SC2->C2_DATPRF, SC2->C2_YDTDISP)

			EndIf
			While !Eof() .and. SC2->C2_FILIAL == xFilial("SC2") .and. SC2->C2_NUM == aCols[k,__NUMOP] .and. SC2->C2_ITEM == aCols[k,__ITEM]
				If SC2->C2_SEQUEN == "001"
					_DatPrf  := SC2->C2_DATPRF
					_DatPri  := SC2->C2_DATPRI
					_DatEmi  := SC2->C2_EMISSAO
					_Operac  := SC2->C2_ROTEIRO
					_Obs     := SC2->C2_OBS
					_DataJf  := SC2->C2_DATAJF
					_Prorid  := SC2->C2_PRIOR
				Else
					RecLock("SC2",.F.)
					SC2->C2_EMISSAO := _DatEmi
					SC2->C2_DATPRI  := _DatPri
					SC2->C2_DATPRF  := _DatPrf
					SC2->C2_ROTEIRO := _Operac
					SC2->C2_OBS     := _Obs
					SC2->C2_DATAJF  := _DataJf
					SC2->C2_PRIOR   := _Prorid
					dbSelectArea("SC2")
					MsUnLock()
				EndIf
				dbSelectArea("SC2")
				dbSkip()
			End

			/*----- Atualiza empenhos a partir dos ajustes efetuados nas OP's -----*/
			dbSelectArea("SD4")
			dbSetOrder(2)
			dbSeek(xFilial("SD4")+aCols[k,__NUMOP]+aCols[k,__ITEM])
			While !Eof() .and. SD4->D4_FILIAL == xFilial("SD4") .and. Substr(SD4->D4_OP,1,8) <= aCols[k,__NUMOP]+aCols[k,__ITEM]
				RecLock("SD4",.F.)
				SD4->D4_DATA := aCols[k,__INICIO]
				MsUnLock()
				dbSelectArea("SD4")
				dbSkip()
			End
		Else
			_cNumOP	:=	GetNumSc2()
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+aCols[k,__PRODUTO]))
			
			U_BFG73LIN(_cLinha,SB1->B1_COD,@_cLocal,.F.)
			
			aMata650  := {{            'C2_SEQUEN'   ,'001'                                    ,NIL},;
			{              'C2_ITEM'     ,'01'                                     ,NIL},;
			{              'C2_NUM'      ,_cNumOP                                  ,NIL},;
			{              'C2_LINHA'    ,_cLinha                                  ,NIL},;
			{              'C2_PRODUTO'  ,SB1->B1_COD                              ,NIL},;
			{              'C2_QUANT'    ,aCols[k,__QUANT]                         ,NIL},;
			{              'C2_QTSEGUM'  ,ConvUm(SB1->B1_COD,aCols[k,__QUANT],0,2) ,NIL},;
			{              'C2_UM'       ,SB1->B1_UM                               ,NIL},;
			{              'C2_CC'       ,SB1->B1_CC                               ,NIL},;
			{              'C2_SEGUM'    ,SB1->B1_SEGUM                            ,NIL},;
			{              'C2_DATPRI'   ,aCols[k,__INICIO]                        ,NIL},;
			{              'C2_DATPRF'   ,aCols[k,__ENTREG]                        ,NIL},;
			{              'C2_REVISAO'  ,SB1->B1_REVATU                          ,NIL},;
			{              'C2_TPOP'     ,"F"                                      ,NIL},;
			{              'C2_EMISSAO'  ,Date()	                               ,NIL},;
			{              'C2_ROTEIRO'  ,SB1->B1_OPERPAD                          ,NIL},;
			{              'C2_OPC'      ,""                                       ,NIL},;
			{              'C2_OBS'      ,aCols[k,__OBS]                           ,NIL},;
			{              'AUTEXPLODE'  ,'S'                                      ,NIL} }
			lMsErroAuto	:=	.F.
			MsExecAuto({|x,Y| Mata650(x,Y)},aMata650,3)
			If lMsErroAuto
				Mostraerro()
			EndIf
		EndIf	
	Next k

Return .T.

/*---------+----------+-------+-----------------------+------+-----------+
|Função    | BIA255G  | Autor | Marcos Alberto        | Data | 13.04.2007|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Pesquisa para posicionamento dentro do vetor                |
|          |             POR OP                                          |
+----------+------------------------------------------------------------*/
Static Function BIA255G

	DEFINE MSDIALOG oDlg02 TITLE "Pesquisa" FROM 50,40 TO 130,350 PIXEL
	@ 015,015 Say "Op/Produto:"                                   Size 048,008 COLOR CLR_BLACK                           PIXEL OF oDlg02
	@ 015,050 MsGet oOpSeq  Var cOpSeq                    Size 048,009 COLOR CLR_BLACK   Picture "@!"            PIXEL OF oDlg02
	DEFINE SBUTTON FROM 015, 115 TYPE 1 ENABLE OF oDlg02 ACTION oDlg02:End()
	ACTIVATE MSDIALOG oDlg02 CENTERED

	nPos := aScan(aCols,{|x| Alltrim(x[__NUMOP]) == Alltrim(cOpSeq) })
	If nPos <> 0
		n:=nPos
		oGetDados:oBrowse:nAt:=nPos
		oGetDados:oBrowse:Refresh()
		oGetDados:oBrowse:SetFocus()
	Else
		nPos := aScan(aCols,{|x| Alltrim(x[__PRODUTO]) == Alltrim(cOpSeq) })
		If nPos <> 0
			n:=nPos
			oGetDados:oBrowse:nAt:=nPos
			oGetDados:oBrowse:Refresh()
			oGetDados:oBrowse:SetFocus()
		EndIf 
	EndIf

Return

/*---------+----------+-------+-----------------------+------+-----------+
|Função    | BIA255I  | Autor | Marcos Alberto        | Data | 17.04.2007|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Muda a Ordens de apresentação do aCols                      |
|          |                                                             |
+----------+------------------------------------------------------------*/
Static Function BIA255I

	local r
	DEFINE MSDIALOG oDlg04 TITLE "Mudança de Indices" FROM 50,40 TO 150,350 PIXEL

	@ 006,007 TO 045,100 LABEL "" PIXEL OF oDlg04
	@ 010,010 Radio oRadioGrp1 Var nRadioGrp1 Items "Por Prioridade","Por Produto","Por Data" 3D Size 056,011 PIXEL OF oDlg04

	DEFINE SBUTTON FROM 018, 115 TYPE 1 ENABLE OF oDlg04 ACTION oDlg04:End()
	ACTIVATE MSDIALOG oDlg04 CENTERED

	If nRadioGrp1 == 1
		aCols := aSort(aCols,,,{|x,y| x[__PRIOR] < y[__PRIOR] })
	ElseIf nRadioGrp1 == 2
		aCols := aSort(aCols,,,{|x,y| x[__PRODUTO] < y[__PRODUTO] })
	ElseIf nRadioGrp1 == 3
		aVet1 := aSort(aCols,,,{|x,y| dtos(x[__ENTREG])+x[__PRIOR] < dtos(y[__ENTREG])+y[__PRIOR] })
		aCols := {}
		df_seq := 0
		For r := 1 To Len(aVet1)
			df_seq ++
			aAdd(aCols, {aVet1[r,1],;
			aVet1[r,2],;
			aVet1[r,3],;
			aVet1[r,4],;
			aVet1[r,5],;
			aVet1[r,6],;
			aVet1[r,7],;
			aVet1[r,8],;
			StrZero(df_seq,3),;
			aVet1[r,10],;
			aVet1[r,11],;
			aVet1[r,12],;
			aCols2[r,13],;
			.F.})
		Next r
	EndIf

Return

/*---------+----------+-------+-----------------------+------+-----------+
|Função    | BIA255J  | Autor | Marcos Alberto        | Data | 25.04.2007|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Legenda para facilitar o uso da rotina                      |
|          |                                                             |
+----------+------------------------------------------------------------*/
User Function BIA255J

	Define FONT oFont3  NAME "Arial" SIZE 0,14 BOLD
	Define MsDialog oDlg002 TITLE 'Legenda....' FROM nLin*.19,nCol*.002 TO nLin*.42,nCol*.400 PIXEL
	oCapA01 := tSay():New(010,010,{|| "F4  -  Mudança da Ordem por Formanto"                                    },oDlg002,,oFont3,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,20)
	oCapA02 := tSay():New(020,010,{|| "F7  -  Pesquisa pelo número da OP"                                       },oDlg002,,oFont3,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,20)
	oCapA02 := tSay():New(030,010,{|| "F9  -  Permite a Mudanca da Ordem de distribução dos registros"          },oDlg002,,oFont3,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,20)
	@ 080,200 Button "Fecha" Size 037,012 PIXEL OF oDlg002 ACTION oDlg002:End()

	Activate MsDialog oDlg002 Centered

Return

Static Function ValidPerg()

	local cLoad	    := "BIA255" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 :=	Stod("")
	MV_PAR02 := STOD('')
	MV_PAR03 := SPACE(TAMSX3("C2_LINHA")[1])
	MV_PAR04 := SPACE(TAMSX3("B1_COD")[1])
	MV_PAR05 := SPACE(TAMSX3("B1_COD")[1])
	
	aAdd( aPergs ,{1,"Data De " 		  	,MV_PAR01 ,""  ,"",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Data Ate " 		  	,MV_PAR02 ,""  ,"",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Linha de Producao " 	,MV_PAR03 ,""  ,"",'ZCO'  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Produto De " 		  	,MV_PAR04 ,""  ,"",'SB1'  ,'.T.',70,.F.})
	aAdd( aPergs ,{1,"Produto Ate " 		,MV_PAR05 ,""  ,"",'SB1'  ,'.T.',70,.F.})

	If ParamBox(aPergs ,"Painel de Controle de OP's",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01)
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05)
	EndIf
Return lRet



/*---------+----------+-------+-----------------------+------+-----------+
|Função    | wfSend   | Autor | Gabriel Rossi         | Data | 30.05.2017|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Envio de e-mail de alteração do Programa de Produção        |
|          |                                                             |
+----------+------------------------------------------------------------*/
Static function wfSend()

	Local _cHtml
	Local _nI
	Local df_Dest := U_EmailWF('BIA255ALT', cEmpAnt)
	Local df_Assu := "Log de Alteração de Ordens de Produção"
	Local df_Erro := df_Assu + " não enviado. Favor verificar!!!" 

	_cHtml	:=	'	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">     '
	_cHtml	+=	'	<html xmlns="http://www.w3.org/1999/xhtml">                                                                                   '
	_cHtml	+=	'	<head>                                                                                                                        '
	_cHtml	+=	'	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />                                                         '
	_cHtml	+=	'	<title>Untitled Document</title>                                                                                              '
	_cHtml	+=	'	<style type="text/css">                                                                                                       '
	_cHtml	+=	'	<!--                                                                                                                          '
	_cHtml	+=	'	.style3 {color: #000000; }                                                                                                    '
	_cHtml	+=	'	.style4 {color: #FFFFFF; }                                                                                                    '
	_cHtml	+=	'	.style5 {color: #FF0000; }
	_cHtml	+=	'	-->                                                                                                                           '
	_cHtml	+=	'	</style>                                                                                                                      '
	_cHtml	+=	'	</head>                                                                                                                       '
	_cHtml	+=	'	<body>                                                                                                                        '
	_cHtml	+=	'	<p>Log de Alteração de Ordens de Produção.</p>                                                                                '
	_cHtml	+=	'	                                                                                                                              '
	_cHtml	+=	'	<table width="1143" border="1" cellpadding="0" cellspacing="0" bordercolor="#000000" >                                        '
	_cHtml	+=	'	  <tr>                                                                                                                        '
	_cHtml	+=	'	    <th width="129" height="21" bgcolor="#0033FF" scope="col"><div align="center" class="style4">Número da OP</div></th>      ' 
	_cHtml	+=	'	    <th width="60" bgcolor="#0033FF" scope="col"><div align="center" class="style4"> 										  '
	_cHtml	+=	'	      <div align="center">Item</div>                                                                                          '
	_cHtml	+=	'	    </div></th>                                                                                                               '
	_cHtml	+=	'	    <th width="60" bgcolor="#0033FF" scope="col"><div align="center" class="style4">                                          '
	_cHtml	+=	'	      <div align="center">Seq.</div>                                                                                          '
	_cHtml	+=	'	    </div></th>                                                                                                               '
	_cHtml	+=	'		<th width="100" bgcolor="#0033FF" scope="col"><div align="center" class="style4">Cod. Produto</div></th>                  '
	_cHtml	+=	'	    <th width="200" bgcolor="#0033FF" scope="col"><div align="center" class="style4">Desc. Produto</div></th>                 '
	_cHtml	+=	'	    <th width="165" bgcolor="#0033FF" scope="col"><div align="right" class="style4">                                          '
	_cHtml	+=	'	      <div align="center">Qtd. Anterior</div>                                                                                 '
	_cHtml	+=	'	    </div></th>                                                                                                               '
	_cHtml	+=	'	    <th width="165" bgcolor="#0033FF" scope="col"><div align="right" class="style4">                                          '
	_cHtml	+=	'	      <div align="center">Qtd. Nova</div>                                                                                     '
	_cHtml	+=	'	    </div></th>                                                                                                               '
	_cHtml	+=	'	    <th width="165" bgcolor="#0033FF" scope="col"><div align="right" class="style4">                                          '
	_cHtml	+=	'	      <div align="center">Dt. Ini. Anterior</div>                                                                             '
	_cHtml	+=	'	    </div></th> 	                                                                                                          '
	_cHtml	+=	'	    <th width="165" bgcolor="#0033FF" scope="col"><div align="right" class="style4">                                          '
	_cHtml	+=	'	      <div align="center">Dt. Ini. Nova</div>                                                                                 '
	_cHtml	+=	'	    </div></th> 	                                                                                                          '
	_cHtml	+=	'	    <th width="165" bgcolor="#0033FF" scope="col"><div align="right" class="style4">                                          '
	_cHtml	+=	'	      <div align="center">Dt. Fim Anterior</div>                                                                              '
	_cHtml	+=	'	    </div></th> 		                                                                                                      '
	_cHtml	+=	'	    <th width="165" bgcolor="#0033FF" scope="col"><div align="right" class="style4">                                          '
	_cHtml	+=	'	      <div align="center">Dt. Fim Nova</div>                                                                                  '
	_cHtml	+=	'	    </div></th> 		                                                                                                      '
	_cHtml	+=	'     </tr> '

	for _nI	:=	1 to Len(aProdAlt)

		_cHtml += '	  </tr>                                                                                                                      '
		_cHtml += '     <td><div align="center">' + aProdAlt[_nI,1] + '</div></td> '
		_cHtml += '     <td><div align="center">' + aProdAlt[_nI,2] + '</div></td> '
		_cHtml += '     <td><div align="center">' + aProdAlt[_nI,3] + '</div></td> '
		_cHtml += '     <td><div align="center">' + aProdAlt[_nI,4] + '</div></td> '
		_cHtml += '     <td><div align="center">' + aProdAlt[_nI,5] + '</div></td> '
		_cHtml += '     <td><div align="right">' + Transform(aProdAlt[_nI,6],"@E 999,999.99") + '</div></td> '
		_cHtml += '     <td><div align="right" ' + iif(aProdAlt[_nI,7] <> aProdAlt[_nI,6],' class="style5"','') + '>' + TRANSFORM(aProdAlt[_nI,7], "@E 999,999.99") + '</div></td> '
		_cHtml += '     <td><div align="center">' + DtoC(aProdAlt[_nI,8]) + '</div></td> '
		_cHtml += '     <td><div align="center"' + iif(aProdAlt[_nI,9] <> aProdAlt[_nI,8],' class="style5"',"")  + '>' + DtoC(aProdAlt[_nI,9]) + '</div></td> '
		_cHtml += '     <td><div align="center">' + DtoC(aProdAlt[_nI,10]) + '</div></td> '
		_cHtml += '     <td><div align="center"' + iif(aProdAlt[_nI,11] <> aProdAlt[_nI,10],' class="style5"','') + '>' + DtoC(aProdAlt[_nI,11]) + '</div></td> '	
		_cHtml += '   </tr> '

	next

	_cHtml	+=	'	 </table>                                                                                                                     '
	_cHtml	+=	'	<p>by BIA255</p> '
	_cHtml	+=	'	</body>                                                                                                                       '
	_cHtml	+=	'	</html>                                                                                                                       '

	U_BIAEnvMail(, df_Dest, df_Assu, _cHtml, df_Erro)

	aProdAlt	:=	{}

Return


User Function B255INC()

	Local _cPrior	:=	SOMA1(aCols[Len(aCols),9])

	IF ConPad1(,,,"SB1",,, .F.)
		If Empty(aCols[Len(aCols),3])
			aDel(aCols,Len(aCols))
			aSize(aCols,Len(aCols)-1)
		EndIf
		aAdd(aCols, {"01",;
		"001",;
		SB1->B1_COD,;
		SB1->B1_DESC,;
		SPACE(TamSx3("C2_NUM")[1]),;
		1,;
		stod(""),;
		stod(""),;
		_cPrior,;
		SPACE(TAMSX3("C2_OBS")[1]),;
		POSICIONE("ZZ6",1,xFilial("ZZ6") + SB1->B1_YFORMAT,"ZZ6_DESC"),;
		stod(""),;
		.F.})
	EndIf

Return

Static Function fGetPSeg(_cProd)

	Local _aArea	:=	GetArea()
	Local _nPsegOp	:=	0

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+_cProd))
		If SB1->B1_YINDCOM > 0
			_nPSegOp	:=	SB1->B1_YINDCOM
		Else
			DbSelectArea("ZZ6")
			ZZ6->(DbSetOrder(1))
			If ZZ6->(DbSeek(xFilial("ZZ6")+SB1->B1_YFORMAT))
				_nPSegOp	:=	ZZ6->ZZ6_INDCOM
			EndIf
		EndIf
	EndIf	
	RestArea(_aArea)
Return _nPSegOp