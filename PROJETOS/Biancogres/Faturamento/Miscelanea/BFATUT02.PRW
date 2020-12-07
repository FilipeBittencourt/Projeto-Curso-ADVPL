#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} BFATUT02
@description Funcoes uteis para proposta de engenharia
@author Fernando Rocha
/*/

/*/{Protheus.doc} PENGCKCL
@description Proposta Comercial de Engenharia >>> Checkar se o cliente tem Propostas de Engenharia Aprovadas e Validas para importação no pedidpo
@author Fernando Rocha
@since 05/09/2016
@version 1.0
@param cPrEng, characters, descricao
@type function
/*/
User Function PENGCKCL(cPrEng)
	Local cAliasTmp
	Local lRet 		:= .F.
	Local cExpProp 	:= "% 1 = 1 %"
	Local cTabPr	:= ""

	Default cPrEng := ""

	If !Empty(cPrEng)
		cExpProp := "% Z68_NUM+Z68_REV = '"+AllTrim(cPrEng)+"' %"
	EndIf

	If (M->C5_YLINHA $ "1_5")//bianco/pegasus
		cTabPr := "% Z68010 %"
	Else
		cTabPr := "% Z68050 %"
	EndIf

	//Propostas Aprovadas do Cliente selecionado no Pedido
	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp 
		%NoParser%

		SELECT Z68_NUM, Z68_REV , Z68_EMISSA 
		FROM %Exp:cTabPr% AS Z68 (NOLOCK)
		WHERE Z68_FILIAL  = %XFILIAL:Z68% 
		AND Z68_CLICAD = 'S'
		AND Z68_STATUS in ('2','4')
		AND Z68_CODCLI = %Exp:M->C5_CLIENTE%
		AND Z68_LOJCLI = %Exp:M->C5_LOJACLI%
		AND Z68_DTVALI >= %Exp:DTOS(dDataBase)%
		AND %Exp:cExpProp%
		AND Z68.D_E_L_E_T_= ' ' 
		ORDER BY 1 

	EndSql

	(cAliasTmp)->(DbGoTop())
	If !(cAliasTmp)->(Eof())
		lRet := .T. 
	EndIf
	(cAliasTmp)->(DbCloseArea())

Return(lRet)

/*/{Protheus.doc} PENGVLC5
@description Validacao do campo C5_YNPRENG
@author Fernando Rocha
@since 05/09/2016
/*/
User Function PENGVLC5()

	Local cPrEng := M->C5_YNPRENG
	Local lRet := .T. 

	If !Empty(cRepAtu) .And. U_GETBIAPAR("REP_BLQPED",.F.)
		MsgInfo("Inclusão de pedidos temporariamente bloqueada pelo departamento comercial","PENGVLC5")
	    lRet	:=	.F.
	EndIf

	If lRet
		lRet := U_PENGCKCL(cPrEng)
		If !lRet
			U_FROPMSG("Canal Engenharia", "Proposta do cliente não existe ou não está aprovada e válida.", {"OK"}, 2, "Verificando Propostas")
		EndIf
	EndIf

Return(lRet)

/*/{Protheus.doc} PENGGAC5
@description Gatilho do campo C5_YNPRENG - Importacao dos itens da proposta para o pedido
@author Fernando Rocha
@since 05/09/2016
/*/
User Function PENGGAC5()
	Local aAreaA1 := SA1->(GetArea())
	Local aAreaB1 := SB1->(GetArea())
	Local cPrEng := M->C5_YNPRENG
	Local nOpc
	Local cAliasTmp
	Local cTabZ69
	Local cTabZ68
	Local _cPctLM 	:= AllTrim(GetNewPar("FA_XPCTLM","8_9_D_B"))
	Local cItem
	Local aEmpFab 	:= {}
	Local aEmpPerg 	:= {}
	Local cEmpSel 	:= ""

	Local nPItem    	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C6_ITEM'})
	Local nPProduto 	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C6_PRODUTO'})
	Local nPUnMed		:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C6_UM'})
	Local nPQtdVen		:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C6_QTDVEN'})
	Local nPSegUnMed	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C6_SEGUM'})
	Local nPDtNece		:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C6_YDTNECE'})
	Local nPDEsp		:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C6_YDESP'})
	Local nPLocal		:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C6_LOCAL'})
	Local nY

	//Posiciona cliente
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(XFilial("SB1")+M->C5_CLIENTE+M->C5_LOJACLI))

	If Alltrim(CEMPANT) <> "07" .And. (Alltrim(SA1->A1_YTRTESP) == "1")
		U_FROPMSG("Canal Engenharia", "Proposta deve ser importada pela empresa LM.", {"OK"}, 2, "Importação de Proposta")
		Return(cPrEng)
	EndIf

	nOpc := U_FROPMSG(	"Canal Engenharia", "Proposta validada com sucesso."+CRLF+;
	"Deseja importar os itens da proposta "+AllTrim(cPrEng)+" para este pedido?", {"SIM","NAO"}, 2, "Importação de Proposta")

	If (nOpc <> 1)
		Return(cPrEng)
	EndIf


	cTabZ69 := "% Z69010 %"
	cTabZ68 := "% Z68010 %"


	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp 
		%NoParser%

		select ZZ6_EMPFAB, Z69_CODPRO, Z69_QTDVEN, Z69_DTNECE, Z69_DESP, Z68_FRTUNI
		from %Exp:cTabZ69% Z69
		join %Exp:cTabZ68% Z68 on Z68_FILIAL = Z69_FILIAL and Z68_NUM = Z69_NUM and Z68_REV = Z69_REV
		join ZZ6010 ZZ6 on ZZ6_FILIAL = '  ' and ZZ6_COD = SUBSTRING(Z69_CODPRO,1,2)
		where Z69_FILIAL = %XFILIAL:Z69%
		and Z69_NUM+Z69_REV = %Exp:cPrEng%
		and Z69.D_E_L_E_T_=''

	EndSql

	//Prevalidar itens de diferentes empresa de fabricacao
	/*(cAliasTmp)->(DbGoTop())
	While !(cAliasTmp)->(Eof())

	_cEmp := IIf((cAliasTmp)->ZZ6_EMPFAB == "14","VITCER",IIf((cAliasTmp)->ZZ6_EMPFAB == "13","MUNDI",IIf((cAliasTmp)->ZZ6_EMPFAB == "05","INCESA","Biancogres")))

	If aScan(aEmpFab, {|x| x[1] == (cAliasTmp)->ZZ6_EMPFAB}) <= 0
	aadd(aEmpFab, {(cAliasTmp)->ZZ6_EMPFAB, _cEmp})

	//If (M->C5_YLINHA == "1" .And. (cAliasTmp)->ZZ6_EMPFAB == "05")
	//	aadd(aEmpPerg, "Outsourcing")
	//Else
	aadd(aEmpPerg, _cEmp)
	//EndIf
	EndIf

	(cAliasTmp)->(DbSkip())	
	EndDo


	If Len(aEmpFab) > 1

	nOpc := U_FROPMSG(	"Canal Engenharia", "Proposta contem itens de mais de uma empresa."+CRLF+;
	"Deseja importar os itens de qual empresa?", aEmpPerg, 2, "Importação de Proposta")

	cEmpSel := aEmpFab[nOpc][1] 

	EndIf 
	*/

	(cAliasTmp)->(DbGoTop())
	//Limpar a cols
	If !(cAliasTmp)->(Eof())
		aCOLS := {}
		cItem := "00"
	EndIf

	While !(cAliasTmp)->(Eof())

		/*If !Empty(cEmpSel) .And. (cAliasTmp)->ZZ6_EMPFAB <> cEmpSel
		(cAliasTmp)->(DbSkip())
		loop
		EndIf
		*/

		//Posiciona produto
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(XFilial("SB1")+(cAliasTmp)->Z69_CODPRO))

		If	Alltrim(CEMPANT) <> "07" .And. (SB1->B1_YPCGMR3 $ _cPctLM)

			U_FROPMSG("Canal Engenharia", "Proposta contém item(s) que tem que ser incluido(s) pela LM.", {"OK"}, 2, "Importação de Proposta")

			(cAliasTmp)->(DbSkip())
			loop
		EndIf

		/*If Alltrim(CEMPANT) <> "07" .And. (cAliasTmp)->ZZ6_EMPFAB <> AllTrim(CEMPANT)

		U_FROPMSG("Canal Engenharia", "Proposta contém item(s) que tem que ser incluido(s) pela empresa "+(cAliasTmp)->ZZ6_EMPFAB+".", {"OK"}, 2, "Importação de Proposta")

		(cAliasTmp)->(DbSkip())
		loop
		EndIf
		*/

		//Atualiza campos do cabelho do Pedido
		M->C5_YFRETE := (cAliasTmp)->Z68_FRTUNI 

		//Adiciona Item no ACOLS do Pedido
		If (Len(aCols) > 0)
			cItem := aCols[Len(aCols)][nPItem]
		EndIf
		aadd(aCOLS,Array(Len(aHeader)+1))
		SX3->(DbSetOrder(2))
		For nY := 1 To Len(aHeader)

			If !SX3->(DbSeek(aHeader[nY][2]))
				loop
			EndIf

			If ( AllTrim(aHeader[nY][2]) == 'C6_ITEM' )
				aCols[Len(aCols)][nY] := Soma1(cItem)
			Else
				aCols[Len(aCols)][nY] := CriaVar(aHeader[nY][2])  
			EndIf
		Next nY
		N := Len(aCols)
		aCOLS[N][Len(aHeader)+1] := .F.

		//Produto
		aCols[N][nPProduto]	:= (cAliasTmp)->Z69_CODPRO
		A410Produto((cAliasTmp)->Z69_CODPRO,.F.)
		A410MultT('M->C6_PRODUTO',(cAliasTmp)->Z69_CODPRO)
		If ExistTrigger('C6_PRODUTO')
			RunTrigger(2,N,Nil,,'C6_PRODUTO')
		Endif
		A410SegUm(.T.)
		aCols[N][nPUnMed]	:= SB1->B1_UM
		aCols[N][nPSegUnMed]:= SB1->B1_SEGUM
		aCols[N][nPLocal]	:= SB1->B1_LOCPAD    
		aCols[N][nPQtdVen]	:= (cAliasTmp)->Z69_QTDVEN
		aCols[N][nPDtNece]	:= Max(U_FROPAD3U(dDataBase), STOD((cAliasTmp)->Z69_DTNECE))  
		aCols[N][nPDEsp]	:= (cAliasTmp)->Z69_DESP

		(cAliasTmp)->(DbSkip())

		GETDREFRESH()
	EndDo
	(cAliasTmp)->(DbCloseArea())

	GETDREFRESH()

	RestArea(aAreaA1)
	RestArea(aAreaB1)

Return(cPrEng)