#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA778
@author Marcos Alberto Soprani
@since 13/06/17
@version 1.0
@description Browser principal para a rotina de RECEITA Integration p/ Orçamento de Receita 
@type function
/*/

User Function BIA778()

	Local aArea     := GetArea()
	Local cCondicao := ""

	Private cCadastro 	:= "RECEITA Integration"
	Private aRotina 	:= { {"Pesquisar"  			,"AxPesqui"     ,0,1},;
	{                         "Visualizar"			,"AxVisual"     ,0,2},;
	{                         "Importa Orçamento"	,"U_B778IEXC"   ,0,3} }

	dbSelectArea("ZBH")
	dbSetOrder(1)

	mBrowse(6,1,22,75,"ZBH",,,,,,)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B778IEXC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 13/06/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Importação planilha Excel para Orçamento - RECEITA         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B778IEXC()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)
	Private xdVersao    := space(010)
	Private xdRevisa    := space(003) 
	Private xdAnoRef	:= space(004) 
	Private xdMarca     := space(004) 

	AADD(aSays, OemToAnsi("Rotina para importação da Planilha RECEITA Integration p/ Orçamento RECEITA!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi("IMPORTANTE: o nome do arquivo não pode ter espaço em branco nem caractes"))   
	AADD(aSays, OemToAnsi("            especiais!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação de RECEITA'), aSays, aButtons ,,,500)

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
	Local cLoad	    := 'B778IEXC' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo		:= space(100) 
	xdVersao        := space(010)
	xdRevisa        := space(003) 
	xdAnoRef		:= space(004) 
	xdUserDigt      := space(006)
	xdMarca         := space(004)

	aAdd( aPergs ,{6,"Arquivo para Importação: " 	,cArquivo  ,"","","", 75 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )		
	aAdd( aPergs ,{1,"Versão:"                      ,xdVersao    ,"@!","NAOVAZIO()",'ZB5','.T.',070,.F.})	
	aAdd( aPergs ,{1,"Revisão:"                     ,xdRevisa    ,"@!","NAOVAZIO()",''   ,'.T.', 03,.F.})	
	aAdd( aPergs ,{1,"Ano Orçamentário: "           ,xdAnoRef    ,"@!","NAOVAZIO()",''   ,'.T.', 04,.F.})	
	aAdd( aPergs ,{1,"Importa Marca Específica: "   ,xdMarca     ,"@!","NAOVAZIO()",'Z37','.T.', 04,.F.})	

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)      
		cArquivo  := ParamLoad(cFileName,,1,cArquivo) 
		xdVersao  := ParamLoad(cFileName,,2,xdVersao) 
		xdRevisa  := ParamLoad(cFileName,,3,xdRevisa) 
		xdAnoRef  := ParamLoad(cFileName,,4,xdAnoRef)
		xdMarca   := ParamLoad(cFileName,,5,xdMarca) 
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
	Local cTabImp			:= 'ZBH'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local aErro				:= {}
	Local cErro 			:= ''
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local M001              := GetNextAlias()
	Local ny, zpt, nx

	Private msrhEnter       := CHR(13) + CHR(10)

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual RECEITA" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação igual a branco" + msrhEnter
	xfMensCompl += "Data Conciliação igual a branco" + msrhEnter
	xfMensCompl += "Data Encerramento igual a branco" + msrhEnter

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:xdVersao%
		AND ZB5.ZB5_REVISA = %Exp:xdRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:xdAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'RECEITA'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT = ''
		AND ZB5.ZB5_DTCONS = ''
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

	msExisReg := .F.
	msMarcaIn := "Marcas: " + msrhEnter
	M0007 := " SELECT ZBH_MARCA, COUNT(*) CONTAD "
	M0007 += "   FROM " + RetSqlName("ZBH") + " ZBH "
	M0007 += "  WHERE ZBH.ZBH_FILIAL = '" + xFilial("ZBH") + "' "
	M0007 += "    AND ZBH.ZBH_VERSAO = '" + xdVersao + "' "
	M0007 += "    AND ZBH.ZBH_REVISA = '" + xdRevisa + "' "
	M0007 += "    AND ZBH.ZBH_ANOREF = '" + xdAnoRef + "' "
	M0007 += "    AND ZBH.ZBH_PERIOD = '00' "
	M0007 += "    AND ZBH.ZBH_ORIGF = '1' "
	If !Empty(xdMarca)
		M0007 += "    AND ZBH.ZBH_MARCA = '" + xdMarca + "' "
	EndIf
	M0007 += "    AND ZBH.D_E_L_E_T_ = ' ' "
	M0007 += "  GROUP BY ZBH_MARCA "
	MSIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
	dbSelectArea("M007")
	M007->(dbGoTop())

	While !M007->(Eof())

		msMarcaIn += M007->ZBH_MARCA + msrhEnter
		msExisReg := .T.

		M007->(dbSkip())

	End

	M007->(dbCloseArea())
	Ferase(MSIndex+GetDBExtension())
	Ferase(MSIndex+OrdBagExt())

	If msExisReg

		xkContinua := MsgNOYES("Já existem registros relacionados à Versão / Revisão / AnoRef informados." + msrhEnter + msrhEnter + msMarcaIn + msrhEnter + msrhEnter + "Caso deseje zerar os dados já importados, clique Sim; do contrário, Não e o sistema irá importar sem apagar nenhum registros." + msrhEnter + msrhEnter+ "Escolha uma das Opções!!!")

		If xkContinua

			KS001 := " DELETE " + RetSqlName("ZBH") + " "
			KS001 += "   FROM " + RetSqlName("ZBH") + " ZBH "
			KS001 += "  WHERE ZBH.ZBH_FILIAL = '" + xFilial("ZBH") + "' "
			KS001 += "    AND ZBH.ZBH_VERSAO = '" + xdVersao + "' "
			KS001 += "    AND ZBH.ZBH_REVISA = '" + xdRevisa + "' "
			KS001 += "    AND ZBH.ZBH_ANOREF = '" + xdAnoRef + "' "
			KS001 += "    AND ZBH.ZBH_ORIGF = '1' "
			If !Empty(xdMarca)
				KS001 += "    AND ZBH.ZBH_MARCA = '" + xdMarca + "' "
			EndIf
			KS001 += "    AND ZBH.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Apagando registros ZBH... ",,{|| TcSQLExec(KS001) })

		Else

			xk2Contin := MsgNOYES("Você escolheu não zerar os dados importados." + msrhEnter + msrhEnter + "Agora clique em Sim para continuar com a importação ou Não para cancelar." + msrhEnter + msrhEnter + "Deseja prosseguir?")
			If !xk2Contin
				Return .F.
			EndIf

		EndIf

	EndIf

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
					msQtdCtrl := 0

					SX3->(DbSetOrder(2))

					For ny := 1 to Len(aLinha)

						If Len(aCampos) >= ny 

							cConteudo := aLinha[ny]

							If SX3->(DbSeek(Padr(aCampos[ny],10),.T.))

								Do Case

									case SX3->X3_TIPO == "D"
									cConteudo := SubStr(cConteudo,1,10)
									cConteudo := stod(StrTran(cConteudo, "-", ""))

									case SX3->X3_TIPO == "N"
									cConteudo := Val(cConteudo)
									If Upper(Alltrim(aCampos[ny])) == "ZBH_QUANT"
										msQtdCtrl += cConteudo
									EndIf

									case SX3->X3_TIPO == "C"
									cConteudo := Padr(cConteudo,TamSX3(aCampos[ny])[1])

								EndCase

								AADD(aItem,{ aCampos[ny] , cConteudo , nil })

							EndIf

						EndIf

					Next ny	

					If len(aItem) > 0

						If msQtdCtrl <> 0

							RecLock("ZBH", .T.)
							ZBH->ZBH_FILIAL := xFilial("ZBH")
							ZBH->ZBH_VERSAO := xdVersao
							ZBH->ZBH_REVISA := xdRevisa
							ZBH->ZBH_ANOREF := xdAnoRef
							ZBH->ZBH_PERIOD := '00'
							For zpt := 1 to Len(aItem)
								&(aItem[zpt][1]) := aItem[zpt][2]  
							Next zpt
							ZBH->ZBH_USER   := __cUserId
							ZBH->ZBH_DTPROC := msDtProc
							ZBH->ZBH_HRPROC := msHrProc
							ZBH->ZBH_ORIGF  := "1"
							ZBH->ZBH_FILEIN := cArquivo
							ZBH->ZBH_LINHAA := nx
							MsUnlockAll()

							nImport ++

						EndIf

					EndIf

				EndIf

			Next nx

		END TRANSACTION

	EndIf

	If nImport > 0 

		MsgInfo("Registros importados com sucesso")

	Else

		MsgStop("Falha na importação dos registros")

	EndIf

	RestArea(aArea)

Return
