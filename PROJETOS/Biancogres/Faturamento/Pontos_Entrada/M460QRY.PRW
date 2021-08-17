#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "topconn.ch"

/*/{Protheus.doc} M460QRY
@author Ranisses A. Corona
@since 02/08/2011
@version 1.0
@description Ponto de entrada para adicionar filtro no SC9 - MATA460 / Deve ser utilizado junto com o P.E. M460FIL
@description Revisoes durante o projeto CICLO DO PEDIDO em 08/2019
@type function
/*/

User Function M460QRY()  //NOVO
	Local cFiltro	:= ""
	Local cQuery	:= Paramixb[1]
	Local cTipo		:= Paramixb[2] //Local do Filtro 1-Primera Tela de Parametros MT461A / 2-Segunda Tela de Parametros MT460A
	Local lUsaCarga	:= GetNewPar("MV_YUSACAR",.F.)  //Define se utiliza a rotina de carga
	Local cAliasTmp

	Private aArea	:= GetArea()
	Private aAreaC9	:= SC9->(GetArea())
	Private cArq 	:= Alias()
	Private cInd	:= IndexOrd()
	Private cReg	:= Recno()

	//Variavel Publica para ser utilizada no PE M460MARK
	Public nPedDe		:= MV_PAR05
	Public nPedAte		:= MV_PAR06
	Public cFilM460QRY	:= ""
	Public aPedOri		:= {}
	Public cEmpCarga	:= MV_PAR21
	Public cQNumCarga	:= Iif(cTipo == 1, MV_PAR19, MV_PAR09)

	//MT461A
	IF lUsaCarga 
		If cTipo == 1	//PRIMEIRA TELA DE PARAMETROS
			If !Empty(MV_PAR19) .And. !Empty(MV_PAR20)
				cFiltro := " AND (C9_AGREG >= '"+MV_PAR19+"' AND C9_AGREG <= '"+MV_PAR20+"') " 
				cQuery	+= cFiltro
			EndIf
		Else			//SEGUNDA E TERCEIRA TELA DE PARAMETROS
			If !Empty(MV_PAR09) .And. !Empty(MV_PAR10)
				cFiltro := " AND (C9_AGREG >= '"+MV_PAR09+"' AND C9_AGREG <= '"+MV_PAR10+"') " 
				cQuery	+= cFiltro
			EndIf
		EndIf
	EndIf

	//Realiza Filtro dos Pedidos Liberados na LM, atraves das Cargas na Biancogres e/ou Incesa.
	If cEmpAnt == "07" .And. !Empty(MV_PAR21) .And. AllTrim(MV_PAR21) <> "07"

		If cTipo == 1	//PRIMEIRA TELA DE PARAMETROS
			If (!Empty(MV_PAR19) .And. !Empty(MV_PAR20)) .Or. (!Empty(MV_PAR05) .And. !Empty(MV_PAR06))

				aPedOri	:= fGetPdOr(MV_PAR21,MV_PAR19,MV_PAR20,MV_PAR05,MV_PAR06)				
				cFiltro	:= " AND ( C9_YEMPORI = '"+MV_PAR21+"' ) "			
				cQuery	+= cFiltro

			EndIf
		EndIf

		//Preenche filtro para ser utilizado no P.E M460MARK
		cFilM460QRY := cFiltro 

		//Adiciona botão para realizar a conferencia de peso entre Cargas
		If Len(aRotina) == 8
			AADD(aRotina,{"Confere Peso","u_fCalcPeso()",0,4,0,.F.})
		EndIf

	EndIf

	#IfDef __DEBUG_FACILE

	// Tiago Rossini Coradini - 25/04/2016 - OS: 4329-15 - Dalvina Maria - Adiciona filtro de Serie na Nota Fiscal de Saida, especifico para LM
	If cEmpAnt == "07"

		cQuery += " AND SC5.C5_YLINHA IN "+FormatIn(U_BIAF032(), "/")

	EndIf

	#EndIf

	If cArq <> ""
		dbSelectArea(cArq)
		dbSetOrder(cInd)
		dbGoTo(cReg)
	EndIf

	RestArea(aAreaC9)
	RestArea(aArea)                     

Return(cQuery)


/*/{Protheus.doc} fGetPdOr
@description Função para Buscar os Pedidos/Produtos na Origem 
@description Revisoes durante o projeto CICLO DO PEDIDO em 08/2019
@author Fernando Rocha / Ranisses Corona
@since 18/07/2016
@version 1.0
@type function
/*/
Static Function fGetPdOr(cEmp,cAgreIni,cAgreFim,cPedIni,cPedFim)
	Local aRet		:= {}	//Variavel de Retorno
	Local lSeq		:= .T.	//Variavel que determina o uso do campo C9_SEQUEN na chave de pesquisa
	Local nPed		:= ""   
	Local nProd		:= ""
	Local nQtd   	:= ""
	Local cSql 		:= ""
	Local cSql2		:= ""
	Local nTable	:= "SC9"+cEmp+"0"
	Local aAreaC9	:= SC9->(GetArea())
	Local cRecProc	:= ""
	Local lFilPed	:= Empty(cAgreIni) .Or. Empty(cAgreFim)
	Local cPedOri	:= ""
	Local cQrySC9	:= ""
	Local cQryLIB	:= ""

	If lFilPed

		SC5->(DbSetOrder(1))
		If SC5->(DbSeek(XFilial("SC5")+cPedIni))

			cPedOri := SC5->C5_YPEDORI
			cEmp	:= SC5->C5_YEMPPED 
			nTable	:= "SC9"+cEmp+"0"

		EndIf

	EndIf

	//Pesquisa pedidos liberados na LM
	cQrySC9	:= GetNextAlias()
	cSql := "SELECT C5_NUM, C9_AGREG, RTRIM(C9_PRODUTO)+C9_ITEM AS C9_PRODUTO, C9_SEQUEN, ROUND(CAST(C9_QTDLIB AS DECIMAL (10,2)),2) C9_QTDLIB, C9_PEDIDO AS PEDORI, C9_ITEM AS ITORI, C9_PRODUTO AS PRODORI, C9_NFISCAL, C9_SERIENF, SC9.R_E_C_N_O_ AS RECNO "
	cSql += "FROM "+nTable+" SC9 INNER JOIN SC5070 SC5 ON "
	cSql += "	C9_PEDIDO = C5_YPEDORI " 
	cSql += "WHERE C9_FILIAL	= '01' "
	cSql += "	AND C5_FILIAL	= '"+XFILIAL("SC5")+"' " 
	If !lFilPed
		cSql += "	AND C9_AGREG 	>= '"+cAgreIni+"' "  
		cSql += "	AND C9_AGREG 	<= '"+cAgreFim+"' "
	Else
		cSql += "	AND C9_PEDIDO 	>= '"+cPedOri+"' "  
		cSql += "	AND C9_PEDIDO 	<= '"+cPedOri+"' "
	EndIf
	cSql += "	AND C5_YEMPPED 	= '"+cEmp+"' " 
	cSql += "	AND C9_NFISCAL <> '' " 
	cSql += "	AND SC5.D_E_L_E_T_ = '' " 
	cSql += "	AND SC9.D_E_L_E_T_ = '' "	
	TcQuery cSQL New Alias (cQrySC9)

	(cQrySC9)->(DbGoTop())
	While .Not. (cQrySC9)->(Eof())         	

		//Fernando/Facile - 16/09/2016 - Pesquisar a Sequencia liberada na LM para vincular com a origem
		cQryLIB	:= GetNextAlias()
		cSql2 := " SELECT REC = R_E_C_N_O_, C9_SEQUEN FROM SC9070 "		 
		cSql2 += " WHERE C9_FILIAL	= '"+XFilial("SC9")+"' "
		cSql2 += " AND C9_NFISCAL	= '' "
		cSql2 += " AND C9_PEDIDO 	= '"+(cQrySC9)->C5_NUM+"' "
		cSql2 += " AND C9_ITEM 		= '"+(cQrySC9)->ITORI+"' "		 
		cSql2 += " AND C9_PRODUTO 	= '"+(cQrySC9)->PRODORI+"' "
		cSql2 += " AND ROUND(CAST (C9_QTDLIB AS DECIMAL (10,2)),2) = "+AllTrim(Str((cQrySC9)->C9_QTDLIB))+" "
		If !Empty(cRecProc)
			cSql2 += " AND R_E_C_N_O_ NOT IN "+FormatIn(cRecProc,"/")+" "
		EndIf
		cSql2 += " AND D_E_L_E_T_='' "
		cSql2 += " ORDER BY REC " 
		TcQuery cSql2 New Alias (cQryLIB)

		//Se achou a sequencia na LM
		If !(cQryLIB)->(Eof())

			If !Empty(nPed)
				nPed	+= "/"	  	
				nProd	+= "/"
				nQtd	+= "/"
			EndIf

			//Associa pedido e sequencia para o filtro do SC9
			nPed	+= Alltrim((cQrySC9)->C5_NUM)
			nProd	+= Alltrim((cQrySC9)->C9_PRODUTO)+Alltrim((cQryLIB)->C9_SEQUEN)  //sempre a sequencia localizada na LM
			nQtd	+= Alltrim(Str(Round((cQrySC9)->C9_QTDLIB,2)))	

			//Gravar a chave de vinculacao no campo C9_BLINF
			SC9->(DbSetOrder(0)) 
			SC9->(DbGoto((cQryLIB)->REC))
			If !SC9->(Eof())
				SC9->(RecLock("SC9",.F.))

				SC9->C9_BLINF	:= AllTrim(cEmp)+(cQrySC9)->(C9_NFISCAL+C9_SERIENF+PEDORI+ITORI+C9_SEQUEN)
				SC9->C9_AGREG	:= (cQrySC9)->C9_AGREG
				SC9->C9_YEMPORI	:= cEmp

				SC9->(MsUnLock())
			EndIf

			If !Empty(cRecProc)
				cRecProc += "/"
			EndIf

			cRecProc += AllTrim(Str((cQryLIB)->REC))

		EndIf
		(cQryLIB)->(DbCloseArea())


		(cQrySC9)->(DbSkip())
	EndDo
	(cQrySC9)->(DbCloseArea())

	AADD(aRet,nPed)     //01
	AADD(aRet,nProd)    //02
	AADD(aRet,nQtd)     //03
	AADD(aRet,lSeq)     //04
	AADD(aRet,MV_PAR05) //05
	AADD(aRet,MV_PAR06) //06
	AADD(aRet,nTable)   //07
	AADD(aRet,MV_PAR19) //08
	AADD(aRet,cAgreIni) //09
	AADD(aRet,cAgreFim) //10

	RestArea(aAreaC9)

Return(aRet)


/*/{Protheus.doc} fCalcPeso
@description Botao de Conferencia de Peso na tela de preparacao de documento de saida
@author Ranisses A. Corona
@since 26/07/2016  
@version 1.0
@type function
/*/
User Function fCalcPeso()

	Local cSql 		:= ""
	Local nEmp		:= "" 
	Local nPesoOri	:= 0 //Peso carga empresa Origem
	Local nPesoAtu	:= 0 //Peso carga empresa Atual
	Local oFont1 	:= TFont():New("Lucida Sans Typewriter",,018,,.F.,,,,,.F.,.F.)
	Local oFont2 	:= TFont():New("Lucida Sans Typewriter",,018,,.T.,,,,,.F.,.F.)
	Local oGroup2
	Local oSay1
	Local oSay2
	Local cQryTMP	:= ""

	Static oDlg  

	If cEmpAnt == "07" .And. !Empty(aPedOri[8])
		If MV_PAR19 == "01"
			nEmp := "BIANCOGRES"
		ElseIf MV_PAR19 == "05"
			nEmp := "INCESA    "
		ElseIf MV_PAR19 == "13"
			nEmp := "MUNDI     "
		ElseIf MV_PAR19 == "14"
			nEmp := "VINILICO  "
		Else
			nEmp := "          "
		EndIf		
	EndIf  

	//Selecina os Pedidos Liberados na Empresa Atual
	cQryTMP	:= GetNextAlias()
	cSql := " SELECT SUM(ROUND((C9_QTDLIB*ISNULL(ZZ9_PESO,B1_PESO))+(C9_QTDLIB2*ISNULL(ZZ9_PESEMB,B1_YPESEMB)),2)) PESOBR "
	cSql += " FROM "+RetSqlName("SC9")+" SC9 INNER JOIN SB1010 SB1 ON "
	cSql += " 	C9_PRODUTO = B1_COD "  
	cSql += " 	LEFT JOIN ZZ9010 ZZ9 ON "
	cSql += " 	C9_PRODUTO = ZZ9_PRODUT AND "
	cSql += " 	C9_LOTECTL = ZZ9_LOTE AND " 
	cSql += " 	ZZ9.D_E_L_E_T_ = '' "
	cSql += " WHERE SC9.C9_FILIAL  	=  '"+xFilial("SC9")+"'	AND	" 
	cSql += "		SC9.C9_NFISCAL	=  ''					AND	" 
	cSql += "		SC9.C9_AGREG	>= '"+aPedOri[09]+"'		AND	"  //Numero Romaneio
	cSql += "		SC9.C9_AGREG	<= '"+aPedOri[10]+"'		AND	"  //Numero Romaneio
	cSql += "		SC9.C9_PEDIDO	>= '"+aPedOri[05]+"'  	AND	"  //Numero Pedido
	cSql += "		SC9.C9_PEDIDO	<= '"+aPedOri[06]+"'	AND	"  //Numero Pedido
	cSql += "		SC9.D_E_L_E_T_	=	''					AND	" 
	cSql += "		SB1.D_E_L_E_T_	=	''						" 
	If Len(aPedOri) > 0
		cSql += cFilM460QRY									  
	EndIf
	TcQuery cSQL New Alias (cQryTMP)

	nPesoAtu := Transform((cQryPED)->PESOBR,		"@E 999,999,999.99")
	
	(cQryTMP)->(DbCloseArea())

	//Selecina os Pedidos Liberados na Empresa Origem
	cQryTMP	:= GetNextAlias()
	cSql := " SELECT SUM(ROUND((C9_QTDLIB*ISNULL(ZZ9_PESO,B1_PESO))+(C9_QTDLIB2*ISNULL(ZZ9_PESEMB,B1_YPESEMB)),2)) PESOBR "
	cSql += " FROM "+aPedOri[7]+" SC9 INNER JOIN SB1010 SB1 ON "
	cSql += " 	C9_PRODUTO = B1_COD "  
	cSql += " 	LEFT JOIN ZZ9010 ZZ9 ON "
	cSql += " 	C9_PRODUTO = ZZ9_PRODUT AND "
	cSql += " 	C9_LOTECTL = ZZ9_LOTE AND " 
	cSql += " 	ZZ9.D_E_L_E_T_ = '' "
	cSql += " WHERE SC9.C9_FILIAL  	=  '01' "
	cSql += "	AND SC9.C9_AGREG  >= '"+aPedOri[09]+"' "
	cSql += "	AND SC9.C9_AGREG  <= '"+aPedOri[10]+"' "
	cSql += " 	AND SC9.D_E_L_E_T_ = ''	"
	cSql += " 	AND SB1.D_E_L_E_T_ = ''	"
	TcQuery cSQL New Alias (cQryTMP)

	nPesoOri := Transform((cQryPED)->PESOBR,		"@E 999,999,999.99")
	
	(cQryTMP)->(DbCloseArea())

	//Monta Tela para exibir os pesos.
	DEFINE MSDIALOG oDlg TITLE "Conferencia de Peso entre Cargas" FROM 000, 000  TO 100, 345 COLORS 0, 16777215 PIXEL

	@ 008, 010 GROUP oGroup2 TO 042, 163 OF oDlg COLOR 0, 16777215 PIXEL

	@ 017, 012 SAY oSay1 PROMPT "Peso "+nEmp OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
	@ 017, 101 SAY nPesoOri  OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

	@ 030, 012 SAY oSay2 PROMPT "Peso LM        " OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
	@ 030, 101 SAY nPesoAtu  OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return()
