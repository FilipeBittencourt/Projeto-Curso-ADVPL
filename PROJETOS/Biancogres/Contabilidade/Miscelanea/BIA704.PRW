#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA704
@author Marcos Alberto Soprani
@since 09/07/21
@version 1.0
@description Controle de Fechamento e Abertura de Período por Impostos
@type function
@Obs Projeto A-59 - Gestão Matricial de Tributos
/*/

User Function BIA704()

	Private xkOpcao

	If ValidPerg()

		xkOpcao := MV_PAR01

		If xkOpcao == "1"       // Fechamento

			U_BIA704F()

		ElseIf xkOpcao == "2"   // Abertura

			U_BIA704A()

		ElseIf xkOpcao == "3"   // Consulta

			U_BIA704C()

		Else

			MsgALERT("Opção Indisponível. Processamento Abortado", "Atenção!!!")


		EndIf


	Else

		MsgALERT("Processamento Abortado", "Atenção!!!")

	EndIf

Return

Static Function ValidPerg()

	local cLoad	    := "BIA704" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 :=	"0"

	aAdd(aPergs, {2, "Escolha uma Opção:",  MV_PAR01, {"1=Fechamento", "2=Abertura", "3=Consulta"},   090, ".T.", .F.})

	If ParamBox(aPergs ,"Processa Fechamento GMT",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 

	EndIf

Return lRet

User Function BIA704F()

	Local oEmp 	:= Nil
	Local nW	:= 0
	Local lRet  := .T.
	Local oProcess

	Private cTitulo := "Processamento Gestão Matricial de Tributos"

	Private dDataIni
	Private xCodPla
	Private msEnter   := CHR(13) + CHR(10)
	Private msEmpAtu  := cEmpAnt
	Private msFilAtu  := cFilAnt
	Private hhTmpINI
	Private smMsnPrc
	Private msCanPrc  := .F.
	Private xVerRet   := .T.
	Private msErroQuery := ""
	Private msLogOkProc := ""
	Private msVetImp  := {}

	Private xoButton1
	Private xoMultiGe1
	Private xcMultiGe1 := "Define variable value"
	Private xoSay1
	Private xoDlg

	oEmp := TLoadEmpresa():New()

	If ValFcPerg()

		dDataIni := MV_PAR01
		xCodPla  := MV_PAR02

		oEmp:GmtQuadroImp()
		msVetImp := oEmp:aEmpSel

		oEmp:GSEmpFil()

		If Len(oEmp:aEmpSel) > 0

			hhTmpINI  := TIME()

			RpcSetType(3)
			RpcSetEnv( cEmpAnt, cFilAnt )
			RpcClearEnv()

			//Begin Transaction

			For nW := 1 To Len(oEmp:aEmpSel)

				RpcSetType(3)
				RpcSetEnv( oEmp:aEmpSel[nW][1], Substr(oEmp:aEmpSel[nW][2], 1, 2) )

				smMsnPrc := oEmp:aEmpSel[nW][1] + "/" + Substr(oEmp:aEmpSel[nW][2], 1, 2) + " - " + Alltrim(oEmp:aEmpSel[nW][4])
				oProcess := MsNewProcess():New({|lEnd| Prc704FX(@oProcess) }, "Gravando...", smMsnPrc, .T.)
				oProcess:Activate()

				lRet := xVerRet

				If !xVerRet

					//DisarmTransaction()
					msCanPrc  := .F.
					Exit

				EndIf

				RpcClearEnv()

			Next nW

			//End Transaction

		Else

			msCanPrc  := .T.

		EndIf

	Else

		msCanPrc  := .T.

	EndIf

	RpcSetEnv( msEmpAtu, msFilAtu )

	If Type("__cInternet") == "C"
		__cInternet := Nil
	EndIf

	If !msCanPrc

		If !lRet

			xcMultiGe1 := "Erro de Query: " + msEnter + msEnter + msErroQuery

			DEFINE MSDIALOG xoDlg TITLE "Atenção!!!" FROM 000, 000  TO 550, 490 COLORS 0, 16777215 PIXEL

			@ 019, 006 GET xoMultiGe1 VAR xcMultiGe1 OF xoDlg MULTILINE SIZE 236, 249 COLORS 0, 16777215 HSCROLL PIXEL
			@ 008, 008 SAY xoSay1 PROMPT "Log de Erro. Apanhe o erro e abra um ticket." SIZE 111, 007 OF xoDlg COLORS 0, 16777215 PIXEL
			@ 006, 205 BUTTON xoButton1 PROMPT "Fecha" SIZE 037, 012 OF xoDlg ACTION xoDlg:End() PIXEL

			ACTIVATE MSDIALOG xoDlg CENTERED

		Else

			//MsgINFO("Fim do Processamento!!!" + msEnter + msEnter + Alltrim(ElapTime(hhTmpINI, TIME())), "Atenção!!!")

			xcMultiGe1 := "Logo de processamento: " + msEnter + msEnter + msLogOkProc

			DEFINE MSDIALOG xoDlg TITLE "Fim do Processamento!!!" FROM 000, 000  TO 550, 490 COLORS 0, 16777215 PIXEL

			@ 019, 006 GET xoMultiGe1 VAR xcMultiGe1 OF xoDlg MULTILINE SIZE 236, 249 COLORS 0, 16777215 HSCROLL PIXEL
			@ 008, 008 SAY xoSay1 PROMPT "Log de processamento." SIZE 111, 007 OF xoDlg COLORS 0, 16777215 PIXEL
			@ 006, 205 BUTTON xoButton1 PROMPT "Fecha" SIZE 037, 012 OF xoDlg ACTION xoDlg:End() PIXEL

			ACTIVATE MSDIALOG xoDlg CENTERED

		EndIf

	Else

		MsgALERT("Processamento Abortado", "Atenção!!!")

	EndIf

Return

Static Function ValFcPerg()

	local cLoad	    := "BIA704F" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 :=	ctod("  /  /  ")
	MV_PAR02 :=	Space(03)

	aAdd( aPergs ,{1, "Data de Fechamento" ,MV_PAR01 ,""  ,"NAOVAZIO()"     ,''     ,'.T.',50,.F.})
	aAdd( aPergs ,{1, "Visão Gerencial"    ,MV_PAR02 ,""  ,"EXISTCPO('CVE')",'CVE'  ,'.T.',50,.F.})

	If ParamBox(aPergs ,"Processa Fechamento GMT",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)

	EndIf

Return lRet

Static Function Prc704FX(oProcess)

	Local pk
	Local lRet	   := .T.
	Local msAlt    := .F.

	If fExistTabl(RetSqlName("ZNA"))

		oProcess:SetRegua1(1)
		oProcess:SetRegua2(1000)             

		If Len(msVetImp) > 0
			oProcess:IncRegua1(smMsnPrc)
			For pk := 1 to Len(msVetImp)
				oProcess:IncRegua2("Gravando a: " + Alltrim(ElapTime(hhTmpINI, TIME())) )

				msAlt    := .F.
				ZNA->(dbSetOrder(1))
				If ZNA->(dbSeek( xFilial("ZNA") + xCodPla + msVetImp[pk][2] ))

					If dDataIni > ZNA->ZNA_ULTGMT

						msAlt    := .T.
						Reclock("ZNA",.F.)
						ZNA->ZNA_ULTGMT   := dDataIni
						ZNA->(MsUnLock())

					EndIf

				Else

					msAlt    := .T.
					Reclock("ZNA",.T.)
					ZNA->ZNA_FILIAL := xFilial("ZNA")
					ZNA->ZNA_CODPLA := xCodPla
					ZNA->ZNA_CODIMP := msVetImp[pk][2]
					ZNA->ZNA_DESIMP := msVetImp[pk][4]
					ZNA->ZNA_ULTGMT := dDataIni
					ZNA->(MsUnLock())

				EndIf

				If msAlt

					msLogOkProc += "Alterado - Emp: " + cEmpAnt + ", Fil: " + cFilAnt + ", Imp: " + ZNA->ZNA_CODIMP + ", UltGMT: " + dtoc(ZNA->ZNA_ULTGMT) + msEnter

				Else

					msLogOkProc += "*Mantido - Emp: " + cEmpAnt + ", Fil: " + cFilAnt + ", Imp: " + ZNA->ZNA_CODIMP + ", UltGMT: " + dtoc(ZNA->ZNA_ULTGMT) + msEnter

				EndIf

			Next pk

		EndIf

	Else 

		msErroQuery := "Empresa: " + cEmpAnt + msEnter + msEnter
		msErroQuery += "Filial: " + cFilAnt + msEnter + msEnter
		msErroQuery += "A tabela ZNA não está configurada para este empresa. Favor Verificar."
		lRet := .F.

	EndIf

	xVerRet := lRet

Return( lRet )

User Function BIA704A()

	Local oEmp  := Nil
	Local nW    := 0
	Local lRet  := .T.
	Local oProcess

	Private cTitulo := "Abertura Período Gestão Matricial de Tributos"

	Private xCodPla
	Private msEnter   := CHR(13) + CHR(10)
	Private msEmpAtu  := cEmpAnt
	Private msFilAtu  := cFilAnt
	Private hhTmpINI
	Private smMsnPrc
	Private msCanPrc  := .F.
	Private xVerRet   := .T.
	Private msErroQuery := ""
	Private msLogsQuery := ""
	Private msVetImp  := {}

	Private xoButton1
	Private xoMultiGe1
	Private xcMultiGe1 := "Define variable value"
	Private xoSay1
	Private xoDlg

	oEmp := TLoadEmpresa():New()

	If aValidPerg()

		xCodPla  := MV_PAR01

		oEmp:GmtQuadroImp()
		msVetImp := oEmp:aEmpSel

		oEmp:GSEmpFil()

		If Len(oEmp:aEmpSel) > 0

			hhTmpINI  := TIME()

			RpcSetType(3)
			RpcSetEnv( cEmpAnt, cFilAnt )
			RpcClearEnv()

			//Begin Transaction

			For nW := 1 To Len(oEmp:aEmpSel)

				RpcSetType(3)
				RpcSetEnv( oEmp:aEmpSel[nW][1], Substr(oEmp:aEmpSel[nW][2], 1, 2) )

				smMsnPrc := oEmp:aEmpSel[nW][1] + "/" + Substr(oEmp:aEmpSel[nW][2], 1, 2) + " - " + Alltrim(oEmp:aEmpSel[nW][4])
				oProcess := MsNewProcess():New({|lEnd| Prc704AX(@oProcess) }, "Gravando...", smMsnPrc, .T.)
				oProcess:Activate()

				lRet := xVerRet

				If !xVerRet

					//DisarmTransaction()
					msCanPrc  := .F.
					Exit

				EndIf

				RpcClearEnv()

			Next nW

			//End Transaction

		Else

			msCanPrc  := .T.

		EndIf

	Else

		msCanPrc  := .T.

	EndIf

	RpcSetEnv( msEmpAtu, msFilAtu )

	If Type("__cInternet") == "C"
		__cInternet := Nil
	EndIf

	If !msCanPrc

		If !lRet

			xcMultiGe1 := "Erro de Query: " + msEnter + msEnter + msErroQuery

			DEFINE MSDIALOG xoDlg TITLE "Atenção!!!" FROM 000, 000  TO 550, 490 COLORS 0, 16777215 PIXEL

			@ 019, 006 GET xoMultiGe1 VAR xcMultiGe1 OF xoDlg MULTILINE SIZE 236, 249 COLORS 0, 16777215 HSCROLL PIXEL
			@ 008, 008 SAY xoSay1 PROMPT "Log de Erro. Apanhe o erro e abra um ticket." SIZE 111, 007 OF xoDlg COLORS 0, 16777215 PIXEL
			@ 006, 205 BUTTON xoButton1 PROMPT "Fecha" SIZE 037, 012 OF xoDlg ACTION xoDlg:End() PIXEL

			ACTIVATE MSDIALOG xoDlg CENTERED

		Else

			xcMultiGe1 := "Logs de Abertura: " + msEnter + msEnter + msLogsQuery

			DEFINE MSDIALOG xoDlg TITLE "Fim do Processamento!!!" FROM 000, 000  TO 550, 490 COLORS 0, 16777215 PIXEL

			@ 019, 006 GET xoMultiGe1 VAR xcMultiGe1 OF xoDlg MULTILINE SIZE 236, 249 COLORS 0, 16777215 HSCROLL PIXEL
			@ 008, 008 SAY xoSay1 PROMPT "Log de Abertura. Confirme as datas e empresas." SIZE 111, 007 OF xoDlg COLORS 0, 16777215 PIXEL
			@ 006, 205 BUTTON xoButton1 PROMPT "Fecha" SIZE 037, 012 OF xoDlg ACTION xoDlg:End() PIXEL

			ACTIVATE MSDIALOG xoDlg CENTERED

		EndIf

	Else

		MsgALERT("Processamento Abortado", "Atenção!!!")

	EndIf

Return

Static Function aValidPerg()

	local cLoad	    := "BIA704A" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 :=	Space(03)

	aAdd( aPergs ,{1, "Visão Gerencial"    ,MV_PAR01 ,""  ,"EXISTCPO('CVE')",'CVE'  ,'.T.',50,.F.})

	If ParamBox(aPergs ,"Processa Fechamento GMT",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 

	EndIf

Return lRet

Static Function Prc704AX(oProcess)

	Local pk
	Local lRet	   := .T.

	If fExistTabl(RetSqlName("ZNA"))

		oProcess:SetRegua1(1)
		oProcess:SetRegua2(1000)

		If Len(msVetImp) > 0
			oProcess:IncRegua1(smMsnPrc)
			For pk := 1 to Len(msVetImp)
				oProcess:IncRegua2("Gravando a: " + Alltrim(ElapTime(hhTmpINI, TIME())) )

				ZNA->(dbSetOrder(1))
				If ZNA->(dbSeek( xFilial("ZNA") + xCodPla + msVetImp[pk][2] ))

					Reclock("ZNA",.F.)
					ZNA->ZNA_ULTGMT   := stod(Substr(dtos(ZNA->ZNA_ULTGMT),1,6) + "01") - 1
					ZNA->(MsUnLock())

					msLogsQuery += "Emp: " + cEmpAnt + " Fil: " + cFilAnt + "Imp: " + ZNA->ZNA_CODIMP + " UltGMT: " + dtoc(ZNA->ZNA_ULTGMT) + msEnter

				EndIf

			Next pk

		EndIf

	Else 

		msErroQuery := "Empresa: " + cEmpAnt + msEnter + msEnter
		msErroQuery += "Filial: " + cFilAnt + msEnter + msEnter
		msErroQuery += "A tabela ZNA não está configurada para este empresa. Favor Verificar."
		lRet := .F.

	EndIf

	xVerRet := lRet

Return( lRet )

User Function BIA704C()

	Local aArea := ZNA->(GetArea())
	Private oBrowse
	Private cChaveAux := ""
	Private cCadastro := "Controle de Fechamento do GMT"
	Private msEnter   := CHR(13) + CHR(10)

	aRotina   := { {"Pesquisar"       ,"AxPesqui"                          ,0,1},;
	{               "Visualizar"      ,"AxVisual"                          ,0,2} }

	//Iniciamos a construção básica de um Browse.
	oBrowse := FWMBrowse():New()

	//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
	oBrowse:SetAlias("ZNA")

	//Definimos o título que será exibido como método SetDescription
	oBrowse:SetDescription(cCadastro)

	//Adiciona um filtro ao browse
	//oBrowse:SetFilterDefault( "ZN6_TIPO1 = 'M'" )

	//Ativamos a classe
	oBrowse:Activate()
	RestArea(aArea)

Return

Static Function fExistTabl(cTabl)

	Local cSQL  := ""
	Local cQry  := ""
	Local lRet  := .F.

	cQry := GetNextAlias()

	cSql := " SELECT COUNT(*) CONTAD
	cSql += " FROM INFORMATION_SCHEMA.TABLES
	cSql += " WHERE TABLE_NAME = '" + cTabl + "';

	TcQuery cSQL New Alias (cQry)

	If (cQry)->CONTAD > 0
		lRet := .T.
	EndIf

	(cQry)->(DbCloseArea())

	xVerRet := lRet 

Return ( lRet )
