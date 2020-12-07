#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA779
@author Marcos Alberto Soprani
@since 21/06/17
@version 1.0
@description Browser principal para a rotina de OBZ Integration (Orcto Custo/Despesas)
@type function
/*/

User Function BIA779()

	Local aArea     := GetArea()
	Local cCondicao := ""

	Private cCadastro 	:= "OBZ Integration (Orcto Custo/Despesas)"
	Private aRotina 	:= { {"Pesquisar"  			,"AxPesqui"     ,0,1},;
	{                         "Visualizar"			,"AxVisual"     ,0,2},;
	{                         "Importa Orçamento"	,"U_B779IEXC"   ,0,3},;
	{                         "Trocar Usuário Resp"	,"U_B779TRCA"   ,0,4},;
	{                         "Conferir Digitação"  ,"U_B779CFDG"   ,0,5},;
	{                         "OBZ p/ DESPESAS"	    ,"U_B779IMDD"   ,0,6} }

	dbSelectArea("Z98")
	dbSetOrder(1)

	If cEmpAnt <> "01"

		MsgSTOP("Esta rotina somente poderá ser acessada pela empresa Biancogres!!!")

	Else

		mBrowse(6,1,22,75,"Z98",,,,,,)

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B779IEXC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21/06/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Importação planilha Excel para Orçamento - OBZ Integration ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B779IEXC()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo		:= space(150)
	Private xdVersao        := space(010)
	Private xdRevisa        := space(003) 
	Private xdAnoRef		:= space(004) 
	Private xdUserDigt      := space(006) 

	AADD(aSays, OemToAnsi("Rotina para importação da Planilha de dados oriunda do OBZ Integration!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("IMPORTANTE: >>>> não é permitido importar arquivos que esteja com proteção"))   
	AADD(aSays, OemToAnsi("                 de planilha ativada!!!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação de OBZ Integration'), aSays, aButtons ,,,500)

	If lConfirm

		If !empty(cArquivo) .and. File(cArquivo)

			Processa({ || fProcImport() },"Aguarde...","Carregando Arquivo...",.F.)

		Else

			MsgStop('Informe o arquivo valido para importação!')

		EndIf

	EndIf	

Return

//Parametros
Static Function fPergunte()

	Local aPergs 	:= {}
	Local cLoad	    := 'B779IEXC' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo		:= space(150)
	xdVersao        := space(010)
	xdRevisa        := space(003) 
	xdAnoRef		:= space(004) 
	xdUserDigt      := space(006) 

	aAdd( aPergs ,{6,"Arquivo para Importação: " 	,cArquivo    ,"","","", 75 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )		
	aAdd( aPergs ,{1,"Versão:"                      ,xdVersao    ,"@!","NAOVAZIO()",'ZB5','.T.',070,.F.})	
	aAdd( aPergs ,{1,"Revisão:"                     ,xdRevisa    ,"@!","NAOVAZIO()",''   ,'.T.', 03,.F.})	
	aAdd( aPergs ,{1,"Ano Orçamentário: "           ,xdAnoRef    ,"@!","NAOVAZIO()",''   ,'.T.', 04,.F.})	
	aAdd( aPergs ,{1,"Usuário Responsável:"         ,xdUserDigt  ,"@!","NAOVAZIO()",'USR','.T.', 06,.F.})	

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)      
		cArquivo    := ParamLoad(cFileName,,1,cArquivo) 
		xdVersao    := ParamLoad(cFileName,,2,xdVersao) 
		xdRevisa    := ParamLoad(cFileName,,3,xdRevisa) 
		xdAnoRef    := ParamLoad(cFileName,,4,xdAnoRef) 
		xdUserDigt  := ParamLoad(cFileName,,5,xdUserDigt) 
	Endif

Return 

//Processa importação
Static Function fProcImport()

	Local aArea 			:= GetArea()
	Local oArquivo 			:= nil
	Local aArquivo 			:= {}
	Local aWorksheet 		:= {}
	Local aCampos			:= {}
	Local cTemp 			:= ''
	Local cTabImp			:= 'Z98'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local aErro				:= {}
	Local cErro 			:= ''
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local M001              := GetNextAlias()
	Local ny
	Local zpt
	Local nx

	Private msrhEnter := CHR(13) + CHR(10)

	// Efetua verificação de Versão e gravação...
	If Empty(xdVersao) .or. Empty(xdRevisa) .or. Empty(xdAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual OBZ" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação igual branco" + msrhEnter
	xfMensCompl += "Data Conciliação igual branco" + msrhEnter
	xfMensCompl += "Data Encerramento igual branco" + msrhEnter

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:xdVersao%
		AND ZB5.ZB5_REVISA = %Exp:xdRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:xdAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'OBZ'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT = ''
		AND ZB5.ZB5_DTCONS = ''
		AND ZB5.ZB5_DTENCR = ''
		AND ZB5.%NotDel%
	EndSql
	(M001)->(dbGoTop())
	If (M001)->CONTAD <> 1
		MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
		(M001)->(dbCloseArea())
		Return .F.
	EndIf	
	(M001)->(dbCloseArea())

	M0007 := " SELECT COUNT(*) CONTAD "
	M0007 += "   FROM " + RetSqlName("Z98") + " Z98 "
	M0007 += "  WHERE Z98.Z98_FILIAL = '" + xFilial("Z98") + "' "
	M0007 += "    AND Z98.Z98_VERSAO = '" + xdVersao + "' "
	M0007 += "    AND Z98.Z98_REVISA = '" + xdRevisa + "' "
	M0007 += "    AND Z98.Z98_ANOREF = '" + xdAnoRef + "' "
	M0007 += "    AND UPPER(Z98.Z98_FILEIN) LIKE UPPER('" + Alltrim(cArquivo) + "') "
	M0007 += "    AND Z98.D_E_L_E_T_ = ' ' "
	MSIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
	dbSelectArea("M007")
	M007->(dbGoTop())

	If M007->CONTAD <> 0

		xkContinua := MsgNOYES("Já existem registros OBZ associados ao arquivo informado." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados existentes." + msrhEnter + msrhEnter+ " Deseja prosseguir com o importação?")

		If xkContinua

			KS001 := " DELETE " + RetSqlName("Z98") + " "
			KS001 += "   FROM " + RetSqlName("Z98") + " Z98 "
			KS001 += "  WHERE Z98.Z98_FILIAL = '" + xFilial("Z98") + "' "
			KS001 += "    AND Z98.Z98_VERSAO = '" + xdVersao + "' "
			KS001 += "    AND Z98.Z98_REVISA = '" + xdRevisa + "' "
			KS001 += "    AND Z98.Z98_ANOREF = '" + xdAnoRef + "' "
			KS001 += "    AND UPPER(Z98.Z98_FILEIN) LIKE UPPER('" + Alltrim(cArquivo) + "') "
			KS001 += "    AND Z98.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Apagando registros Z98... ",,{|| TcSQLExec(KS001) })

		Else

			M007->(dbCloseArea())
			Ferase(MSIndex+GetDBExtension())
			Ferase(MSIndex+OrdBagExt())

			Return .F.

		EndIf

	EndIf

	M007->(dbCloseArea())
	Ferase(MSIndex+GetDBExtension())
	Ferase(MSIndex+OrdBagExt())

	// Inicia leitura do arquivo de importação...
	ProcRegua(0) 

	msTmpINI := Time()
	oArquivo := TBiaArquivo():New()
	aArquivo := oArquivo:GetArquivo(cArquivo)

	msDtProc  := Date()
	msHrProc  := Time()
	msTmpRead := Alltrim(ElapTime(msTmpINI, msHrProc))

	If Len(aArquivo) > 0 

		msTpLin   := Alltrim( Str( ( ( Val( Substr(msTmpRead,1,2)) * 3600 ) + ( Val(Substr(msTmpRead,4,2)) * 360 ) + ( Val(Substr(msTmpRead,7,2)) ) ) / Len(aArquivo[1]) ) )

		aWorksheet 	:= aArquivo[1]	
		nTotLin		:= len(aWorksheet)

		ProcRegua(nTotLin)

		BEGIN TRANSACTION   

			msTotPos := 1
			msVerPos := 1
			msFirstP := .T. 
			For nx := 1 to len(aWorksheet) 

				IncProc("Tmp Leit:(" + msTmpRead + ") Proc: " + StrZero(nx,6) + "/" + StrZero(nTotLin,6) )	

				If nx == 1

					aCampos := aWorksheet[nx]
					For ny := 1 to len(aCampos)
						cTemp := SubStr(UPPER(aCampos[ny]),AT(cTabImp+'_',UPPER(aCampos[ny])),10)
						aCampos[ny] := cTemp
					Next ny

				Else

					aLinha    := aWorksheet[nx]
					aItem     := {}
					cConteudo := ''
					msTotMesO := 0
					msCabecIn := .F.

					SX3->(DbSetOrder(2))

					For ny := 1 to Len(aLinha)

						If Len(aCampos) >= ny 

							cConteudo := aLinha[ny]

							If SX3->(DbSeek(Padr(aCampos[ny],10),.T.))

								If Alltrim(Padr(aCampos[ny],10)) == "Z98_CLVL"
									If Alltrim(cConteudo) == "ClasseValor"
										msCabecIn := .T.
									EndIf
								EndIf

								Do Case

									case SX3->X3_TIPO == "D"
									cConteudo := SubStr(cConteudo,1,10)
									cConteudo := stod(StrTran(cConteudo, "-", ""))

									case SX3->X3_TIPO == "N"
									cConteudo := Val(cConteudo)
									If Alltrim(Padr(aCampos[ny],10)) $ "Z98_M01/Z98_M02/Z98_M03/Z98_M04/Z98_M05/Z98_M06/Z98_M07/Z98_M08/Z98_M09/Z98_M10/Z98_M11/Z98_M12"
										msTotMesO += cConteudo
									EndIf

									case SX3->X3_TIPO == "C"
									cConteudo := Padr(cConteudo,TamSX3(aCampos[ny])[1])

								EndCase

								AADD(aItem,{ aCampos[ny] , cConteudo , nil })

							EndIf

						EndIf

					Next ny

					If len(aItem) > 0

						If !msCabecIn .and. msTotMesO <> 0

							RecLock("Z98", .T.)
							Z98->Z98_FILIAL := xFilial("Z98")
							Z98->Z98_VERSAO := xdVersao
							Z98->Z98_REVISA := xdRevisa
							Z98->Z98_ANOREF := xdAnoRef
							For zpt := 1 to Len(aItem)
								&(aItem[zpt][1]) := aItem[zpt][2]  
							Next zpt
							Z98->Z98_USER   := cUserName
							Z98->Z98_DTPROC := msDtProc
							Z98->Z98_HRPROC := msHrProc
							Z98->Z98_FILEIN := Alltrim(cArquivo)
							Z98->Z98_LINHAA := nx
							Z98->Z98_USRRSP := xdUserDigt
							Z98->Z98_USRRS2 := xdUserDigt
							MsUnlockAll()

							nImport ++

						EndIf

					EndIf

				EndIf

			Next nx

		END TRANSACTION

	EndIf

	If nImport > 0 

		KS006 := " UPDATE " + RetSqlName("Z98") + " SET Z98_TOTAL = Z98_M01 + Z98_M02 + Z98_M03 + Z98_M04 + Z98_M05 + Z98_M06 + Z98_M07 + Z98_M08 + Z98_M09 + Z98_M10 + Z98_M11 + Z98_M12 "
		KS006 += "   FROM " + RetSqlName("Z98") + " Z98 "
		KS006 += "  WHERE Z98.Z98_FILIAL = '" + xFilial("Z98") + "' "
		KS006 += "    AND Z98.Z98_VERSAO = '" + xdVersao + "' "
		KS006 += "    AND Z98.Z98_REVISA = '" + xdRevisa + "' "
		KS006 += "    AND Z98.Z98_ANOREF = '" + xdAnoRef + "' "
		KS006 += "    AND UPPER(Z98.Z98_FILEIN) LIKE UPPER('" + Alltrim(cArquivo) + "') "
		KS006 += "    AND Z98.D_E_L_E_T_ = ' ' "
		U_BIAMsgRun("Aguarde... Atualizando totalizadores Z98... ",,{|| TcSQLExec(KS006) })

		MsgInfo("Registros importados com sucesso")

	Else

		MsgStop("Falha na importação dos registros")

	EndIf

	RestArea(aArea)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B779TRCA ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 25/10/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Troca de Usuário que terá acesso a visualizar os dados     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B779TRCA()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private trVersao        := space(010)
	Private trRevisa        := space(003) 
	Private trAnoRef		:= space(004) 
	Private trUserDigt      := space(006) 
	Private trNovoUser      := space(006) 

	AADD(aSays, OemToAnsi("Rotina para Troca de Usuário Responsável pelo Acompanhamento OBZ Integration!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergTroca() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Troca de Usuário'), aSays, aButtons ,,,500)

	If lConfirm

		Processa({ || fProcTroca() },"Aguarde...","Carregando Arquivo...",.F.)

	Else

		MsgStop('Processo Abortado!!!')

	EndIf

Return

//Parametros
Static Function fPergTroca()

	Local aPergs 	:= {}
	Local cLoad	    := 'B779TRCA' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	trVersao        := space(010)
	trRevisa        := space(003) 
	trAnoRef		:= space(004) 
	trUserDigt      := space(006)
	trNovoUser      := space(006)

	aAdd( aPergs ,{1,"Versão:"                      ,trVersao    ,"@!","NAOVAZIO()",'ZB5','.T.',070,.F.})	
	aAdd( aPergs ,{1,"Revisão:"                     ,trRevisa    ,"@!","NAOVAZIO()",''   ,'.T.', 03,.F.})	
	aAdd( aPergs ,{1,"Ano Orçamentário: "           ,trAnoRef    ,"@!","NAOVAZIO()",''   ,'.T.', 04,.F.})	
	aAdd( aPergs ,{1,"Usuário Responsável:"         ,trUserDigt  ,"@!","NAOVAZIO()",'USR','.T.', 06,.F.})	
	aAdd( aPergs ,{1,"Novo Usuário Responsável:"    ,trNovoUser  ,"@!","NAOVAZIO()",'USR','.T.', 06,.F.})	

	If ParamBox(aPergs ,"Troca Responsável",,,,,,,,cLoad,.T.,.T.)      
		trVersao    := ParamLoad(cFileName,,1,trVersao) 
		trRevisa    := ParamLoad(cFileName,,2,trRevisa) 
		trAnoRef    := ParamLoad(cFileName,,3,trAnoRef) 
		trUserDigt  := ParamLoad(cFileName,,4,trUserDigt) 
		trNovoUser  := ParamLoad(cFileName,,5,trNovoUser) 
	Endif

Return 

//Processa Troca de Responsável
Static Function fProcTroca()

	Local trrhEnter := CHR(13) + CHR(10)

	VC002 := " SELECT COUNT(*) CONTAD "
	VC002 += "   FROM " + RetSqlName("Z98") + " Z98 "
	VC002 += "  WHERE Z98.Z98_FILIAL = '" + xFilial("Z98") + "' "
	VC002 += "    AND Z98.Z98_VERSAO = '" + trVersao + "' "
	VC002 += "    AND Z98.Z98_REVISA = '" + trRevisa + "' "
	VC002 += "    AND Z98.Z98_ANOREF = '" + trAnoRef + "' "
	VC002 += "    AND Z98_USRRS2 = '" + trUserDigt + "' "
	VC002 += "    AND Z98.D_E_L_E_T_ = ' ' "
	VCIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,VC002),'VC02',.T.,.T.)
	dbSelectArea("VC02")
	VC02->(dbGoTop())

	If VC02->CONTAD <> 0

		trContinua := MsgNOYES("Já existem registros OBZ associados ao usuário responsável mencionado." + trrhEnter + trrhEnter + " São " + Alltrim(Str(VC02->CONTAD)) + " registros." + trrhEnter + trrhEnter+ " Deseja prosseguir com o TROCA de usuário RESPONSÁVEL???")

		If trContinua

			KS001 := " UPDATE " + RetSqlName("Z98") + " SET Z98_USRRS2 = '" + trNovoUser + "' "
			KS001 += "   FROM " + RetSqlName("Z98") + " Z98 "
			KS001 += "  WHERE Z98.Z98_FILIAL = '" + xFilial("Z98") + "' "
			KS001 += "    AND Z98.Z98_VERSAO = '" + trVersao + "' "
			KS001 += "    AND Z98.Z98_REVISA = '" + trRevisa + "' "
			KS001 += "    AND Z98.Z98_ANOREF = '" + trAnoRef + "' "
			KS001 += "    AND Z98_USRRS2 = '" + trUserDigt + "' "
			KS001 += "    AND Z98.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Trocando usuário responsável Z98... ",,{|| TcSQLExec(KS001) })

		Else

			VC02->(dbCloseArea())
			Ferase(VCIndex+GetDBExtension())
			Ferase(VCIndex+OrdBagExt())
			Return .F.

		EndIf


	Else

		MsgALERT("Nenhum registro afetado. Usuário responsável não localizado!!!")

		VC02->(dbCloseArea())
		Ferase(VCIndex+GetDBExtension())
		Ferase(VCIndex+OrdBagExt())
		Return .F.

	EndIf

	VC02->(dbCloseArea())
	Ferase(VCIndex+GetDBExtension())
	Ferase(VCIndex+OrdBagExt())

	MsgINFO("Troca de responsável realizada com sucesso!!!")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B779CFDG ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 27/10/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Lista divergência encontrada após importação planilhas OBZ ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B779CFDG()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cfVersao        := space(010)
	Private cfRevisa        := space(003) 
	Private cfAnoRef		:= space(004) 

	AADD(aSays, OemToAnsi("Rotina para listar divergência encontrada após importação planilhas OBZ!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergCfDgt() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Conferência Integridade OBZ Integration'), aSays, aButtons ,,,500)

	If lConfirm

		Processa({ || fProcConfer() },"Aguarde...","Carregando Arquivo...",.F.)

		MsgINFO('Processamento concluído!')

	Else

		MsgStop('Processo Abortado!')

	EndIf

Return

//Parametros
Static Function fPergCfDgt()

	Local aPergs 	:= {}
	Local cLoad	    := 'B779CFDG' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cfVersao        := space(010)
	cfRevisa        := space(003) 
	cfAnoRef		:= space(004) 

	aAdd( aPergs ,{1,"Versão:"                      ,cfVersao    ,"@!","NAOVAZIO()",'ZB5','.T.',070,.F.})	
	aAdd( aPergs ,{1,"Revisão:"                     ,cfRevisa    ,"@!","NAOVAZIO()",''   ,'.T.', 03,.F.})	
	aAdd( aPergs ,{1,"Ano Orçamentário: "           ,cfAnoRef    ,"@!","NAOVAZIO()",''   ,'.T.', 04,.F.})	

	If ParamBox(aPergs ,"Conferência dados OBZ",,,,,,,,cLoad,.T.,.T.)      
		cfVersao    := ParamLoad(cFileName,,1,cfVersao) 
		cfRevisa    := ParamLoad(cFileName,,2,cfRevisa) 
		cfAnoRef    := ParamLoad(cFileName,,3,cfAnoRef) 
	Endif

Return 

//Processa listagem para conferência
Static Function fProcConfer()

	Local _cAlias   := GetNextAlias()
	Local nRegAtu   := 0
	Local _daduser
	Local _mNomeUsr

	local cCab1Fon   := 'Calibri' 
	local cCab1TamF  := 8   
	local cCab1CorF  := '#FFFFFF'
	local cCab1Fun   := '#4F81BD'

	local cFonte1	 := 'Arial'
	local nTamFont1	 := 12   
	local cCorFont1  := '#FFFFFF'
	local cCorFun1	 := '#4F81BD'

	local cFonte2	 := 'Arial'
	local nTamFont2	 := 8   
	local cCorFont2  := '#000000'
	local cCorFun2	 := '#B8CCE4'
	Local nConsumo	 :=	0

	local cEmpresa   := CapitalAce(SM0->M0_NOMECOM)

	local cArqXML    := UPPER(Alltrim(FunName())) + "_" + ALLTrim( DTOS(DATE()) + "_" + StrTran( time(),':',''))
	private cDirDest := "c:\temp\"

	oExcel := ARSexcel():New()

	ProcRegua(100000)

	oExcel:AddPlanilha("Relatorio", {20, 70, 70, 70, 70, 150, 50, 150, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 300, 60, 60, 60}, 6)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2, (1 + 23 + 1) - 3 ) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2, (1 + 23 + 1) - 3 ) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Orçamento - OBZ", 0, 'L', cFonte1, nTamFont1, cCorFont1, .T., , cCorFun1, , , , , .T., 2, (1 + 23 + 1) - 3 )  

	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	oExcel:AddCelula("Versão"          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Revisão"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Ano.Ref"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Classe Valor"    , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Descr.CLVL"      , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Empresa"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Conta"           , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Descr.Cta"       , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Janeiro"         , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Fevereiro"       , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Março"           , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Abril"           , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Maio"            , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Junho"           , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Julho"           , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Agosto"          , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Setembro"        , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Outubro"         , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Novembro"        , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Dezembro"        , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Arquivo Imp"     , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("LinhaArq"        , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("UsrRespon"       , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("NomeUsrResp"     , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)

	KV005 := " WITH OBZINTEG AS (SELECT Z98_VERSAO, "
	KV005 += "                          Z98_REVISA, "
	KV005 += "                          Z98_ANOREF, "
	KV005 += "                          Z98_CLVL, "
	KV005 += "                          ISNULL(CTH_DESC01, 'ERRO DIGITACAO') CTH_DESC01, "
	KV005 += "                          ISNULL(SUBSTRING(CTH_YEMPFL,1,2), 'ER') CTH_YEMPFL, "
	KV005 += "                          Z98_CONTA, "
	KV005 += "                          ISNULL(CT1_DESC01, 'ERRO DIGITACAO') CT1_DESC01, "
	KV005 += "                          ISNULL(CT1_NORMAL, 'E') CT1_NORMAL,
	KV005 += "                          CASE
	KV005 += "                            WHEN CT1_NORMAL = '1' THEN 'DEBITO'
	KV005 += "                            WHEN CT1_NORMAL = '2' THEN 'CREDIT'
	KV005 += "                            ELSE 'ERROR'
	KV005 += "                          END NORMAL,
	KV005 += "                          Z98_M01, "
	KV005 += "                          Z98_M02, "
	KV005 += "                          Z98_M03, "
	KV005 += "                          Z98_M04, "
	KV005 += "                          Z98_M05, "
	KV005 += "                          Z98_M06, "
	KV005 += "                          Z98_M07, "
	KV005 += "                          Z98_M08, "
	KV005 += "                          Z98_M09, "
	KV005 += "                          Z98_M10, "
	KV005 += "                          Z98_M11, "
	KV005 += "                          Z98_M12, "
	KV005 += "                          Z98_FILEIN, "
	KV005 += "                          Z98_LINHAA, "
	KV005 += "                          Z98_USRRSP "
	KV005 += "                     FROM " + RetSqlName("Z98") + " Z98 "
	KV005 += "                     LEFT JOIN " + RetSqlName("CT1") + " CT1 ON CT1_CONTA = Z98_CONTA "
	KV005 += "                                         AND CT1.D_E_L_E_T_ = ' ' "
	KV005 += "                     LEFT JOIN " + RetSqlName("CTH") + " CTH ON CTH_CLVL = Z98_CLVL "
	KV005 += "                                         AND CTH.D_E_L_E_T_ = ' ' "
	KV005 += "                    WHERE Z98.Z98_FILIAL = '" + xFilial("Z98") + "' "
	KV005 += "                      AND Z98.Z98_VERSAO = '" + cfVersao + "' "
	KV005 += "                      AND Z98.Z98_REVISA = '" + cfRevisa + "' "
	KV005 += "                      AND Z98.Z98_ANOREF = '" + cfAnoRef + "' "
	KV005 += "                      AND Z98.D_E_L_E_T_ = ' ') "
	KV005 += " SELECT * "
	KV005 += "   FROM OBZINTEG "
	KV005 += "  WHERE CT1_NORMAL = 'E' OR CTH_YEMPFL = 'ER' "
	KV005 += "  ORDER BY Z98_CLVL, Z98_CONTA "
	KVIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,KV005),'KV05',.T.,.T.)
	dbSelectArea("KV05")
	KV05->(dbGoTop())

	If KV05->(!Eof())

		While KV05->(!Eof())

			IncProc("Carregando dados " + AllTrim(Str(KV05->(Recno()))) )

			psworder(1)                          // Pesquisa por Nome
			If  pswseek(KV05->Z98_USRRSP,.t.)    // Nome do usuario, Pesquisa usuarios
				_daduser  := pswret(1)           // Numero do registro
				_mNomeUsr := _daduser[1][4]
			EndIf
			nRegAtu++
			if MOD(nRegAtu,2) > 0 
				cCorFun2 := '#DCE6F1'
			else
				cCorFun2 := '#B8CCE4'
			endif

			oExcel:AddLinha(14) 
			oExcel:AddCelula()
			oExcel:AddCelula( KV05->Z98_VERSAO                            , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->Z98_REVISA                            , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->Z98_ANOREF                            , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->Z98_CLVL                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->CTH_DESC01                            , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->CTH_YEMPFL                            , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->Z98_CONTA                             , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->CT1_DESC01                            , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->Z98_M01                               , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->Z98_M02                               , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->Z98_M03                               , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->Z98_M04                               , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->Z98_M05                               , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->Z98_M06                               , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->Z98_M07                               , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->Z98_M08                               , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->Z98_M09                               , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->Z98_M10                               , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->Z98_M11                               , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->Z98_M12                               , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->Z98_FILEIN                            , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->Z98_LINHAA                            , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->Z98_USRRSP                            , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( _mNomeUsr                                   , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			KV05->(dbSkip())

		EndDo

	EndIf

	KV05->(dbCloseArea())
	Ferase(KVIndex+GetDBExtension())
	Ferase(KVIndex+OrdBagExt())

	oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.) 

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B779IMDD ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 30/10/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Gera Integração com modelo de Despesas                     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B779IMDD()

	Local M001          := GetNextAlias()
	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private idVersao    := space(010)
	Private idRevisa    := space(003) 
	Private idAnoRef    := space(004) 
	Private msrhEnter   := CHR(13) + CHR(10)
	Private xkContinua  := .T.

	AADD(aSays, OemToAnsi("Rotina para Geração de Integração dos registros OBZ com Modelo de Despesas!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergIntMD() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Integração OBZ vs DESPESAS'), aSays, aButtons ,,,500)

	If lConfirm

		xfMensCompl := ""
		xfMensCompl += "Tipo Orçamento igual OBZ" + msrhEnter
		xfMensCompl += "Status igual Aberto" + msrhEnter
		xfMensCompl += "Data Digitação diferente branco" + msrhEnter
		xfMensCompl += "Data Conciliação diferente branco" + msrhEnter
		xfMensCompl += "Data Encerramento diferente de branco e menor ou igual a database" + msrhEnter

		BeginSql Alias M001
			SELECT COUNT(*) CONTAD
			FROM %TABLE:ZB5% ZB5
			WHERE ZB5_FILIAL = %xFilial:ZB5%
			AND ZB5.ZB5_VERSAO = %Exp:idVersao%
			AND ZB5.ZB5_REVISA = %Exp:idRevisa%
			AND ZB5.ZB5_ANOREF = %Exp:idAnoRef%
			AND RTRIM(ZB5.ZB5_TPORCT) = 'OBZ'
			AND ZB5.ZB5_STATUS = 'A'
			AND ZB5.ZB5_DTDIGT <> ''
			AND ZB5.ZB5_DTCONS <> ''
			AND ZB5.ZB5_DTENCR <> ''
			AND ZB5.ZB5_DTENCR <= %Exp:dtos(Date())%
			AND ZB5.%NotDel%
		EndSql
		(M001)->(dbGoTop())
		If (M001)->CONTAD <> 1
			MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
			(M001)->(dbCloseArea())
			Return .F.
		EndIf	
		(M001)->(dbCloseArea())

		M0007 := " SELECT COUNT(*) CONTAD "
		M0007 += "   FROM " + RetSqlName("ZBZ") + " ZBZ "
		M0007 += "  WHERE ZBZ.ZBZ_FILIAL = '" + xFilial("ZBZ") + "' "
		M0007 += "    AND ZBZ.ZBZ_VERSAO = '" + idVersao + "' "
		M0007 += "    AND ZBZ.ZBZ_REVISA = '" + idRevisa + "' "
		M0007 += "    AND ZBZ.ZBZ_ANOREF = '" + idAnoRef + "' "
		M0007 += "    AND ZBZ.ZBZ_ORIPRC = 'OBZ' "
		M0007 += "    AND ZBZ.D_E_L_E_T_ = ' ' "
		MSIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
		dbSelectArea("M007")
		M007->(dbGoTop())

		If M007->CONTAD <> 0

			xkContinua := MsgNOYES("Já existe base contábel orçamentária para a Versão / Revisão / AnoRef informados." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados gravados." + msrhEnter + msrhEnter+ " Deseja prosseguir com o reprocessamento!!!")

		EndIf

		M007->(dbCloseArea())
		Ferase(MSIndex+GetDBExtension())
		Ferase(MSIndex+OrdBagExt())

		If xkContinua

			Processa({ || cMsg := fProcIntMD() },"Aguarde...","Carregando Arquivo...",.F.)

		EndIf

	Else

		MsgStop('Processo Abortado!!!')

	EndIf

Return

//Parametros
Static Function fPergIntMD()

	Local aPergs 	:= {}
	Local cLoad	    := 'B779IMDD' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	idVersao        := space(010)
	idRevisa        := space(003) 
	idAnoRef		:= space(004) 

	aAdd( aPergs ,{1,"Versão:"                      ,idVersao    ,"@!","NAOVAZIO()",'ZB5','.T.',070,.F.})	
	aAdd( aPergs ,{1,"Revisão:"                     ,idRevisa    ,"@!","NAOVAZIO()",''   ,'.T.', 03,.F.})	
	aAdd( aPergs ,{1,"Ano Orçamentário: "           ,idAnoRef    ,"@!","NAOVAZIO()",''   ,'.T.', 04,.F.})	

	If ParamBox(aPergs ,"Integração OBZ p/ DESPESAS",,,,,,,,cLoad,.T.,.T.)      
		idVersao    := ParamLoad(cFileName,,1,idVersao) 
		idRevisa    := ParamLoad(cFileName,,2,idRevisa) 
		idAnoRef    := ParamLoad(cFileName,,3,idAnoRef) 
	Endif

Return 

//Processa Troca de Responsável
Static Function fProcIntMD()

	Local trrhEnter := CHR(13) + CHR(10)
	Local lvxt

	SL008 := " WITH OBZINTEG AS (SELECT ISNULL(SUBSTRING(CTH_YEMPFL,1,2), 'ER') EMPR "
	SL008 += "                     FROM " + RetSqlName("Z98") + " Z98 "
	SL008 += "                     LEFT JOIN " + RetSqlName("CT1") + " CT1 ON CT1_CONTA = Z98_CONTA "
	SL008 += "                                         AND CT1.D_E_L_E_T_ = ' ' "
	SL008 += "                     LEFT JOIN " + RetSqlName("CTH") + " CTH ON CTH_CLVL = Z98_CLVL "
	SL008 += "                                         AND CTH.D_E_L_E_T_ = ' ' "
	SL008 += "                    WHERE Z98.Z98_FILIAL = '" + xFilial("Z98") + "' "
	SL008 += "                      AND Z98.Z98_VERSAO = '" + idVersao + "' "
	SL008 += "                      AND Z98.Z98_REVISA = '" + idRevisa + "' "
	SL008 += "                      AND Z98.Z98_ANOREF = '" + idAnoRef + "' "
	SL008 += "                      AND SUBSTRING(Z98.Z98_CONTA,1,3) <> '165' "
	SL008 += "                      AND Z98.D_E_L_E_T_ = ' ' "
	SL008 += "                    GROUP BY SUBSTRING(CTH_YEMPFL,1,2), "
	SL008 += "                             Z98_VERSAO, "
	SL008 += "                             Z98_REVISA, "
	SL008 += "                             Z98_ANOREF) "
	SL008 += " SELECT * "
	SL008 += "   FROM OBZINTEG "
	SL008 += "  ORDER BY EMPR "
	SLIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,SL008),'SL08',.T.,.T.)
	dbSelectArea("SL08")
	SL08->(dbGoTop())
	ProcRegua(LASTREC())
	If SL08->(!Eof())

		While SL08->(!Eof())

			ksEmpres := SL08->EMPR
			While SL08->(!Eof()) .and. SL08->EMPR == ksEmpres  

				KS001 := " DELETE ZBZ" + ksEmpres + "0 "
				KS001 += "   FROM ZBZ" + ksEmpres + "0 ZBZ "
				KS001 += "  WHERE ZBZ.ZBZ_VERSAO = '" + idVersao + "' "
				KS001 += "    AND ZBZ.ZBZ_REVISA = '" + idRevisa + "' "
				KS001 += "    AND ZBZ.ZBZ_ANOREF = '" + idAnoRef + "' "
				KS001 += "    AND ZBZ.ZBZ_ORIPRC = 'OBZ' "
				KS001 += "    AND ZBZ.D_E_L_E_T_ = ' ' "
				U_BIAMsgRun("Aguarde... Apagando registros ZBZ... ",,{|| TcSQLExec(KS001) })

				For lvxt := 1 to 12

					IncProc("Empresa: " + ksEmpres + ", " + AllTrim(Str(lvxt)) )

					LvDtRef := dtos( UltimoDia( stod( idAnoRef + StrZero(lvxt,2) + "01" ) ) )

					LV007 := " WITH OBZINTEG AS (SELECT Z98_VERSAO, "
					LV007 += "                          Z98_REVISA, "
					LV007 += "                          Z98_ANOREF, "
					LV007 += "                          Z98_CLVL, "
					LV007 += "                          ISNULL(SUBSTRING(CTH_YEMPFL,1,2), 'ER') EMPR, "
					LV007 += "                          Z98_CONTA, "
					LV007 += "                          ISNULL(CT1_NORMAL, 'E') CT1_NORMAL, "
					LV007 += "                          SUM(Z98_M" + StrZero(lvxt,2) + ") MESREF
					LV007 += "                     FROM " + RetSqlName("Z98") + " Z98 "
					LV007 += "                     LEFT JOIN " + RetSqlName("CT1") + " CT1 ON CT1_CONTA = Z98_CONTA "
					LV007 += "                                         AND CT1.D_E_L_E_T_ = ' ' "
					LV007 += "                     LEFT JOIN " + RetSqlName("CTH") + " CTH ON CTH_CLVL = Z98_CLVL "
					LV007 += "                                         AND CTH.D_E_L_E_T_ = ' ' "
					LV007 += "                    WHERE Z98.Z98_FILIAL = '" + xFilial("Z98") + "' "
					LV007 += "                      AND Z98.Z98_VERSAO = '" + idVersao + "' "
					LV007 += "                      AND Z98.Z98_REVISA = '" + idRevisa + "' "
					LV007 += "                      AND Z98.Z98_ANOREF = '" + idAnoRef + "' "
					LV007 += "                      AND SUBSTRING(Z98.Z98_CONTA,1,3) <> '165' "
					LV007 += "                      AND Z98.D_E_L_E_T_ = ' ' "
					LV007 += "                    GROUP BY SUBSTRING(CTH_YEMPFL,1,2), "
					LV007 += "                             Z98_VERSAO, "
					LV007 += "                             Z98_REVISA, "
					LV007 += "                             Z98_ANOREF, "
					LV007 += "                             Z98_CLVL, "
					LV007 += "                             Z98_CONTA, "
					LV007 += "                             CT1_NORMAL) "
					LV007 += " INSERT INTO ZBZ" + ksEmpres + "0 "
					LV007 += " (ZBZ_FILIAL, "
					LV007 += "  ZBZ_VERSAO, "
					LV007 += "  ZBZ_REVISA, "
					LV007 += "  ZBZ_ANOREF, "
					LV007 += "  ZBZ_ORIPRC, "
					LV007 += "  ZBZ_ORGLAN, "
					LV007 += "  ZBZ_DATA, "
					LV007 += "  ZBZ_LOTE, "
					LV007 += "  ZBZ_SBLOTE, "
					LV007 += "  ZBZ_DOC, "
					LV007 += "  ZBZ_LINHA, "
					LV007 += "  ZBZ_DC, "
					LV007 += "  ZBZ_DEBITO, "
					LV007 += "  ZBZ_CREDIT, "
					LV007 += "  ZBZ_CLVLDB, "
					LV007 += "  ZBZ_CLVLCR, "
					LV007 += "  ZBZ_ITEMD, "
					LV007 += "  ZBZ_ITEMC, "
					LV007 += "  ZBZ_VALOR, "
					LV007 += "  ZBZ_HIST, "
					LV007 += "  ZBZ_YHIST, "
					LV007 += "  ZBZ_SI, "
					LV007 += "  ZBZ_YDELTA, "
					LV007 += "  D_E_L_E_T_, "
					LV007 += "  R_E_C_N_O_, "
					LV007 += "  R_E_C_D_E_L_) "
					LV007 += " SELECT '01' ZBZ_FILIAL, "
					LV007 += "        Z98_VERSAO, "
					LV007 += "        Z98_REVISA, "
					LV007 += "        Z98_ANOREF, "
					LV007 += "        'OBZ' ZBZ_ORIPRC, "
					LV007 += "        CASE "
					LV007 += "          WHEN CT1_NORMAL = '1' THEN 'D' "
					LV007 += "          WHEN CT1_NORMAL = '2' THEN 'C' "
					LV007 += "          ELSE 'E' "
					LV007 += "        END ZBZ_ORGLAN, "
					LV007 += "        '" + LvDtRef + "' ZBZ_DATA, "
					LV007 += "        '004500'ZBZ_LOTE, "
					LV007 += "        '001' ZBZ_SBLOTE, "
					LV007 += "        '' ZBZ_DOC, "
					LV007 += "        '' ZBZ_LINHA, "
					LV007 += "        CT1_NORMAL ZBZ_DC, "
					LV007 += "        CASE "
					LV007 += "          WHEN CT1_NORMAL = '1' THEN Z98_CONTA "
					LV007 += "          WHEN CT1_NORMAL = '2' THEN '' "
					LV007 += "          ELSE '' "
					LV007 += "        END ZBZ_DEBITO, "
					LV007 += "        CASE "
					LV007 += "          WHEN CT1_NORMAL = '1' THEN '' "
					LV007 += "          WHEN CT1_NORMAL = '2' THEN Z98_CONTA "
					LV007 += "          ELSE '' "
					LV007 += "        END ZBZ_CREDIT, "
					LV007 += "        CASE "
					LV007 += "          WHEN CT1_NORMAL = '1' THEN Z98_CLVL "
					LV007 += "          WHEN CT1_NORMAL = '2' THEN '' "
					LV007 += "          ELSE '' "
					LV007 += "        END ZBZ_CLVLDB, "
					LV007 += "        CASE "
					LV007 += "          WHEN CT1_NORMAL = '1' THEN '' "
					LV007 += "          WHEN CT1_NORMAL = '2' THEN Z98_CLVL "
					LV007 += "          ELSE '' "
					LV007 += "        END ZBZ_CLVLCR, "
					LV007 += "        ' ' ZBZ_ITEMD, "
					LV007 += "        ' ' ZBZ_ITEMC, "
					LV007 += "        MESREF ZBZ_VALOR, "
					LV007 += "        'ORCTO OBZ' ZBZ_HIST, "
					LV007 += "        'ORCAMENTO OBZ' ZBZ_YHIST, "
					LV007 += "        '' ZBZ_SI, "
					LV007 += "        '' ZBZ_YDELTA, "
					LV007 += "        ' ' D_E_L_E_T_, "
					LV007 += "        (SELECT ISNULL(MAX(R_E_C_N_O_),0) FROM ZBZ" + ksEmpres + "0) + ROW_NUMBER() OVER(ORDER BY OBZI.Z98_CLVL, OBZI.Z98_CONTA) AS R_E_C_N_O_, "
					LV007 += "        0 R_E_C_D_E_L_ "
					LV007 += "   FROM OBZINTEG OBZI "
					LV007 += "  WHERE NOT ( CT1_NORMAL = 'E' OR EMPR = 'ER' ) "
					LV007 += "    AND MESREF <> 0 "
					LV007 += "    AND EMPR = '" + ksEmpres + "' "
					U_BIAMsgRun("Aguarde... Convertendo OBZ em DEPESAS... ",,{|| TcSQLExec(LV007) })

				Next lvxt

				SL08->(dbSkip())

			EndDo

		EndDo

	EndIf	

	SL08->(dbCloseArea())
	Ferase(SLIndex+GetDBExtension())
	Ferase(SLIndex+OrdBagExt())

	MsgINFO("Conversão OBZ em DESPESAS realizada com sucesso!!!")

Return
