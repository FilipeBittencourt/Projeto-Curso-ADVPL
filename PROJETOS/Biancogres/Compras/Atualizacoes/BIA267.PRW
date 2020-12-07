#Include "PROTHEUS.CH"
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#include "vkey.ch"
#Include "TOTVS.CH"

/*/{Protheus.doc} BIA267
@author Marcos Alberto Soprani
@since 10/10/2011
@version undefined
@description Browser Principal para Rotina de Processo de Devolucao
@obs Uso : Compras
@type function
/*/

User Function BIA267()

	Local aCores
	Private xImpDh := .F.
	Private wdProc := ""

	dbSelectArea("Z25")
	dbGoTop()
	aCores :=  { ;
	{" Z25_APRADM == ' ' .AND. Z25_NFLANC == ' ' .AND. Z25_APRFIS == ' ' .AND. Z25_APRFIN == ' ' " , "BR_BRANCO"  },;
	{" Z25_APRADM <> ' ' .AND. Z25_NFLANC == ' ' .AND. Z25_APRFIS == ' ' .AND. Z25_APRFIN == ' ' " , "BR_MARRON"  },;
	{" Z25_APRADM <> ' ' .AND. Z25_NFLANC <> ' ' .AND. Z25_APRFIS == ' ' .AND. Z25_APRFIN == ' ' " , "BR_AZUL"    },;
	{" Z25_APRADM <> ' ' .AND. Z25_NFLANC <> ' ' .AND. Z25_APRFIS <> ' ' .AND. Z25_APRFIN == ' ' " , "BR_AMARELO" },;
	{" Z25_APRADM <> ' ' .AND. Z25_NFLANC <> ' ' .AND. Z25_APRFIS == ' ' .AND. Z25_APRFIN <> ' ' " , "BR_PRETO"   },;
	{" Z25_APRADM <> ' ' .AND. Z25_NFLANC <> ' ' .AND. Z25_APRFIS <> ' ' .AND. Z25_APRFIN <> ' ' " , "BR_VERDE"   } }
	n := 1
	cCadastro := " ....: Processo de Devolução :.... "

	aSubRotina:= {  {"Comercial"      ,'Execblock("BIA267D" ,.F.,.F.,"C")'    ,0, 4},;
	{                "Fiscal"         ,'Execblock("BIA267D" ,.F.,.F.,"F")'    ,0, 4},;
	{                "Expedição"      ,'Execblock("BIA267D" ,.F.,.F.,"E")'    ,0, 4},;
	{                "Adm/Financeiro" ,'Execblock("BIA267D" ,.F.,.F.,"A")'    ,0, 4} }

	bSubRotina:= {  {"Detalhado"		,'Execblock("BIA267R1" ,.F.,.F.,"D")'   ,0, 7},;
	{                "Por Datas"		,'Execblock("BIA267R2" ,.F.,.F.,"P")'   ,0, 7},;
	{                "Devoluções"		,'U_BIA267R3()'   , 0, 7} }

	aRotina   := {  {"Pesquisar"    ,'AxPesqui'                             ,0, 1},;
	{                "Visualizar"   ,'Execblock("BIA267B" ,.F.,.F.,"V")'    ,0, 2},;
	{                "Incluir"      ,'Execblock("BIA267B" ,.F.,.F.,"I")'    ,0, 3},;
	{                "Alterar"      ,'Execblock("BIA267B" ,.F.,.F.,"T")'    ,0, 4},;
	{                "Excluir"      ,'Execblock("BIA267B" ,.F.,.F.,"E")'    ,0, 5},;
	{                "Pareceres"    ,aSubRotina                             ,0, 6},;
	{                "Relatórios"   ,bSubRotina                             ,0, 7},;
	{                "Legenda"      ,'Execblock("BIA267A" ,.F.,.F.,"L")'    ,0, 8},;
	{                "Filtrar Nota" ,'Execblock("BIA267K" ,.F.,.F.,"K")'    ,0, 9} }

	SetKey(VK_F5,{|| U_BIABC003(Z25->Z25_NUM,'P')})
	mBrowse(6,1,22,75, "Z25", , , , , ,aCores)

Return

/*/{Protheus.doc} BIA267A
@author Marcos Alberto Soprani
@since 10/10/2011
@version undefined
@description Funcao para apresenta a Cor na tela
@obs Uso : Compras
@type function
/*/
User Function BIA267A()

	Brwlegenda(cCadastro, "Legenda",{{ "BR_BRANCO"    ,"Totalmente em Aberto"}                    ,;
	{                                  "BR_MARRON"    ,"Parecer Comercial"}                       ,;
	{                                  "BR_AZUL"      ,"Lançada Nota Fiscal de Entrada"}          ,;
	{                                  "BR_AMARELO"   ,"Parecer da Expedição"}                    ,;
	{                                  "BR_PRETO"     ,"Parecer Financeiro"}                      ,;
	{                                  "BR_VERDE"     ,"Processo de Devolução Finalizado"}        ,;
	{                                  "BR_VERMELHO"  ,"Outros: ações fora do padrão"}            })

Return

/*/{Protheus.doc} BIA267B
@author Marcos Alberto Soprani
@since 10/10/2011
@version undefined
@description Funcao para apresenta a Cor na tela
@obs Uso : Compras
@type function
/*/

User Function BIA267B()

	Local i, z
	Local _ni

	If PARAMIXB $ "I/T/E" .And. !U_VALOPER("011",.F.) //!__cUserID $ GetMV("MV_YUSMNPD")
		MsgSTOP("Usuário sem permissão para esta operação no cadastro!!!", "OP 011")
		Return
	EndIf

	If PARAMIXB == "I"
		cOpcao := "INCLUIR"
	ElseIf PARAMIXB == "V"
		cOpcao := "VISUALIZAR"
	ElseIf PARAMIXB == "T"
		cOpcao := "ALTERAR"
		If !Empty(Z25->Z25_NFLANC)
			MsgINFO("Este processo já possui Nota Fiscal associada... Favor Verificar antes de prosseguir")
			Return
		EndIf
	ElseIf PARAMIXB == "E"
		cOpcao := "EXCLUIR"
		If !Empty(Z25->Z25_NFLANC)
			MsgINFO("Este processo já possui Nota Fiscal associada... Favor Verificar antes de prosseguir")
			Return
		EndIf
	EndIf
	Do Case
		Case cOpcao == "VISUALIZAR"; nOpcE:=2 ; nOpcG:=2
		Case cOpcao == "INCLUIR"   ; nOpcE:=3 ; nOpcG:=3
		Case cOpcao == "ALTERAR"   ; nOpcE:=3 ; nOpcG:=3
		Case cOpcao == "EXCLUIR"   ; nOpcE:=2 ; nOpcG:=2
	EndCase

	RegToMemory("Z25", (cOpcao == "INCLUIR") )

	nUsado := 0
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("Z26")
	aHeader := {}
	While !Eof() .and. SX3->X3_ARQUIVO == "Z26"
		If X3USO(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
			nUsado := nUsado+1
			Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture, x3_tamanho, x3_decimal,"AllwaysTrue()", x3_usado, x3_tipo, x3_arquivo, x3_context } )
		Endif
		dbSkip()
	End

	If cOpcao == "INCLUIR"
		M->Z25_NUM := GetSx8Num("Z25","Z25_NUM")
		aCols := {Array(nUsado+1)}
		aCols[1,nUsado+1]:=.F.
		For _ni := 1 to nUsado
			aCols[1,_ni] := CriaVar(aHeader[_ni,2])
		Next
	Else
		aCols:={}
		dbSelectArea("Z26")
		dbSetOrder(1)
		dbSeek(xFilial()+M->Z25_NUM)
		While !Eof() .and. Z26->Z26_NUMPRC == M->Z25_NUM
			AADD(aCols,Array(nUsado+1))
			For _ni:=1 to nUsado
				aCols[Len(aCols),_ni] := FieldGet(FieldPos(aHeader[_ni,2]))
				If Alltrim(aHeader[_ni,2]) == "Z26_DESCRI"
					aCols[Len(aCols),_ni] := Substr(Posicione("SB1",1,xFilial("SB1")+Z26->Z26_PROD,"B1_DESC"),1,70)
				EndIf
			Next
			aCols[Len(aCols),nUsado+1]:=.F.
			dbSkip()
		End
	Endif

	If Len(aCols) > 0

		cTitulo        := "Processo de Devolução"
		cAliasEnchoice := "Z25"
		cAliasGetD     := "Z26"
		cLinOk         := "ExecBlock('BIA267C',.F.,.F.)"
		cTudOk         := "ExecBlock('BIA267T',.F.,.F.)"
		cFieldOk       := "AllwaysTrue()"
		aCpoEnchoice   := {"C5_CLIENTE"}
		bak_aHe        := aHeader
		xf_Tela        := {130,007,680,950}
		xf_Buttons     := {{'CLIENTE',{|| ExecBlock("BIA267U",.F.,.F.,"U") },'Envolvidos'} , {'BUDGETY',{|| ExecBlock("BIA267E",.F.,.F.,"V") },'Parecer'}}

		_lRet := Modelo3(cTitulo, cAliasEnchoice, cAliasGetD, aCpoEnchoice, cLinOk, cTudOk, nOpcE, nOpcG, cFieldOk, .T., 9999, , , IIF(PARAMIXB == "V",xf_Buttons,), xf_Tela, 320)

		If _lRet
			If cOpcao $ "ALTERAR/EXCLUIR"
				dbSelectArea("Z25")
				dbSetOrder(1)
				If dbSeek(xFilial("Z25")+M->Z25_NUM)
					RecLock("Z25",.F.)
					DELETE
					MsUnLockAll()
				EndIf
				dbSelectArea("Z26")
				dbSetOrder(1)
				If dbSeek(xFilial("Z26")+M->Z25_NUM)
					While !Eof() .and. xFilial("Z26") == Z26->Z26_FILIAL .and. Z26->Z26_NUMPRC == M->Z25_NUM
						RecLock("Z26",.F.)
						DELETE
						MsUnLockAll()
						dbSelectArea("Z26")
						dbSkip()
					End
				EndIf
			EndIf
			If cOpcao $ "INCLUIR/ALTERAR"
				If cOpcao == "INCLUIR"
					ConfirmSX8()
				EndIf
				Z25->(dbSetOrder(1))
				If Z25->(dbSeek(xFilial("Z25")+M->Z25_NUM))
					M->Z25_NUM := GetSx8Num("Z25","Z25_NUM")
					ConfirmSx8()
					MsgINFO("O novo número sequencial para o processo é:"+M->Z25_NUM)
				EndIf
				// Cabeçalho do Processo
				RecLock("Z25",.T.)
				Z25->Z25_FILIAL  := xFilial("Z25")
				Z25->Z25_USR     := __cUserID
				dbSelectArea("SX3")
				dbSetOrder(1)
				dbSeek("Z25")
				aHeader := {}
				While !Eof() .and. SX3->X3_ARQUIVO == "Z25"
					If X3USO(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .and. SX3->X3_CONTEXT <> "V"
						&("Z25->"+TRIM(SX3->X3_CAMPO))  := &("M->"+TRIM(SX3->X3_CAMPO))
					Endif
					dbSelectArea("SX3")
					dbSkip()
				End
				MsUnLockAll()
				// Item do Processo
				For i := 1 to Len(aCols)
					RecLock("Z26",.T.)
					Z26->Z26_FILIAL := xFilial("Z26")
					Z26->Z26_NUMPRC := M->Z25_NUM
					For z := 1 to Len(bak_aHe)-1
						If TRIM(bak_aHe[z][2]) <> "Z26_DESCRI"
							&("Z26->"+TRIM(bak_aHe[z][2])) := ACOLS[i][z]
						EndIf
					Next z
					MsUnLockAll()
				Next i
				If cOpcao == "INCLUIR"
					or_AcAtu := "Incluído Processo de Devolução."
					or_DescS := "Favor verificar a existência de movimentações financeiras com os títulos associadas às notas fiscais deste processo."
					U_BWfPDevL( Z25->Z25_NUM, or_AcAtu, or_DescS, 0)
				EndIf
			EndIf
		Else
			RollBackSx8()
		Endif
	Endif

	n := 1

Return

/*/{Protheus.doc} BIA267C
@author Marcos Alberto Soprani
@since 10/10/2011
@version undefined
@description Validacao do conteudo digitado nas linhas do Grid 
@obs Uso : Compras
@type function
/*/

User Function BIA267C()

	sf_Retr := .T.

	If !Gddeleted(n)
		If Alltrim(cOpcao) $ "INCLUIR/ALTERAR"
			If !Empty(Alltrim(GdFieldGet("Z26_ITEMNF",n))) .or. !Empty(Alltrim(GdFieldGet("Z26_PROD",n))) .or. GdFieldGet("Z26_QTDORI",n) <> 0 .or. GdFieldGet("Z26_QTDDEV",n) <> 0 .or. GdFieldGet("Z26_QTDBOA",n) <> 0
				MsgINFO("Durante a inclusão de um processo de devolução, apenas os campos N.Fiscal e Serie.N.Fisc deverão ser preenchidos!!!")
				sf_Retr := .F.
			EndIf
		EndIf

		If !(Alltrim(M->Z25_CODCLI) $ GetMv("MV_YDEVCLI"))
			SF2->(dbSetOrder(1))
			If !SF2->(dbSeek(xFilial("SF2")+GdFieldGet("Z26_NFISC",n)+GdFieldGet("Z26_SERIE",n)+M->Z25_CODCLI+M->Z25_LOJCLI))
				MsgINFO("Os campos N.Fiscal e Serie.N.Fisc estão vazios ou foram preenchidos incorretamente... ")
				sf_Retr := .F.
			EndIf
		EndIf
	EndIf

Return(sf_Retr)

/*/{Protheus.doc} BIA267D
@author Marcos Alberto Soprani
@since 10/10/2011
@version undefined
@description Tela para inclusão dos Pareceres - Fisico - Adm - Fin 
@obs Uso : Compras
@type function
/*/

User Function BIA267D()

	Local   nOpc       := GD_UPDATE
	Local   aEdits
	Private aCoBrw1    := {}
	Private aHoBrw1    := {}
	Private ck_cliente := Z25->Z25_CODCLI
	Private ck_loja    := Z25->Z25_LOJCLI
	Private ck_motivo  := Z25->Z25_MOTIVO
	Private ck_nome    := Posicione("SA1",1,xFilial("SA1")+ck_cliente+ck_loja,"A1_NOME")
	Private ck_numero  := Z25->Z25_NUM
	Private dk_DtIni   := Z25->Z25_DTINI
	Private noBrw1     := 0
	Private df_Param   := PARAMIXB
	aEdits             := IIf(!df_Param $ "F/C/A", {"Z26_QTDDEV","Z26_QTDBOA","Z26_OBS"}, {})

	SetPrvt("oDlg1","oSay1","oSay2","oSay3","oBrw1","oGet1","oGet2","oGet3","oGet4","oGet5","oMGet1")

	If df_Param == "C"  // Parecer Comercial
		If !U_VALOPER("012",.F.) //!__cUserID $ GetMv("MV_YUSDADM")
			MsgSTOP("Usuário sem permissão para emitir parecer COMERCIAL!!!", "OP 012")
			Return
		EndIf

	ElseIf df_Param == "F"  // Parecer Fiscal
		If !U_VALOPER("013",.F.) //!__cUserID $ GetMv("MV_YUSDFIS")
			MsgSTOP("Usuário sem permissão para emitir parecer da FISCAL!!!", "OP 013")
			Return
		Else
			If !Empty(Z25->Z25_NFLANC)
				MsgALERT("A nota fiscal já foi incluída, portanto não será possível dar o parecer Fiscal!!!")
				Return
			Else
				If Empty(Z25->Z25_APRADM) // Antes do Parecer Comercial, não será possível alterar o parecer fiscal.
					MsgALERT("Ainda foi dado o parecer Comercial. Favor Verificar!!!")
					Return
				EndIf
			EndIf
		EndIf

	ElseIf df_Param == "E"  // Parecer Expedição
		If  !U_VALOPER("014",.F.) //!__cUserID $ GetMv("MV_YUSDEXP")
			MsgSTOP("Usuário sem permissão para emitir parecer da EXPEDIÇÃO!!!", "OP 014")
			Return
		Else
			If Empty(Z25->Z25_NFLANC)
				MsgALERT("Ainda não foi dada entrada na nota fiscal relacionada ao processo!!!")
				Return
			Else
				If Empty(Z25->Z25_APRADM)
					MsgALERT("Ainda foi dado o parecer Comercial. Favor Verificar!!!")
					Return
				EndIf
			EndIf
		EndIf

	ElseIf df_Param == "A"  // Parecer Financeiro
		If !U_VALOPER("015",.F.) //!__cUserID $ GetMv("MV_YUSDFIN")
			MsgSTOP("Usuário sem permissão para emitir parecer FINANCEIRO!!!", "OP 015")
			Return
		Else
			If Empty(Z25->Z25_APRADM)
				MsgALERT("Ainda foi dado o parecer Comercial. Favor Verificar!!!")
				Return
			EndIf
		EndIf

	EndIf

	oDlg1      := MSDialog():New( 000,000,560,980,"Parecer",,,.F.,,,,,,.T.,,,.T. )

	oDlg1:bInit := {||EnchoiceBar(oDlg1, IIF(df_Param == "E",{|| ExecBlock("BIA267G",.F.,.F.) }, {|| SetKey(VK_F7,), oDlg1:End() } ), {|| SetKey(VK_F7,), oDlg1:End() }, .F., {{'BUDGETY',{|| ExecBlock("BIA267E",.F.,.F.,"P") },'Parecer'}} )}

	oSay1      := TSay():New( 020,008,{||"Número:"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
	oSay2      := TSay():New( 020,092,{||"Data Inicial:"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay3      := TSay():New( 036,008,{||"Cliente:"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
	MHoBrw1()
	MCoBrw1()
	oBrw1      := MsNewGetDados():New(100, 008, 275, 480, nOpc, 'AllwaysTrue()', 'AllwaysTrue()', '', aEdits, 0, 99, 'U_BIA267F()', '', 'AllwaysTrue()', oDlg1, aHoBrw1, aCoBrw1 )
	oGet1      := TGet():New( 020,036,{|u| If(PCount()>0,ck_numero:=u,ck_numero)}      ,oDlg1,040,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","ck_numero",,)
	oGet2      := TGet():New( 020,128,{|u| If(PCount()>0,dk_DtIni:=u,dk_DtIni)}        ,oDlg1,044,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dk_DtIni",,)
	oGet3      := TGet():New( 036,032,{|u| If(PCount()>0,ck_cliente:=u,ck_cliente)}    ,oDlg1,036,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","ck_cliente",,)
	oGet4      := TGet():New( 036,072,{|u| If(PCount()>0,ck_loja:=u,ck_loja)}          ,oDlg1,012,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","ck_loja",,)
	oGet5      := TGet():New( 036,088,{|u| If(PCount()>0,ck_nome:=u,ck_nome)}          ,oDlg1,228,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","ck_nome",,)
	oMGet1     := TMultiGet():New( 052,008,{|u| If(PCount()>0,ck_motivo:=u,ck_motivo)} ,oDlg1,308,044,  ,,CLR_BLACK,CLR_WHITE,  ,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
	oGet1:Disable()
	oGet2:Disable()
	oGet3:Disable()
	oGet4:Disable()
	oGet5:Disable()
	oMGet1:Disable()

	SetKey(VK_F7,{|| U_BIA267E("P")})

	oDlg1:Activate(,,,.T.)

Return

/*/{Protheus.doc} MHoBrw1
@author Marcos Alberto Soprani
@since 02/06/2009
@version undefined
@description Monta aHeader da MsNewGetDados para o Alias
@obs Uso : Compras
@type function
/*/

Static Function MHoBrw1()

	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("Z26")
	While !Eof() .and. SX3->X3_ARQUIVO == "Z26"
		If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
			noBrw1++
			Aadd(aHoBrw1,{Trim(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			"",;
			"",;
			SX3->X3_TIPO,;
			"",;
			"" } )
		EndIf
		dbSkip()
	End
	aAdd(aHoBrw1,{"RegZ26"        ,"REGZ26"   ,"@E 999999999999999999",18, 0,,,"N", ,})

Return

/*/{Protheus.doc} MCoBrw1
@author Marcos Alberto Soprani
@since 02/06/2009
@version undefined
@description Monta aCols da MsNewGetDados para o Alias
@obs Uso : Compras
@type function
/*/

Static Function MCoBrw1()

	Local _ni
	Local aAux := {}

	aAux:={}
	dbSelectArea("Z26")
	dbSetOrder(1)
	dbSeek(xFilial()+Z25->Z25_NUM)
	While !Eof() .and. Z26->Z26_FILIAL == xFilial("Z26") .and. Z26->Z26_NUMPRC == Z25->Z25_NUM
		AADD(aCoBrw1,Array(noBrw1+2))
		For _ni := 1 to noBrw1
			aCoBrw1[Len(aCoBrw1),_ni] := FieldGet(FieldPos(aHoBrw1[_ni,2]))
			If Alltrim(aHoBrw1[_ni,2]) == "Z26_DESCRI"
				aCoBrw1[Len(aCoBrw1),_ni] := Substr(Posicione("SB1",1,xFilial("SB1")+Z26->Z26_PROD,"B1_DESC"),1,70)
			EndIf
		Next
		aCoBrw1[Len(aCoBrw1),noBrw1+1]:= Z26->(Recno())
		aCoBrw1[Len(aCoBrw1),noBrw1+2]:= .F.
		dbSkip()
	End

Return

/*/{Protheus.doc} BIA267E
@author Marcos Alberto Soprani
@since 10/10/2011
@version undefined
@description Responsável pela digitação dos pareceres
@obs Uso : Compras
@type function
/*/

User Function BIA267E()

	Private cs_DetFis  := Alltrim(Z25->Z25_PFISCA)
	Private cs_DetCom  := Alltrim(Z25->Z25_PARADM)
	Private cs_DetFin  := Alltrim(Z25->Z25_PARFIN)

	SetPrvt("owDlg1","owSay1","owSay2","owSay3","owMGet1","owMGet2","owMGet3","owBtn1")

	owDlg1      := MSDialog():New( 095,232,434,924,"Detalhamento dos Pareceres",,,.F.,,,,,,.T.,,,.T. )

	owSay1      := TSay():New( 008,008,{||"Fiscal"}               ,owDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,008)
	owSay2      := TSay():New( 060,008,{||"Comercial"}            ,owDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,008)
	owSay3      := TSay():New( 112,008,{||"ADM/Financeiro"}       ,owDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,008)
	owMGet1     := TMultiGet():New( 016,008,{|u| If(PCount()>0,cs_DetFis:=u,cs_DetFis)},owDlg1,308,037,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
	owMGet2     := TMultiGet():New( 068,008,{|u| If(PCount()>0,cs_DetCom:=u,cs_DetCom)},owDlg1,308,037,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
	owMGet3     := TMultiGet():New( 120,008,{|u| If(PCount()>0,cs_DetFin:=u,cs_DetFin)},owDlg1,308,037,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )

	owBtn1      := TButton():New( 016,320,"Ok" ,owDlg1,{|| IIF(ParamIXB == "V", owDlg1:End(), ExecBlock("BIA267H",.F.,.F.)) },020,141,,,,.T.,,"",,,,.F. )

	If ParamIXB == "V"
		owMGet1:Disable()
		owMGet2:Disable()
		owMGet3:Disable()
	Else
		If df_Param == "C"      // Parecer Comercial
			owMGet1:Disable()
			owMGet3:Disable()
		ElseIf df_Param $ "F"   // Parecer Fiscal
			owMGet2:Disable()
			owMGet3:Disable()
		ElseIf df_Param $ "E"   // Parecer Expedição
			owMGet1:Disable()
			owMGet2:Disable()
			owMGet3:Disable()
		ElseIf df_Param == "A"  // Parecer Financeiro
			owMGet1:Disable()
			owMGet2:Disable()
		EndIf
	EndIf

	owDlg1:Activate(,,,.T.)

Return

/*/{Protheus.doc} BIA267F
@author Marcos Alberto Soprani
@since 10/10/2011
@version undefined
@description Controle de Alteração dos campos do GrId
@obs Uso : Compras
@type function
/*/

User Function BIA267F()

	Local gk_Retn := .T.

	If GdFieldGet("Z26_ITEMNF",n) $ "XX/  "
		MsgINFO("Não é permitido alterar qualquer dado desta linha de registro!!!")
		gk_Retn := .F.
	EndIf

Return (gk_Retn)

/*/{Protheus.doc} BIA267G
@author Marcos Alberto Soprani
@since 10/10/2011
@version undefined
@description Grava Informações adcionais registradas no grid referentes ao parecer da Expedição
@obs Uso : Compras
@type function
/*/

User Function BIA267G()

	Local y
	oDlg1:End()

	dbSelectArea("Z25")
	RecLock("Z25",.F.)
	Z25->Z25_APRFIS := "X"
	If !Empty(Z25->Z25_APRFIN)
		Z25->Z25_DTPFIN := dDataBase
	EndIf
	MsUnLock()

	For y := 1 to Len(oBrw1:ACOLS)
		dbSelectArea("Z26")
		dbGoto(oBrw1:ACOLS[y][11])
		RecLock("Z26",.F.)
		Z26->Z26_QTDDEV := oBrw1:ACOLS[y][7]
		Z26->Z26_QTDBOA := oBrw1:ACOLS[y][8]
		Z26->Z26_OBS    := oBrw1:ACOLS[y][9]
		Z26->Z26_USPEXP := __cUserID
		Z26->Z26_DTPEXP := dDataBase
		MsUnLock()
	Next y

	If !Empty(Z25->Z25_APRFIN)
		or_AcAtu := "Registrado parecer da EXPEDIÇÃO, posterior ao parecer FINANCEIRO. Processo finalizado!!!"
		or_DescS := "COMERCIAL"
		U_BWfPDevL( Z25->Z25_NUM, or_AcAtu, or_DescS, 4)
	EndIf

Return(.T.)

/*/{Protheus.doc} BIA267H
@author Marcos Alberto Soprani
@since 10/10/2011
@version undefined
@description Grava os pareceres do Comercial e do ADM/Financeiro
@obs Uso : Compras
@type function
/*/

User Function BIA267H()

	owDlg1:End()
	oDlg1:End()

	If df_Param == "C"  // Parecer Comercial
		dbSelectArea("Z25")
		RecLock("Z25",.F.)
		Z25->Z25_APRADM := "X"
		Z25->Z25_PARADM := Alltrim(cs_DetCom)
		Z25->Z25_USPADM := __cUserID
		Z25->Z25_DTPADM := dDataBase
		MsUnLock()
		or_AcAtu := "Registrado parecer COMERCIAL!!!"
		or_DescS := "Fiscal"
		U_BWfPDevL( Z25->Z25_NUM, or_AcAtu, or_DescS, 1)

	ElseIf df_Param == "F"  // Parecer Fiscal
		dbSelectArea("Z25")
		RecLock("Z25",.F.)
		Z25->Z25_PFISCA := Alltrim(cs_DetFis)
		Z25->Z25_USPLVR := __cUserID
		Z25->Z25_DTPLVR := dDataBase
		MsUnLock()
		or_AcAtu := "Apresentado parecer FISCAL que pode mudar o curso normal do lançamento da Nota Fiscal de Entrada por Devolução!!!"
		or_DescS := "Comercial"
		U_BWfPDevL( Z25->Z25_NUM, or_AcAtu, or_DescS, 2)

		// Lançamento da Nota Fiscal de Devolução no sistema "3" via ponto de entrada SD1100I_AP5

	ElseIf df_Param == "A"  // Parecer Financeiro
		dbSelectArea("Z25")
		RecLock("Z25",.F.)
		If !Empty(Alltrim(cs_DetFin))
			Z25->Z25_APRFIN := "X"
			Z25->Z25_PARFIN := Alltrim(cs_DetFin)
		Else
			Z25->Z25_APRFIN := ""
			Z25->Z25_PARFIN := ""
		EndIf
		Z25->Z25_DTFIN  := dDataBase
		Z25->Z25_USPFIN := __cUserID
		If !Empty(Z25->Z25_APRFIS)
			Z25->Z25_DTPFIN := dDataBase
		EndIf
		MsUnLock()
		If !Empty(Z25->Z25_APRFIS)
			or_AcAtu := "Registrado parecer FINANCEIRO, posterior ao parecer da EXPEDIÇÃO. Processo finalizado!!!"
			or_DescS := "COMERCIAL"
			U_BWfPDevL( Z25->Z25_NUM, or_AcAtu, or_DescS, 5)
		EndIf

	EndIf

Return(.T.)

/*/{Protheus.doc} BIA267U
@author Marcos Alberto Soprani
@since 10/10/2011
@version undefined
@description Apresenta Nome dos Usuários que participaram do Processo 
@obs Uso : Compras
@type function
/*/

User Function BIA267U()

	R0002 := " SELECT MAX(Z26_USPEXP) USPEXP
	R0002 += "   FROM " + RetSqlName("Z26")
	R0002 += "  WHERE Z26_FILIAL = '"+xFilial("ZZ6")+"'
	R0002 += "    AND Z26_NUMPRC = '"+Z25->Z25_NUM+"'
	R0002 += "    AND Z26_ITEMNF <> 'XX'
	R0002 += "    AND D_E_L_E_T_ = ' '
	TcQuery R0002 ALIAS "R002" NEW
	dbSelectArea("R002")
	dbGoTop()
	xfMens := "Abertura do Processo: " + UsrRetNameFull(Z25->Z25_USR)    + CHR(13) + CHR(10)
	xfMens += "Lançamento da Nota:   " + UsrRetNameFull(Z25->Z25_USLNFE) + CHR(13) + CHR(10)
	xfMens += "Parecer Fiscal:       " + UsrRetNameFull(Z25->Z25_USPLVR) + CHR(13) + CHR(10)
	xfMens += "Parecer da Expedição: " + UsrRetNameFull(R002->USPEXP)    + CHR(13) + CHR(10)
	xfMens += "Parecer Comercial:    " + UsrRetNameFull(Z25->Z25_USPADM) + CHR(13) + CHR(10)
	xfMens += "Parecer Finaceiro:    " + UsrRetNameFull(Z25->Z25_USPFIN)
	R002->(dbCloseArea())

	MsgINFO(xfMens)

Return

/*/{Protheus.doc} BIA267R1
@author Marcos Alberto Soprani
@since 16/01/2012
@version undefined
@description Imprime Relatório dos Processo 
@obs Uso : Compras
@type function
/*/

User Function BIA267R1()

	#IFDEF WINDOWS
	Processa({|| RptDetail()})
Return
Static Function RptDetail()
	#ENDIF

	xImpDh := .F.
	cHInicio := Time()
	fPerg := "BIA267"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	aDados2 := {}

	aBitmap  := "LOGOPRI"+cEmpAnt+".BMP"
	fCabec   := "Processo de Devolução"
	fCabe02  := ""

	wnPag    := 0
	nRow1    := 0

	oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10  := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont32  := TFont():New("Lucida Console"    ,9,32,.T.,.T.,5,.T.,5,.T.,.F.)

	oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
	oPrint:SetLandscape()
	oPrint:SetPaperSize(09)
	oPrint:Setup()

	cTempo := Alltrim(ElapTime(cHInicio, Time()))

	fImpCabec()

	dbSelectArea("Z25")
	dbSetOrder(1)
	dbGoTop()
	ProcRegua(RecCount())
	dbSeek(xFilial("Z25")+MV_PAR01, .T.)
	While !Eof() .and. Z25->Z25_FILIAL == xFilial("Z25") .and. Z25->Z25_NUM <= MV_PAR02

		sf_NumP := Z25->Z25_NUM
		While !Eof() .and. Z25->Z25_FILIAL == xFilial("Z25") .and. Z25->Z25_NUM <= MV_PAR02 .and. sf_NumP == Z25->Z25_NUM

			IncProc()

			fSaltPag()

			sf_C1Prc := +;
			Padr("Número: " + Z25->Z25_NUM                                                                                                                             ,020)+" "+;
			Padr("DtIni: " + dtoc(Z25->Z25_DTINI)                                                                                                                      ,020)+" "+;
			Padr("DtFim: " + dtoc(Z25->Z25_DTFIN)                                                                                                                      ,020)+" "+;
			Padr("RetMerc: " + Z25->Z25_RETMRC                                                                                                                         ,015)+" "+;
			Padr("Cliente: " + Z25->Z25_CODCLI + "-" + Z25->Z25_LOJCLI + " " + Alltrim(Posicione("SA1", 1, xFilial("SA1") + Z25->Z25_CODCLI + Z25->Z25_LOJCLI, "A1_NOME"))   ,060)
			oPrint:Say  (nRow1 ,0050 ,sf_C1Prc                               ,oFont8)
			nRow1 += 050
			fSaltPag()
			sf_C2Prc := +;
			Padr(""                                                                                                                                                    ,014)+" "+;
			Padr("Transp: " + Z25->Z25_TRANSP + " " + Alltrim(Posicione("SA4", 1, xFilial("SA4") + Z25->Z25_TRANSP, "A4_NOME"))                                        ,048)+" "+;
			Padr("Motorista: " + Z25->Z25_NMOTOR                                                                                                                       ,051)
			oPrint:Say  (nRow1 ,0050 ,sf_C2Prc                               ,oFont8)
			nRow1 += 050
			fSaltPag()

			df_Motiv := "Motivo: " + Alltrim(StrTran(Z25->Z25_MOTIVO, CHR(13)+CHR(10), " "))
			If !Empty(Z25->Z25_MOTIVO)
				oPrint:Say  (nRow1 ,0050 ,Substr(df_Motiv,1,185)                                     ,oFont8)
				nRow1 += 050
				fSaltPag()
				If !Empty(Substr(df_Motiv,186,185))
					oPrint:Say  (nRow1 ,0050 ,Substr(df_Motiv,186,185)                                 ,oFont8)
					nRow1 += 050
					fSaltPag()
					If !Empty(Substr(df_Motiv,371,185))
						oPrint:Say  (nRow1 ,0050 ,Substr(df_Motiv,371,185)                               ,oFont8)
						nRow1 += 050
						fSaltPag()
					EndIf
				EndIf
				nRow1 += 025
				fSaltPag()
			EndIf

			df_Orient := "Orientação: " +  Alltrim(StrTran(Z25->Z25_ORIENT, CHR(13)+CHR(10), " "))
			If !Empty(Z25->Z25_ORIENT)
				oPrint:Say  (nRow1 ,0050 ,Substr(df_Orient,1,185)                                    ,oFont8)
				nRow1 += 050
				fSaltPag()
				If !Empty(Substr(df_Orient,186,185))
					oPrint:Say  (nRow1 ,0050 ,Substr(df_Orient,186,185)                                ,oFont8)
					nRow1 += 050
					fSaltPag()
					If !Empty(Substr(df_Orient,371,185))
						oPrint:Say  (nRow1 ,0050 ,Substr(df_Orient,371,185)                              ,oFont8)
						nRow1 += 050
						fSaltPag()
					EndIf
				EndIf
				nRow1 += 025
				fSaltPag()
			EndIf

			df_Fisca := "Parecer Fiscal: " + Alltrim(StrTran(Z25->Z25_PFISCA, CHR(13)+CHR(10), " "))
			If !Empty(Z25->Z25_PFISCA)
				oPrint:Say  (nRow1 ,0050 ,Substr(df_Fisca,1,185)                                     ,oFont8)
				nRow1 += 050
				fSaltPag()
				If !Empty(Substr(df_Fisca,186,185))
					oPrint:Say  (nRow1 ,0050 ,Substr(df_Fisca,186,185)                                 ,oFont8)
					nRow1 += 050
					fSaltPag()
					If !Empty(Substr(df_Fisca,371,185))
						oPrint:Say  (nRow1 ,0050 ,Substr(df_Fisca,371,185)                               ,oFont8)
						nRow1 += 050
						fSaltPag()
					EndIf
				EndIf
				nRow1 += 025
				fSaltPag()
			EndIf

			df_Comer := "Parecer Comercial: " + Alltrim(StrTran(Z25->Z25_PARADM, CHR(13)+CHR(10), " "))
			If !Empty(Z25->Z25_PARADM)
				oPrint:Say  (nRow1 ,0050 ,Substr(df_Comer,1,185)                                     ,oFont8)
				nRow1 += 050
				fSaltPag()
				If !Empty(Substr(df_Comer,186,185))
					oPrint:Say  (nRow1 ,0050 ,Substr(df_Comer,186,185)                                 ,oFont8)
					nRow1 += 050
					fSaltPag()
					If !Empty(Substr(df_Comer,371,185))
						oPrint:Say  (nRow1 ,0050 ,Substr(df_Comer,371,185)                               ,oFont8)
						nRow1 += 050
						fSaltPag()
					EndIf
				EndIf
				nRow1 += 025
				fSaltPag()
			EndIf

			df_Finan := "Parecer Financeiro: " + Alltrim(StrTran(Z25->Z25_PARFIN, CHR(13)+CHR(10), " "))
			If !Empty(Z25->Z25_PARFIN)
				oPrint:Say  (nRow1 ,0050 ,Substr(df_Finan,1,185)                                     ,oFont8)
				nRow1 += 050
				fSaltPag()
				If !Empty(Substr(df_Finan,186,185))
					oPrint:Say  (nRow1 ,0050 ,Substr(df_Finan,186,185)                                 ,oFont8)
					nRow1 += 050
					fSaltPag()
					If !Empty(Substr(df_Finan,371,185))
						oPrint:Say  (nRow1 ,0050 ,Substr(df_Finan,371,185)                               ,oFont8)
						nRow1 += 050
						fSaltPag()
					EndIf
				EndIf
				nRow1 += 025
				fSaltPag()
			EndIf
			oPrint:Line (nRow1-40, 050, nRow1-40, 3350)

			aAdd(aDados2, { Z25->Z25_NUM                                                                  ,;
			dtoc(Z25->Z25_DTINI)                                                                          ,;
			dtoc(Z25->Z25_DTFIN)                                                                          ,;
			Z25->Z25_USR                                                                                  ,;
			Z25->Z25_CODCLI                                                                               ,;
			Z25->Z25_LOJCLI                                                                               ,;
			Alltrim(Posicione("SA1", 1, xFilial("SA1") + Z25->Z25_CODCLI + Z25->Z25_LOJCLI, "A1_NOME"))   ,;
			Alltrim(StrTran(Z25->Z25_MOTIVO,CHR(13)+CHR(10), " "))                                        ,;
			Z25->Z25_TRANSP                                                                               ,;
			Alltrim(Posicione("SA4", 1, xFilial("SA4") + Z25->Z25_TRANSP, "A4_NOME"))                     ,;
			Alltrim(StrTran(Z25->Z25_PARADM, CHR(13)+CHR(10), " "))                                       ,;
			Alltrim(StrTran(Z25->Z25_PARFIN, CHR(13)+CHR(10), " "))                                       ,;
			Alltrim(StrTran(Z25->Z25_ORIENT, CHR(13)+CHR(10), " "))                                       ,;
			Alltrim(StrTran(Z25->Z25_PFISCA, CHR(13)+CHR(10), " "))                                       })

			nRow1 += 050
			fSaltPag()

			dbSelectArea("Z25")
			dbSkip()
		End
	End

	fImpRoda()

	oPrint:EndPage()
	oPrint:Preview()

Return

/*/{Protheus.doc} BIA267R2
@author Marcos Alberto Soprani
@since 17/01/2012
@version undefined
@description Imprime Relatório dos Processo por data  
@obs Uso : Compras
@type function
/*/

User Function BIA267R2()

	#IFDEF WINDOWS
	Processa({|| RptDetaiX()})
Return
Static Function RptDetaiX()
	#ENDIF

	xImpDh := .T.
	cHInicio := Time()
	fPerg := "BIA267"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	aDados2 := {}

	aBitmap  := "LOGOPRI"+cEmpAnt+".BMP"
	fCabec   := "Processo de Devolução"
	fCabe02  := ""

	wnPag    := 0
	nRow1    := 0

	oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10  := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont32  := TFont():New("Lucida Console"    ,9,32,.T.,.T.,5,.T.,5,.T.,.F.)

	oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
	oPrint:SetLandscape()
	oPrint:SetPaperSize(09)
	oPrint:Setup()

	cTempo := Alltrim(ElapTime(cHInicio, Time()))

	fImpCabec()

	dbSelectArea("Z25")
	dbSetOrder(1)
	dbGoTop()
	ProcRegua(RecCount())
	dbSeek(xFilial("Z25")+MV_PAR01, .T.)
	While !Eof() .and. Z25->Z25_FILIAL == xFilial("Z25") .and. Z25->Z25_NUM <= MV_PAR02

		R0002 := " SELECT MAX(Z26_DTPEXP) DTPEXP
		R0002 += "   FROM " + RetSqlName("Z26")
		R0002 += "  WHERE Z26_FILIAL = '"+xFilial("ZZ6")+"'
		R0002 += "    AND Z26_NUMPRC = '"+Z25->Z25_NUM+"'
		R0002 += "    AND Z26_ITEMNF <> 'XX'
		R0002 += "    AND D_E_L_E_T_ = ' '
		TcQuery R0002 ALIAS "R002" NEW
		dbSelectArea("R002")
		dbGoTop()

		sf_C1Prc := +;
		Padr(Z25->Z25_NUM                                                                                                                  ,010)+" "+;
		Padr(dtoc(Z25->Z25_DTINI)                                                                                                          ,010)+" "+;
		Padr(dtoc(Z25->Z25_DTLNFE)                                                                                                         ,010)+" "+;
		Padr(dtoc(Z25->Z25_DTPLVR)                                                                                                         ,010)+" "+;
		Padr(dtoc(stod(R002->DTPEXP))                                                                                                      ,010)+" "+;
		Padr(dtoc(Z25->Z25_DTPADM)                                                                                                         ,010)+" "+;
		Padr(dtoc(Z25->Z25_DTPFIN)                                                                                                         ,010)+" "+;
		Padr(dtoc(Z25->Z25_DTFIN)                                                                                                          ,010)
		oPrint:Say  (nRow1 ,0050 ,sf_C1Prc                               ,oFont8)
		nRow1 += 050
		fSaltPag()

		R002->(dbCloseArea())

		dbSelectArea("Z25")
		dbSkip()
	End

	fImpRoda()

	oPrint:EndPage()
	oPrint:Preview()

Return

/*/{Protheus.doc} BIA267K
@author Marcos Alberto Soprani
@since 20/06/2012
@version undefined
@description Filtra Processos a Partir da Informação de uma Nota Fiscal 
@obs Uso : Compras
@type function
/*/

User Function BIA267K()

	Private oDlgFilt
	Private oButton1Ft
	Private oFont1 := TFont():New("Arial",,019,,.T.,,,,,.F.,.F.)
	Private oMultiGet1Ft
	Private cMultiGet1Ft := ""
	Private oSay1Ft
	Private oSay2Ft

	DEFINE MSDIALOG oDlgFilt TITLE "Filtro" FROM 000, 000  TO 190, 445 COLORS 0, 16777215 PIXEL
	@ 010, 008 SAY oSay1Ft PROMPT "Informar a Nota (ou Notas) para usar no Filtro:" SIZE 166, 011 OF oDlgFilt FONT oFont1 COLORS 0, 16777215 PIXEL
	@ 024, 008 GET oMultiGet1Ft VAR cMultiGet1Ft OF oDlgFilt MULTILINE SIZE 166, 044 COLORS 0, 16777215 HSCROLL PIXEL
	@ 074, 008 SAY oSay2Ft PROMPT "Obs.: Separar o numero das notas por virgula (,)" SIZE 165, 007 OF oDlgFilt COLORS 0, 16777215 PIXEL
	@ 009, 177 BUTTON oButton1Ft PROMPT "Filtrar" SIZE 037, 074 OF oDlgFilt ACTION gRetFilt() PIXEL
	ACTIVATE MSDIALOG oDlgFilt

Return

/*/{Protheus.doc} gRetFilt
@author Marcos Alberto Soprani
@since 20/06/2012
@version undefined
@description Filtra Processos a Partir da Informação de uma Nota Fiscal 
@obs Uso : Compras
@type function
/*/

Static Function gRetFilt()

	oDlgFilt:End()
	wdProc := ""
	If !Empty(cMultiGet1Ft)
		xf_Stri := Alltrim(cMultiGet1Ft)
		xLike   := "'"
		cs_VetLoc := {}
		If Right(xf_Stri,1) <> ','
			xf_Stri := xf_Stri+","
		EndIf
		While .T.
			nPos := AT(",", xf_Stri )
			If nPos > 0
				xLike   += Substr(xf_Stri,1,nPos-1)
				aAdd( cs_VetLoc , Substr(xf_Stri,1,nPos-1) )
				xf_Stri := Alltrim(Substr(xf_Stri,nPos+1,Len(xf_Stri)))
			Endif
			If Empty(xf_Stri)
				xLike += "'"
				Exit
			EndIf
			xLike += "','"
		End

		FR001 := " SELECT DISTINCT Z26_NUMPRC
		FR001 += "   FROM " + RetSqlName("Z26")
		FR001 += "  WHERE Z26_FILIAL = '"+xFilial("Z26")+"'
		FR001 += "    AND Z26_NFISC IN("+xLike+")
		FR001 += "    AND Z26_ITEMNF = 'XX'
		FR001 += "    AND D_E_L_E_T_ = ' '
		TcQuery FR001 ALIAS "FR01" NEW
		dbSelectArea("FR01")
		dbGoTop()
		While !Eof()
			wdProc += FR01->Z26_NUMPRC+","
			dbSelectArea("FR01")
			dbSkip()
		End
		FR01->(dbCloseArea())

	EndIf

	dbSelectArea("Z25")
	If !Empty(wdProc)
		Set filter to Z25_NUM $ wdProc
	Else
		MsgINFO("Não existe processo para a nota selecionada!!!")
		Set filter to
	EndIf

	dbGotop()

Return

/*/{Protheus.doc} fImpCabec
@author Marcos Alberto Soprani
@since 29/08/11
@version undefined
@description Imprime cabeçalho 
@obs Uso : Compras
@type function
/*/

Static Function fImpCabec()

	oPrint:StartPage()
	wnPag ++
	nRow1 := 050
	If File(aBitmap)
		oPrint:SayBitmap( nRow1+25, 050, aBitmap, 0600, 0125 )
	EndIf
	nRow1 += 025

	oPrint:Say  (nRow1    ,0050 ,Padc(fCabec,110)                                           ,oFont14)
	oPrint:Say  (nRow1+75 ,0050 ,Padc(fCabe02,110)                                          ,oFont14)
	oPrint:Say  (nRow1+10 ,3000 ,"Página:"                                                  ,oFont7)
	oPrint:Say  (nRow1+05 ,3150 ,Transform(wnPag,"@E 99999999")                             ,oFont8)
	oPrint:Say  (nRow1+60 ,3000 ,"Emissão:"                                                 ,oFont7)
	oPrint:Say  (nRow1+65 ,3150 ,dtoc(dDataBase)                                            ,oFont8)

	nRow1 += 175
	oPrint:Line (nRow1-40, 050, nRow1-40, 3350)

	If xImpDh
		sf_C1Prc := +;
		Padr("Processo"                                                              ,010)+" "+;
		Padc("DtIni"                                                                 ,010)+" "+;
		Padc("DtLancNf"                                                              ,010)+" "+;
		Padc("DtParFis"                                                              ,010)+" "+;
		Padc("DtParExp"                                                              ,010)+" "+;
		Padc("DtParCom"                                                              ,010)+" "+;
		Padc("DtParFin"                                                              ,010)+" "+;
		Padc("DtFim"                                                                 ,010)
		oPrint:Say  (nRow1 ,0050 ,sf_C1Prc                               ,oFont8)
		oPrint:Line (nRow1+40, 050, nRow1+40, 3350)
		nRow1 += 075
	EndIf

Return

/*/{Protheus.doc} fImpRoda
@author Marcos Alberto Soprani
@since 05/07/11
@version undefined
@description Imprime rodapé 
@obs Uso : Compras
@type function
/*/

Static Function fImpRoda()

	oPrint:Line (2300, 050, 2300, 3350)
	oPrint:Say  (2300+30 , 050,"Prog.: " + fPerg                                                    ,oFont7)
	oPrint:Say  (2300+30 ,2850,"Impresso em:  "+dtoc(dDataBase)+"  "+TIME()                         ,oFont7)
	oPrint:EndPage()
	nRow1 := 4000

Return

/*/{Protheus.doc} fSaltPag
@author Marcos Alberto Soprani
@since 05/07/11
@version undefined
@description Pula para próxima página
@obs Uso : Compras
@type function
/*/

Static Function fSaltPag()

	If nRow1 > 2250
		fImpRoda()
		fImpCabec()
	EndIf

Return

/*/{Protheus.doc} ValidPerg
@author Marcos Alberto Soprani
@since 05/07/11
@version undefined
@description Valida perg
@obs Uso : Compras
@type function
/*/

Static Function ValidPerg()
	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Do Processo         ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Processo        ?","","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})

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


User Function BIA267T()
	Local lRet := .T.
	Local nCount := 0

	For nCount := 1 To Len(aCols)

		If !GdDeleted(nCount)

			fExist(M->Z25_CODCLI, M->Z25_LOJCLI, GdFieldGet("Z26_NFISC", nCount), GdFieldGet("Z26_SERIE", nCount))						

		EndIf

	Next

Return(lRet)


Static Function fExist(cCodCli, cLojCli, cDoc, cSerie)
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT ISNULL(Z25_NUM, '') AS Z25_NUM "
	cSQL += " FROM " + RetSQLName("Z25") + " Z25 "
	cSQL += " INNER JOIN " + RetSQLName("Z26") + " Z26" 
	cSQL += " ON Z25_FILIAL = Z26_FILIAL " 
	cSQL += " AND Z25_NUM = Z26_NUMPRC "
	cSQL += " WHERE Z25_FILIAL = " + ValToSQL(xFilial("Z25"))
	cSQL += " AND Z25_CODCLI = " + ValToSQL(cCodCli)
	cSQL += " AND Z25_LOJCLI = " + ValToSQL(cLojCli)
	cSQL += " AND Z26_NFISC = " + ValToSQL(cDoc)
	cSQL += " AND Z26_SERIE = " + ValToSQL(cSerie)
	cSQL += " AND Z25.D_E_L_E_T_ = '' "
	cSQL += " AND Z26.D_E_L_E_T_ = '' "	

	TcQuery cSQL New Alias (cQry)

	If !Empty((cQry)->Z25_NUM)

		MsgAlert("Atenção a Nota Fiscal / Série: " + AllTrim(cDoc) +" / "+ AllTrim(cSerie) + " já esta associada ao processo de devolução: " + (cQry)->Z25_NUM)

	EndIf

	(cQry)->(dbCloseArea())

Return()


