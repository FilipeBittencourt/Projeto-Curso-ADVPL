#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA621
@author Marcos Alberto Soprani
@since 22/03/16
@version 1.0
@description Meta de Qualidade para Produção
@type function
/*/

User Function BIA621()

	dbSelectArea("Z71")
	dbGoTop()

	n := 1
	cCadastro := " ....: Meta de Qualidade para Produção :.... "

	aRotina   := {  {"Pesquisar"   ,'AxPesqui'                             ,0, 1},;
	{                "Visualizar"  ,'AxVisual'                             ,0, 2},;
	{                "Incluir"     ,'AxInclui'                             ,0, 3},;
	{                "Alterar"     ,'AxAltera'                             ,0, 4},;
	{                "Excluir"     ,'AxDeleta'                             ,0, 5},;
	{                "Del_Formato" ,'Execblock("BIA621D" ,.F.,.F.)'        ,0, 6},;
	{                "Explodir"    ,'Execblock("BIA621A" ,.F.,.F.)'        ,0, 7} }

	mBrowse(6,1,22,75, "Z71", , , , , ,)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA621A  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 23/03/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Explode Meta de Qualidade do Formato para o Produto Ativo  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA621A()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	PX003 := " WITH METASFOR AS (SELECT Z71_DATADE, "
	PX003 += "                          Z71_DATAAT, "
	PX003 += "                          Z71_FORMAT, "
	PX003 += " 	                        Z71_QUALIT, "
	PX003 += " 	                        Z71_HD, "
	PX003 += " 	                        R_E_C_N_O_ REGZ71 "
	PX003 += "                     FROM "+RetSqlName("Z71")+" "
	PX003 += "                    WHERE Z71_FILIAL = '"+xFilial("Z71")+"' "
	PX003 += "                      AND Z71_EXPL IN('N',' ') "
	PX003 += "                      AND Z71_PRODUT = '               ' "
	PX003 += "                      AND D_E_L_E_T_ = ' ') "
	PX003 += " SELECT B1_COD, MTF.* "
	PX003 += "   FROM "+RetSqlName("SB1")+" SB1 "
	PX003 += "  INNER JOIN METASFOR MTF ON Z71_FORMAT = B1_YFORMAT "
	PX003 += "                             AND Z71_HD = B1_YHD "
	PX003 += "  WHERE B1_FILIAL = '"+xFilial("SB1")+"' "
	PX003 += "    AND B1_TIPO = 'PA' "
	PX003 += "    AND B1_YSTATUS = '1' "
	PX003 += "    AND SB1.D_E_L_E_T_ = ' ' "
	PX003 += "  ORDER BY 2, 3, 1 "
	PXIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,PX003),'PX03',.T.,.T.)
	dbSelectArea("PX03")
	dbGotop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		RecLock("Z71",.T.)
		Z71->Z71_FILIAL := xFilial("Z71")
		Z71->Z71_DATADE := stod(PX03->Z71_DATADE)
		Z71->Z71_DATAAT := stod(PX03->Z71_DATAAT)
		Z71->Z71_PRODUT := PX03->B1_COD
		Z71->Z71_QUALIT := PX03->Z71_QUALIT
		Z71->Z71_EXPL   := "S"
		MsUnLock()

		dbSelectArea("Z71")
		dbSetOrder(1)
		dbGoTo(PX03->REGZ71)
		RecLock("Z71",.F.)
		Z71->Z71_EXPL   := "S"
		MsUnLock()

		dbSelectArea("PX03")
		dbSkip()

	End
	PX03->(dbCloseArea())
	Ferase(PXIndex+GetDBExtension())
	Ferase(PXIndex+OrdBagExt())

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA621D  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 23/03/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Exclui todas as metas a partir do posicionamento no formato¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA621D()

	If Empty(Z71->Z71_FORMAT)

		MsgINFO("Não é possível prosseguir porque não está posicionado sobre o registro do formato. Favor Verificar!!!")

	ElseIf !Empty(Z71->Z71_FORMAT) .and. !Empty(Z71->Z71_PRODUT)

		MsgINFO("Não é possível prosseguir porque não está posicionado sobre o registro do formato. Favor Verificar!!!")

	Else

		UP004 := " DELETE " + RetSqlName("Z71") + " " 
		UP004 += "   FROM " + RetSqlName("Z71") + " "
		UP004 += "  WHERE ( ( Z71_FORMAT = '" + Z71->Z71_FORMAT + "' AND Z71_HD = '" + Z71->Z71_HD + "' ) OR SUBSTRING(Z71_PRODUT,1,2) = '" + Z71->Z71_FORMAT + "' ) "
		UP004 += "    AND Z71_DATADE >= '" + dtos(Z71->Z71_DATADE) + "' "
		UP004 += "    AND Z71_DATAAT <= '" + dtos(Z71->Z71_DATAAT) + "' "
		UP004 += "    AND D_E_L_E_T_ = ' ' "
		TCSQLExec(UP004)

	EndIf

Return
