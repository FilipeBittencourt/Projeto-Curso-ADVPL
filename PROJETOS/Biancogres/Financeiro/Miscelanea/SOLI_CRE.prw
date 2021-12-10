#Include "RwMake.ch"
#include "TOPCONN.ch"
#include "ap5mail.ch"

/*/{Protheus.doc} SOLI_CRE
@description TELA DE SOLICITACAO DE CREDITO
@author BRUNO MADALENO   /  Revisado por Fernando Rocha em 20/11/2019
@since 20/11/2019
@version 1.0
@type function
/*/
USER FUNCTION SOLI_CRE()

	Private aCampos0
	Private cSql
	Private cNomeUsuario	:= cUserName
	PRIVATE CREMETENTE		:= ""   
	Private aSize      		:= MsAdvSize(,.F. )
	PRIVATE ENTER			:= CHR(13)+CHR(10)
	Private EhRepBianc		:= .F.
	Private	lDebug			:= .F.
	Private oAceTela 		:= TAcessoTelemarketing():New()

	_aCampos :=	{{"CODIGO"		,"C",06,0},;
	{"DATA_SOLI"	,"C",20,0},;
	{"DATA_LIB"	,"D",08,0},;
	{"COD_CLI"		,"C",06,0},;
	{"NOME_CLI"	,"C",50,0},;
	{"NOVO_CLI"	,"C",10,0},;
	{"USUARIO"		,"C",20,0},;
	{"NOMEUSU"		,"C",30,0},;
	{"NUM_PEDIDO"	,"C",10,0},;
	{"VAL_PEDIDO"  ,"C",14,2},;
	{"TIP_PAG"		,"C",15,0},;
	{"COND_PAG"	,"C",15,0},;
	{"PRA_LIB"		,"C",15,0},;
	{"PRAZO"		,"C",15,0},;
	{"RESTO"		,"N",15,0},;
	{"cSTATUS"		,"C",15,0}}
	_trab22 := CriaTrab(_aCampos)
	dbUseArea(.T.,,_trab22,"_trab22",.t.)                           

	//Selecionando todos os produtos e suas quantidades em estoque
	U_BIAMsgRun("Aguarde, carregando informações...",, {|| SQL_TODOS() })

	If chkfile("c_CONS")
		dbSelectArea("c_CONS")
		dbCloseArea()
	EndIf
	TCQUERY cSql ALIAS "c_CONS" NEW
	c_CONS->(DbGoTop())
	While !c_CONS->(EOF())

		psworder(2)
		cNomeUsr := "" 

		If SubStr(c_CONS->ZU_USUARIO,1,2) == "B-"
			cNomeUsr := SubStr(c_CONS->ZU_USUARIO,3, 23)
		Else
			If  pswseek(c_CONS->ZU_USUARIO,.t.)           
				_daduser  := pswret(1)           
				cNomeUsr  := _daduser[1,4]
			EndIf 
		EndIf

		RecLock("_trab22",.t.)
		_trab22->CODIGO		:= c_CONS->ZU_CODIGO
		_trab22->DATA_SOLI	:= alltrim(dtoc(stod(c_CONS->ZU_DATA)))
		_trab22->DATA_LIB	:= stod(c_CONS->ZU_DATAAPR) //alltrim(dtoc(stod(c_CONS->ZU_DATAAPR)))
		_trab22->USUARIO	:= IIf(SubStr(c_CONS->ZU_USUARIO,1,2) == "B-","BIZAGI",c_CONS->ZU_USUARIO)
		_trab22->NOMEUSU	:= AllTrim(cNomeUsr)
		_trab22->COD_CLI	:= c_CONS->ZU_CODCLI
		_trab22->NOME_CLI   := Posicione("SA1",1,xFilial("SA1")+c_CONS->ZU_CODCLI,"A1_NOME")
		_trab22->NOVO_CLI	:= c_CONS->ZU_NOV_CLI
		_trab22->NUM_PEDIDO	:= c_CONS->ZU_PEDIDO
		_trab22->VAL_PEDIDO	:= TRANS(c_CONS->ZU_VALOR,"@E 999,999,999.99")
		_trab22->TIP_PAG	:= c_CONS->ZU_TIPOPAG
		_trab22->COND_PAG	:= c_CONS->ZU_COND_PA
		_trab22->PRAZO		:= alltrim(dtoc(stod(c_CONS->ZU_PRAZO))) 
		_trab22->cSTATUS	:= c_CONS->ZU_STATUS
		_trab22->RESTO		:= IIF(c_CONS->ZU_STATUS="PENDENTE",c_CONS->RESTANTE,0)
		MsUnlock()
		c_CONS->(DbSkip())
	EndDo

	aCampos0 := {}
	AADD(aCampos0,{"CODIGO"		,"CODIGO" 				,08})
	AADD(aCampos0,{"DATA_SOLI"	, "DATA SOLICITAÇÃO" 	,18})
	AADD(aCampos0,{"DATA_LIB"	, "DATA LIBERAÇÃO" 		,20})
	AADD(aCampos0,{"COD_CLI"	, "COD. CLIENTE" 		,18})
	AADD(aCampos0,{"NOME_CLI"	, "NOME DO CLIENTE" 	,50})
	AADD(aCampos0,{"USUARIO"	, "USUARIO" 			,20})
	AADD(aCampos0,{"NOMEUSU"	, "NOME USUARIO"		,60})
	AADD(aCampos0,{"NUM_PEDIDO"	, "NUM. PEDIDO"			,18})
	AADD(aCampos0,{"cSTATUS"	, "STATUS"				,18})
	AADD(aCampos0,{"RESTO"		, "DIAS RESTANTE"		,20})


	Markbrow()
Return


Static Function Markbrow()

	PRIVATE aRadio := {}
	PRIVATE nRadio := 1
	PRIVATE cClient := SPACE(06)
	PRIVATE dDataIni := CTOD("  /  /  ")
	PRIVATE dDataFim := CTOD("  /  /  ")


	aAdd( aRadio, "PENDENTE" )
	aAdd( aRadio, "APROVADO" )
	aAdd( aRadio, "REPROVADO" )

	DEFINE MSDialog oDlg Title "::::: SOLICITAÇÃO DE CRÉDITO :::::" FROM aSize[7],000 TO aSize[6],aSize[5] PIXEL

	_oGrUsu	:= TGroup():New( 000,000,25,489,,oDlg,,,.T.,.F. )
	_oGrUsu:Align := CONTROL_ALIGN_TOP  


	@ 005,010	SAY "USUARIO:  " + cNomeUsuario //"ADMINISTRATOR" // USUARIO 
	@ 015,010	SAY "DATA DA SOLICITAÇÃO   " + ALLTRIM(DTOC(DATE())) + "  " + TIME() // USUARIO

	_oGrFil	:= TGroup():New( 000,000,060,489,,oDlg,,,.T.,.F. )
	_oGrFil:Align := CONTROL_ALIGN_TOP

	@ 030,010	To 080,080 // FRAME DO RADIO BUTTONS
	@ 035,020	SAY "STATUS"  Size 500,200 
	@ 045,020 RADIO aRadio VAR nRadio 

	@ 030,090	To 080,160 // FRAME DO RADIO BUTTONS
	@ 035,100	SAY "CLIENTE"  Size 500,200 
	@ 045,100 	GET cClient SIZE 35,10 F3 "SA1REP" PICT "@!R" 

	@ 030,170	To 080,240 // FRAME DO RADIO BUTTONS
	@ 035,180	SAY "DATA"  Size 500,200 
	@ 045,180 	GET dDataIni SIZE 35,10 PICT "@D"   
	@ 055,180	SAY "até"  Size 500,200 
	@ 065,180 	GET dDataFim SIZE 35,10 PICT "@D"   


	@ 030,280	Button "Filtrar" Size 50,15 Action U_BIAMsgRun("Aguarde, carregando informações...",, {|| SQL_FILTRO(.T.) }) 

	If U_VALOPER("007",.F.) .Or. U_VALOPER("017",.F.) .Or. !Empty(Alltrim(cRepAtu)) .Or. lDebug 
		@ 030,335	Button "Nova solicitação" Size 50,15 Action uNOVO() 
	EndIf

	oBrow := IW_Browse(120,015,308,480,"_trab22",,,aCampos0)
	oBrow:OBROWSE:Align := CONTROL_ALIGN_ALLCLIENT
	oBrow:OBROWSE:BLDBLCLICK := {|| uDetalhes() }

	ACTIVATE DIALOG oDlg ON INIT Eval({|| MsAguarde(), _trab22->(DbGoTop()), oBrow:oBrowse:Refresh(), }) Centered

	DbSelectArea("_trab22")
	_trab22->(DbCloseArea())

Return

Static Function uNOVO(nCli,nPed,nVlr,nVrObra,nCndPag,ChvTmp)

	Local lEditTela := .T.

	PRIVATE nRadio 		:= 1
	PRIVATE cNClient 	:= SPACE(06)
	PRIVATE cNClient1 	:= SPACE(100)
	PRIVATE cNPEDIDO 	:= SPACE(10)
	PRIVATE cNVALOR 	:= 0.00
	PRIVATE cNVROBRA 	:= 0.00	
	PRIVATE cNCOND 		:= SPACE(3)
	PRIVATE cNCOND1 	:= SPACE(50)
	PRIVATE cNOBS 
	PRIVATE cNDATALIB 	:= ""
	PRIVATE oCheckBox
	PRIVATE cNRadio
	PRIVATE cChaveTmp	:= ""

	PRIVATE lSemPed		:= .F.
	PRIVATE oCheckPed
	PRIVATE oTGetPed
	Private	lDebug		:= .F.

	Private aItems		:= {"01=Biancogres","05=Incesa","07=LM"}

	If ValType(nCli) <> "U" 
		cNomeUsuario:= cUserName
		cNClient	:= nCli
		cNClient1	:= Posicione("SA1",1,xFilial("SA1")+nCli,"A1_NOME")    
		cNPEDIDO	:= nPed
		
		if(( ROUND(nVlr, 2) - nVlr) < 0) //para arredondar valor do pedido de venda e garantir que sempre terá o credito solicitado
			cNVALOR		:= ROUND(nVlr, 2) + 0.01 
		else
			cNVALOR		:= ROUND(nVlr, 2)
		endif 
		
		cNVROBRA  := nVrObra
		cNCOND		:= nCndPag
		cNCOND1		:= Posicione("SE4",1,xFilial("SE4")+nCndPag,"E4_DESCRI")
		cChaveTmp	:= ChvTmp
		lEditTela	:= .F.
	EndIf

	Ver_Prazo()

	@ 010,010	To 500,800 Dialog oDlg1 Title "::::: SOLICITAÇÃO DE CRÉDITO :::::"

	@ 005,006	To 30,390
	@ 010,010	SAY "USUARIO:  " + cNomeUsuario //"ADMINISTRATOR" // USUARIO
	@ 020,010	SAY "DATA DA SOLICITAÇÃO   " + ALLTRIM(DTOC(DATE())) + "  " + TIME()  // USUARIO

	@ 030,006	To 230,390 // FRAME GERAL

	@ 035,010	SAY "CÓDIGO DO CLIENTE:  "
	@ 035,100 	GET cNClient  SIZE 35,10 F3 "SA1REP" Valid fVldCli() WHEN lEditTela 

	@ 050,010	SAY "DESCRIÇÃO:  "
	@ 050,100 	GET cNClient1  PICT "@!R" WHEN .F.

	@ 080,010	SAY "NUMERO DO PEDIDO:  "

	oTGetPed := TGet():New(080,100,{|u| If(PCount() >0,cNPEDIDO:=u,cNPEDIDO)},oDLG1,35,10,"@!R",,,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"oTGetPed")

	If cEmpAnt $ "01_05_07_14"
		cCombo:= cEmpAnt
	Else	
		cCombo:= aItems[1]
	EndIf

	oComboEmp := TComboBox():New(080,175,{|u|if(PCount()>0,cCombo:=u,cCombo)},aItems,065,20,oDlg1,,,,,,.T.,,,,,,,,,'cCombo')
	@ 081,140	SAY "EMP. PEDIDO:"
	oCheckPed := TCheckBox():New(082,250,'Sem Ped. Venda',{||lSemPed},oDLG1,215,10,,{|| MudaCheckBox() },,,,,,.T.)

	If ValType(nCli) <> "U"            
		oTGetPed:Disable()
		oComboEmp:Disable()
		oCheckPed:Disable()
	EndIf

	@ 095,010	SAY "VALOR SOLICITADO:  "
	@ 095,100 GET cNVALOR SIZE 50,14 Picture "@E 999,999,999.99" WHEN lEditTela 

	@ 110,010	SAY "POTENCIAL DA OBRA:  "
	@ 110,100 GET cNVROBRA SIZE 50,12 Picture "@E 9,999,999.99" 
	
	@ 130,010	SAY "CONDIÇÃO DE PAGAMENTO:  "
	@ 130,100 	GET cNCOND  SIZE 35,10 F3 "ZU2" PICT "@!R" Valid fVldCond() WHEN lEditTela 
	@ 130,150 	GET cNCOND1 PICT "@!R" WHEN .F. 

	@ 145,010	SAY "OBSERVAÇÃO:  "
	@ 145,100   GET cNOBS    SIZE 200,40 MEMO

	If U_VALOPER("007",.F.) .Or. U_VALOPER("017",.F.) .Or. !Empty(Alltrim(cRepAtu)) .Or. lDebug
		@ 040,330	Button "SALVAR" Size 50,15 Action uSALVAR(nCli)
	EndIf

	If ValType(nCli) == "U" 
		@ 080,330	Button "SAIR" Size 50,15 Action CLOSE(ODLG1)
	EndIf

	ACTIVATE DIALOG oDlg1 Centered

RETURN


Static Function uSALVAR(nCli)

	Local lPedido	:= .F.           
	Local ENTER		:= CHR(13)+CHR(10) 
	Local nObsBGZ	:= ""
	Local I 
	Local ehEng := 0

	IF EMPTY(ALLTRIM(cNClient)) .OR. EMPTY(ALLTRIM(cNClient1)) .OR. ;
	EMPTY(ALLTRIM(cNCOND)) .OR. EMPTY(ALLTRIM(cNCOND1)) .OR. ;
	EMPTY(ALLTRIM(cNOBS)) 
		MSGBOX("FAVOR PREENCHER TODOS OS CAMPOS","INFO","INFO")
		RETURN
	END IF
	
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1") + cNClient))
		
		IF (ALLTRIM(SA1->A1_YTPSEG) == "E")
			ehEng := 1
		ENDIF
		
		//para segmento engenharia é obrigatrio
		If (EMPTY(ALLTRIM(STR(cNVROBRA))) .OR. ALLTRIM(STR(cNVROBRA)) == "0") .AND. ALLTRIM(SA1->A1_YTPSEG) == "E"
		  	
		  	SA1->(DbCloseArea())
		  	
		  	MSGBOX("O CAMPO POTENCIAL DA OBRA É OBRIGATÓRIO PARA SEGMENTO ENGENHARIA!","INFO","INFO")
			RETURN
		Elseif (!EMPTY(ALLTRIM(STR(cNVROBRA))) .AND. ALLTRIM(STR(cNVROBRA)) != "0") .AND. ALLTRIM(SA1->A1_YTPSEG) != "E"
		 	MSGBOX("O CAMPO POTENCIAL DA OBRA É APENAS PARA SEGMENTO ENGENHARIA!","INFO","INFO")
		 	cNVROBRA := 0.00
		EndIf
		
		SA1->(DbCloseArea())
	ENDIF

	//se nao for engenharia obriga o preenchimento do valor do pedido
	IF (EMPTY(ALLTRIM(STR(cNVALOR))) .OR. ALLTRIM(STR(cNVALOR)) == "0") .AND. ehEng == 0
		MSGBOX("FAVOR PREENCHER O VALOR SOLICITADO","INFO","INFO")
		RETURN
	ENDIF
	
	IF valtype(cNDATALIB) <> "D"
		MSGBOX("FAVOR PREENCHER TODOS OS CAMPOS","INFO","INFO")
		RETURN
	END IF
	If !lSemPed .And. EMPTY(ALLTRIM(cNPEDIDO))
		MSGBOX("FAVOR PREENCHER O CAMPO NÚMERO DO PEDIDO","INFO","INFO")
		RETURN
	EndIf


	If !lSemPed .And. AllTrim(FunName()) <> "MATA410"
		CSQL := " SELECT COUNT(0) AS QTD " +ENTER   
		CSQL += " FROM( "  +ENTER
		CSQL += " SELECT '01' AS EMP, C5_NUM, C5_CLIENTE, C5_YCLIORI, C5_YPEDORI "  +ENTER
		CSQL += " FROM SC5010 WITH (NOLOCK) "  +ENTER
		CSQL += " WHERE D_E_L_E_T_ = '' " +ENTER
		CSQL += " UNION " +ENTER
		CSQL += " SELECT '05' AS EMP, C5_NUM, C5_CLIENTE, C5_YCLIORI, C5_YPEDORI " +ENTER
		CSQL += " FROM SC5050 WITH (NOLOCK) " +ENTER
		CSQL += " WHERE D_E_L_E_T_ = '' " +ENTER
		CSQL += " UNION " +ENTER
		CSQL += " SELECT '07' AS EMP, C5_NUM, C5_CLIENTE, C5_YCLIORI, C5_YPEDORI " +ENTER
		CSQL += " FROM SC5070 WITH (NOLOCK) " +ENTER
		CSQL += " WHERE D_E_L_E_T_ = '' " +ENTER
		CSQL += " ) C5 " +ENTER
		CSQL += " WHERE C5.EMP            = '"+cCombo+"' " +ENTER
		CSQL += " AND (C5.C5_NUM          = '"+cNPEDIDO+"' OR C5_YPEDORI = '"+cNPEDIDO+"') " +ENTER
		CSQL += " AND (C5.C5_CLIENTE      = '"+cNClient+"' OR C5.C5_YCLIORI = '"+cNClient+"') " +ENTER	
		TCQUERY CSQL ALIAS "QRY" NEW 

		lPedido := (QRY->QTD != 0)

		QRY->(DbCloseArea())

		If !lPedido
			MSGBOX("Pedido Informado Não Encontrado","INFO","INFO")
			RETURN
		EndIf
	EndIf

	//VERIFICAR SE JA EXISTE SOLICITACAO PARA ESSE PEDIDO
	CSQL := " SELECT * " +ENTER   
	CSQL += " FROM SZU010 WITH (NOLOCK)"  +ENTER
	CSQL += " WHERE " +ENTER
	CSQL += " ZU_CODCLI = '"+cNClient+"'
	CSQL += " AND ZU_PEDIDO = '"+Alltrim(cNPEDIDO)+"' "
	CSQL += " AND D_E_L_E_T_='' "
	CSQL += " ORDER BY ZU_DATA DESC "
	TCQUERY CSQL ALIAS "QRY" NEW 

	IF !QRY->(EOF())
		If !MsgYesNo("Já existe a solicitação de crédito "+Alltrim(QRY->ZU_CODIGO)+" para esse cliente "+IIF(Alltrim(QRY->ZU_PEDIDO) == "*",'Sem Pedido','com pedido número '+ Alltrim(QRY->ZU_PEDIDO))+". Deseja prosseguir? ")
			QRY->(DbCloseArea())
			Return
		EndIf
	EndIf
	QRY->(DbCloseArea())

	// Politica de Credito - Rocket
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1") + cNClient))
	
		If !U_BIAF149(dDataBase, SA1->A1_COD, SA1->A1_LOJA, SA1->A1_GRPVEN, SA1->A1_CGC, "2", .F.)
		
			MsgStop("Atenção, já existe uma solcititação de crédito em processamento para esse cliente.")
			
			Return()
		
		EndIf
		
	EndIf

	auxx := cNVALOR	
	FOR I := 1 TO LEN(ALLTRIM(auxx))
		IF SUBST(auxx,i,1) = ","
			cNVALOR += "."
		ELSE
			cNVALOR += SUBST(auxx,I,1)
		END IF
	NEXT I
	
	auxx := cNVROBRA	
	FOR I := 1 TO LEN(ALLTRIM(auxx))
		IF SUBST(auxx,i,1) = ","
			cNVROBRA += "."
		ELSE
			cNVROBRA += SUBST(auxx,I,1)
		END IF
	NEXT I
	
	//Verifica se exite Sol. de Credito pendente no BIZAGI, e adiciona na Observação.
	If ValType(nCli) <> "U"

		cSql := "SELECT ZU_CODIGO FROM "+RetSqlName("SZU")+" WHERE ZU_BIZAGI <> '' AND ZU_STATUS = 'PENDENTE' AND ZU_CODCLI = '"+cNClient+"' AND D_E_L_E_T_ = '' "
		If chkfile("_BZG")
			dbSelectArea("_BZG")
			dbCloseArea()
		EndIf
		TCQUERY CSQL ALIAS "_BZG" NEW
		If !_BZG->(EOF())
			nObsBGZ := " - JÁ EXISTE UMA SOL. DE CRÉDITO EM ABERTO NO BIZAGI - NÚMERO "+_BZG->ZU_CODIGO+"." 
		EndIf
		_BZG->(DbCloseArea())

	EndIf

	//INICIO DA TRANSACAO 	
	BEGIN TRANSACTION

		DBSELECTAREA("SZU")
		RecLock("SZU",.T.)
		SZU->ZU_FILIAL	:= XFILIAL("SZU")
		SZU->ZU_CODIGO := GetSxEnum('SZU', 'ZU_CODIGO')
		SZU->ZU_DATA 	:= DATE()
		SZU->ZU_USUARIO := cNomeUsuario
		SZU->ZU_CODCLI 	:= cNClient
		SZU->ZU_NOV_CLI := "INA"
		SZU->ZU_PEDIDO 	:= cNPEDIDO
		SZU->ZU_VALOR 	:= cNVALOR
		SZU->ZU_VROBRA 	:= cNVROBRA	
		SZU->ZU_TIPOPAG := "BANCO"
		SZU->ZU_COND_PA := cNCOND
		SZU->ZU_OBSERVA := cNOBS + nObsBGZ
		SZU->ZU_PRAZO 	:= cNDATALIB
		SZU->ZU_STATUS 	:= "PENDENTE" 
		SZU->ZU_SHORA 	:= TIME()
		SZU->ZU_CHAVTMP := cChaveTmp
		
		If !lSemPed .Or. ValType(nCli) <> "U" 
			SZU->ZU_EMPRESA := cCombo
		EndIf
		
		// Politica de Credito - Rocket
		SZU->ZU_CODPRO := U_BIAF146(dDataBase, SA1->A1_COD, SA1->A1_LOJA, SA1->A1_GRPVEN, SA1->A1_CGC, cNVALOR, cNVROBRA, "2", .F.)
		
		SZU->(MsUnLock())
		
		ConfirmSX8()

	END TRANSACTION

	If ValType(nCli) == "U" 
		U_BIAMsgRun("Aguarde, carregando informações...",, {|| SQL_FILTRO(.F.) })
	EndIf

	CLOSE(ODLG1)

RETURN


Static Function uDetalhes()

	PRIVATE cNClient 	:= SPACE(06)
	PRIVATE cNClient1 	:= SPACE(100)
	PRIVATE cNPEDIDO 	:= SPACE(10)
	PRIVATE cNVALOR 	:= SPACE(10)
	PRIVATE cNVROBRA  := SPACE(10)	
	PRIVATE cNCOND 		:= SPACE(3)
	PRIVATE cNCOND1 	:= SPACE(50)
	PRIVATE cNOBS
	PRIVATE cNOBS_FIN 
	PRIVATE cNDATALIB 	:= SPACE(50)
	PRIVATE cNRadio
	PRIVATE cNRadio3
	PRIVATE aRadio3 	:= {}
	PRIVATE lSemPed := .F.
	PRIVATE oCheckPed
	PRIVATE oTGetPed

	Private aItems :={"01=Biancogres","05=Incesa","07=LM",""}

	aAdd( aRadio3, "DESFAVORÁVEL  " )
	aAdd( aRadio3, "FAVORÁVEL   " )

	cQUERY := "SELECT LTRIM(RTRIM(CONVERT(VARCHAR(2047),CONVERT(BINARY(2047),ZU_OBSERVA)))) AS OBS, LTRIM(RTRIM(CONVERT(VARCHAR(2047),CONVERT(BINARY(2047),ZU_OBS_LIB)))) AS OBS_LIB, * "
	cQUERY += "FROM SZU010  "
	cQUERY += "WHERE ZU_CODIGO = '"+_trab22->CODIGO+"' AND D_E_L_E_T_ = '' "
	If chkfile("_ATU")
		dbSelectArea("_ATU")
		dbCloseArea()
	EndIf
	TCQUERY cQUERY ALIAS "_ATU" NEW


	cNClient  	:= _ATU->ZU_CODCLI
	cNClient1 	:= Posicione("SA1",1,xFilial("SA1")+_ATU->ZU_CODCLI,"A1_NOME")
	cNPEDIDO	:= _ATU->ZU_PEDIDO
	cNVALOR   	:= _ATU->ZU_VALOR
	cNVROBRA := _ATU->ZU_VROBRA	
	cNCOND   	:= _ATU->ZU_COND_PA
	cNCOND1		:= Posicione("SE4",1,xFilial("SE4")+_ATU->ZU_COND_PA,"E4_DESCRI")
	cNOBS		:= _ATU->OBS
	cNDATALIB	:= alltrim(dtoc(stod(_ATU->ZU_PRAZO)))
	cNRadio3 	:= iif(_ATU->ZU_STATUS = "APROVADO",2,1)
	cNOBS_FIN 	:= _ATU->OBS_LIB
	nHORA		:= _ATU->ZU_SHORA

	@ 010,010	To 500,800 Dialog oDlg1 Title "::::: SOLICITAÇÃO DE CRÉDITO :::::" //"Consulta Estoque"
	// TELA DO BOTAO NOVO
	@ 005,006	To 30,390
	@ 010,010	SAY "USUARIO:  " + _ATU->ZU_USUARIO //"ADMINISTRATOR" // USUARIO
	@ 020,010	SAY "DATA DA SOLICITAÇÃO   " + alltrim(dtoc(stod(_ATU->ZU_DATA)))  + "  " + nHORA

	@ 030,006	To 205,390 // FRAME GERAL

	@ 035,010	SAY "CÓDIGO DO CLIENTE:  "
	@ 035,100 	GET cNClient  SIZE 35,10 F3 "SA1REP" PICT "@!R"    WHEN .F.

	@ 050,010	SAY "DESCRIÇÃO:  "
	@ 050,100 	GET cNClient1  PICT "@!R" WHEN .F.

	@ 080,010	SAY "NUMERO DO PEDIDO:  "
	@ 080,100 	GET cNPEDIDO  SIZE 35,10 PICT "@!R" WHEN .F.

	If (Empty(_ATU->ZU_EMPRESA))
		cCombo:= ""
	Else
		cCombo:= _ATU->ZU_EMPRESA
	EndIf

	oComboEmp := TComboBox():New(080,175,{|u|if(PCount()>0,cCombo:=u,cCombo)},aItems,065,20,oDlg1,,,,,,.T.,,,,,,,,,'cCombo')
	oComboEmp:Disable()

	@ 081,140	SAY "EMP. PEDIDO:"
	oCheckPed := TCheckBox():New(082,250,'Sem Ped. Venda',{||lSemPed},oDLG1,215,10,,{|| MudaCheckBox() },,,,,,.T.) 
	oCheckPed:Disable()

	@ 095,010	SAY "VALOR SOLICITADO:  "
	@ 095,100 GET cNVALOR SIZE 50,14 PICT "@E 999,999,999.99"

	@ 110,010	SAY "POTENCIAL DA OBRA:  "
	@ 110,100 GET cNVROBRA SIZE 50,12 PICT "@E 9,999,999.99"		     

	@ 130,010	SAY "CONDIÇÃO DE PAGAMENTO:  "
	@ 130,100 	GET cNCOND  SIZE 35,10 F3 "ZU2" PICT "@!R" WHEN .F.
	@ 130,150 	GET cNCOND1  PICT "@!R" WHEN .F. 

	@ 145,010	SAY "OBSERVAÇÃO:  "
	@ 145,100   GET cNOBS    SIZE 250,40 MEMO 

	@ 205,006	To 240,390 
	@ 206,010	SAY "SETOR DE CRÉDITO"

	If U_VALOPER("017",.F.)
		@ 215,010	SAY "PARECER: "
		@ 215,80 	RADIO aRadio3 VAR cNRadio3 

		@ 215,150	SAY "OBSERVAÇÃO:  "
		@ 215,189   GET cNOBS_FIN    SIZE 200,24 MEMO
	else
		@ 215,150	SAY "OBSERVAÇÃO:  "
		@ 215,189   GET cNOBS_FIN    SIZE 200,24 MEMO WHEN .F.
	end if	

	If (_ATU->ZU_STATUS = "PENDENTE" .AND. U_VALOPER("007",.F.)) .Or. U_VALOPER("017",.F.) .Or. !Empty(Alltrim(cRepAtu))
		@ 040, 330	Button "SALVAR" Size 50,15 Action uLIBERAR()
	END IF

	@ 060, 330	Button "SAIR" Size 50,15 Action CLOSE(ODLG1)


	ACTIVATE DIALOG oDlg1 Centered

RETURN


STATIC Function uLIBERAR()

	PRIVATE eeSTATUS 		:= ""
	PRIVATE eePEDIDO 		:= ""
	PRIVATE eeOBS 			:= ""

	SZU->(DbSetOrder(1))
	If SZU->(DbSeek(xFilial("SZU")+_trab22->CODIGO))

		If U_VALOPER("017",.F.)
			RecLock("SZU",.F.)
			SZU->ZU_OBS_LIB	:= AllTrim(cNOBS_FIN)
			SZU->ZU_STATUS	:= IIF(cNRadio3=1,"REPROVADO","APROVADO")
			SZU->ZU_DATAAPR	:= DATE()		
			MsUnLock()

			//Libera Pedido de Engenharia bloqueado
			If Alltrim(SZU->ZU_STATUS) == "APROVADO" .And. !Empty(Alltrim(SZU->ZU_EMPRESA)) .And. Alltrim(SZU->ZU_PEDIDO) <> "*"

				If cEmpAnt == SZU->ZU_EMPRESA
					U_fGrvStSC(SZU->ZU_PEDIDO,SZU->ZU_CODCLI)
				Else
					U_FROPCPRO(SZU->ZU_EMPRESA,"01","U_fGrvStSC",SZU->ZU_PEDIDO,SZU->ZU_CODCLI)	
				EndIf

			EndIf

			U_BIAMsgRun("Aguarde, carregando informações...",, {|| SQL_FILTRO(.F.) })
			CLOSE(ODLG1)

			eeSTATUS	:= IIF(cNRadio3=1,"REPROVADO","APROVADO")
			eePEDIDO	:= _ATU->ZU_PEDIDO
			eeOBS 		:= cNOBS_FIN


			//ENVIAR E-Mail interno somente para solicitacoes não BIZAGI - quando é BizAgi a tratativa já é feita via bizagi - Ticket 19952
			If ( SubStr(_ATU->ZU_USUARIO,1,2) <> "B-" )

				//U_SCREMAIL(_ATU->ZU_USUARIO)

				StartJob( "U_SCREMAIL", GetEnvServer(),.F., CEMPANT, CFILANT, SZU->(RecNo()))

			EndIf

		ELSE
			RecLock("SZU",.F.)
			SZU->ZU_VALOR 	:= cNVALOR
			SZU->ZU_VROBRA 	:= cNVROBRA
			SZU->ZU_OBSERVA	:= cNOBS
			SZU->ZU_DATAAPR	:= DATE()
			MsUnLock()
			U_BIAMsgRun("Aguarde, carregando informações...",, {|| SQL_FILTRO(.F.) })
			CLOSE(ODLG1)
		END IF
	Else
		MsgAlert("Não encontrou registro. Favor entre contato com o setor de TI.")
	EndIf

RETURN


User Function SCREMAIL(_cEmp, _cFil, _ZUREC)

	RpcSetEnv(_cEmp, _cFil)	

	Private Destinatario := ""
	Private wUsuario := ""

	SZU->(DbSetOrder(0))
	SZU->(DbGoTo(_ZUREC))

	If !SZU->(Eof())

		//BUSCANDO O EMAIL DO USUARIO
		psworder(2)
		IF pswseek(PADR(ALLTRIM(SZU->ZU_USUARIO),16," "),.t.)

			wUsuario := pswret(1)[1][1]
			Destinatario := ALLTRIM(pswret(1)[1][14])

		ENDIF

		If Empty(Destinatario)

			pswseek(cUserName,.t.)
			wUsuario := pswret(1)[1][1]
			Destinatario := ALLTRIM(pswret(1)[1][14])

		EndIf

		If !Empty(Destinatario)

			CRIA_EMAIL()

		EndIf

	EndIf

	RpcClearEnv()

Return


STATIC Function CRIA_EMAIL() 

	cData     := DTOC(DDATABASE)
	cTitulo   := "SISTEMA LIBERAÇÃO DE CRÉDITO - " + SZU->ZU_STATUS

	CSQL := "SELECT A1_COD, A1_NOME,					" + CHR(13)+CHR(10) 
	CSQL += "		A1_VEND,    A1_YVENDB2, A1_YVENDB3, " + CHR(13)+CHR(10) 
	CSQL += "		A1_YVENDI,  A1_YVENDI2, A1_YVENDI3, " + CHR(13)+CHR(10)
	CSQL += "		A1_YVENVT1, A1_YVENVT2, A1_YVENVT3, " + CHR(13)+CHR(10)
	CSQL += "		A1_YVENML1, A1_YVENML2, A1_YVENML3, " + CHR(13)+CHR(10)
	CSQL += "		A1_YVENBE1, A1_YVENBE2, A1_YVENBE3, " + CHR(13)+CHR(10)
	CSQL += "		A1_YVENPEG, A1_YVENVI1 				" + CHR(13)+CHR(10)
	CSQL += "FROM SA1010 SA1 WITH (NOLOCK)" + CHR(13)+CHR(10)
	CSQL += "WHERE	A1_COD = '"+ SZU->ZU_CODCLI +"' AND " + CHR(13)+CHR(10)
	CSQL += "		SA1.D_E_L_E_T_ = '' " + CHR(13)+CHR(10)
	If chkfile("_AUX")
		dbSelectArea("_AUX")
		dbCloseArea()
	EndIf

	TCQUERY CSQL ALIAS "_AUX" NEW

	cMensagem := "Seu pedido de venda 	Nº " + SZU->ZU_PEDIDO + " 	foi " + SZU->ZU_STATUS + "." + CHR(13)+CHR(10) 
	cMensagem += "CODIGO DO CLIENTE : " + _AUX->A1_COD  + CHR(13)+CHR(10) 
	cMensagem += "NOME DO CLIENTE : " + _AUX->A1_NOME  + CHR(13)+CHR(10) 
	cMensagem += CHR(13)+CHR(10)
	cMensagem += "JUSTIFICATIVA: " + CHR(13)+CHR(10) 
	cMensagem += "          " + SZU->ZU_OBS_LIB + CHR(13)+CHR(10)

	IF ! _AUX->(EOF())
		//BIANCOGRES
		IF ALLTRIM(_AUX->A1_VEND) <> ""
			cMensagem += CHR(13)+CHR(10)
			cMensagem += "REPRESENTANTE_1 BIANCO: " + ALLTRIM(_AUX->A1_VEND) + " - " + Posicione("SA3",1,xFilial("SA3")+_AUX->A1_VEND,"A3_NREDUZ") + CHR(13)+CHR(10)
			EhRepBianc := .T.	
		END IF
		IF ALLTRIM(_AUX->A1_YVENDB2) <> ""
			cMensagem += CHR(13)+CHR(10)
			cMensagem += "REPRESENTANTE_2 BIANCO: " + ALLTRIM(_AUX->A1_YVENDB2) + " - " + Posicione("SA3",1,xFilial("SA3")+_AUX->A1_YVENDB2,"A3_NREDUZ") + CHR(13)+CHR(10)
			EhRepBianc := .T.	
		END IF
		IF ALLTRIM(_AUX->A1_YVENDB3) <> ""
			cMensagem += CHR(13)+CHR(10)
			cMensagem += "REPRESENTANTE_3 BIANCO: " + ALLTRIM(_AUX->A1_YVENDB3) + " - " + Posicione("SA3",1,xFilial("SA3")+_AUX->A1_YVENDB3,"A3_NREDUZ") + CHR(13)+CHR(10)
			EhRepBianc := .T.	
		END IF

		//INCESA
		IF ALLTRIM(_AUX->A1_YVENDI) <> ""
			cMensagem += CHR(13)+CHR(10)
			cMensagem += "REPRESENTANTE_1 INCESA: " + ALLTRIM(_AUX->A1_YVENDI) + " - " + Posicione("SA3",1,xFilial("SA3")+_AUX->A1_YVENDI,"A3_NREDUZ") + CHR(13)+CHR(10)	
		END IF
		IF ALLTRIM(_AUX->A1_YVENDI2) <> ""
			cMensagem += CHR(13)+CHR(10)
			cMensagem += "REPRESENTANTE_2 INCESA: " + ALLTRIM(_AUX->A1_YVENDI2) + " - " + Posicione("SA3",1,xFilial("SA3")+_AUX->A1_YVENDI2,"A3_NREDUZ") + CHR(13)+CHR(10)	
		END IF
		IF ALLTRIM(_AUX->A1_YVENDI3) <> ""
			cMensagem += CHR(13)+CHR(10)
			cMensagem += "REPRESENTANTE_3 INCESA: " + ALLTRIM(_AUX->A1_YVENDI3) + " - " + Posicione("SA3",1,xFilial("SA3")+_AUX->A1_YVENDI3,"A3_NREDUZ") + CHR(13)+CHR(10)	
		END IF

		//VITCER
		IF ALLTRIM(_AUX->A1_YVENVT1) <> ""
			cMensagem += CHR(13)+CHR(10)
			cMensagem += "REPRESENTANTE_1 VITCER: " + ALLTRIM(_AUX->A1_YVENVT1) + " - " + Posicione("SA3",1,xFilial("SA3")+_AUX->A1_YVENVT1,"A3_NREDUZ") + CHR(13)+CHR(10)	
		END IF
		IF ALLTRIM(_AUX->A1_YVENVT2) <> ""
			cMensagem += CHR(13)+CHR(10)
			cMensagem += "REPRESENTANTE_2 VITCER: " + ALLTRIM(_AUX->A1_YVENVT2) + " - " + Posicione("SA3",1,xFilial("SA3")+_AUX->A1_YVENVT2,"A3_NREDUZ") + CHR(13)+CHR(10)	
		END IF
		IF ALLTRIM(_AUX->A1_YVENVT3) <> ""
			cMensagem += CHR(13)+CHR(10)
			cMensagem += "REPRESENTANTE_3 VITCER: " + ALLTRIM(_AUX->A1_YVENVT3) + " - " + Posicione("SA3",1,xFilial("SA3")+_AUX->A1_YVENVT3,"A3_NREDUZ") + CHR(13)+CHR(10)	
		END IF	

		//MUNDIALLI
		IF ALLTRIM(_AUX->A1_YVENML1) <> ""
			cMensagem += CHR(13)+CHR(10)
			cMensagem += "REPRESENTANTE_1 MUNDIALLI: " + ALLTRIM(_AUX->A1_YVENML1) + " - " + Posicione("SA3",1,xFilial("SA3")+_AUX->A1_YVENML1,"A3_NREDUZ") + CHR(13)+CHR(10)	
		END IF
		IF ALLTRIM(_AUX->A1_YVENML2) <> ""
			cMensagem += CHR(13)+CHR(10)
			cMensagem += "REPRESENTANTE_2 MUNDIALLI: " + ALLTRIM(_AUX->A1_YVENML2) + " - " + Posicione("SA3",1,xFilial("SA3")+_AUX->A1_YVENML2,"A3_NREDUZ") + CHR(13)+CHR(10)	
		END IF
		IF ALLTRIM(_AUX->A1_YVENML3) <> ""
			cMensagem += CHR(13)+CHR(10)
			cMensagem += "REPRESENTANTE_3 MUNDIALLI: " + ALLTRIM(_AUX->A1_YVENML3) + " - " + Posicione("SA3",1,xFilial("SA3")+_AUX->A1_YVENML3,"A3_NREDUZ") + CHR(13)+CHR(10)	
		END IF

		//BELLACASA
		IF ALLTRIM(_AUX->A1_YVENBE1) <> ""
			cMensagem += CHR(13)+CHR(10)
			cMensagem += "REPRESENTANTE_1 BELLACASA: " + ALLTRIM(_AUX->A1_YVENBE1) + " - " + Posicione("SA3",1,xFilial("SA3")+_AUX->A1_YVENBE1,"A3_NREDUZ") + CHR(13)+CHR(10)	
		END IF
		IF ALLTRIM(_AUX->A1_YVENBE2) <> ""
			cMensagem += CHR(13)+CHR(10)
			cMensagem += "REPRESENTANTE_2 BELLACASA: " + ALLTRIM(_AUX->A1_YVENBE2) + " - " + Posicione("SA3",1,xFilial("SA3")+_AUX->A1_YVENBE2,"A3_NREDUZ") + CHR(13)+CHR(10)	
		END IF
		IF ALLTRIM(_AUX->A1_YVENBE3) <> ""
			cMensagem += CHR(13)+CHR(10)
			cMensagem += "REPRESENTANTE_3 BELLACASA: " + ALLTRIM(_AUX->A1_YVENBE3) + " - " + Posicione("SA3",1,xFilial("SA3")+_AUX->A1_YVENBE3,"A3_NREDUZ") + CHR(13)+CHR(10)	
		END IF
		
		//PEGASUS
		IF ALLTRIM(_AUX->A1_YVENPEG) <> ""
			cMensagem += CHR(13)+CHR(10)
			cMensagem += "REPRESENTANTE_1 PEGASUS : " + ALLTRIM(_AUX->A1_YVENPEG) + " - " + Posicione("SA3",1,xFilial("SA3")+_AUX->A1_YVENPEG,"A3_NREDUZ") + CHR(13)+CHR(10)	
		END IF
		
		//VINILICO
		IF ALLTRIM(_AUX->A1_YVENVI1) <> ""
			cMensagem += CHR(13)+CHR(10)
			cMensagem += "REPRESENTANTE_1 VINILICO: " + ALLTRIM(_AUX->A1_YVENVI1) + " - " + Posicione("SA3",1,xFilial("SA3")+_AUX->A1_YVENVI1,"A3_NREDUZ") + CHR(13)+CHR(10)	
		END IF

		cMensagem += CHR(13)+CHR(10)
		cMensagem += CHR(13)+CHR(10)
		cMensagem += "USUARIO DO SISTEMA: " + ALLTRIM(wUsuario) + CHR(13)+CHR(10)	
		cMensagem += "EMAIL DO USUARIO: " + ALLTRIM(Destinatario) + CHR(13)+CHR(10)	

	END IF

	If EhRepBianc
		cAuxDest := U_EmailWF('SOLI_CRE', cEmpAnt)
		If !Empty(cAuxDest)
			Destinatario += '; ' + cAuxDest
		EndIf
	EndIf

	ENV_EMAIL(cData,cTitulo,cMensagem)

RETURN


STATIC Function ENV_EMAIL(cData,cTitulo,cMensagem) 

	Local lOk

	///Destinatario := "fernando@facilesistemas.com.br" //*******TESTES*************//

	lOk := U_BIAEnvMail(,Destinatario,cTitulo,cMensagem) 

	If lOk   
		CONOUT("[SOLI_CRE] ENV_EMAIL ==> EMAIL ENVIADO COM SUCESSO ==> "+cMensagem)
	Else  
		CONOUT("[SOLI_CRE] ENV_EMAIL ==> ERRO AO ENVIAR O EMAIL ==> "+cMensagem)
	Endif    

return


Static Function Ver_Prazo()

	Local I
	xxDATA := DATE()

	FOR I := 1 TO 4
		xxDATA := Datavalida(xxDATA+1,.T.)
	NEXT
	cNDATALIB := xxDATA

return cNDATALIB


Static function AtualizaBrowse()

	dbSelectArea("_trab22")
	_trab22->(dbCloseArea())

	_aCampos :=	{{"CODIGO"		,"C",06,0},;
	{"DATA_SOLI"	,"C",20,0},;
	{"DATA_LIB"	,"D",08,0},;
	{"COD_CLI"		,"C",06,0},;
	{"NOME_CLI"	,"C",50,0},;
	{"USUARIO"		,"C",20,0},;
	{"NOMEUSU"		,"C",30,0},;
	{"NOVO_CLI"	,"C",10,0},;
	{"NUM_PEDIDO"	,"C",10,0},;
	{"VAL_PEDIDO"  ,"C",14,2},;
	{"TIP_PAG"		,"C",15,0},;
	{"COND_PAG"	,"C",15,0},;
	{"PRA_LIB"		,"C",15,0},;
	{"PRAZO"		,"C",15,0},;
	{"RESTO"		,"N",15,0},;
	{"cSTATUS"		,"C",15,0}}

	_trab22 := CriaTrab(_aCampos)
	dbUseArea(.T.,,_trab22,"_trab22",.t.)                           

	//Selecionando todos os produtos e suas quantidades em estoque
	If chkfile("c_CONS")
		dbSelectArea("c_CONS")
		dbCloseArea()
	EndIf
	TCQUERY cSql ALIAS "c_CONS" NEW
	c_CONS->(DbGoTop())
	While !c_CONS->(EOF())
		psworder(2)
		cNomeUsr := ""

		If SubStr(c_CONS->ZU_USUARIO,1,2) == "B-"
			cNomeUsr := SubStr(c_CONS->ZU_USUARIO,3, 23)
		Else
			If  pswseek(c_CONS->ZU_USUARIO,.t.)           
				_daduser  := pswret(1)           
				cNomeUsr  := _daduser[1,4]
			EndIf
		EndIf

		RecLock("_trab22",.t.)
		_trab22->CODIGO		:= c_CONS->ZU_CODIGO
		_trab22->DATA_SOLI	:= alltrim(dtoc(stod(c_CONS->ZU_DATA)))
		_trab22->DATA_LIB	:= stod(c_CONS->ZU_DATAAPR) //alltrim(dtoc(stod(c_CONS->ZU_DATAAPR)))
		_trab22->USUARIO	:= IIf(SubStr(c_CONS->ZU_USUARIO,1,2) == "B-","BIZAGI",c_CONS->ZU_USUARIO)
		_trab22->NOMEUSU	:= AllTrim(cNomeUsr)
		_trab22->COD_CLI	:= c_CONS->ZU_CODCLI
		_trab22->NOME_CLI   := Posicione("SA1",1,xFilial("SA1")+c_CONS->ZU_CODCLI,"A1_NOME")
		_trab22->NOVO_CLI	:= c_CONS->ZU_NOV_CLI
		_trab22->NUM_PEDIDO	:= c_CONS->ZU_PEDIDO
		_trab22->VAL_PEDIDO	:= TRANS(c_CONS->ZU_VALOR,"@E 999,999,999.99")
		_trab22->TIP_PAG	:= c_CONS->ZU_TIPOPAG
		_trab22->COND_PAG	:= c_CONS->ZU_COND_PA
		_trab22->PRAZO		:= alltrim(dtoc(stod(c_CONS->ZU_PRAZO))) 
		_trab22->cSTATUS	:= c_CONS->ZU_STATUS
		_trab22->RESTO		:= IIF(c_CONS->ZU_STATUS="PENDENTE",c_CONS->RESTANTE,0)
		MsUnlock()
		c_CONS->(DbSkip())	
	EndDo

	DbSelectArea("c_CONS")
	c_CONS->(DbCloseArea())

	aCampos0 := {}
	AADD(aCampos0,{"CODIGO"		,"CODIGO" 				,08})
	AADD(aCampos0,{"DATA_SOLI"	, "DATA SOLICITAÇÃO" 	,18})
	AADD(aCampos0,{"DATA_LIB"	, "DATA LIBERAÇÃO" 		,20})
	AADD(aCampos0,{"COD_CLI"	, "COD. CLIENTE" 		,18})
	AADD(aCampos0,{"NOME_CLI"	, "NOME DO CLIENTE" 	,50})
	AADD(aCampos0,{"USUARIO"	, "USUARIO" 			,20})
	AADD(aCampos0,{"NOMEUSU"	, "NOME DO USUARIO"		,30})
	AADD(aCampos0,{"NUM_PEDIDO"	, "NUM. PEDIDO"			,18})
	AADD(aCampos0,{"cSTATUS"	, "STATUS"				,18})
	AADD(aCampos0,{"RESTO"		, "DIAS RESTANTE"		,20})

	_trab22->(DbGoTop())
	oBrow:oBrowse:Refresh()

Return


Static Function SQL_FILTRO(_lBut)


	ccSTATUS := IIF(nRadio=1,"PENDENTE",IIF(nRadio=2,"APROVADO","REPROVADO"))

	If !_lBut

		ccSTATUS := "PENDENTE"

	EndIf

	If (  AllTrim(ccSTATUS) == "PENDENTE" ) .Or. !Empty(cClient) .Or. ( !Empty(dDataIni) .And. !Empty(dDataFim) )

		cSql := "SELECT DATEDIFF(DAY,GETDATE(),ZU_PRAZO) AS  RESTANTE, * FROM SZU010 WHERE 1=1 "
		
		If (oAceTela:UserTelemaketing())
			
			cSql += " AND ZU_USUARIO = '"+cNomeUsuario+"'  "
	
		Else
		
			If U_VALOPER("007",.F.) .Or. !Empty(Alltrim(cRepAtu))
				If !U_VALOPER("107",.F.) 
					cSql += " AND ZU_USUARIO = '"+cNomeUsuario+"'  "
				EndIf	
			EndIf
	
			IF ALLTRIM(cClient) <> ""
				cSql += " AND	ZU_CODCLI = '"+cClient+"'	"
			END IF
	
			If (!Empty(dDataIni))
				cSql += "	AND ZU_DATA >= '"+cvaltochar(DtoS(dDataIni))+"' "	
			END IF
	
			If (!Empty(dDataFim))
				cSql += "	AND ZU_DATA <= '"+cvaltochar(DtoS(dDataFim))+"' "	
			EndIf
	
			cSql += "	AND ZU_STATUS = '"+ccSTATUS+"'  	"
			cSql += "	AND D_E_L_E_T_ = '' 			"
			cSql += "ORDER BY ZU_DATA ASC, ZU_SHORA ASC "
			
		EndIf
		
		AtualizaBrowse()

	Else

		MsgAlert("Para filtrar é obrigatório informar somente PENDENTES, e/ou CLIENTE e/ou INTERVALO DE DATAS!","ATENÇÃO")

	EndIf

Return


Static Function SQL_TODOS()

	cSql := "SELECT DATEDIFF(DAY,GETDATE(),ZU_PRAZO) AS  RESTANTE, * "
	cSql += "FROM	SZU010	"
	cSql += "WHERE 	1=1		"
	
	If (oAceTela:UserTelemaketing())
		cSql += " AND ZU_USUARIO = '"+cNomeUsuario+"'  "
	
	Else
		
		If U_VALOPER("007",.F.) .Or. !Empty(Alltrim(cRepAtu))
			If !U_VALOPER("107",.F.) 
				cSql += " AND ZU_USUARIO = '"+cNomeUsuario+"'  "
			EndIf
		EndIf
		
	EndIf	
		

	cSql += " AND ZU_STATUS = 'PENDENTE' "
	cSql += " AND D_E_L_E_T_ = '' 
	cSql += "ORDER BY ZU_DATA ASC, ZU_SHORA ASC "

Return


Static Function MudaCheckBox()

	If oCheckPed:lModified
		oTGetPed:Disable()
		oComboEmp:Disable()
		cNPEDIDO	:= '*'
		lSemPed		:= .T.	
	Else
		cNPEDIDO	:= SPACE(10)
		oTGetPed:Enable()
		oComboEmp:Enable()
		lSemPed		:= .F.
	EndIf
	oTGetPed:Refresh()

Return


User Function GetSolCred(nOpc)

	Local aArea := GetArea()
	Local oButton1
	Local lSolicitacao := .F.
	Static oDlg
	Static oWBrowse1
	Static aWBrowse1 := {} 

	nOpc := IIF(nOpc <> NIL,nOpc,1)

	//MONTA QUERY PARA CONSULTA 
	cQuery := "Select * From " 
	cQuery += + RetSqlName("SZU") + " SZU " 
	cQuery += " WHERE ZU_PEDIDO = '" + IIF(nOpc == 1,SC5->C5_NUM,SCJ->CJ_NUM) + "' 
	cQuery += " AND SZU.D_E_L_E_T_='' "       

	TCQUERY cQuery ALIAS "QRY" NEW 

	aWBrowse1 := {}

	dbSelectArea("QRY")
	While !QRY->(EOF())
		lSolicitacao := .T.
		Aadd(aWBrowse1,{QRY->ZU_CODIGO,QRY->ZU_USUARIO,QRY->ZU_CODCLI,SUBSTR(QRY->ZU_DATA,7,2)+"/"+SUBSTR(QRY->ZU_DATA,5,2)+"/"+SUBSTR(QRY->ZU_DATA,1,4),QRY->ZU_VALOR,QRY->ZU_STATUS,QRY->ZU_EMPRESA})

		QRY->(DbSkip())	  
	enddo
	QRY->(dbCloseArea())

	If ! lSolicitacao
		MsgInfo("Não Possui Solicitação de Crédito Para Esse Pedido de Venda.")
	Else

		DEFINE MSDIALOG oDlg TITLE "Consulta Solicitacoes de Credito" FROM 000, 000  TO 250, 500 COLORS 0, 16777215 PIXEL
		fWBrowse1()
		@ 104, 095	Button "Fechar" Size 037,12 Action oDlg:End()

		ACTIVATE MSDIALOG oDlg CENTERED

	EndIf

	RestArea(aArea)
Return


Static Function fWBrowse1()

	@ 026, 000 LISTBOX oWBrowse1 Fields HEADER "CODIGO","USUARIO","COD.CLI.","ZU_DATA","VALOR","STATUS","EMPRESA" SIZE 249, 060 OF oDlg PIXEL ColSizes 40,50
	oWBrowse1:SetArray(aWBrowse1)
	oWBrowse1:bLine := {|| {;
	aWBrowse1[oWBrowse1:nAt,1],;
	aWBrowse1[oWBrowse1:nAt,2],;
	aWBrowse1[oWBrowse1:nAt,3],;
	aWBrowse1[oWBrowse1:nAt,4],;
	aWBrowse1[oWBrowse1:nAt,5],;
	aWBrowse1[oWBrowse1:nAt,6];
	}}

Return


Static Function fVldCli()

	Local lRet := .T.

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+cNClient))


	If !Empty(Alltrim(cRepAtu))
		If !(SA1->A1_VEND    == cRepAtu .Or. SA1->A1_YVENDB2 == cRepAtu .Or. SA1->A1_YVENDB3 == cRepAtu .Or. ;
		SA1->A1_YVENDI  == cRepAtu .Or. SA1->A1_YVENDI2 == cRepAtu .Or. SA1->A1_YVENDI3 == cRepAtu .Or. ;
		SA1->A1_YVENBE1 == cRepAtu .Or. SA1->A1_YVENBE2 == cRepAtu .Or. SA1->A1_YVENBE3 == cRepAtu .Or. ;
		SA1->A1_YVENML1 == cRepAtu .Or. SA1->A1_YVENML2 == cRepAtu .Or. SA1->A1_YVENML3 == cRepAtu .Or. ;
		SA1->A1_YVENVT1 == cRepAtu .Or. SA1->A1_YVENVT2 == cRepAtu .Or. SA1->A1_YVENVT3 == cRepAtu .Or. ;
		SA1->A1_YVENVI1 == cRepAtu )
			MsgStop("Cliente NÃO permitido para o Representante!","Valida Cliente")
			cNClient1 	:= ""
			lRet 		:= .F.
		EndIf
		cNClient1 := SA1->A1_NOME
	Else
		cNClient1 := SA1->A1_NOME
	EndIf


Return(lRet)


Static Function fVldCond()
	Local lRet := .T.

	DbSelectArea("SE4")
	SE4->(DbSetOrder(1))
	SE4->(DbSeek(xFilial("SE4")+cNCOND))

	cNCOND1 := SE4->E4_DESCRI

Return(lRet)                  


User Function fGrvStSC(cPedido,cCliente)

	SC5->(DbSetOrder(1))			
	If SC5->(DbSeek(xFilial("SC5")+cPedido)) .And. SC5->C5_CLIENTE == cCliente .And. SC5->C5_YTPCRED == '5' .And. SC5->C5_YCRDENG == '03' 
		RecLock("SC5",.F.)		
		SC5->C5_YCRDENG := "02"
		SC5->(MsUnlock())			
	EndIf

Return()
