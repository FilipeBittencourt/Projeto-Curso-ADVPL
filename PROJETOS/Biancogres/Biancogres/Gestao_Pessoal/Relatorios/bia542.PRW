#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA542
Empresa   := Biancogres Cerâmica S/A
Data      := 16/04/15
Uso       := Gestão de Pessoal
Aplicação := Relação de Verbas da Folha
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function BIA542()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local xt

	Private oDlgTp
	Private oButt1Tp
	Private oRadM1Tp
	Private nRadM1Tp := 0
	Private cProcesso	:=	""
	Private cFilRCJ		:= ""

	Public bpmFiltM0Tr := Space(200)

	DEFINE MSDIALOG oDlgTp TITLE "Marque uma Opção" FROM 000, 000  TO 110, 315 COLORS 0, 16777215 PIXEL

	@ 017, 006 RADIO oRadM1Tp VAR nRadM1Tp ITEMS "Folha de Pagamento","Vale Transporte" SIZE 106, 020 OF oDlgTp COLOR 0, 16777215 PIXEL
	@ 016, 115 BUTTON oButt1Tp PROMPT "Gerar" SIZE 037, 022 OF oDlgTp ACTION oDlgTp:End() PIXEL
	ACTIVATE MSDIALOG oDlgTp CENTERED

	If nRadM1Tp == 1                                                    // Folha de Pagamento
		//***********************************************************************************

		fPerg := "BIA542"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		
		If !ValidPerg()
			Return
		EndIf

		oExcel := FWMSEXCEL():New()

		nxPlan := "Planilha 01"
		nxTabl := "RelaçãoVerbas"

		oExcel:AddworkSheet(nxPlan)
		oExcel:AddTable (nxPlan, nxTabl)
		oExcel:AddColumn(nxPlan, nxTabl, "EMPR"           ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "CCUSTO"         ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "CLVL"           ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "ASMEDIC"        ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "MATRIC"         ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "NOME"           ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "VERBA"          ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DVERBA"         ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "VALOR"          ,3,2)

		KU009 := " WITH PLANOATV AS (SELECT RHK_MAT, RHK_PLANO
		KU009 += "                     FROM " + RetSqlName("RHK") + " RHK
		KU009 += "                    WHERE RHK_TPFORN = '1'
		KU009 += "                      AND RHK_PERFIM = '      '
		KU009 += "                      AND RHK.D_E_L_E_T_ = ' ')
		KU009 += " SELECT '" + cEmpAnt + "' EMPR,
		KU009 += "        RGB_CC CCUSTO,
		KU009 += "        RGB_CLVL CLVL,
		If MV_PAR07 == 'S'
			KU009 += "        RHK_PLANO ASMEDIC,
		Else
			KU009 += "        '' ASMEDIC,
		EndIf
		KU009 += "        RGB_MAT MATRIC,
		KU009 += "        RA_NOME NOME,
		KU009 += "        RGB_PD VERBA,
		KU009 += "        RV_DESC DVERBA,
		KU009 += "        RGB_VALOR VALOR
		KU009 += "   FROM " + RetSqlName("RGB") + " RGB
		If MV_PAR07 == "S"
			KU009 += "  INNER JOIN PLANOATV PLS ON RHK_MAT = RGB_MAT
			KU009 += "                         AND RHK_PLANO IN" + FormatIn(trim(MV_PAR06),"",2)
		EndIf
		KU009 += "  INNER JOIN " + RetSqlName("SRV") + " SRV ON RV_FILIAL = '" + xFilial("SRV") + "'
		KU009 += "                       AND RV_COD = RGB_PD
		KU009 += "                       AND SRV.D_E_L_E_T_ = ' '
		KU009 += "  INNER JOIN " + RetSqlName("SRA") + " SRA ON RA_FILIAL = '" + xFilial("SRA") + "'
		KU009 += "                       AND RA_MAT = RGB_MAT
		KU009 += "                       AND SRA.D_E_L_E_T_ = ' '
		KU009 += "  WHERE RGB_FILIAL BETWEEN '  ' AND 'ZZ'
		KU009 += "    AND RGB_PD IN" + FormatIn(trim(MV_PAR05),"",3)
		KU009 += "    AND RGB_PROCES = " + ValtoSql(MV_PAR01)
		KU009 += "    AND RGB_ROTEIR = " + ValtoSql(MV_PAR02)
		KU009 += "    AND RGB_PERIOD = " + ValtoSql(MV_PAR03)
		KU009 += "    AND RGB.D_E_L_E_T_ = ' '
		KU009 += "  ORDER BY 1, RGB_MAT
		KUcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,KU009),'KU09',.F.,.T.)
		dbSelectArea("KU09")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc()

			oExcel:AddRow(nxPlan, nxTabl, { KU09->EMPR, KU09->CCUSTO, KU09->CLVL, KU09->ASMEDIC, KU09->MATRIC, KU09->NOME, KU09->VERBA, KU09->DVERBA, KU09->VALOR  })

			dbSelectArea("KU09")
			dbSkip()

		End

		KU09->(dbCloseArea())
		Ferase(KUcIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(KUcIndex+OrdBagExt())          //indice gerado

		xArqTemp := "mesais_verbas"

	ElseIf nRadM1Tp == 2                                                   // Vale Transporte
		//***********************************************************************************

		U_GPM5002()

		oExcel := FWMSEXCEL():New()

		nxPlan := "Planilha 01"
		nxTabl := "ValeTransporte"

		oExcel:AddworkSheet(nxPlan)
		oExcel:AddTable (nxPlan, nxTabl)
		oExcel:AddColumn(nxPlan, nxTabl, "EMPR"           ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "CCUSTO"         ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "CLVL"           ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "SITFOLH"        ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "MATRIC"         ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "NOME"           ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "VALOR"          ,3,2)

		KU009 := " SELECT '"+Alltrim(SM0->M0_NOME)+"' EMPR,
		KU009 += "        RA_CC CCUSTO,
		KU009 += "        RA_CLVL CLVL,
		KU009 += "        RA_SITFOLH SITFOLH,
		KU009 += "        R0_MAT MATRIC,
		KU009 += "        RA_NOME NOME,
		KU009 += "        R0_CODIGO,
		KU009 += "        R0_VALCAL VALOR
		KU009 += "   FROM "+RetSqlName("SR0")+" SR0
		KU009 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"'
		KU009 += "                       AND RA_MAT = R0_MAT
		KU009 += "                       AND RA_SITFOLH <> 'D'
		KU009 += "                       AND SRA.D_E_L_E_T_ = ' '
		KU009 += "  WHERE SR0.D_E_L_E_T_ = ' '
		KU009 += "    AND R0_VALCAL <> 0
		KU009 += "  ORDER BY 1, R0_MAT
		KUcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,KU009),'KU09',.F.,.T.)
		dbSelectArea("KU09")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc()

			If KU09->R0_CODIGO $ bpmFiltM0Tr

				oExcel:AddRow(nxPlan, nxTabl, { KU09->EMPR, KU09->CCUSTO, KU09->CLVL, KU09->SITFOLH, KU09->MATRIC, KU09->NOME, KU09->VALOR })

			EndIf

			dbSelectArea("KU09")
			dbSkip()

		End

		KU09->(dbCloseArea())
		Ferase(KUcIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(KUcIndex+OrdBagExt())          //indice gerado

		xArqTemp := "ValeTransporte"

	Else

		MsgINFO("Nenhuma opção selecionada...")
		REturn

	EndIf

	If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
		Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
	EndIf

	oExcel:Activate()
	oExcel:GetXMLFile("C:\TEMP\"+xArqTemp+".xml")

	cCrLf := Chr(13) + Chr(10)
	If ! ApOleClient( 'MsExcel' )
		MsgAlert( "MsExcel nao instalado!"+cCrLf+cCrLf+"Você poderá recuperar este arquivo em: "+"C:\TEMP\"+xArqTemp+".xml" )
	Else
		oExcel:= MsExcel():New()
		oExcel:WorkBooks:Open( "C:\TEMP\"+xArqTemp+".xml" ) // Abre uma planilha
		oExcel:SetVisible(.T.)
	EndIf

Return

//*****************************************************************************************
//**                                                                                     **
//*****************************************************************************************
User Function fAsMedicB(l1Elem,lTipoRet)

	Local cTitulo  := ""
	Local MvPar
	Local MvParDef := ""
	Local nTamx    := 2
	Private aSit   := {}
	l1Elem := If (l1Elem = Nil , .F. , .T.)

	DEFAULT lTipoRet := .T.

	cAlias := Alias() 					     // Salva Alias Anterior

	If lTipoRet
		MvPar := &(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
		MvRet := Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno
	EndIf

	cTitulo := Alltrim(Left("AsMedic",20))
	MvParDef := ""

	AADD(aSit, "  " )
	MvParDef += "  "
	KT009 := " SELECT DISTINCT RHK_PLANO
	KT009 += "   FROM " + RetSqlName("RHK") + " RHK
	KT009 += "  WHERE RHK_TPFORN = '1'
	KT009 += "    AND RHK_PERFIM = '      '
	KT009 += "    AND RHK.D_E_L_E_T_ = ' '
	KT009 += "  ORDER BY RHK_PLANO
	KTcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,KT009),'KT09',.F.,.T.)
	dbSelectArea("KT09")
	dbGoTop()
	While !Eof()
		AADD(aSit, KT09->RHK_PLANO )
		MvParDef += KT09->RHK_PLANO
		dbSkip()
	End

	KT09->(dbCloseArea())
	Ferase(KTcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(KTcIndex+OrdBagExt())          //indice gerado

	//MvParDef := "  E4E5E6"

	If lTipoRet
		If f_Opcoes(@MvPar, cTitulo, aSit, MvParDef, 12, 49, l1Elem, nTamx)  // Chama funcao f_Opcoes
			&MvRet := MvPar                                                  // Devolve Resultado
		EndIf
	EndIf

	dbSelectArea(cAlias) 								                     // Retorna Alias

Return( IF( lTipoRet , .T. , MvParDef ) )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidPerg ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 18/09/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
/*Static Function fValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Verbas a Listar          ?","","","mv_ch1","C",60,0,0,"G","fVerbas(NIL,,20)","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","AsMedic a Listar         ?","","","mv_ch2","C",20,0,0,"G","u_fAsMedicB()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Considerar AsMedic       ?","","","mv_ch3","N",01,0,0,"C","","mv_par03","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})
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
*/

Static Function ValidPerg()

	local cLoad	    := "BIA542" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local _nPeso	:=	0
	Local aPergs	:=	{}
	
	
	
	MV_PAR01 :=	SPACE(TAMSX3("RCJ_CODIGO")[1])
	MV_PAR02 := SPACE(TAMSX3("RY_CALCULO")[1])
	MV_PAR03 := SPACE(6)
	MV_PAR04 := space(2)
	MV_PAR05 := Space(60)
	MV_PAR06 := SPACE(20)
	MV_PAR07 :=	"S"
	
	aAdd( aPergs ,{1,"Processo " 	  				,MV_PAR01 ,""  ,"Gpem020VldPrc() .And. Gpm020SetVar()",'RCJ'  ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Roteiro de Cálculo " 	  		,MV_PAR02 ,""  ,"U_BIA542PR()",'GPM020'  ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Período " 	  				,MV_PAR03 ,""  ,"",''  ,'.F.',50,.F.})
	aAdd( aPergs ,{1,"Nro. Pagamento " 	  			,MV_PAR04 ,""  ,"",''  ,'.F.',50,.F.})
	aAdd( aPergs ,{1,"Verbas a Listar " 	  		,MV_PAR05 ,""  ,"fVerbas(NIL,,20)",''  ,'.T.',60,.F.})
	aAdd( aPergs ,{1,"AsMedic a Listar " 	  		,MV_PAR06 ,""  ,"u_fAsMedicB()",''  ,'.T.',60,.F.})
	aAdd( aPergs ,{2,"Considerar AsMedic" 			,MV_PAR07 ,{"S=Sim","N=Não"},40,'.T.',.F.})
	
	/*
	aAdd( aPergs ,{1,"Empresa(s)? " 	  	,MV_PAR01 ,""  ,"U_BIAFG14E()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Data de? " 	   		,MV_PAR02 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Data Até?" 	   		,MV_PAR03 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{6,"Pasta Destino?"  		,MV_PAR04 ,"","","", 90 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )
*/
	If ParamBox(aPergs ,"Relação de Verbas da Folha",,,,,,,,cLoad,.T.,.T.)
	
		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05)
		MV_PAR06 := ParamLoad(cFileName,,6,MV_PAR06)
		MV_PAR07 := ParamLoad(cFileName,,7,MV_PAR07)

/*
		if empty(MV_PAR04) 
			MV_PAR04 := AllTrim(GetTempPath()) 	
		endif
	*/
	EndIf
	
Return lRet


User Function BIA542PR()

	Local _aPer	:=	{}
	Local _lRet	:=	fGetPerAtual( _aPer,, MV_PAR01, MV_PAR02 )
	
	If _lRet
		MV_PAR03	:=	_aPer[1,1]
		MV_PAR04	:=	_aPer[1,2]	
	EndIf

Return _lRet