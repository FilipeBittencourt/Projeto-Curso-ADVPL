#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA625
@author Marcos Alberto Soprani
@since 28/03/16
@version 1.0
@description Cadastro de Metas de quantidade por Dia/Linha/Formato/Turno
@type function
/*/

User Function BIA625()

	dbSelectArea("Z74")
	dbGoTop()

	n := 1
	cCadastro := " ....: Metas de Produção :.... "

	aRotina   := {  {"Pesquisar"   ,'AxPesqui'                             ,0, 1},;
	{                "Visualizar"  ,'AxVisual'                             ,0, 2},;
	{                "Incluir"     ,'AxInclui'                             ,0, 3},;
	{                "Alterar"     ,'AxAltera'                             ,0, 4},;
	{                "Excluir"     ,'AxDeleta'                             ,0, 5},;
	{                "PlumaoMeta"  ,"U_BIA625P"                            ,0, 6} }

	mBrowse(6,1,22,75, "Z74", , , , , ,)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BTRIGG625  ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 01/04/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Gatinho para validação da digitação das metas de produção  ¦¦¦
¦¦¦          ¦ dos formatos B9, BO e C6                                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BTRIGG625()

	krValidOk := .T.

	If M->Z74_FORMAT $ "B9/BO/C6"

		PX007 := " WITH METAUTIPS AS (SELECT CASE
		PX007 += "                             WHEN Z74_FORMAT IN('B9', 'BO', 'C6') THEN Z74_METAQT * (-1)
		PX007 += "                             ELSE (Z74_METAQT * 0.9770114942528736)
		PX007 += "                           END METAQT
		PX007 += "                      FROM Z74010 Z74
		PX007 += "                     WHERE Z74_FILIAL = '"+xFilial("Z74")+"'
		PX007 += "                       AND Z74_FORMAT IN('C1', 'B9', 'BO', 'C6')
		PX007 += "                       AND Z74_DATA <= '" + dtos(M->Z74_DATA) + "'
		PX007 += "                       AND Z74.D_E_L_E_T_ = ' '
		PX007 += "                     UNION ALL
		PX007 += "                    SELECT CASE
		PX007 += "                             WHEN Z74_FORMAT IN('B9', 'BO', 'C6') THEN Z74_METAQT * (-1)
		PX007 += "                             ELSE (Z74_METAQT * 0.9770114942528736)
		PX007 += "                           END METAQT
		PX007 += "                      FROM Z74140 Z74
		PX007 += "                     WHERE Z74_FILIAL = '"+xFilial("Z74")+"'
		PX007 += "                       AND Z74_FORMAT IN('C1', 'B9', 'BO', 'C6')
		PX007 += "                       AND Z74_DATA <= '" + dtos(M->Z74_DATA) + "'
		PX007 += "                       AND Z74.D_E_L_E_T_ = ' ')
		PX007 += " SELECT ISNULL(SUM(PPM.METAQT),0) DISPON
		PX007 += "   FROM METAUTIPS PPM
		PXcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,PX007),'PX07',.F.,.T.)
		dbSelectArea("PX07")
		dbGoTop()
		If PX07->DISPON < M->Z74_METAQT
			MsgINFO("Não existe saldo suficiente de Meta de PS para compor a Meta do PA em questão. Saldo atual disponível:("+Alltrim(Transform(PX07->DISPON, "@E 999,999,999.999"))+")... Favor verificar!!!")
			krValidOk := .F.
		EndIf
		PX07->(dbCloseArea())
		Ferase(PXcIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(PXcIndex+OrdBagExt())          //indice gerado

	EndIf

Return ( krValidOk )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA625P  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 02/02/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Kardex de Pulmão de Meta                                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA625P()

	fPerg := "BIA625"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Metas de Movimento VS Metas de Referência"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "Empresa"              ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DATAREF"              ,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "FORMATO"              ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "LINHA"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ENTRADA"              ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "SAIDA"                ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "SALDO"                ,3,2)

	cdSaldo := 0
	TD008 := " WITH METAUTIPS AS (SELECT 'Biancogres' EMPR,
	TD008 += "                           CASE
	TD008 += "                             WHEN Z74_FORMAT IN('B9', 'BO', 'C6') THEN Z74_METAQT * 0
	TD008 += "                             ELSE ROUND((Z74_METAQT * 0.9770114942528736),2)
	TD008 += "                           END ENTRADA,
	TD008 += "                           CASE
	TD008 += "                             WHEN Z74_FORMAT IN('B9', 'BO', 'C6') THEN Z74_METAQT * (-1)
	TD008 += "                             ELSE (Z74_METAQT * 0)
	TD008 += "                           END SAIDA,
	TD008 += "                           0 SALDO,
	TD008 += "                           *
	TD008 += "                      FROM Z74010 Z74
	TD008 += "                     WHERE Z74_FILIAL = '01'
	TD008 += "                       AND Z74_DATA BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'
	TD008 += "                       AND Z74_FORMAT IN('C1', 'B9', 'BO', 'C6')
	TD008 += "                       AND Z74.D_E_L_E_T_ = ' '
	TD008 += "                     UNION ALL
	TD008 += "                    SELECT 'Vitcer' EMPR,
	TD008 += "                           CASE
	TD008 += "                             WHEN Z74_FORMAT IN('B9', 'BO', 'C6') THEN Z74_METAQT * 0
	TD008 += "                             ELSE ROUND((Z74_METAQT * 0.9770114942528736),2)
	TD008 += "                           END ENTRADA,
	TD008 += "                           CASE
	TD008 += "                             WHEN Z74_FORMAT IN('B9', 'BO', 'C6') THEN Z74_METAQT * (-1)
	TD008 += "                             ELSE (Z74_METAQT * 0)
	TD008 += "                           END SAIDA,
	TD008 += "                           0 SALDO,
	TD008 += "                           *
	TD008 += "                      FROM Z74140 Z74
	TD008 += "                     WHERE Z74_FILIAL = '01'
	TD008 += "                       AND Z74_DATA BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'
	TD008 += "                       AND Z74_FORMAT IN('C1', 'B9', 'BO', 'C6')
	TD008 += "                       AND Z74.D_E_L_E_T_ = ' ')
	TD008 += " ,    METSALIPS AS (SELECT 'Biancogres' EMPR,
	TD008 += "                           CASE
	TD008 += "                             WHEN Z74_FORMAT IN('B9', 'BO', 'C6') THEN Z74_METAQT * 0
	TD008 += "                             ELSE ROUND((Z74_METAQT * 0.9770114942528736),2)
	TD008 += "                           END ENTRADA,
	TD008 += "                           CASE
	TD008 += "                             WHEN Z74_FORMAT IN('B9', 'BO', 'C6') THEN Z74_METAQT * (-1)
	TD008 += "                             ELSE (Z74_METAQT * 0)
	TD008 += "                           END SAIDA,
	TD008 += "                           *
	TD008 += "                      FROM Z74010 Z74
	TD008 += "                     WHERE Z74_FILIAL = '01'
	TD008 += "                       AND Z74_DATA < '" + dtos(MV_PAR01) + "'
	TD008 += "                       AND Z74_FORMAT IN('C1', 'B9', 'BO', 'C6')
	TD008 += "                       AND Z74.D_E_L_E_T_ = ' '
	TD008 += "                     UNION ALL
	TD008 += "                    SELECT 'Vitcer' EMPR,
	TD008 += "                           CASE
	TD008 += "                             WHEN Z74_FORMAT IN('B9', 'BO', 'C6') THEN Z74_METAQT * 0
	TD008 += "                             ELSE ROUND((Z74_METAQT * 0.9770114942528736),2)
	TD008 += "                           END ENTRADA,
	TD008 += "                           CASE
	TD008 += "                             WHEN Z74_FORMAT IN('B9', 'BO', 'C6') THEN Z74_METAQT * (-1)
	TD008 += "                             ELSE (Z74_METAQT * 0)
	TD008 += "                           END SAIDA,
	TD008 += "                           *
	TD008 += "                      FROM Z74140 Z74
	TD008 += "                     WHERE Z74_FILIAL = '01'
	TD008 += "                       AND Z74_DATA < '" + dtos(MV_PAR01) + "'
	TD008 += "                       AND Z74_FORMAT IN('C1', 'B9', 'BO', 'C6')
	TD008 += "                       AND Z74.D_E_L_E_T_ = ' ')
	TD008 += " SELECT *
	TD008 += "   FROM (SELECT EMPR,
	TD008 += "                Z74_DATA,
	TD008 += "                Z74_FORMAT,
	TD008 += "                Z74_LINHA,
	TD008 += "                SUM(ENTRADA) ENTRADA,
	TD008 += "                SUM(SAIDA) SAIDA,
	TD008 += "         	  SUM(SALDO) SALDO
	TD008 += "           FROM METAUTIPS PPM
	TD008 += "         GROUP BY EMPR,
	TD008 += "                  Z74_DATA,
	TD008 += "                  Z74_FORMAT,
	TD008 += "                  Z74_LINHA
	TD008 += "          UNION ALL
	TD008 += "         SELECT EMPR,
	TD008 += "                MAX(Z74_DATA)  DATARF,
	TD008 += "                Z74_FORMAT,
	TD008 += "                Z74_LINHA,
	TD008 += "                0 ENTRADA,
	TD008 += "                0 SAIDA,
	TD008 += "                SUM(ENTRADA)+SUM(SAIDA) SALDO
	TD008 += "           FROM METSALIPS PPM
	TD008 += "         GROUP BY EMPR,
	TD008 += "                  Z74_FORMAT,
	TD008 += "                  Z74_LINHA) AS TAB
	TD008 += "   ORDER BY EMPR, Z74_DATA
	TDcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,TD008),'TD08',.F.,.T.)
	dbSelectArea("TD08")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Gerando...")

		cdSaldo += TD08->SALDO + TD08->ENTRADA + TD08->SAIDA

		oExcel:AddRow(nxPlan, nxTabl, { TD08->EMPR               ,;
		stod(TD08->Z74_DATA)                                     ,;
		TD08->Z74_FORMAT                                         ,;
		TD08->Z74_LINHA                                          ,;
		TD08->ENTRADA                                            ,;
		TD08->SAIDA                                              ,;
		cdSaldo                                                  })

		dbSelectArea("TD08")
		dbSkip()

	End

	TD08->(dbCloseArea())
	Ferase(TDcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(TDcIndex+OrdBagExt())          //indice gerado

	xArqTemp := "pulmaometa - "+cEmpAnt+" - "+dtos(MV_PAR01)+" - "+dtos(MV_PAR02)

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


/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidPerg ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 18/09/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data                  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até Data                 ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
