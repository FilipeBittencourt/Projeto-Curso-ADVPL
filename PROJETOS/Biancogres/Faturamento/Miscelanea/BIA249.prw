#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIA249
@description Controle de Cargas Protheus x Ecosis x Balança
@author Marcos Alberto Soprani
@since 14/12/12
@version 1.0 Revisado por Fernando Rocha 08/02/2012
@type function
/*/

User Function BIA249()

	Local lRet 		:= .T.
	Local lLEcoNE	:= GetNewPar("MV_YLECONE", .F.)
	Local aArea		:= GetArea()	
	
	
	If (!Empty(ZZV->ZZV_TICKET))
	
		//lRet := U_BIA249VE(ZZV->ZZV_TICKET, .T.)

	EndIf
	
	DbSelectArea("ZZV")
	ZZV->(dbSetOrder(1))
	If ZZV->(DbSeek(xFilial("ZZV")+ZZV->ZZV_CARGA))
		If (ZZV->(FieldPos("ZZV_SCECOS")) > 0)
			If (Empty(ZZV->ZZV_SCECOS))
				Reclock("ZZV", .F.)
				ZZV->ZZV_SCECOS	:= IIF(lRet, 'S', 'N') 
				ZZV->(MsUnLock())
			EndIf
		EndIf
	EndIf
	
	If lRet .Or. lLEcoNE

		U_BIAMsgRun('Carregando Pesagem...', 'Aguarde!', {|| fProcess() })

	EndIf

	RestArea(aArea)

Return()


Static Function fProcess()

	Local _aSize 		:=	{}
	Local _aObjects		:=	{}
	Local _aInfo 		:=	{}
	Local _aPosObj 		:=	{}
	Local cSQL 			:= ""
	Local cQry 			:= GetNextAlias()

	Private oPesaCarga	:= Nil
	Private oDlgCarga
	Private oFont1 := TFont():New("Arial",,020,,.T.,,,,,.F.,.F.)
	Private oFont2 := TFont():New("Arial",,020,,.T.,,,,,.F.,.F.)
	Private oGroup1
	Private oSay1
	Private oSay10
	Private oSay11
	Private oSay12
	Private oSay13
	Private oSay14
	Private oSay15
	Private oSay16
	Private oSay17
	Private oSay18
	Private oSay19
	Private oSay2
	Private oSay3
	Private oSay4
	Private oSay5
	Private oSay6
	Private oSay7
	Private oSay8
	Private oSay9
	Private oMultiGet1
	Private cMultiGet1 := ""
	Private xfAlterObs := .F.
	Private kt_BsDad
	Private ktGuardi := ""
	Private cCbConf	:= Nil

	rbCarga := ""
	rbTickt := ""
	rbDtInc := cToD("")
	rbPlaca := ""
	rbMotor := ""
	rbPsFat := 0
	rbPsEco := 0
	rbPsBal := 0
	rbPsBru := 0

	If cEmpAnt == "01"

		kt_BsDad := "DADOSEOS"

	ElseIf cEmpAnt == "05"

		kt_BsDad := "DADOS_05_EOS"

	ElseIf cEmpAnt == "14"

		kt_BsDad := "DADOS_14_EOS"

	Else

		MsgINFO("Empresa não configurada para controle de BALANÇA!!!")

		Return()

	EndIf

	cSQL := " SELECT ZZV_CARGA, ZZV_TICKET, ZZV_DATINC, ZZV_PLACA, ZZV_MOTOR, "
	cSQL += " ( "
	cSQL += " 	SELECT SUM(F2_PBRUTO) "
	cSQL += "   FROM " + RetSQLName("SF2")
	cSQL += " 	WHERE F2_FILIAL = " + ValToSQL(xFilial("SF2"))
	cSQL += " 	AND SUBSTRING(F2_YAGREG, 5, 4) = ZZV_CARGA "
	cSQL += " ) AS PES_FAT, "
	cSQL += " ( "
	cSQL += "   SELECT SUM(iord_peso) "
	cSQL += "   FROM DADOSEOS.dbo.fat_ordem_faturamento ORDEM "
	cSQL += "   INNER JOIN DADOSEOS.dbo.fat_itens_ordem ITENS "
	cSQL += "   ON ITENS.ford_numero = ORDEM.ford_numero "
	cSQL += "   WHERE ORDEM.ford_num_carga COLLATE Latin1_General_BIN = ZZV_CARGA "
	cSQL += " ) AS PES_ECO, "
	cSQL += " ( "
	cSQL += "		SELECT SUM(Z11_PESLIQ) "
	cSQL += "   FROM " + RetSQLName("Z11")
	cSQL += "   WHERE Z11_FILIAL = " + ValToSQL(xFilial("Z11"))
	cSQL += "   AND Z11_PESAGE = ZZV_TICKET "
	cSQL += "   AND D_E_L_E_T_ = '' "
	cSQL += " ) AS PES_BAL, "
	cSQL += " ( "
	cSQL += "		SELECT SUM(Z11_PESOSA) "
	cSQL += "   FROM " + RetSQLName("Z11")
	cSQL += "   WHERE Z11_FILIAL = " + ValToSQL(xFilial("Z11"))
	cSQL += "   AND Z11_PESAGE = ZZV_TICKET "
	cSQL += "   AND D_E_L_E_T_ = '' "
	cSQL += " ) AS PES_BRU, "
	cSQL += " ( "
	cSQL += "		SELECT TOP 1 Z11_OBSER "
	cSQL += "   FROM " + RetSQLName("Z11")
	cSQL += "   WHERE Z11_FILIAL = " + ValToSQL(xFilial("Z11"))
	cSQL += " 	AND Z11_PESAGE = ZZV_TICKET "
	cSQL += "   AND D_E_L_E_T_ = '' "
	cSQL += " ) AS OBS_TICKT, "
	cSQL += " ( "
	cSQL += "		SELECT TOP 1 Z11_GUARDI "
	cSQL += "   FROM " + RetSQLName("Z11")
	cSQL += "   WHERE Z11_FILIAL = " + ValToSQL(xFilial("Z11"))
	cSQL += "   AND Z11_PESAGE = ZZV_TICKET "
	cSQL += "   AND D_E_L_E_T_ = '' "
	cSQL += " ) AS GUARDIAN "
	cSQL += "	FROM " + RetSqlName("ZZV")
	cSQL += " WHERE ZZV_FILIAL = " + ValToSQL(xFilial("ZZV"))

	If !Empty(ZZV->ZZV_TICKET)
		cSQL += " AND (ZZV_CARGA = " + ValToSQL(ZZV->ZZV_CARGA) + " OR ZZV_TICKET = " + ValToSQL(ZZV->ZZV_TICKET) + ") "
	Else
		cSQL += " AND ZZV_CARGA = " + ValToSQL(ZZV->ZZV_CARGA)
	EndIf

	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	If !Empty((cQry)->ZZV_CARGA)

		rbCarga := (cQry)->ZZV_CARGA
		rbTickt := (cQry)->ZZV_TICKET
		rbDtInc := stod((cQry)->ZZV_DATINC)
		rbPlaca := (cQry)->ZZV_PLACA
		rbMotor := (cQry)->ZZV_MOTOR
		cMultiGet1 := (cQry)->OBS_TICKT
		ktGuardi := Alltrim((cQry)->GUARDIAN)
		rbPsBal := (cQry)->PES_BAL
		rbPsBru := (cQry)->PES_BRU

		If Empty(ZZV->ZZV_TICKET)

			rbPsFat := (cQry)->PES_FAT
			rbPsEco := (cQry)->PES_ECO

		Else

			rbPsFat := fPesFat(ZZV->ZZV_TICKET)
			rbPsEco := fPesEco(ZZV->ZZV_TICKET)

		EndIf

	EndIf

	(cQry)->(dbCloseArea())


	cNumTicket			:= ""
	cNumExTicket		:=""
	nCapVeiculo			:= 0
	nPesoAdCarroceria	:= 0
	nPesoBalanca		:= 0
	nPesoFat			:= 0
	nPesoEcosis			:= 0
	nDiverPeso			:= 0
	nDiverCapacidade	:= 0
	nPesoBruto			:= 0
	cObsTicket			:= ""
	cConferido			:= ""
	cPreAutorizado		:= ""
	nIcmFreLM			:= 0
	nIcmFreBia			:= 0

	oPesaCarga := TPesagemCarga():New(ZZV->ZZV_CARGA, ZZV->ZZV_TICKET)

	nCapVeiculo			:= oPesaCarga:nCapVeiculo
	nPesoAdCarroceria	:= oPesaCarga:nPesoAdCarroceria
	nPesoBalanca		:= oPesaCarga:nPesoBalanca
	nPesoFat			:= oPesaCarga:nPesoFat
	nPesoEcosis			:= oPesaCarga:nPesoEcosis
	nDiverPeso			:= oPesaCarga:nDiverPeso
	nDiverCapacidade	:= oPesaCarga:nDiverCapacidade
	nPesoBruto			:= oPesaCarga:nPesoBruto
	cObsTicket			:= AllTrim(oPesaCarga:cObsTicket)
	cConferido			:= IIF(AllTrim(oPesaCarga:cConferido) == 'S', 'Sim', IIF(AllTrim(oPesaCarga:cConferido) == 'N', 'Não', ''))
	cPreAutorizado		:= AllTrim(oPesaCarga:cPreAutorizado)
	cAutoEmail			:= AllTrim(oPesaCarga:cConferido)//A=Aprovado OU R=Reprovada
	nIcmFreLM			:= oPesaCarga:nIcmFreLM
	nIcmFreBia			:= oPesaCarga:nIcmFreBia
	cNumTicket			:= oPesaCarga:cNumTicket
	cNumExTicket		:= oPesaCarga:cNumExTicket

	_aSize := MsAdvSize(.T.)

	AAdd(_aObjects, {100, 35, .T. , .T. })
	AAdd(_aObjects, {100, 65, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	DEFINE MSDIALOG oDlgCarga TITLE "Controle de Pesagem de Carga" FROM _aSize[7],0 To _aSize[6],_aSize[5] COLORS 0, 16777215 PIXEL

	@ _aPosObj[1,1], _aPosObj[1,2] GROUP oGroup1 TO _aPosObj[1,3], _aPosObj[1,4] OF oDlgCarga COLOR 0, 16777215 PIXEL

	@ _aPosObj[1,1]+007, 012 SAY oSay1 PROMPT "Carga:"                                  SIZE 028, 010 OF oDlgCarga FONT oFont1 COLORS CLR_BLUE PIXEL
	@ _aPosObj[1,1]+007, 043 SAY oSay2 PROMPT rbCarga                                   SIZE 039, 010 OF oDlgCarga FONT oFont2 COLORS CLR_CYAN PIXEL

	If (Empty(cNumExTicket))
		@ _aPosObj[1,1]+007, 080 SAY oSay3 PROMPT "Ticket:"                                 SIZE 029, 010 OF oDlgCarga FONT oFont1 COLORS CLR_BLUE PIXEL
		@ _aPosObj[1,1]+007, 111 SAY oSay4 PROMPT cNumTicket                                SIZE 031, 009 OF oDlgCarga FONT oFont2 COLORS CLR_CYAN PIXEL
	Else
		@ _aPosObj[1,1]+007, 075 SAY oSay3 PROMPT "Ticket Ex:"                                 SIZE 040, 010 OF oDlgCarga FONT oFont1 COLORS CLR_BLUE PIXEL
		@ _aPosObj[1,1]+007, 125 SAY oSay4 PROMPT cNumExTicket                                 SIZE 031, 009 OF oDlgCarga FONT oFont2 COLORS CLR_CYAN PIXEL
	EndIf

	@ _aPosObj[1,1]+007, 150 SAY oSay3 PROMPT "Guardian:"                               SIZE 040, 010 OF oDlgCarga FONT oFont1 COLORS CLR_BLUE PIXEL
	@ _aPosObj[1,1]+007, 195 SAY oSay4 PROMPT ktGuardi                                  SIZE 040, 009 OF oDlgCarga FONT oFont2 COLORS CLR_CYAN PIXEL

	@ _aPosObj[1,1]+007, 245 SAY oSay5 PROMPT "Dt Entrada:"                             SIZE 068, 010 OF oDlgCarga FONT oFont1 COLORS CLR_BLUE PIXEL
	@ _aPosObj[1,1]+007, 290 SAY oSay6 PROMPT dtoc(rbDtInc)                             SIZE 036, 009 OF oDlgCarga FONT oFont2 COLORS CLR_CYAN PIXEL

	@ _aPosObj[1,1]+007, 370 SAY oSay21 PROMPT "ICMS Frete Aut. LM:"           	         	SIZE 120, 050 OF oDlgCarga FONT oFont1 COLORS CLR_BLUE PIXEL
	@ _aPosObj[1,1]+007, 450 SAY oSay22 PROMPT Transform(nIcmFreLM, "@E 999,999,999.99")	SIZE 080, 009 OF oDlgCarga FONT oFont2 COLORS CLR_CYAN PIXEL

	@ _aPosObj[1,1]+022, 370 SAY oSay21 PROMPT "ICMS Frete Aut. Bianco:"					SIZE 120, 090 OF oDlgCarga FONT oFont1 COLORS CLR_BLUE PIXEL
	@ _aPosObj[1,1]+022, 450 SAY oSay22 PROMPT Transform(nIcmFreBia, "@E 999,999,999.99")	SIZE 080, 009 OF oDlgCarga FONT oFont2 COLORS CLR_CYAN PIXEL

	@ _aPosObj[1,1]+022, 012 SAY oSay7 PROMPT "Placa:"                                  SIZE 028, 010 OF oDlgCarga FONT oFont1 COLORS CLR_BLUE PIXEL
	@ _aPosObj[1,1]+022, 042 SAY oSay8 PROMPT Transform(rbPlaca, "@R AAA-9999")         SIZE 041, 010 OF oDlgCarga FONT oFont2 COLORS CLR_CYAN PIXEL

	@ _aPosObj[1,1]+022, 093 SAY oSay9 PROMPT "Motorista:"                              SIZE 043, 011 OF oDlgCarga FONT oFont1 COLORS CLR_BLUE PIXEL
	@ _aPosObj[1,1]+022, 137 SAY oSay10 PROMPT rbMotor                                  SIZE 131, 010 OF oDlgCarga FONT oFont2 COLORS CLR_CYAN PIXEL

	@ _aPosObj[1,1]+036, 012 SAY oSay11 PROMPT "Peso Faturamento:"                      		SIZE 075, 010 OF oDlgCarga FONT oFont1 COLORS CLR_BLUE PIXEL
	@ _aPosObj[1,1]+048, 033 SAY oSay12 PROMPT Transform(nPesoFat, "@E 999,999,999.99")  		SIZE 056, 009 OF oDlgCarga FONT oFont2 COLORS CLR_CYAN PIXEL

	@ _aPosObj[1,1]+036, 114 SAY oSay13 PROMPT "Peso Ecosis:"                           		SIZE 055, 010 OF oDlgCarga FONT oFont1 COLORS CLR_BLUE PIXEL
	@ _aPosObj[1,1]+048, 115 SAY oSay14 PROMPT Transform(nPesoEcosis, "@E 999,999,999.99")  	SIZE 049, 009 OF oDlgCarga FONT oFont2 COLORS CLR_CYAN PIXEL

	@ _aPosObj[1,1]+036, 210 SAY oSay15 PROMPT "Peso Balança:"                          		SIZE 059, 010 OF oDlgCarga FONT oFont1 COLORS CLR_BLUE PIXEL
	@ _aPosObj[1,1]+048, 218 SAY oSay16 PROMPT Transform(nPesoBalanca, "@E 999,999,999.99")  	SIZE 047, 009 OF oDlgCarga FONT oFont2 COLORS CLR_CYAN PIXEL

	@ _aPosObj[1,1]+036, 293 SAY oSay17 PROMPT "Divergência:"                           	SIZE 059, 010 OF oDlgCarga FONT oFont1 COLORS CLR_BLACK PIXEL
	@ _aPosObj[1,1]+048, 300 SAY oSay18 PROMPT Transform(nDiverPeso, "@E 999,999.99")+" %" 	SIZE 047, 009 OF oDlgCarga FONT oFont2 COLORS CLR_HRED PIXEL

	@ _aPosObj[1,1]+060, 012 SAY oSay23 PROMPT "Tampa:"					                   					SIZE 080, 011 OF oDlgCarga FONT oFont1 COLORS CLR_BLACK PIXEL
	@ _aPosObj[1,1]+070, 033 SAY oSay24 PROMPT Transform(nPesoAdCarroceria, "@E 999,999,999.99")			SIZE 056, 010 OF oDlgCarga FONT oFont2 COLORS CLR_BLACK PIXEL

	@ _aPosObj[1,1]+060, 114 SAY oSay13 PROMPT "Peso Bruto:"     		                  		   			SIZE 080, 010 OF oDlgCarga FONT oFont1 COLORS CLR_BLACK PIXEL
	@ _aPosObj[1,1]+070, 115 SAY oSay14 PROMPT Transform(nPesoBruto, "@E 999,999,999.99")  					SIZE 049, 009 OF oDlgCarga FONT oFont2 COLORS CLR_BLACK PIXEL

	@ _aPosObj[1,1]+060, 210 SAY oSay15 PROMPT "PBT Total:"		                          					SIZE 059, 010 OF oDlgCarga FONT oFont1 COLORS CLR_BLACK PIXEL
	@ _aPosObj[1,1]+070, 218 SAY oSay16 PROMPT Transform(nPesoAdCarroceria+nPesoBruto, "@E 999,999,999.99") SIZE 047, 009 OF oDlgCarga FONT oFont2 COLORS CLR_BLACK PIXEL

	@ _aPosObj[1,1]+060, 293 SAY oSay17 PROMPT "PBT Cap.:"	                        	   					SIZE 059, 010 OF oDlgCarga FONT oFont1 COLORS CLR_BLACK PIXEL
	@ _aPosObj[1,1]+070, 300 SAY oSay18 PROMPT Transform(nCapVeiculo, "@E 999,999,999.99")					SIZE 047, 009 OF oDlgCarga FONT oFont2 COLORS CLR_BLACK PIXEL

	@ _aPosObj[1,1]+060, 376 SAY oSay17 PROMPT "%PBT:" 					                           			SIZE 059, 010 OF oDlgCarga FONT oFont1 COLORS CLR_BLACK PIXEL
	@ _aPosObj[1,1]+070, 378 SAY oSay18 PROMPT Transform(nDiverCapacidade, "@E 999,999.99")+" %"	  	SIZE 047, 009 OF oDlgCarga FONT oFont2 COLORS CLR_HRED PIXEL

	// Tiago Rossini Coradini - 24/05/16 - OS: 2074-16 - Angelo Alencar - Adicionado campo de peso bruto a tela

	fGetDdCarga(_aPosObj)
	zrButtons := {}

	@ _aPosObj[1,1]+007, 500 SAY oSay20 PROMPT "Conferido:" 				SIZE 053, 009 OF oDlgCarga FONT oFont1 COLORS CLR_BLUE PIXEL
	@ _aPosObj[1,1]+007, 540 ComboBox cConferido Items {" ","Sim","Não"}	SIZE 047, 009 OF oDlgCarga FONT oFont2 COLORS CLR_HRED PIXEL

	@ _aPosObj[1,1]+022, 500 SAY oSay19 PROMPT "Observação:" SIZE 053, 009 OF oDlgCarga FONT oFont1 COLORS CLR_BLUE PIXEL
	@ _aPosObj[1,1]+032, 500 GET oMultiGet1 VAR cObsTicket OF oDlgCarga MULTILINE SIZE 130, 045 COLORS 0, 16777215 HSCROLL PIXEL

	//@ _aPosObj[1,1]+032, 480 GET oMultiGet1 VAR cMultiGet1 OF oDlgCarga MULTILINE SIZE 130, 045 When xfAlterObs VALID BIA249O()  COLORS 0, 16777215 HSCROLL PIXEL

	aAdd(zrButtons,{"NOVACELULA",{|| BIA249A()},"IntraEmpresa"})
	//aAdd(zrButtons,{"NOVACELULA",{|| BIA249C()},"Observação"})

	ACTIVATE MSDIALOG oDlgCarga CENTERED ON INIT (EnchoiceBar(oDlgCarga, {|| IIF(SalvarDialog(), oDlgCarga:End(),) }, {|| oDlgCarga:End()},,zrButtons))

Return()

Static Function SalvarDialog()

	Local lRetPesagem := .F.

	Processa( {|| lRetPesagem := ConfPesagem() }, "Aguarde...", "Processando informações de peso...",.F.)

Return lRetPesagem

Static Function ConfPesagem()

	Local cMsg			:= ""
	Local aRet			:= Nil
	Local lOk			:= Nil
	Local cMensagem		:= Nil
	Local cConf			:= ""
	Local cObservacao	:= AllTrim(cObsTicket)

	If (Alltrim(cConferido) == "Sim")

		If (AllTrim(cPreAutorizado) == 'S')
			lOk			:= .T.
			cMensagem	:= ""
		ElseIf (AllTrim(cAutoEmail) == 'A')
			lOk			:= .T.
			cMensagem	:= ""
		Else
			aRet 		:= oPesaCarga:DivergenciaValidas()
			lOk			:= aRet[1]
			cMensagem	:= aRet[2]
		EndIf


		If (!lOk)
			cMsg := "<font size='3' color='red'>"+cMensagem+"</font>"
			Alert(cMsg)
			Return .F.
		Else

			If (!Empty(cObsTicket))

				If (!Empty(cConferido))
					cConf := IIF(Alltrim(cConferido) == "Sim", 'S', 'N')
					oPesaCarga:Conferir(cConf, cObservacao)
				EndIf
				Return .T.

			Else

				Alert("<font size='3' color='red'>Campo observação é obrigatório.</font>")

			EndIf


		EndIf

	EndIf

Return

/*/{Protheus.doc} fGetDdCarga
@description Monta Grid  
/*/
Static Function fGetDdCarga(_aPosObj)

	Local nX
	Local aHeaderEx := {}
	Local aColsEx := {}
	Local aFieldFill := {}
	Local aFields := {"CARGAECO","D2_CLIENTE","D2_LOJA","A1_NOME","D2_DOC","D2_SERIE","D2_PEDIDO","D2_ITEMPV","D2_COD","B1_DESC","D2_LOTECTL","D2_QUANT","PESOPRT","QUANTECO","PESOECO","D2_EMISSAO"}
	Local aAlterFields := {}
	Private oGetDdCarga

// Define field properties
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	For nX := 1 to Len(aFields)

		If Alltrim(aFields[nX]) == "CARGAECO"
			Aadd(aHeaderEx, {"CargaEco", "CARGAECO", "@!", 10, 0, , , "C", , , ,})

		ElseIf Alltrim(aFields[nX]) == "B1_DESC"
			Aadd(aHeaderEx, {AllTrim("Descrição"),SX3->X3_CAMPO,SX3->X3_PICTURE, 40,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})

		ElseIf Alltrim(aFields[nX]) == "A1_NOME"
			Aadd(aHeaderEx, {AllTrim("Nome"),SX3->X3_CAMPO,SX3->X3_PICTURE, 40,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})

		ElseIf Alltrim(aFields[nX]) == "PESOPRT"
			Aadd(aHeaderEx, {"PesoNota", "PESOPRT", "@R 999,999,999.99", 14, 2, , , "N", , , ,})

		ElseIf Alltrim(aFields[nX]) == "QUANTECO"
			Aadd(aHeaderEx, {"QuantEco", "QUANTECO", "@R 999,999,999.99", 14, 2, , , "N", , , ,})

		ElseIf Alltrim(aFields[nX]) == "PESOECO"
			Aadd(aHeaderEx, {"PesoEco", "PESOECO", "@R 999,999,999.99", 14, 2, , , "N", , , ,})

		ElseIf SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})

		Endif

	Next nX

	QM007 := " SELECT ford_numero CARGA_ECO,
	QM007 += "        D2_CLIENTE,
	QM007 += "        D2_LOJA,
	QM007 += "        CASE
	QM007 += "          WHEN F2_TIPO IN('B','D') THEN A2_NOME
	QM007 += "          ELSE A1_NOME
	QM007 += "        END A1_NOME,
	QM007 += "        D2_DOC,
	QM007 += "        D2_SERIE,
	QM007 += "        D2_PEDIDO,
	QM007 += "        D2_ITEMPV,
	QM007 += "        D2_COD,
	QM007 += "        SUBSTRING(B1_DESC,1,50) B1_DESC,
	QM007 += "        D2_LOTECTL,
	QM007 += "        D2_QUANT,
	QM007 += "        CASE
	QM007 += "          WHEN B1_TIPCONV = 'M' THEN ( D2_QUANT * ISNULL((SELECT ZZ9_PESO
	QM007 += "                                                            FROM "+RetSqlName("ZZ9")+" ZZ9
	QM007 += "                                                           WHERE ZZ9_FILIAL = '"+xFilial("ZZ9")+"'
	QM007 += "                                                             AND ZZ9_PRODUT = D2_COD
	QM007 += "                                                             AND ZZ9_LOTE = D2_LOTECTL
	QM007 += "                                                             AND ZZ9.D_E_L_E_T_ <> '*'), B1_PESO) ) + ( ( D2_QUANT * B1_CONV ) * ISNULL((SELECT ZZ9_PESEMB
	QM007 += "                                                                                                                                           FROM "+RetSqlName("ZZ9")+" ZZ9
	QM007 += "                                                                                                                                          WHERE ZZ9_FILIAL = '"+xFilial("ZZ9")+"'
	QM007 += "                                                                                                                                            AND ZZ9_PRODUT = D2_COD
	QM007 += "                                                                                                                                            AND ZZ9_LOTE = D2_LOTECTL
	QM007 += "                                                                                                                                            AND ZZ9.D_E_L_E_T_ <> '*'), B1_YPESEMB) )
	QM007 += "          ELSE ( D2_QUANT * ISNULL((SELECT ZZ9_PESO
	QM007 += "                                      FROM "+RetSqlName("ZZ9")+" ZZ9
	QM007 += "                                     WHERE ZZ9_FILIAL = '"+xFilial("ZZ9")+"'
	QM007 += "                                       AND ZZ9_PRODUT = D2_COD
	QM007 += "                                       AND ZZ9_LOTE = D2_LOTECTL
	QM007 += "                                       AND ZZ9.D_E_L_E_T_ <> '*'), B1_PESO) ) + ( ( D2_QUANT / B1_CONV ) * ISNULL((SELECT ZZ9_PESEMB
	QM007 += "                                                                                                                     FROM "+RetSqlName("ZZ9")+" ZZ9
	QM007 += "                                                                                                                    WHERE ZZ9_FILIAL = '"+xFilial("ZZ9")+"'
	QM007 += "                                                                                                                      AND ZZ9_PRODUT = D2_COD
	QM007 += "                                                                                                                      AND ZZ9_LOTE = D2_LOTECTL
	QM007 += "                                                                                                                      AND ZZ9.D_E_L_E_T_ <> '*'), B1_YPESEMB) )
	QM007 += "        END PESOBR,
	QM007 += "        iord_qtdade_baixada QTD_ECO,
	QM007 += "        iord_peso PS_ECO,
	QM007 += "        D2_EMISSAO
	QM007 += "   FROM "+RetSqlName("SF2")+" SF2
	QM007 += "  INNER JOIN "+RetSqlName("SD2")+" SD2 ON D2_FILIAL = '"+xFilial("SD2")+"'
	QM007 += "                       AND D2_DOC = F2_DOC
	QM007 += "                       AND D2_SERIE = F2_SERIE
	QM007 += "                       AND D2_CLIENTE = F2_CLIENTE
	QM007 += "                       AND D2_LOJA = F2_LOJA
	QM007 += "                       AND D2_EMISSAO = F2_EMISSAO
	QM007 += "                       AND SD2.D_E_L_E_T_ = ' '
	QM007 += "   LEFT JOIN "+RetSqlName("SA1")+" SA1 ON A1_FILIAL = '"+xFilial("SA1")+"'
	QM007 += "                       AND A1_COD = D2_CLIENTE
	QM007 += "                       AND A1_LOJA = D2_LOJA
	QM007 += "                       AND SA1.D_E_L_E_T_ = ' '
	QM007 += "   LEFT JOIN "+RetSqlName("SA2")+" SA2 ON A2_FILIAL = '"+xFilial("SA2")+"'
	QM007 += "                       AND A2_COD = D2_CLIENTE
	QM007 += "                       AND A2_LOJA = D2_LOJA
	QM007 += "                       AND SA2.D_E_L_E_T_ = ' '
	QM007 += "  INNER JOIN SB1010 SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	QM007 += "                       AND B1_COD = D2_COD
	QM007 += "                       AND SB1.D_E_L_E_T_ = ' '
	QM007 += "   LEFT JOIN "+kt_BsDad+".dbo.fat_itens_ordem ON ford_numero in(SELECT DISTINCT ford_numero
	QM007 += "                                                              FROM "+kt_BsDad+".dbo.fat_ordem_faturamento
	QM007 += "                                                             WHERE ford_num_carga COLLATE Latin1_General_BIN = SUBSTRING(F2_YAGREG,5,4))
	QM007 += "                                         AND RTRIM(cod_pedido) COLLATE Latin1_General_BIN = RTRIM(D2_PEDIDO)
	QM007 += "                                         AND RTRIM(cod_produto) COLLATE Latin1_General_BIN = RTRIM(D2_COD)
	QM007 += "                                         AND RTRIM(iord_lote) COLLATE Latin1_General_BIN = RTRIM(D2_LOTECTL)
	QM007 += "  WHERE F2_FILIAL = '"+xFilial("SF2")+"'
	QM007 += "    AND SUBSTRING(F2_YAGREG,5,4) IN(SELECT ZZV_CARGA
	QM007 += "                       FROM "+RetSqlName("ZZV")
	QM007 += "                      WHERE ZZV_FILIAL = '"+xFilial("ZZV")+"'
	If !Empty(ZZV->ZZV_TICKET)
		QM007 += "                        AND ( ZZV_CARGA = '"+ZZV->ZZV_CARGA+"' OR ZZV_TICKET = '"+ZZV->ZZV_TICKET+"' )
	Else
		QM007 += "                        AND ZZV_CARGA = '"+ZZV->ZZV_CARGA+"'
	EndIf
	QM007 += "                        AND D_E_L_E_T_ = ' ')
	QM007 += "    AND SF2.D_E_L_E_T_ = ' '

	If !Empty(ZZV->ZZV_TICKET)

		QM007 += fSQLCarga(ZZV->ZZV_TICKET)

	EndIf

	QM007 := ChangeQuery(QM007)
	cIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QM007),'SP01',.T.,.T.)
	aStruX := ("SP01")->(dbStruct())
/*----- Exporta os dados do resultado de uma Query para um arquivo temporário normal -----*/
	gh_IndX := "CARGA_ECO"
	If !chkfile("QM01")
		QM01 := U_BIACrTMP(aStruX)
		dbUseArea( .T.,, QM01, "QM01", .F., .F. )
		dbCreateInd(QM01, gh_IndX,{ || gh_IndX })
	EndIf
	dbSelectArea("QM01")
	APPEND FROM ("SP01")
	If Select("SP01") > 0
		Ferase(cIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(cIndex+OrdBagExt())          //indice gerado
		SP01->(dbCloseArea())
	Endif

	dbSelectArea("QM01")
	dbGoTop()
	While !Eof()
		Aadd(aFieldFill, {QM01->CARGA_ECO, QM01->D2_CLIENTE, QM01->D2_LOJA, QM01->A1_NOME, QM01->D2_DOC, QM01->D2_SERIE, QM01->D2_PEDIDO, QM01->D2_ITEMPV, QM01->D2_COD, QM01->B1_DESC, QM01->D2_LOTECTL, QM01->D2_QUANT, QM01->PESOBR, QM01->QTD_ECO, QM01->PS_ECO, stod(QM01->D2_EMISSAO), .F. })
		dbSkip()
	End
	Ferase(QM01+GetDBExtension())     //arquivo de trabalho
	Ferase(QM01+OrdBagExt())          //indice gerado
	QM01->(dbCloseArea())

// Define field values
	If Len(aFieldFill) == 0
		dbSelectArea("SX3")
		dbSetOrder(2)
		For nX := 1 to Len(aFields)
			If Alltrim(aFields[nX]) == "CARGAECO"
				Aadd(aFieldFill, CriaVar("F2_YAGREG"))

			ElseIf Alltrim(aFields[nX]) == "PESOPRT"
				Aadd(aFieldFill, CriaVar("D2_QUANT"))

			ElseIf Alltrim(aFields[nX]) == "QUANTECO"
				Aadd(aFieldFill, CriaVar("D2_QUANT"))

			ElseIf Alltrim(aFields[nX]) == "PESOECO"
				Aadd(aFieldFill, CriaVar("D2_QUANT"))

			ElseIf DbSeek(aFields[nX])
				Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
			Endif
		Next nX
		Aadd(aFieldFill, .F.)
		Aadd(aColsEx, aFieldFill)
	Else
		aColsEx := aFieldFill
	EndIf

	oGetDdCarga := MsNewGetDados():New( _aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], /*GD_INSERT+GD_DELETE+GD_UPDATE*/, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgCarga, aHeaderEx, aColsEx)

Return

/*/{Protheus.doc} BIA249A
@description Tela de Consulta  
/*/
Static Function BIA249A()

	Local gnX
	Local gHeaderEx := {}
	Local gColsEx := {}
	Local gFieldFill := {}
	Local gFields := {"D2_DOC","D2_SERIE","D2_EMISSAO","D2_CLIENTE","D2_LOJA","A1_NOME"}
	Local gAlterFields := {}
	Private oGDNfVc
	Private oDlgNfVinc

// Define field properties
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	For gnX := 1 to Len(gFields)
		If SX3->(dbSeek(gFields[gnX]))
			Aadd(gHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next gnX

	JV004 := " SELECT D2_DOC,
	JV004 += "        D2_SERIE,
	JV004 += "        D2_EMISSAO,
	JV004 += "        D2_CLIENTE,
	JV004 += "        D2_LOJA,
	JV004 += "        A1_NOME
	JV004 += "   FROM SD2070 SD2
	JV004 += "  INNER JOIN SC5070 SC5 ON C5_FILIAL = '01'
	JV004 += "                       AND C5_NUM = D2_PEDIDO
	JV004 += "                       AND SC5.D_E_L_E_T_ = ' '
	JV004 += "  INNER JOIN SA1070 SA1 ON A1_FILIAL = '  '
	JV004 += "                       AND A1_COD = D2_CLIENTE
	JV004 += "                       AND A1_LOJA = D2_LOJA
	JV004 += "                       AND SA1.D_E_L_E_T_ = ' '
	JV004 += "  WHERE D2_FILIAL = '"+xFilial("SD2")+"'
	JV004 += "    AND D2_EMISSAO+ D2_CLIENTE + D2_LOJA + C5_YPEDORI + D2_ITEMPV + D2_COD + D2_LOTECTL + CONVERT(VARCHAR, D2_QUANT)
	JV004 += "                                     IN(SELECT D2_EMISSAO + C5_YCLIORI + C5_YLOJORI + D2_PEDIDO + D2_ITEMPV + D2_COD + D2_LOTECTL + CONVERT(VARCHAR, D2_QUANT)
	JV004 += "                                          FROM "+RetSqlName("SF2")+" SF2
	JV004 += "                                         INNER JOIN "+RetSqlName("SD2")+" SD2 ON D2_FILIAL = '"+xFilial("SD2")+"'
	JV004 += "                                                              AND D2_DOC = F2_DOC
	JV004 += "                                                              AND D2_SERIE = F2_SERIE
	JV004 += "                                                              AND D2_CLIENTE = F2_CLIENTE
	JV004 += "                                                              AND D2_LOJA = F2_LOJA
	JV004 += "                                                              AND D2_EMISSAO = F2_EMISSAO
	JV004 += "                                                              AND SD2.D_E_L_E_T_ = ' '
	JV004 += "                                         INNER JOIN "+RetSqlName("SC5")+" SC5 ON C5_FILIAL = '"+xFilial("SC5")+"'
	JV004 += "                                                              AND C5_NUM = D2_PEDIDO
	JV004 += "                                                              AND C5_CLIENTE = D2_CLIENTE
	JV004 += "                                                              AND C5_LOJACLI = D2_LOJA
	JV004 += "                                                              AND SC5.D_E_L_E_T_ = ' '
	JV004 += "                                         WHERE F2_FILIAL = '"+xFilial("SF2")+"'
	JV004 += "                                           AND SUBSTRING(F2_YAGREG,5,4) IN(SELECT ZZV_CARGA
	JV004 += "                                                              FROM "+RetSqlName("ZZV")
	JV004 += "                                                             WHERE ZZV_FILIAL = '"+xFilial("ZZV")+"'
	If !Empty(ZZV->ZZV_TICKET)
		JV004 += "                                                               AND ( ZZV_CARGA = '"+ZZV->ZZV_CARGA+"' OR ZZV_TICKET = '"+ZZV->ZZV_TICKET+"' )
	Else
		JV004 += "                                                               AND ZZV_CARGA = '"+ZZV->ZZV_CARGA+"'
	EndIf
	JV004 += "                                                               AND D_E_L_E_T_ = ' ')
	JV004 += "                                           AND SF2.D_E_L_E_T_ = ' ')
	JV004 += "    AND SD2.D_E_L_E_T_ = ' '
	JV004 := ChangeQuery(JV004)
	cIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,JV004),'DH04',.T.,.T.)
	aStruX := ("DH04")->(dbStruct())
/*----- Exporta os dados do resultado de uma Query para um arquivo temporário normal -----*/
	gh_IndX := "D2_DOC"
	If !chkfile("JV04")
		JV04 := U_BIACrTMP(aStruX)
		dbUseArea( .T.,, JV04, "JV04", .F., .F. )
		dbCreateInd(JV04, gh_IndX,{ || gh_IndX })
	EndIf
	dbSelectArea("JV04")
	APPEND FROM ("DH04")
	If Select("DH04") > 0
		Ferase(cIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(cIndex+OrdBagExt())          //indice gerado
		DH04->(dbCloseArea())
	Endif

	dbSelectArea("JV04")
	dbGoTop()
	While !Eof()
		Aadd(gFieldFill, {JV04->D2_DOC, JV04->D2_SERIE, stod(JV04->D2_EMISSAO), JV04->D2_CLIENTE, JV04->D2_LOJA, JV04->A1_NOME, .F. })
		dbSkip()
	End
	Ferase(JV04+GetDBExtension())     //arquivo de trabalho
	Ferase(JV04+OrdBagExt())          //indice gerado
	JV04->(dbCloseArea())

// Define field values
	If Len(gFieldFill) == 0
		dbSelectArea("SX3")
		dbSetOrder(2)
		For gnX := 1 to Len(gFields)
			If dbSeek(gFields[gnX])
				Aadd(gFieldFill, CriaVar(SX3->X3_CAMPO))
			Endif
		Next gnX
		Aadd(gFieldFill, .F.)
		Aadd(gColsEx, gFieldFill)
	Else
		gColsEx := gFieldFill
	EndIf

	DEFINE MSDIALOG oDlgNfVinc TITLE "Relação de Notas Vinculadas" FROM 000, 000  TO 530, 700 COLORS 0, 16777215 PIXEL

	oGDNfVc := MsNewGetDados():New( 008, 004, 243, 345, , "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", gAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgNfVinc, gHeaderEx, gColsEx)

	ACTIVATE MSDIALOG oDlgNfVinc CENTERED ON INIT (EnchoiceBar(oDlgNfVinc, {|| IIF(1==1, oDlgNfVinc:End(),) }, {|| oDlgNfVinc:End()},,))

Return


/*/{Protheus.doc} BIA249R
@description Relatório de Pesagem para confronto de faturamento e pesagem  
/*/
User Function BIA249R()

	Processa({|| xptDetal()})

Return

Static Function xptDetal()

	zdNPath := "c:\temp\"
	If !lIsDir( zdNPath )
		MakeDir( zdNPath )
	EndIf

	fPerg := "BIA249R"
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	If cEmpAnt == "01"
		kt_BsDad := "DADOSEOS"
	ElseIf cEmpAnt == "05"
		kt_BsDad := "DADOS_05_EOS"
	ElseIf cEmpAnt == "14"
		kt_BsDad := "DADOS_14_EOS"		
	Else
		MsgINFO("Empresa não configurada para controle de BALANÇA!!!")
		Return
	EndIf

	xfSheel := "PESAGEM"
	xfTabel := "Relatório de Pesagem"
	oExcel := FWMSEXCEL():New()
	oExcel:AddworkSheet(xfSheel)
	oExcel:AddTable (xfSheel, xfTabel)
	oExcel:AddColumn(xfSheel, xfTabel ,"CARGA"            ,1,1)
	oExcel:AddColumn(xfSheel, xfTabel ,"TICKET"           ,1,1)
	oExcel:AddColumn(xfSheel, xfTabel ,"GUARDIAN"         ,1,1)
	oExcel:AddColumn(xfSheel, xfTabel ,"DATINC"           ,2,1)
	oExcel:AddColumn(xfSheel, xfTabel ,"DATFIM"           ,2,1)
	oExcel:AddColumn(xfSheel, xfTabel ,"PLACA"            ,2,1)
	oExcel:AddColumn(xfSheel, xfTabel ,"MOTORISTA"        ,1,1)
	oExcel:AddColumn(xfSheel, xfTabel ,"PES_FAT"          ,2,2)
	oExcel:AddColumn(xfSheel, xfTabel ,"PES_ECO"          ,2,2)
	oExcel:AddColumn(xfSheel, xfTabel ,"PES_BAL"          ,2,2)
	oExcel:AddColumn(xfSheel, xfTabel ,"Difer Fat x Eco"  ,2,2)
	oExcel:AddColumn(xfSheel, xfTabel ,"Difer Fat x Bal"  ,2,2)
	oExcel:AddColumn(xfSheel, xfTabel ,"Variação (%)"     ,2,2)
	oExcel:AddColumn(xfSheel, xfTabel ,"Difer Eco x Bal"  ,2,2)
	oExcel:AddColumn(xfSheel, xfTabel ,"PBT Carregado "   ,2,2)
	oExcel:AddColumn(xfSheel, xfTabel ,"Obs. Ticket"      ,1,1)

	GK009 := " SELECT ZZV_CARGA CARGA,
	GK009 += "        ZZV_TICKET TICKET,
	GK009 += "        ZZV_DATINC DATINC,
	GK009 += "        ZZV_DATFIM DATFIM,
	GK009 += "        ZZV_PLACA PLACA,
	GK009 += "        ZZV_MOTOR MOTORISTA,
	GK009 += "        ISNULL((SELECT Z11_PESOSA
	GK009 += "                  FROM " + RetSqlName("Z11")
	GK009 += "                 WHERE Z11_FILIAL = '"+xFilial("Z11")+"'
	GK009 += "                   AND Z11_PESAGE = ZZV_TICKET
	GK009 += "                   AND D_E_L_E_T_ = ' '), 0) PBT_CAR,
	GK009 += "        ISNULL((SELECT SUM(F2_PBRUTO)
	GK009 += "                  FROM " + RetSqlName("SF2")
	GK009 += "                 WHERE F2_FILIAL = '"+xFilial("SF2")+"'
	GK009 += "                   AND SUBSTRING(F2_YAGREG,5,4) = ZZV_CARGA
	GK009 += "                   AND D_E_L_E_T_ = ' '), 0) PES_FAT,
	GK009 += "        ISNULL((SELECT SUM(iord_peso)
	GK009 += "                  FROM "+kt_BsDad+".dbo.fat_ordem_faturamento ORDEM
	GK009 += "                 INNER JOIN "+kt_BsDad+".dbo.fat_itens_ordem ITENS ON ITENS.ford_numero = ORDEM.ford_numero
	GK009 += "                 WHERE ORDEM.ford_num_carga COLLATE Latin1_General_BIN = ZZV_CARGA), 0) PES_ECO,
	GK009 += "        ISNULL((SELECT SUM(Z11_PESLIQ)
	GK009 += "                  FROM " + RetSqlName("Z11")
	GK009 += "                 WHERE Z11_FILIAL = '"+xFilial("Z11")+"'
	GK009 += "                   AND Z11_PESAGE = ZZV_TICKET
	GK009 += "                   AND D_E_L_E_T_ = ' '), 0) PES_BAL,
	GK009 += "        ISNULL((SELECT TOP 1 Z11_OBSER
	GK009 += "                  FROM " + RetSqlName("Z11")
	GK009 += "                 WHERE Z11_FILIAL = '"+xFilial("Z11")+"'
	GK009 += "                   AND Z11_PESAGE = ZZV_TICKET
	GK009 += "                   AND D_E_L_E_T_ = ' '), '') OBS_TICKT,
	GK009 += "        ISNULL((SELECT TOP 1 Z11_GUARDI
	GK009 += "                  FROM " + RetSqlName("Z11")
	GK009 += "                 WHERE Z11_FILIAL = '"+xFilial("Z11")+"'
	GK009 += "                   AND Z11_PESAGE = ZZV_TICKET
	GK009 += "                   AND D_E_L_E_T_ = ' '), '') GUARDIAN
	GK009 += "   FROM (SELECT ZZV_CARGA,
	GK009 += "                ZZV_TICKET,
	GK009 += "                ZZV_DATINC,
	GK009 += "                ZZV_DATFIM,
	GK009 += "                ZZV_PLACA,
	GK009 += "                ZZV_MOTOR
	GK009 += "           FROM " + RetSqlName("ZZV")
	GK009 += "          WHERE ZZV_FILIAL = '"+xFilial("ZZV")+"'
	GK009 += "            AND ZZV_DATFIM BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	GK009 += "            AND ZZV_TICKET BETWEEN '000000' AND 'ZZZZZZ'
	GK009 += "            AND D_E_L_E_T_ = ' ') AS TAB
	GK009 += " ORDER BY ZZV_PLACA, ZZV_DATINC, ZZV_DATFIM  "
	GKIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,GK009),'GK09',.T.,.T.)
	dbSelectArea("GK09")
	dbGoTop()
	ProcRegua(RecCount())

	TotPesoEco := 0
	TotPesFat  := 0
	TotPesBal  := 0

	While !Eof()

		IncProc()
		xfDFatEco := GK09->PES_FAT - GK09->PES_ECO
		xfDFatBal := GK09->PES_FAT - GK09->PES_BAL
		xfDVariac := xfDFatBal / GK09->PES_FAT
		xfDEcoBal := GK09->PES_ECO - GK09->PES_BAL

		TotPesoEco 	+= GK09->PES_ECO
		TotPesFat 	+= GK09->PES_FAT
		TotPesBal   += GK09->PES_BAL

		oExcel:AddRow(xfSheel, xfTabel ,{ GK09->CARGA, GK09->TICKET, GK09->GUARDIAN, stod(GK09->DATINC), stod(GK09->DATFIM), GK09->PLACA, GK09->MOTORISTA,  GK09->PES_FAT, GK09->PES_ECO, GK09->PES_BAL, xfDFatEco, xfDFatBal, xfDVariac, xfDEcoBal, GK09->PBT_CAR, Alltrim(GK09->OBS_TICKT) })

		dbSelectArea("GK09")
		dbSkip()
	End

	oExcel:AddRow(xfSheel, xfTabel ,{ , , , , , , '		TOTAL: ' ,  TotPesFat, TotPesoEco, TotPesBal, , , , , ,  })

	GK09->(dbCloseArea())
	Ferase(GKIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(GKIndex+OrdBagExt())          //indice gerado

	If File(zdNPath+fPerg+cEmpAnt+".xml")
		If fErase(zdNPath+fPerg+cEmpAnt+".xml") == -1
			Aviso('Arquivo em uso','Favor fechar o arquivo: ' + zdNPath+fPerg+cEmpAnt+'.xml' + ' antes de prosseguir!!!',{'Ok'})
		EndIf
	EndIf

	oExcel:Activate()
	oExcel:GetXMLFile(zdNPath+fPerg+cEmpAnt+".xml")

	cCrLf := Chr(13) + Chr(10)
	If ! ApOleClient( 'MsExcel' )
		MsgAlert( "MsExcel nao instalado!"+cCrLf+cCrLf+"Você poderá recuperar este arquivo em: "+zdNPath+fPerg+cEmpAnt+".xml"  )
	Else
		oExcel:= MsExcel():New()
		oExcel:WorkBooks:Open( zdNPath+fPerg+cEmpAnt+".xml" ) // Abre uma planilha
		oExcel:SetVisible(.T.)
	EndIf

Return

/*/{Protheus.doc} BIA249C
@description Possibilita a alteração da observação do Ticket  
/*/
// Static Function BIA249C()

// 	If !Empty(rbTickt)
// 		If xfAlterObs
// 			xfAlterObs := .F.
// 		Else
// 			xfAlterObs := .T.
// 		EndIf
// 	EndIf

// Return

/*/{Protheus.doc} BIA249O
@description Grava Alteração da Observação no ticket de pesagem 
/*/
// Static Function BIA249O()

// 	fgtArea := GetArea()

// 	If !Empty(rbTickt)

// 		dbSelectArea("Z11")
// 		dbSetOrder(1)
// 		If dbSeek(xFilial("Z11")+rbTickt)
// 			RecLock("Z11",.F.)
// 			Z11->Z11_OBSER := Alltrim(cMultiGet1)
// 			MsUnLock()
// 		EndIf

// 		xfAlterObs := .F.

// 	EndIf

// 	RestArea(fgtArea)

// Return ( .T. )


/*/{Protheus.doc} fValidPerg
@description Criacao do grupo de perguntas
/*/
Static Function fValidPerg()
	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,10)
	aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data                   ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até Data                  ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return


Static Function fPesFat(cTicket)
	Local nRet := 0
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT ISNULL(SUM(F2_PBRUTO), 0) AS PESO "
	cSQL += " FROM VW_ZZV_EMP "
	cSQL += " INNER JOIN VW_SF2_EMP "
	cSQL += " ON EMPR = F2_EMP "
	cSQL += " AND ZZV_CARGA = SUBSTRING(F2_YAGREG, 5, 4) "
	cSQL += " WHERE ZZV_TICKET = " + ValToSQL(cTicket)

	TcQuery cSQL New Alias (cQry)

	nRet := (cQry)->PESO

	(cQry)->(DbCloseArea())

Return(nRet)


Static Function fPesEco(cTicket)
	Local nRet := 0
	Local cSQL := ""
	Local cQryCar := GetNextAlias()
	Local cQryEco := ""

	cSQL := " SELECT EMPR AS EMP, ZZV_CARGA AS CARGA "
	cSQL += " FROM VW_ZZV_EMP "
	cSQL += " WHERE ZZV_TICKET = " + ValToSQL(cTicket)

	TcQuery cSQL New Alias (cQryCar)

	While !(cQryCar)->(Eof())

		cSQL := " SELECT ISNULL(SUM(iord_peso), 0) AS PESO "
		cSQL += " FROM " + If ((cQryCar)->EMP == "01","DADOSEOS",If ((cQryCar)->EMP == "05","DADOS_05_EOS","DADOS_14_EOS")) + ".dbo.fat_ordem_faturamento ORDEM "
		cSQL += " INNER JOIN " + If ((cQryCar)->EMP == "01", "DADOSEOS",If ((cQryCar)->EMP == "05","DADOS_05_EOS","DADOS_14_EOS")) + ".dbo.fat_itens_ordem ITENS "
		cSQL += " ON ITENS.ford_numero = ORDEM.ford_numero "
		cSQL += " WHERE ORDEM.ford_num_carga COLLATE Latin1_General_BIN = " + ValToSQL((cQryCar)->CARGA)

		cQryEco := GetNextAlias()

		TcQuery cSQL New Alias (cQryEco)

		nRet += (cQryEco)->PESO

		(cQryEco)->(DbCloseArea())

		(cQryCar)->(DbSkip())

	EndDo()

	(cQryCar)->(DbCloseArea())

Return(nRet)


Static Function fSQLCarga(cTicket)
	Local cRet := ""
	Local cEmp := ""
	Local cDBEco := ""
	Local cSQL := ""
	Local cQryCar := GetNextAlias()
	Local cCarga := ""

	If cEmpAnt == "01"

		cEmp := "14"
		cDBEco := "DADOS_14_EOS"

	ElseIf cEmpAnt == "14"

		cEmp := "01"
		cDBEco := "DADOSEOS"

	EndIf

	cSQL := " SELECT EMPR AS EMP, ZZV_CARGA AS CARGA "
	cSQL += " FROM VW_ZZV_EMP "
	cSQL += " WHERE EMPR = " + ValToSQL(cEmp)
	cSQL += " AND ZZV_TICKET = " + ValToSQL(cTicket)

	TcQuery cSQL New Alias (cQryCar)

	cCarga := (cQryCar)->CARGA

	(cQryCar)->(DbCloseArea())

	If !Empty(cCarga)

		cSQL := " UNION ALL "

		cSQL += " SELECT ford_numero CARGA_ECO,
		cSQL += "        D2_CLIENTE,
		cSQL += "        D2_LOJA,
		cSQL += "        CASE
		cSQL += "          WHEN F2_TIPO IN('B','D') THEN A2_NOME
		cSQL += "          ELSE A1_NOME
		cSQL += "        END A1_NOME,
		cSQL += "        D2_DOC,
		cSQL += "        D2_SERIE,
		cSQL += "        D2_PEDIDO,
		cSQL += "        D2_ITEMPV,
		cSQL += "        D2_COD,
		cSQL += "        SUBSTRING(B1_DESC,1,50) B1_DESC,
		cSQL += "        D2_LOTECTL,
		cSQL += "        D2_QUANT,
		cSQL += "        CASE
		cSQL += "          WHEN B1_TIPCONV = 'M' THEN ( D2_QUANT * ISNULL((SELECT ZZ9_PESO
		cSQL += "                                                            FROM "+RetFullName("ZZ9", cEmp)+" ZZ9
		cSQL += "                                                           WHERE ZZ9_FILIAL = '"+xFilial("ZZ9")+"'
		cSQL += "                                                             AND ZZ9_PRODUT = D2_COD
		cSQL += "                                                             AND ZZ9_LOTE = D2_LOTECTL
		cSQL += "                                                             AND ZZ9.D_E_L_E_T_ <> '*'), B1_PESO) ) + ( ( D2_QUANT * B1_CONV ) * ISNULL((SELECT ZZ9_PESEMB
		cSQL += "                                                                                                                                           FROM "+RetFullName("ZZ9", cEmp)+" ZZ9
		cSQL += "                                                                                                                                          WHERE ZZ9_FILIAL = '"+xFilial("ZZ9")+"'
		cSQL += "                                                                                                                                            AND ZZ9_PRODUT = D2_COD
		cSQL += "                                                                                                                                            AND ZZ9_LOTE = D2_LOTECTL
		cSQL += "                                                                                                                                            AND ZZ9.D_E_L_E_T_ <> '*'), B1_YPESEMB) )
		cSQL += "          ELSE ( D2_QUANT * ISNULL((SELECT ZZ9_PESO
		cSQL += "                                      FROM "+RetFullName("ZZ9", cEmp)+" ZZ9
		cSQL += "                                     WHERE ZZ9_FILIAL = '"+xFilial("ZZ9")+"'
		cSQL += "                                       AND ZZ9_PRODUT = D2_COD
		cSQL += "                                       AND ZZ9_LOTE = D2_LOTECTL
		cSQL += "                                       AND ZZ9.D_E_L_E_T_ <> '*'), B1_PESO) ) + ( ( D2_QUANT / B1_CONV ) * ISNULL((SELECT ZZ9_PESEMB
		cSQL += "                                                                                                                     FROM "+RetFullName("ZZ9", cEmp)+" ZZ9
		cSQL += "                                                                                                                    WHERE ZZ9_FILIAL = '"+xFilial("ZZ9")+"'
		cSQL += "                                                                                                                      AND ZZ9_PRODUT = D2_COD
		cSQL += "                                                                                                                      AND ZZ9_LOTE = D2_LOTECTL
		cSQL += "                                                                                                                      AND ZZ9.D_E_L_E_T_ <> '*'), B1_YPESEMB) )
		cSQL += "        END PESOBR,
		cSQL += "        iord_qtdade_baixada QTD_ECO,
		cSQL += "        iord_peso PS_ECO,
		cSQL += "        D2_EMISSAO
		cSQL += "   FROM "+RetFullName("SF2", cEmp)+" SF2
		cSQL += "  INNER JOIN "+RetFullName("SD2", cEmp)+" SD2 ON D2_FILIAL = '"+xFilial("SD2")+"'
		cSQL += "                       AND D2_DOC = F2_DOC
		cSQL += "                       AND D2_SERIE = F2_SERIE
		cSQL += "                       AND D2_CLIENTE = F2_CLIENTE
		cSQL += "                       AND D2_LOJA = F2_LOJA
		cSQL += "                       AND D2_EMISSAO = F2_EMISSAO
		cSQL += "                       AND SD2.D_E_L_E_T_ = ' '
		cSQL += "   LEFT JOIN "+RetFullName("SA1", cEmp)+" SA1 ON A1_FILIAL = '"+xFilial("SA1")+"'
		cSQL += "                       AND A1_COD = D2_CLIENTE
		cSQL += "                       AND A1_LOJA = D2_LOJA
		cSQL += "                       AND SA1.D_E_L_E_T_ = ' '
		cSQL += "   LEFT JOIN "+RetFullName("SA2", cEmp)+" SA2 ON A2_FILIAL = '"+xFilial("SA2")+"'
		cSQL += "                       AND A2_COD = D2_CLIENTE
		cSQL += "                       AND A2_LOJA = D2_LOJA
		cSQL += "                       AND SA2.D_E_L_E_T_ = ' '
		cSQL += "  INNER JOIN SB1010 SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
		cSQL += "                       AND B1_COD = D2_COD
		cSQL += "                       AND SB1.D_E_L_E_T_ = ' '
		cSQL += "   LEFT JOIN "+cDBEco+".dbo.fat_itens_ordem ON ford_numero in(SELECT DISTINCT ford_numero
		cSQL += "                                                              FROM "+cDBEco+".dbo.fat_ordem_faturamento
		cSQL += "                                                             WHERE ford_num_carga COLLATE Latin1_General_BIN = SUBSTRING(F2_YAGREG,5,4))
		cSQL += "                                         AND RTRIM(cod_pedido) COLLATE Latin1_General_BIN = RTRIM(D2_PEDIDO)
		cSQL += "                                         AND RTRIM(cod_produto) COLLATE Latin1_General_BIN = RTRIM(D2_COD)
		cSQL += "                                         AND RTRIM(iord_lote) COLLATE Latin1_General_BIN = RTRIM(D2_LOTECTL)
		cSQL += "  WHERE F2_FILIAL = '"+xFilial("SF2")+"'
		cSQL += "    AND SUBSTRING(F2_YAGREG,5,4) IN(SELECT ZZV_CARGA
		cSQL += "                       FROM "+RetFullName("ZZV", cEmp)
		cSQL += "                      WHERE ZZV_FILIAL = '"+xFilial("ZZV")+"'
		cSQL += "                        AND ( ZZV_CARGA = '"+cCarga+"' OR ZZV_TICKET = '"+cTicket+"' )
		cSQL += "                        AND D_E_L_E_T_ = ' ')
		cSQL += "    AND SF2.D_E_L_E_T_ = ' '

		cRet := cSQL

	EndIf

Return(cRet)
