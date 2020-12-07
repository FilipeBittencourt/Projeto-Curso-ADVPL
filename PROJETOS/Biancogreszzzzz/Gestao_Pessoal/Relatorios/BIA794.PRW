#Include "RwMake.ch"
#Include "topconn.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA794
@author Marcos Alberto Soprani
@since 21/01/16
@version 1.0
@description Verbas por Funcionário - SRc (Mensais)
@type function
/*/

User Function BIA794()

	Local cDesc1       := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2       := "de acordo com os parametros informados pelo usuario."
	Local cDesc3       := "Verbas por Funcionario - SRC (Mensais)"
	Local cPict        := ""
	Local titulo       := "Verbas por Funcionario - SRC (Mensais)"
	Local nLin         := 80
	Local Cabec1       := ""
	Local Cabec2       := ""
	Local imprime      := .T.
	Local aOrd         := {}
	Private lEnd       := .F.
	Private lAbortPrint:= .F.
	Private CbTxt      := ""
	Private limite     := 80
	Private tamanho    := "P"
	Private nomeprog   := "BIA794 "
	Private nTipo      := 18
	Private aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey   := 0
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "BIA794"
	Private cPerg      := "BIA794"
	Private cString    := "SRC"
	Private TMP

	ValidPerg(cPerg)
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)
	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	Pergunte(cPerg, .F.)

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*111111111111111111111111111111111111111111111111111111111111111111111111111
11IMMMMMMMMMMQMMMMMMMMMMKMMMMMMMQMMMMMMMMMMMMMMMMMMMMKMMMMMMQMMMMMMMMMMMMM;11
11:Funo    3RUNREPORT : Autor 3 AP6 IDE            : Data 3  18/09/06   :11
11LMMMMMMMMMMXMMMMMMMMMMJMMMMMMMOMMMMMMMMMMMMMMMMMMMMJMMMMMMOMMMMMMMMMMMMM911
11:Descrio 3 Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS :11
11:          3 monta a janela com a regua de processamento.               :11
11HMMMMMMMMMMOMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM<11
111111111111111111111111111111111111111111111111111111111111111111111111111*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local cNomFilial := aAreaSM0 := cSQL:=""
	Local dDtStart := dDtPoint := mv_par01
	Local dUltDia := ctod("//")
	Local cVrbQuery 	:= ""
	Local cCatQuery 	:= ""
	Local cSitQuery 	:= ""
	Local nS			:= 0
	Local aStruSRA		:= {}
	Local lQuery		:= .F.
	Local ftx

	cVerbas  	:= AllTrim(mv_par01 + mv_par02) 		// Verbas a Listar1
	cSituacao  	:= mv_par03		// Situacao do Funcionario
	cCategoria 	:= mv_par04 	// Categoria do Funcionario

	lQuery	:= .T.
	//-- Modifica variaveis para a Query
	For nS:=1 to Len(cSituacao)
		cSitQuery += "'"+Subs(cSituacao,nS,1)+"'"
		If ( nS+1) <= Len(cSituacao)
			cSitQuery += ","
		Endif
	Next nS

	cCatQuery := ""
	For nS:=1 to Len(cCategoria)
		cCatQuery += "'"+Subs(cCategoria,nS,1)+"'"
		If ( nS+1) <= Len(cCategoria)
			cCatQuery += ","
		Endif
	Next nS

	cVrbQuery := ""
	For nS:=1 to Len(AllTrim(cVerbas))
		cVrbQuery += "'"+Subs(AllTrim(cVerbas),nS,3)+"'"
		If (nS+3) <= Len(AllTrim(cVerbas))
			cVrbQuery += ","
		Endif
		nS += 2
	Next nS

	SetRegua(5000)
	Pergunte(cPerg,.f.)
	DbSelectArea("SRC")

	cSQL := " SELECT RC_FILIAL, RA_YSEMAIL, RC_CC, CTT_DESC01, RA_NOME, RC_MAT, RA_SITFOLH, RA_CATFUNC, RJ_DESC, RC_PD, RC_TIPO1, RC_DATA, SUM(RC_HORAS) RC_HORAS, SUM(RC_VALOR) RC_VALOR "
	cSQL += "   FROM " + RetSqlName("SRC")+" SRC "
	cSQL += "  INNER JOIN " + RetSqlName("SRA")+" SRA ON RC_FILIAL = RA_FILIAL "  
	cSQL += "                   AND RC_MAT = RA_MAT "
	cSQL += "                   AND SRA.D_E_L_E_T_ = ' '"
	cSQL += "  INNER JOIN " + RetSqlName("SRJ")+" SRJ ON RJ_FUNCAO = RA_CODFUNC "
	cSQL += "                   AND SRJ.D_E_L_E_T_ = ' '"
	cSQL += "  INNER JOIN " + RetSqlName("CTT")+" CTT ON CTT_CUSTO = RC_CC "
	cSQL += "  WHERE SRC.D_E_L_E_T_ = ' ' "
	cSQL += "    AND SRC.RC_PD IN (" + Upper(cVrbQuery)    + ") "
	cSQL += "    AND SRA.RA_SITFOLH IN (" + Upper(cSitQuery)    + ") "
	cSQL += "    AND SRA.RA_CATFUNC IN (" + Upper(cCatQuery)    + ") "
	cSQL += "  GROUP BY RC_FILIAL, RA_YSEMAIL, RC_CC, CTT_DESC01, RA_NOME, RC_MAT, RA_SITFOLH, RA_CATFUNC, RJ_DESC, RC_PD, RC_TIPO1, RC_DATA "
	cSQL += "  ORDER BY RC_FILIAL, RC_MAT, RC_CC, RC_PD "

	If Select("tmpSQL") > 0
		tmpSQL->(DbCloseArea())
	Endif

	TCQUERY cSQL NEW ALIAS "tmpSQL"
	TCSetField("tmpSQL","RC_DATA","D")

	tmpSQL->(DbGoTop())

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Verbas por Funcionario - SRC (Mensais)"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "FILIAL"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "NOM_FIL"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "SUPERVISOR"      ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CC"              ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DCUSTO"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "MATR"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "NOME"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "FUNCAO"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CATEGORIA"       ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "SITFOLH"         ,1,1)
	xtVetPD  := {}
	xrQtdP   := 10
	axVetPro := {}

	// **************************** Cria Arquivo Temporario
	_aStru:={}//SD2SQL->(DbStruct())
	aadd( _aStru , {"FILIAL"  		, "C" , 02 , 00 } )
	aadd( _aStru , {"NOM_FIL" 		, "C" , 15 , 00 } )
	aadd( _aStru , {"SUPERVISOR"	, "C" , 75 , 00 } )
	aadd( _aStru , {"CC" 			, "C" , 12 , 00 } )
	aadd( _aStru , {"DCUSTO" 		, "C" , 20 , 00 } )
	aadd( _aStru , {"MATR"  		, "C" , 06 , 00 } )
	aadd( _aStru , {"NOME"  		, "C" , 30 , 00 } )
	aadd( _aStru , {"FUNCAO" 		, "C" , 20 , 00 } )
	aadd( _aStru , {"CATEGORIA" 	, "C" , 01 , 00 } )
	aadd( _aStru , {"SITFOLH" 		, "C" , 01 , 00 } )

	//-- Cria colunas de acordo com os codigos das verbas (INICIO)
	cSQL := " SELECT RC_PD "
	cSQL += "   FROM " + RetSqlName("SRC")+" SRC "
	cSQL += "  WHERE SRC.D_E_L_E_T_ = ' ' "
	cSQL += "    AND SRC.RC_PD IN (" + Upper(cVrbQuery)    + ") "
	cSQL += "  GROUP BY RC_PD "
	cSQL += "  ORDER BY RC_PD "

	If Select("tmpSQL2") > 0
		tmpSQL2->(DbCloseArea())
	Endif

	TCQUERY cSQL NEW ALIAS "tmpSQL2"

	DbSelectArea("tmpSQL2")
	iColuna := 1
	iColuna1 := 1
	Do While tmpSQL2->(!Eof())
		cColuna1 := ("HR_"+StrZero(Val(tmpSQL2->RC_PD),3))
		cColuna := ("PD_"+StrZero(Val(tmpSQL2->RC_PD),3))
		aadd( _aStru , {cColuna1	, "C" , 20 , 00 } )
		aadd( _aStru , {cColuna	, "C" , 20 , 00 } )
		tmpSQL2->(DbSkip())
		iColuna++
		iColuna1++
	Enddo

	tmpSQL2->(DbCloseArea())

	// CRIA ARQUIVO DE TRABALHO
	_cTemp 	:= CriaTrab(_aStru)
	dbUseArea(.t.,,_cTemp,"TMP",.t.)
	dbCreateInd(_cTemp,"Filial+Matr+CC",{ || Filial+Matr+CC } )

	//==================================================================================== (INICIO)
	//----- PREENCHER A DESCRICAO DAS VERBAS (INICIO)
	cSQL := " SELECT RC_PD "
	cSQL += "   FROM " + RetSqlName("SRC")+" SRC "
	cSQL += "  WHERE SRC.D_E_L_E_T_=' ' "
	cSQL += "    AND SRC.RC_PD IN (" + Upper(cVrbQuery)    + ")"
	cSQL += "  GROUP BY RC_PD"
	cSQL += "  ORDER BY RC_PD"

	If Select("tmpSQL_PD") > 0
		tmpSQL_PD->(DbCloseArea())
	Endif

	TCQUERY cSQL NEW ALIAS "tmpSQL_PD"

	DbSelectArea("tmpSQL_PD")
	RecLock("TMP",.T.)
	Do While tmpSQL_PD->(!Eof())
		cCampo1	:= "HR_" + StrZero(Val(tmpSQL_PD->RC_PD),3)
		cCampo	:= "PD_" + StrZero(Val(tmpSQL_PD->RC_PD),3)
		SRV->(DbSeek(xFilial("SRV")+tmpSQL_PD->RC_PD))
		TMP->(&cCampo1)	:= SRV->RV_DESC
		TMP->(&cCampo)	:= SRV->RV_DESC

		// Integração com Excel
		oExcel:AddColumn(nxPlan, nxTabl, "HR_" + StrZero(Val(tmpSQL_PD->RC_PD),3)       ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "PD_" + StrZero(Val(tmpSQL_PD->RC_PD),3)       ,3,2)
		AADD( xtVetPD , cCampo1 )
		AADD( xtVetPD , cCampo  )
		xrQtdP += 2

		tmpSQL_PD->(DbSkip())
	Enddo
	TMP->(MsUnlock())
	tmpSQL_PD->(DbCloseArea())

	//----- PREENCHER A DESCRICAO DAS VERBAS (FIM)

	// CRIAR ITENS (INICIO)
	DbSelectArea("tmpSQL")
	Do While tmpSQL->(!Eof())

		IF .not. TMP->(DbSeek(tmpSQL->RC_FILIAL+tmpSQL->RC_MAT+tmpSQL->RC_CC))

			aAreaSM0 := SM0->(GetArea())
			SM0->(MsSeek(cEmpAnt+tmpSQL->RC_FILIAL))
			cNomFilial := SM0->M0_FILIAL
			RestArea(aAreaSM0)

			RecLock("TMP",.T.)
			TMP->FILIAL 	:= tmpSQL->RC_FILIAL
			TMP->NOM_FIL 	:= cNomFilial
			TMP->MATR	 	:= tmpSQL->RC_MAT
			TMP->NOME 		:= tmpSQL->RA_NOME
			TMP->FUNCAO		:= tmpSQL->RJ_DESC
			TMP->CATEGORIA	:= tmpSQL->RA_CATFUNC
			TMP->SITFOLH	:= tmpSQL->RA_SITFOLH
			TMP->SUPERVISOR	:= tmpSQL->RA_YSEMAIL
			TMP->CC		    := tmpSQL->RC_CC
			TMP->DCUSTO		:= tmpSQL->CTT_DESC01
			TMP->(MsUnlock())
		EndIf

		RecLock("TMP",.F.)
		cCampo1	:= "HR_" + StrZero(Val(tmpSQL->RC_PD),3)
		cCampo	:= "PD_" + StrZero(Val(tmpSQL->RC_PD),3)
		TMP->(&cCampo1)	:= Str(tmpSQL->RC_HORAS,9,2)
		TMP->(&cCampo)	:= Str(tmpSQL->RC_VALOR,9,2)
		TMP->(MsUnlock())

		MsUnlock()
		IncRegua()
		tmpSQL->(DbSkip())
	Enddo

	dbSelectArea("TMP")
	dbGoTop("TMP")
	While !Eof()

		Aadd( axVetPro, Array(xrQtdP) )

		axVetPro[len(axVetPro)][01] := TMP->FILIAL
		axVetPro[len(axVetPro)][02] := TMP->NOM_FIL
		axVetPro[len(axVetPro)][03] := TMP->SUPERVISOR
		axVetPro[len(axVetPro)][04] := TMP->CC
		axVetPro[len(axVetPro)][05] := TMP->DCUSTO
		axVetPro[len(axVetPro)][06] := TMP->MATR
		axVetPro[len(axVetPro)][07] := TMP->NOME
		axVetPro[len(axVetPro)][08] := TMP->FUNCAO
		axVetPro[len(axVetPro)][09] := TMP->CATEGORIA
		axVetPro[len(axVetPro)][10] := TMP->SITFOLH
		For ftx := 1 To len(xtVetPD)
			axVetPro[len(axVetPro)][10+ftx] := IIF(recno() == 1, StrTran(&("TMP->"+xtVetPD[ftx]),".",","), Val(Alltrim(&("TMP->"+xtVetPD[ftx]))) )
		Next ftx

		oExcel:AddRow(nxPlan, nxTabl, axVetPro[1] )
		axVetPro := {}

		dbSelectArea("TMP")
		dbSkip()
	End

	DbSelectArea("TMP")
	TMP->(DbCloseArea())

	xArqTemp := "verbas_mensais"

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

/*111111111111111111111111111111111111111111111111111111111111111111111111111
11IMMMMMMMMMMQMMMMMMMMMMKMMMMMMMQMMMMMMMMMMMMMMMMMMMMKMMMMMMQMMMMMMMMMMMMM;11
11:Programa  3ValidPerg : Autor 3                    : Data 3  18/09/06   :11
11LMMMMMMMMMMXMMMMMMMMMMJMMMMMMMOMMMMMMMMMMMMMMMMMMMMJMMMMMMOMMMMMMMMMMMMM911
11:Descricao 3 Cria/Valida Parametros do sistema                          :11
11HMMMMMMMMMMOMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM<11
111111111111111111111111111111111111111111111111111111111111111111111111111*/

Static Function ValidPerg(cPerg)

	Local _sAlias := Alias()
	Local aRegs := {}
	Local i,j

	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)
	aAdd(aRegs,{cPerg,"01","Cod. Verbas Listar?","","","mv_ch1","C",60,0,0,"G","fVerbas(NIL,MV_PAR02,20)","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","SRV",""})
	aAdd(aRegs,{cPerg,"02","Cont.Verbas Listar?","","","mv_ch2","C",60,0,0,"G","fVerbas(NIL,MV_PAR01,20)","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","SRV",""})
	aAdd(aRegs,{cPerg,"03","Situacao          ?","","","mv_ch3","C",05,0,0,"G","fSituacao               ","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Categoria         ?","","","mv_ch4","C",12,0,0,"G","fCategoria              ","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				EndIf
			Next
			MsUnlock()
		EndIf
	Next
	dbSelectArea(_sAlias)

Return
