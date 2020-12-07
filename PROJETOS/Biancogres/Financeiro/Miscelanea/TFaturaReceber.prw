#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TFaturaReceber
@author Wlysses Cerqueira (Facile)
@since 26/04/2019
@project Automação Financeira
@version 1.0
@description Classe responsavel pela criacao de faturas a receber.   
@type class
/*/

// ARRAY aFatura
#DEFINE FPOSCLI		1
#DEFINE FPOSLOJ		2
#DEFINE FPOSNUM		3
#DEFINE FPOSPRF		4
#DEFINE FPOSTIP		5
#DEFINE FPOSPAR		6
#DEFINE FPOSCOND	7
#DEFINE FPOSVENC	8
#DEFINE FPOSVENCR	9
#DEFINE FPOSVLR		10

Class TFaturaReceber From LongClasName

Data lContab
Data nHdlPrv
Data cLote
Data aFlagCTB
Data cArquivo
Data cLanPad

Data lBaixaTit
Data lBaixaFat
Data cNumFat
Data cNatureza
Data aRecnoTit
Data aFatura
Data oPro // Objeto Gestor de Processos
Data oLog // Objeto de Log

Method New() Constructor
Method Create()
Method GetNextNumFat()
Method GetMaxNumFat()

EndClass

Method New() Class TFaturaReceber

	::lContab := .F.
	::nHdlPrv := 0
	::cLote := "008850"
	::aFlagCTB := {}
	::cArquivo := ""
	::cLanPad := ""

	::cNumFat := ""
	::cNatureza := ""
	::aRecnoTit := {}
	::aFatura := {}
	::lBaixaTit := .F.
	::lBaixaFat := .F.

	::oPro := TAFProcess():New()
	::oLog := TAFLog():New()

Return()

Method Create() Class TFaturaReceber

	Local nW_ := 0
	Local lRet := .T.
	Local aRecFat	:= {}
	Local cVendTit	:= ""
	Local aAreaSA1	:= SA1->(GetArea())
	Local aAreaSE1	:= SE1->(GetArea())
	Local aAreaSE5	:= SE5->(GetArea())
	Local nX_

	If Len(::aRecnoTit) > 0

		Begin Transaction

			If ::lContab

				Private nHdlPrv 	:= @::nHdlPrv
				Private cLote		:= @::cLote
				Private aFlagCTB	:= @::aFlagCTB
				Private cArquivo 	:= @::cArquivo

			EndIf

			DBSelectArea("SA1")
			SA1->(DBSetOrder(1)) // A1_FILIAL, A1_COD, A1_LOJA, R_E_C_N_O_, D_E_L_E_T_

			For nX_ := 1 To Len(::aFatura)

				SA1->(DBSeek(xFilial("SA1") + ::aFatura[nX_][FPOSCLI] + ::aFatura[nX_][FPOSLOJ]))

				DbSelectArea("SE1")

				RecLock("SE1", .T.)
				SE1->E1_FILIAL   	:= xFilial("SE1")
				SE1->E1_PREFIXO  	:= GetNewPar("MV_FATPREF", "1")
				SE1->E1_NUM      	:= ::cNumFat
				SE1->E1_PARCELA	 	:= ::aFatura[nX_][FPOSPAR]
				SE1->E1_TIPO     	:= ::aFatura[nX_][FPOSTIP]
				SE1->E1_NATUREZ  	:= ::cNatureza
				SE1->E1_CLIENTE  	:= ::aFatura[nX_][FPOSCLI]
				SE1->E1_LOJA     	:= ::aFatura[nX_][FPOSLOJ]
				SE1->E1_NOMCLI   	:= SA1->A1_NREDUZ
				SE1->E1_YUFCLI	 	:= SA1->A1_EST
				SE1->E1_EMISSAO  	:= dDataBase
				SE1->E1_VENCTO   	:= ::aFatura[nX_][FPOSVENC]
				SE1->E1_VENCREA  	:= ::aFatura[nX_][FPOSVENCR]
				SE1->E1_VALOR    	:= ::aFatura[nX_][FPOSVLR]
				SE1->E1_EMIS1    	:= dDataBase
				SE1->E1_SITUACA  	:= "0"
				SE1->E1_SALDO    	:= ::aFatura[nX_][FPOSVLR]
				SE1->E1_VENCORI  	:= ::aFatura[nX_][FPOSVENC]
				SE1->E1_MOEDA    	:= 1
				SE1->E1_FATURA   	:= "NOTFAT"
				SE1->E1_OCORREN  	:= "01"
				SE1->E1_VLCRUZ   	:= ::aFatura[nX_][FPOSVLR]
				SE1->E1_STATUS   	:= "A"
				SE1->E1_ORIGEM   	:= "FINA280"
				SE1->E1_FILORIG  	:= cFilAnt
				SE1->E1_YFORMA   	:= "1"
				SE1->E1_YRECR		:= "N"

				/* Em teste feito pela rotina padrao,
				esses campos nao sao preenchidos.
				SE1->E1_PORCJUR  	:= GetMv("MV_TXPER")
				SE1->E1_VEND1	 	:= ""
				SE1->E1_VEND2	 	:= ""
				SE1->E1_VEND3	 	:= ""
				SE1->E1_VEND4	 	:= ""
				SE1->E1_VEND5	 	:= ""

				SE1->E1_PORTADO  	:= ""
				SE1->E1_YBAIDEL  	:= ""
				SE1->E1_YRECR	 	:= ""
				SE1->E1_YEMP	 	:= ""
				*/
				SE1->E1_YCLASSE		:= "5"	

				SE1->(MsUnLock())

				aAdd(aRecFat, SE1->(Recno()))

				::oLog:cIDProc := ::oPro:cIDProc
				::oLog:cOperac := "R"
				::oLog:cMetodo := "CR_FAT_INTER"
				::oLog:cTabela := RetSQLName("SE1")
				::oLog:nIDTab := SE1->(Recno())
				::oLog:cHrFin := Time()
				::oLog:cEnvWF := "S"
				::oLog:cRetMen := "Criacao de fatura receber " + ::cNumFat + " referente fatura a pagar: " + ::aFatura[1][FPOSNUM]

				::oLog:Insert()

			Next nX_

			For nW_ := 1 To Len(::aRecnoTit)

				SE1->(DBGoTo(::aRecnoTit[nW_]))

				cVendTit := If(Empty(cVendTit), SE1->E1_VEND1, cVendTit)

				RecLock("SE1", .F.)
				SE1->E1_YFATPAG := ::aFatura[1][FPOSNUM]
				SE1->E1_MOVIMEN := dDataBase
				SE1->E1_DTFATUR := dDataBase			
				SE1->E1_FATPREF := GetNewPar("MV_FATPREF", "1")
				SE1->E1_FATURA  := ::cNumFat
				SE1->E1_OK      := "ok"
				SE1->E1_STATUS  := "B"
				SE1->E1_FLAGFAT := "S"
				SE1->E1_TIPOFAT := "FT"

				If ::lBaixaTit

					SE1->E1_BAIXA   := dDataBase
					SE1->E1_VALLIQ  := SE1->E1_SALDO
					SE1->E1_SALDO   := 0

				EndIf

				SE1->(MSUnLock())

				::oLog:cIDProc := ::oPro:cIDProc
				::oLog:cOperac := "R"
				::oLog:cMetodo := "CR_FAT_INTER"
				::oLog:cTabela := RetSQLName("SE1")
				::oLog:nIDTab := SE1->(Recno())
				::oLog:cHrFin := Time()

				If ::lBaixaTit

					::oLog:cRetMen := "Baixando titulo ref fatura " + ::cNumFat

				Else

					::oLog:cRetMen := "Incluindo na fatura " + ::cNumFat

				EndIf

				::oLog:cEnvWF := "N"

				::oLog:Insert()

				If ::lBaixaTit

					DbSelectArea("SE5")
					DbSetOrder(1)

					RecLock("SE5", .T.)
					SE5->E5_FILIAL	:= xFilial("SE5")
					SE5->E5_DATA	:= dDataBase
					SE5->E5_VENCTO	:= SE1->E1_VENCTO
					SE5->E5_TIPO	:= SE1->E1_TIPO
					SE5->E5_VALOR	:= SE1->E1_VALLIQ
					SE5->E5_NATUREZ	:= SE1->E1_NATUREZ
					SE5->E5_RECPAG	:= "R"
					SE5->E5_BENEF	:= SE1->E1_NOMCLI
					SE5->E5_HISTOR	:= "Bx.Emis.Fat." + ::cNumFat
					SE5->E5_TIPODOC	:= "BA"
					SE5->E5_VLMOED2	:= SE1->E1_VALLIQ
					SE5->E5_LA		:= "S"
					SE5->E5_PREFIXO	:= SE1->E1_PREFIXO
					SE5->E5_NUMERO	:= SE1->E1_NUM
					SE5->E5_PARCELA	:= SE1->E1_PARCELA
					SE5->E5_CLIFOR	:= SE1->E1_CLIENTE
					SE5->E5_LOJA	:= SE1->E1_LOJA
					SE5->E5_DTDIGIT	:= dDataBase
					SE5->E5_MOTBX	:= "FAT"
					SE5->E5_SEQ		:= "01"
					SE5->E5_DTDISPO	:= dDataBase
					SE5->E5_FILORIG	:= cFilAnt
					SE5->E5_MOEDA	:= "M1"
					SE5->E5_TXMOEDA	:= 0
					SE5->E5_FATURA	:= ::cNumFat
					SE5->E5_FATPREF	:= GetNewPar("MV_FATPREF", "1")
					SE5->E5_CLIENTE	:= SE1->E1_CLIENTE
					SE5->E5_ORIGEM	:= "FINA280"
					SE5->(MsUnLock())

					FinXSE5(SE5->(Recno()), 3)

				EndIf

				If ::lContab

					// Atualiza saldo bancario
					AtuSalBco(SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_DATA, SE5->E5_VALOR, "-")

					// Adiciona linha ao lancamento contabil
					nTotal := DetProva(::nHdlPrv, ::cLanPad, "FINA280", ::cLote, /*nLinha*/, /*lExecuta*/, /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/, /*lPosiciona*/, @::aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/)

					// Calcula rodape do lancamento contabil
					RodaProva(::nHdlPrv, nTotal)

					// Grava lancamento contabil
					cA100Incl(::cArquivo, ::nHdlPrv, 3, ::cLote, .F., .F.)

				EndIf

				If ::lBaixaFat

					lRet := .T. // Baixa a fatura - colocar a rotina

					If !lRet

						DisarmTransaction()

					EndIf

				EndIf

			Next nW_

			For nX_ := 1 To Len(aRecFat)

				SE1->(DBGoTo(aRecFat[nX_]))

				RecLock("SE1", .F.)
				SE1->E1_VEND1 := cVendTit
				SE1->(MSUnLock())

			Next nX_

		End Transaction

	Else

		::oLog:cIDProc := ::oPro:cIDProc
		::oLog:cOperac := "R"
		::oLog:cMetodo := "CR_FAT_INTER"
		::oLog:cTabela := RetSQLName("SE1")
		::oLog:cHrFin := Time()
		::oLog:cRetMen := "Baixa automatica ref fatura " + ::cNumFat + " [não encontrou titulos!]"
		::oLog:cEnvWF := "N"

		::oLog:Insert()

	EndIf

	RestArea(aAreaSA1)
	RestArea(aAreaSE1)
	RestArea(aAreaSE5)

Return(lRet)

Method GetMaxNumFat() Class TFaturaReceber

	Local aTam := TamSx3("E1_NUM")
	Local cFatura := Soma1(GetMv("MV_NUMFAT"), aTam[1])
	Local cSQL := ""
	Local cQry := ""

	If Len(AllTrim(cFatura)) <> aTam[1]

		cFatura	+= Space(aTam[1] - Len(cFatura))

		cQry := GetNextAlias()

		cSQL := "SELECT ISNULL(MAX(A.E1_FATURA), REPLICATE('0', " + cValToChar(aTam[1] - 1) + ") + '1') E1_FATURA "
		cSQL += "FROM " + RetSQLName("SE1") + " A ( NOLOCK ) "
		cSQL += "WHERE LEN(RTRIM(LTRIM(A.E1_FATURA))) = " + cValToChar(aTam[1])
		cSQL += "AND A.D_E_L_E_T_ = '' "

		TcQuery cSQL New Alias (cQry)

		cFatura := (cQry)->E1_FATURA

		(cQry)->(DbCloseArea())

	EndIf

Return(cFatura)

Method GetNextNumFat(cPrefix) Class TFaturaReceber

	Local aAreaSE1	:= SE1->(GetArea())
	Local cFatura 	:= ::GetMaxNumFat()
	Local cMay 		:= ""

	Default cPrefix	:= SuperGetMv("MV_FATPREF",, Space(3))

	If Len(cPrefix) < 3

		cPrefix := cPrefix + Space(3 - Len(cPrefix))

	EndIf

	cMay := "SE1" + xFilial("SE1") + cFatura

	DBSelectArea("SE1")
	SE1->(DbSetOrder(1)) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_

	While SE1->(MsSeek(xFilial("SE1") + PADR(cPrefix, 3) + cFatura)) .Or. !MayIUseCode(cMay)

		// Busca o proximo numero disponivel 
		cFatura := Soma1(RTrim(cFatura))

		cMay := "SE1" + xFilial("SE1") + cFatura

	EndDo

	PutMV("MV_NUMFAT", cFatura)

	RestArea(aAreaSE1)

Return(cFatura)