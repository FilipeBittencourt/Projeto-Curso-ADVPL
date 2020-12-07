#include "topconn.ch"
#include "rwmake.ch"

/*/{Protheus.doc} CALC_ST
@author Ranisses A. Corona
@since 09/10/2007
@version 1.0
@description Realiza o cálculo e a inclusão da GUIA de ST (SF6), do Titulo a Receber (SE1) e do Contas a Pagar (SE2)
@history 08/06/2017, Ranisses A. Corona, Alteração para considerar a Função de Exceção de Vencimento 
@type function
/*/

User Function CALC_ST()
	Private cRegEsp

	lOk := .T.

	do while lOk
		@ 0,0 TO 250,450 DIALOG oEntra TITLE "Insira os dados da NF de Saida"

		cNota   := SPACE(09)
		cPref   := SPACE(03)
		cClient := SPACE(06)
		cTransp := SPACE(06)

		@ 35,10 SAY "Prefixo "    ; @35,40 GET cPref	  PICT "@!R"
		@ 55,10 SAY "Nota Fiscal "; @55,40 GET cNota	  PICT "@!R"
		@ 100,80  BUTTON "_Ok"       SIZE 30,15 ACTION fSubmit()
		@ 100,120 BUTTON "_Sair"     SIZE 30,15 ACTION fAborta()
		ACTIVATE DIALOG oEntra CENTERED
	enddo
Return

/*/{Protheus.doc} fSubmit
@author Ranisses A. Corona
@since 09/10/2007
@version 1.0
@description Valida a NF para calculo da ST.
/*/
Static Function fSubmit()

	SF2->(DbSetOrder(1))
	SA1->(DbSetOrder(1))
	SA3->(DbSetOrder(1))

	//VERIFICA SE FOI UTILIZADO MAIS DE UM PEDIDO NA GERACAO DA NF (ESTE PROBLEMA PASSOU A OCORRER APÓS A MIGRAÇÃO PARA O PROTHEUS11
	CSQL := "SELECT COUNT(*) QUANT	"
	CSQL += "FROM					"
	CSQL += "	(SELECT D2_PEDIDO, COUNT(*) COUNT		"
	CSQL += "	FROM "+RetSqlName("SD2")+" 				"
	CSQL += "	WHERE 	D2_DOC 		= '"+cNota+"' 	AND "
	CSQL += "			D2_SERIE 	= '"+cPref+"'	AND "
	CSQL += "			D_E_L_E_T_ 	= ''				"
	CSQL += "	GROUP BY D2_PEDIDO) TMP					"
	If chkfile("R003")
		dbSelectArea("R003")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "R003" NEW
	If R003->QUANT <> 1
		MsgBox("Não será possível a inclusão da GNRE, pois ocorreu um problema na geração desta NF (MAIS DE UM PEDIDO PARA MESMA NF). Será necessário excluir a NF, e corrigir o Pedido!","CALC_ST","STOP")
		Return
	EndIf

	If !SF2->(DbSeek(xFilial("SF2")+cNota+cPref,.F.))
		MsgBox("NF não encontrada!","CALC_ST","STOP")
		Return
	EndIf

	If SF2->F2_EMISSAO <= GetMv("MV_ULMES")
		MsgBox("Não é permitida a inclusão de GNRE, após o fechamento do mês!","CALC_ST","STOP")
		Return
	EndIf

	If ALLTRIM(SF2->F2_YSUBTP) == 'A' .AND. !Alltrim(SF2->F2_CLIENTE) $ '008960'
		MsgBox("Não é permitida a inclusão de GNRE, para pedidos de AMOSTRA!","CALC_ST","STOP")
		Return
	EndIf

	If ALLTRIM(SF2->F2_YSUBTP) == 'O' .AND. !Alltrim(SF2->F2_CLIENTE) $ '008960' //INCLUIDA EM 08/10/12 CONFORME SOLICITACAO SR. RAFAEL
		MsgBox("Não é permitida a inclusão de GNRE, para pedidos do tipo OUTROS!","CALC_ST","STOP")
		Return
	EndIf

//Valida os estados para geração da Guia Manual
	If !Alltrim(SF2->F2_EST) $ GetMV("MV_YUFSTSD")
		MsgBox("Não é permitida a inclusão Manual da GNRE, para clientes fora do estado de SP, PE(Tupan), AL(Tupan) e MT!","CALC_ST","STOP")
		Return
	EndIf

//Para o Estado de PE, so e permitida inclusao de ST para o cliente Tupan - em 09/06/11
	If Alltrim(SF2->F2_EST) == 'PE' .And. !Alltrim(SF2->F2_CLIENTE) $ '005693_002940' //ALTERADO NO DIA 09/06/11 PARA CONSIDERAR O CLIENTE 005693 e 002940 - UF "PE"
		MsgBox("Para o Estado do PE, só é permitida a inclusão para o cliente Tupan!","CALC_ST","STOP")
		Return
	EndIf

//Para o Estado de AL, so e permitida inclusao de ST para o cliente Tupan - em 12/12/12
	If Alltrim(SF2->F2_EST) == 'AL' .And. !Alltrim(SF2->F2_CLIENTE) $ '010825_010864'
		MsgBox("Para o Estado do AL, só é permitida a inclusão para o cliente Tupan!","CALC_ST","STOP")
		Return
	EndIf


	If Alltrim(SF2->F2_EST) == 'MT' .And. !Alltrim(SF2->F2_CLIENTE) $ '008960'
		MsgBox("Para o Estado do MT, só é permitida a inclusão para o cliente 008960!","CALC_ST","STOP")
		Return
	EndIf


	If Alltrim(SF2->F2_TIPOCLI) <> 'S'
		MsgBox("Nao e permitida a inclusao da GNRE, para clientes diferentes de Solidario!","CALC_ST","STOP")
		Return
	EndIf

	If SF2->F2_YVLGNRE > 0
		MsgBox("Ja foi gerado GNRE para esta NF!","CALC_ST","STOP")
		Return
	EndIf

	If !Empty(SF2->F2_YVLFRTR)
		MsgBox("ICMS SUBSTITUICAO TRIBUTARIA ja calculada!","CALC_ST","STOP")
		Return
	EndIf

	if !RecLock("SF2",.F.)
		MsgBox("Registro em uso por outra esta‡„o! Aguarde um momento e tente novamente.","CALC_ST","STOP")
		Return
	endif
	MsUnLock()

//Posiciona no cadastro de Cliente
	SA1->(DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))

//Validacao do campo Regime Especial no Cadastro de Cliente.
	If !Empty(Alltrim(SA1->A1_YREGESP))
		MsgBox("Não é permitido inclusão de GNRE para clientes com Regime Especial.","CALC_ST","STOP")
		Return
	EndIf

//Posiciona no cadastro de Representante
	SA3->(DbSeek(xFilial("SA3")+SF2->F2_VEND1))

	cRegEsp	:= SA1->A1_YREGESP
	cNreduz := SA1->A1_NREDUZ
	cVlMerc	:= SF2->F2_VALMERC
	cVlIPI	:= SF2->F2_VALIPI
	cBase 	:= SF2->F2_FRETAUT
	cClient	:= SF2->F2_CLIENTE
	cVlFr	:= 0
	cVlST   := {}

	@0,0 TO 250,450 DIALOG oDigit TITLE "Calculo do ICMS Substituicao Tributaria (GNRE)"
	@005,010 SAY "Nota Fiscal "			; @005,040 SAY cNota
	@015,010 SAY "Prefixo "      		; @015,040 SAY cPref
	@025,010 SAY "Cliente "    	 		; @025,040 SAY cClient+" - "+trim(cNreduz) PICT "@!"
	@035,010 SAY "Represent. "			; @035,040 SAY SA3->A3_COD+" - "+trim(SA3->A3_NREDUZ) PICT "@!"
	@045,010 SAY "Valor Merc. "    		; @045,040 SAY cVlMerc 	Size 40,20 Picture "@E 999,999.99"
	@055,010 SAY "Valor IPI "      		; @055,040 SAY cVlIPI  	Size 40,20 Picture "@E 999,999.99"
	@065,010 SAY "Frete Aut. "   		; @065,040 SAY cBase   	Size 40,20 Picture "@E 999,999.99"
	@075,010 SAY "Frete Trans. "		; @075,040 GET cVlFr   	Size 40,20 Picture "@E 999,999.99"
	@085,010 SAY "Valor GNRE "     		; @085,040 SAY 0		Size 40,20 Picture "@E 999,999.99"
	@100,80  BUTTON "_Calcular"	SIZE 30,15 ACTION fSubmit2()
	@100,120 BUTTON "_Voltar"	SIZE 30,15 ACTION gAborta()
	ACTIVATE DIALOG oDigit CENTERED

Return

/*/{Protheus.doc} fSubmit
@author Ranisses A. Corona
@since 09/10/2007
@version 1.0
@description Calcula ICMS Substituicao Tributaria - GNRE
/*/
Static Function fSubmit2()
	Local cCliEsp 	:= "N"
	Private nBaseST := 0
	Private nVlST	:= 0
	Private nVlMerc := 0

//cIcms := SF2->F2_VALICM
//Alterado por Ranisses no dia 27/02/09, com inicio no dia 02/03/09, para faturamento ST no Estado de SP para as empresas Biancogres e Incesa

//Alteracao conforme solicitacao do Sr. Robert e Enelcio
//If Alltrim(cEmpAnt) == "01" //.and. Alltrim(SA3->A3_YBSICMS) == "1"							//Alterado dia 14/05/08
//	cIcms := Round((SF2->F2_VALICM*30/100),2) //Apura 30% do valor do ICMS na Biancogres	//Alterado dia 14/05/08
//	cIcms := Round((SF2->F2_VALICM*75.5/100),2) //Apura 75,5% do valor do ICMS na Biancogres //Alterado dia 14/05/08
//Else
//	cIcms := SF2->F2_VALICM
//EndIf

//cVlST := Round((((SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_FRETAUT+cVlFr) + ((SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_FRETAUT+cVlFr) * 35 / 100)) * 18 / 100 ) - cIcms, 2) Alteracao da Aliquota de 18 para 12 no dia 27/03/08

//Alterado por Ranisses no dia 27/02/09, com inicio no dia 02/03/09, para faturamento ST no Estado de SP para as empresas Biancogres e Incesa
//If Alltrim(SF2->F2_EST) == "SP"
//	//cVlST := Round((((SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_FRETAUT+cVlFr) + ((SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_FRETAUT+cVlFr) * 35.33/ 100)) * 12 / 100 ) - cIcms, 2) DESATIVADO EM 01/07/10
//	cVlST := Round((((SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_FRETAUT+cVlFr) + ((SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_FRETAUT+cVlFr) * 39.00/ 100)) * 12 / 100 ) - cIcms, 2) //ATIVADO EM 01/07/10, CONFORME PORTARIA CAT_78
//
//ElseIf Alltrim(SF2->F2_EST) == "RJ" //Alterado por Ranisses no dia 29/04/09, com inicia no dia 01/05/10, para faturamento ST no Estado de RJ, para as empresa BIA/INC/LM
//	//cVlST := Round((((SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_FRETAUT+cVlFr) + ((SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_FRETAUT+cVlFr) * 47.03/ 100)) * 19 / 100 ) - cIcms, 2)
//	cVlST := Round((((SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_FRETAUT+cVlFr) + ((SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_FRETAUT+cVlFr) * 51.01/ 100)) * 19 / 100 ) - cIcms, 2) //ALTERADO EM 01/06/11 CONFORME SOLICITACAO DO ROBERT
//
//ElseIf Alltrim(SF2->F2_EST) == "PE" .And. Alltrim(SF2->F2_CLIENTE) $ "005693_002940" //Incluido nova regra para o Cliente Tupan de "PE" em  09/06/11
//	cVlST := Round((((SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_FRETAUT+cVlFr) + ((SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_FRETAUT+cVlFr) * 47.40/ 100)) * 17 / 100 ) - cIcms, 2)
//
//Else
//	//cVlST := Round((((SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_FRETAUT+cVlFr) + ((SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_FRETAUT+cVlFr) * 35 / 100)) * 12 / 100 ) - cIcms, 2)
//	//cVlST := Round((((SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_FRETAUT+cVlFr) + ((SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_FRETAUT+cVlFr) * 35.33/ 100)) * 12 / 100 ) - cIcms, 2)  //ALTERADO EM 01/09/09 Decreto 45.138 de 21/07/2009
//	cVlST := Round((((SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_FRETAUT+cVlFr) + ((SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_FRETAUT+cVlFr) * 39.00/ 100)) * 12 / 100 ) - cIcms, 2)  //ALTERADO EM 01/03/11 Decreto 45.531 de 21/01/2011
//EndIf

//Funcao para Calcular o Valor da ST - USERLIBRARY -- fCalcVlrST(xUF,xVlMerc,xVlIcms,xVlIpi,xVlAut,xVlTran)
	If SF2->F2_CLIENTE == "015966" .AND. !(SF2->F2_TIPO $ "D_B")
		cCliEsp := "S"
	EndIf

//Seleciona Itens da NF, para calculo do ICMS ST
	CSQL := ""
	CSQL += "SELECT	F2_VALMERC, F2_VALICM, F2_VALIPI, F2_FRETAUT, F2_YVLGNRE, D2_TOTAL, D2_DESCON, D2_BASEICM, D2_VALICM, D2_PICM, D2_VALIPI, B1_GRTRIB, B1_POSIPI, D2_COD, D2_LOTECTL,	D2_QUANT,						"
	CSQL += "		ROUND(F2_FRETAUT*D2_QUANT/(SELECT SUM(D2_QUANT) FROM "+RetSqlName("SD2")+" WHERE D2_DOC = SD2.D2_DOC AND D2_SERIE = SD2.D2_SERIE AND D_E_L_E_T_ = ''),2) BASEFRET	"
	CSQL += "FROM "+RetSqlName("SF2")+" SF2 INNER JOIN "+RetSqlName("SD2")+" SD2 ON	"
	CSQL += "		F2_SERIE	= D2_SERIE		AND 	"
	CSQL += "		F2_DOC		= D2_DOC		AND 	"
	CSQL += "		F2_CLIENTE	= D2_CLIENTE			"
	CSQL += "	INNER JOIN "+RetSqlName("SB1")+" SB1 ON	"
	CSQL += "		D2_COD		= B1_COD				"
	CSQL += "WHERE	SF2.F2_FILIAL   = '"+xFilial("SF2")+"' AND 	"
	CSQL += "       SD2.D2_FILIAL	= '"+xFilial("SD2")+"' AND	"
	CSQL += "       SB1.B1_FILIAL   = '"+xFilial("SB1")+"' AND 	"
	CSQL += "		SF2.F2_DOC		= '"+cNota+"' 	AND 		"
	CSQL += "		SF2.F2_SERIE	= '"+cPref+"'	AND			"
	CSQL += "		SF2.D_E_L_E_T_	= '' AND 					"
	CSQL += "		SD2.D_E_L_E_T_	= '' AND 					"
	CSQL += "		SB1.D_E_L_E_T_	= ''						"
	If chkfile("_TMP")
		dbSelectArea("_TMP")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "_TMP" NEW

	dbSelectArea("_TMP")
	WHILE !_TMP->(EOF())

		If !U_fBuscaMVA(_TMP->B1_POSIPI,SF2->F2_EST,_TMP->B1_GRTRIB,dDataBase)[1]
			Return
		EndIf

		If SF2->F2_CLIENTE == "010864" //OS 3729-15 TANIA E LUISMAR EM 24/09/2015
			nVlMerc	 := _TMP->D2_TOTAL+_TMP->D2_DESCON
		Else
			nVlMerc	 := _TMP->D2_TOTAL
		EndIf

		cVlST := U_fCalcVlrST(_TMP->B1_GRTRIB,_TMP->B1_POSIPI,cRegEsp,cCliEsp,SF2->F2_EST,nVlMerc,_TMP->D2_VALICM,_TMP->D2_VALIPI,_TMP->BASEFRET,cVlFr,SF2->F2_CLIENTE,_TMP->D2_PICM,_TMP->D2_BASEICM)

		nBaseST += cVlST[1]
		nVlST	+= cVlST[2]

		_TMP->(DBSKIP())
	ENDDO
	_TMP->(DbCloseArea())

	@0,0 TO 250,450 DIALOG oDigit2 TITLE "Alteracao Vlr Frete Autonomo"
	@005,010 SAY "Nota Fiscal "			; @005,040 SAY cNota
	@015,010 SAY "Prefixo "      		; @015,040 SAY cPref
	@025,010 SAY "Cliente "    	 		; @025,040 SAY cClient+" - "+trim(cNreduz) PICT "@!"
	@035,010 SAY "Represent. "			; @035,040 SAY SA3->A3_COD+" - "+trim(SA3->A3_NREDUZ) PICT "@!"
	@045,010 SAY "Valor Merc. "    		; @045,040 SAY cVlMerc 	Size 40,20 Picture "@E 999,999.99"
	@055,010 SAY "Valor IPI "      		; @055,040 SAY cVlIPI  	Size 40,20 Picture "@E 999,999.99"
	@065,010 SAY "Frete Aut. "   		; @065,040 SAY cBase   	Size 40,20 Picture "@E 999,999.99"
	@075,010 SAY "Frete Trans. "		; @075,040 SAY cVlFr   	Size 40,20 Picture "@E 999,999.99"
	@085,010 SAY "Valor GNRE "     		; @085,040 SAY nVlST	Size 40,20 Picture "@E 999,999.99"
	@100,80  BUTTON "_Incluir"	SIZE 30,15 ACTION fGrava()
	@100,120 BUTTON "_Voltar"	SIZE 30,15 ACTION hAborta()
	ACTIVATE DIALOG oDigit2 CENTERED

Return

/*/{Protheus.doc} fSubmit
@author Ranisses A. Corona
@since 09/10/2007
@version 1.0
@description Grava o CR e CP com o valor da GNRE
/*/
Static Function fGrava()

	Local nDias		:= ""	//Quantidade de Dias para Incremento ou Vencimento Fixo
	Local nForma	:= "1"	//Forma de Pagamento (1=Banco/2=Cheque/3=OP	- Padrao 1=Banco)
	Local nSomaMes	:= 0	//Vencimento Dentro/Fora do Mês Corrente
	Local aNewVenc	:= {} 	//Retorno da função Exceção de Vencimento
	Local cFilST

	cNota   := SPACE(9)
	cPref   := SPACE(3)
	cClient := SPACE(6)

	//Atualiza Valor Frete Trans. e da GNRE na NF
	cQuery  := ""
	cQuery  += "UPDATE "+RetSQLName("SF2")+" SET F2_YVLFRTR = '"+Str(cVlFr)+"', F2_YVLGNRE = '"+Str(nVlST)+"' "
	cQuery  += "WHERE "
	cQuery  += " F2_FILIAL  = '"+xFilial("SF2")+"' AND "
	cQuery  += " F2_DOC     = '"+SF2->F2_DOC+"' AND "
	cQuery  += " F2_SERIE   = '"+SF2->F2_SERIE+"' AND "
	cQuery  += " F2_CLIENTE = '"+SF2->F2_CLIENTE+"' AND "
	cQuery  += " D_E_L_E_T_ = '' "
	TCSQLExec(cQuery)

	//ROTINA PARA INCLUSAO DOS TITULOS REFERENTE A SUBSTITUICAO TRIBUTARIA NO CONTAS A RECEBER A CONTAS A PAGAR
	//Verifica se o cliente e de MG / Solidario
	If SF2->F2_EST $ GetMV("MV_YUFSTSD") .And. SF2->F2_TIPOCLI == 'S' //Ranisses alterou em 17/06/15, para considerar parametro com os Estados

		//DEFINE VENCIMENTO DA ST (SUBSTITUI A REGRA ACIMA)
		If Alltrim(SF2->F2_YEMP) == "0101" .And. SF2->F2_EST == "SP"
			nDias := 14
		Else
			nDias := 7
		EndIf

		If AllTrim(CEMPANT)+AllTrim(CFILANT) == "0701" .And. Alltrim(SF2->F2_CLIENTE) $ "029954"
			cFilST := "05"
		Else
			cFilST := xFilial("SE1")
		EndIf

		//Grava Valor no Contas a Receber
		If !ALLTRIM(SF2->F2_YSUBTP) $ 'A_O' .or. Alltrim(SF2->F2_CLIENTE) $ '008960'//ticket 17142
			
			
			If ALLTRIM(SF2->F2_YSUBTP) <> 'G' .And. !((AllTrim(CEMPANT)+AllTrim(CFILANT) == "0701") .And. (Alltrim(SF2->F2_CLIENTE) $ "029954"))
			
				 
				DbSelectArea("SE1")
				DbSetOrder(1)
				RecLock("SE1",.T.)
				SE1->E1_FILIAL	:=	cFilST
				SE1->E1_PREFIXO	:=	SF2->F2_SERIE
				SE1->E1_NUM		:=	SF2->F2_DOC
				SE1->E1_PARCELA	:=	'1'
				SE1->E1_TIPO	:=	'ST'
				SE1->E1_NATUREZ	:=	'1230'
				SE1->E1_CLIENTE	:=	SF2->F2_CLIENTE
				SE1->E1_LOJA	:=	SF2->F2_LOJA
				SE1->E1_NOMCLI	:=	SA1->A1_NREDUZ
				SE1->E1_YUFCLI	:=	SF2->F2_EST

				//Define vencimento Padrão
				SE1->E1_VENCTO	:=	MonthSum(SF2->F2_EMISSAO,nSomaMes) + nDias
				SE1->E1_VENCREA	:=	DATAVALIDA(MonthSum(SF2->F2_EMISSAO,nSomaMes) + nDias)
				SE1->E1_VENCORI	:=	MonthSum(SF2->F2_EMISSAO,nSomaMes) + nDias
				SE1->E1_YFORMA	:=	nForma

				//Define tratamento de Excecões de Vencimento
				//SE FOR PEDIDO ANTECIPADO, GRAVA O MESMO VENCIMENTO E FORMA DE PAGAMENTO DA NF E DIFERENTES DE BONIFICAÇÃO
				If U_fValidaRA(SF2->F2_COND) .AND. ALLTRIM(SF2->F2_YSUBTP) <> 'B'
					aParc	:= Condicao(nVlST,SF2->F2_COND,0,SF2->F2_EMISSAO,0)
					SE1->E1_VENCTO	:=	aParc[1][1]
					SE1->E1_VENCREA	:=	DATAVALIDA(aParc[1][1])
					SE1->E1_VENCORI	:=	aParc[1][1]
					SE1->E1_YFORMA	:=	'3' //OP

					//PARA PEDIDOS DIFERENTES DE ANTECIPADOS E BONIFICAÇÃO
				Else

					//Tratamento para Exceção de Vencimento de ST
					If !Alltrim(SF2->F2_COND) $ "328_195_980_A80_331_192_982_A82_330_194"
						aNewVenc := U_fExcVenc("ST",SF2->F2_YEMP,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_EMISSAO,SF2->F2_EMISSAO,SF2->F2_VALBRUT,SF2->F2_COND,SF2->F2_VALIPI,SF2->F2_ICMSRET,"CALC_ST",SF2->F2_SERIE,SF2->F2_DOC)
						If Len(aNewVenc) > 1
							SE1->E1_VENCTO	:=	aNewVenc[1]
							SE1->E1_VENCREA	:=	DATAVALIDA(aNewVenc[1])
							SE1->E1_VENCORI	:=	aNewVenc[1]
							If !Empty(Alltrim(aNewVenc[2]))
								SE1->E1_YFORMA	:=	aNewVenc[2]
							EndIf
						EndIf
					EndIf

				EndIf
				SE1->E1_EMISSAO	:= 	SF2->F2_EMISSAO
				SE1->E1_VALOR	:=	nVlST

				//Comentado no projeto Automacao Financeiro - Nosso numero passa a ser gerado no bordero automatico
				//SE1->E1_NUMBCO	:=	U_fGeraNossoNumero("1") //Funcao para Geracao do NossoNumero

				SE1->E1_EMIS1	:=	SF2->F2_EMISSAO
				SE1->E1_SITUACA	:=	'0'
				SE1->E1_LA		:=	'S'
				SE1->E1_SALDO	:=	nVlST
				SE1->E1_VEND1	:=  '999999'
				SE1->E1_COMIS1	:=	0

				//OS 0335-14 Zerando Juros dos Grupos Abaixo
				If Alltrim(SA1->A1_GRPVEN) $ "000380_000026_000010_000030_000938" //OS 1487-16 - Cassol
					SE1->E1_PORCJUR	:=	0
				Else
					SE1->E1_PORCJUR	:=	0.20
				EndIf

				SE1->E1_MOEDA	:=	1
				SE1->E1_BASCOM1	:=	0
				SE1->E1_OCORREN	:= '01'
				//SE1->E1_INSTR1	:=	VER BB
				//SE1->E1_INSTR2	:=	VER BB
				SE1->E1_PEDIDO	:=	SF2->F2_YPEDIDO
				SE1->E1_VLCRUZ	:=	nVlST
				SE1->E1_SERIE	:=	SF2->F2_SERIE
				SE1->E1_STATUS	:=	'A'
				SE1->E1_ORIGEM	:=	'MATA460'
				SE1->E1_YPRZPTO	:=	'00'
				SE1->E1_YBAIDEL	:=	'N'
				SE1->E1_FILORIG	:=	cFilST
				SE1->E1_YRECR	:=	'N'
				SE1->E1_MSFIL	:=	cFilST
				SE1->E1_MSEMP	:=	cFilST
				SE1->E1_FRETISS	:=	'1'
				SE1->E1_YCLASSE	:=	'1' //Classe do Titulo : 1 - ST
				SE1->E1_YEMP	:=	SF2->F2_YEMP
				msUnLock()
			Else
				MsgBox("Para NF de REMESSA EM GARANTIA/Cliente:'029954', será gerada apenas a GUIA para Pagamento no Contas a Pagar!","CALC_ST","STOP")
			EndIf

			//Grava Valor no Contas a Pagar
			DbSelectArea("SE2")
			DbSetOrder(1)
			RecLock("SE2",.T.)
			SE2->E2_FILIAL	:=	cFilST
			SE2->E2_PREFIXO	:=	SF2->F2_SERIE
			SE2->E2_NUM		:=	SF2->F2_DOC
			SE2->E2_PARCELA	:=	'1'
			SE2->E2_TIPO	:=	'ST'
			SE2->E2_NATUREZ	:=	'1230'
			SE2->E2_LOJA	:=	'01'
			If Alltrim(SA1->A1_EST) == "MG"
				SE2->E2_FORNECE	:=	'GNRE'
				SE2->E2_NOMFOR	:=	'GOVERNO DO ESTADO MG'
			ElseIf Alltrim(SA1->A1_EST) == "RJ" //Alterado por Ranisses no dia 29/04/09, com inicia no dia 01/05/10, para faturamento ST no Estado de RJ, para as empresa BIA/INC/LM
				SE2->E2_FORNECE	:=	'GNRERJ'
				SE2->E2_NOMFOR	:=	'GOVERNO DO ESTADO RJ'
			ElseIf Alltrim(SA1->A1_EST) == "PE" //Alterado por Ranisses no dia 09/09/11, para gerar ST para o cliente Tupan do estado de PE
				SE2->E2_FORNECE	:=	'GNREPE'
				SE2->E2_NOMFOR	:=	'GOVERNO DO ESTADO PE'
			ElseIf Alltrim(SA1->A1_EST) == "BA" //Alterado por Ranisses no dia 19/11/12, OS 2569-12
				SE2->E2_FORNECE	:=	'GNREBA'
				SE2->E2_NOMFOR	:=	'GOVERNO DO ESTADO BA'
			ElseIf Alltrim(SA1->A1_EST) == "AL" //Alterado por Ranisses no dia 12/12/12
				SE2->E2_FORNECE	:=	'GNREAL'
				SE2->E2_NOMFOR	:=	'GOVERNO DO ESTADO AL'
			ElseIf Alltrim(SA1->A1_EST) == "PR" //Alterado por Ranisses no dia 30/05/14
				SE2->E2_FORNECE	:=	'GNREPR'
				SE2->E2_NOMFOR	:=	'GOVERNO DO ESTADO PR'
			ElseIf Alltrim(SA1->A1_EST) == "SC" //Alterado por Ranisses no dia 30/05/14
				SE2->E2_FORNECE	:=	'GNRESC'
				SE2->E2_NOMFOR	:=	'GOVERNO DO ESTADO SC'
			ElseIf Alltrim(SA1->A1_EST) == "RS" //Alterado por Ranisses no dia 30/05/14
				SE2->E2_FORNECE	:=	'GNRERS'
				SE2->E2_NOMFOR	:=	'GOVERNO DO ESTADO RS'
			ElseIf Alltrim(SA1->A1_EST) == "AP" //Alterado por Ranisses no dia 17/06/15
				SE2->E2_FORNECE	:=	'GNREAP'
				SE2->E2_NOMFOR	:=	'GOVERNO DO ESTADO AP'
			ElseIf Alltrim(SA1->A1_EST) == "SP"
				SE2->E2_FORNECE	:=	'GNRESP'
				SE2->E2_NOMFOR	:=	'GOVERNO DO ESTADO SP'
			Else
				SE2->E2_FORNECE	:=	'GNREMT'
				SE2->E2_NOMFOR	:=	'GOVERNO DO ESTADO MT'
			EndIf

			SE2->E2_VENCTO	:=	SF2->F2_EMISSAO
			SE2->E2_VENCREA	:=	SF2->F2_EMISSAO
			SE2->E2_EMISSAO	:=	SF2->F2_EMISSAO
			SE2->E2_VALOR	:=	nVlST
			SE2->E2_EMIS1	:=	SF2->F2_EMISSAO
			SE2->E2_LA		:=	'S'
			SE2->E2_SALDO	:=	nVlST
			SE2->E2_VENCORI	:=	SF2->F2_EMISSAO
			SE2->E2_MOEDA 	:=	1
			SE2->E2_VLCRUZ	:=	nVlST
			SE2->E2_ORIGEM	:=	'MATA460'
			SE2->E2_APLVLMN	:=	'1'
			SE2->E2_FRETISS	:=	'1'
			SE2->E2_MDRTISS	:=	'1'
			SE2->E2_FILORIG	:=	cFilST
			SE2->E2_YNFGUIA	:= SF2->F2_SERIE+SF2->F2_DOC
			msUnLock()

			//Grava Valor na Tabela de Guia GNRE - SF6
			If Alltrim(SA1->A1_EST) $ "AL_SP_MT"
				DbSelectArea("SF6")
				DbSetOrder(1)
				RecLock("SF6",.T.)
				SF6->F6_FILIAL	:= cFilST
				SF6->F6_EST		:= SF2->F2_EST
				SF6->F6_NUMERO	:= SF2->F2_PREFIXO+SF2->F2_DOC
				SF6->F6_INSC	:= StrTran(Alltrim(SA1->A1_INSCR),".","")
				SF6->F6_CNPJ	:= SA1->A1_CGC
				SF6->F6_VALOR 	:= nVlST
				SF6->F6_DTARREC	:= SF2->F2_EMISSAO
				SF6->F6_DTVENC 	:= SF2->F2_EMISSAO
				SF6->F6_DTPAGTO	:= SF2->F2_EMISSAO
				SF6->F6_MESREF	:= Month(SF2->F2_EMISSAO)
				SF6->F6_ANOREF	:= Year(SF2->F2_EMISSAO)
				SF6->F6_REF		:= '1'
				If cFilST == '05'
					SF6->F6_CODREC	:= '0632'
					SF6->F6_TIPOIMP	:= '0'
				Else				
					SF6->F6_TIPOIMP	:= '3'
					If Alltrim(SA1->A1_EST) == "SP"
						SF6->F6_CODREC	:= '100080'
					ElseIf Alltrim(SA1->A1_EST) == "AL"
						SF6->F6_CODREC	:= '100099'
						SF6->F6_CODPROD := 18
					Else
						//SF6->F6_CODREC	:= '100098'
						SF6->F6_PROCESS		:= '1'
					EndIf
				EndIf
				SF6->F6_DOC		:= SF2->F2_DOC
				SF6->F6_SERIE	:= SF2->F2_SERIE
				SF6->F6_CLIFOR	:= SF2->F2_CLIENTE
				SF6->F6_LOJA	:= SF2->F2_LOJA
				SF6->F6_OPERNF	:= '2'
				SF6->F6_TIPODOC	:= 'N'
				SF6->F6_COBREC	:= "999"

				msUnLock()
			EndIf
		Else
			MsgBox("Nao e permitida a inclusao da GNRE, para pedidos de AMOSTRA e tipo OUTROS!","CALC_ST","STOP")
		EndIf

	EndIf

	Close(oDigit)
	Close(oDigit2)
	Close(oEntra)

	//Nao executa contabilizacao, quando a guia for referente a NF de Transferencia para Filial LM SP 
	If cFilST <> '05'
		EXECBLOCK("NOTA_ICMS",.F.,.F.)
	EndIf

	//Fecha arquivo temporarios
	If chkfile("R002")
		dbSelectArea("R002")
		dbCloseArea()
	EndIf

	If chkfile("R003")
		dbSelectArea("R003")
		dbCloseArea()
	EndIf

Return

//Funcao para fechar tela
Static Function fAborta()
	lOk := .F.
	Close(oEntra)
Return

//Funcao para fechar tela
Static Function gAborta()
	Close(oDigit)
	Close(oEntra)
Return

//Funcao para fechar tela
Static Function hAborta()
	Close(oDigit2)
	Close(oEntra)
Return