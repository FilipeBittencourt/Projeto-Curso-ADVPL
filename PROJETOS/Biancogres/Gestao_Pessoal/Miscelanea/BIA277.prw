#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA277
@author Marcos Alberto Soprani
@since 08/01/18
@version 1.0
@description Browser principal para a rotina Ctrl Conta Contábil para RPA
@type function
/*/

User Function BIA277()

	Local aArea     := GetArea()
	Local cCondicao := ""

	Private cCadastro 	:= "Ctrl Conta Contábil para RPA"
	Private aRotina 	:= { {"Pesquisar"  			,"AxPesqui"     ,0,1},;
	{                         "Visualizar"			,"AxVisual"     ,0,2} }

	dbSelectArea("ZCT")
	dbSetOrder(1)

	mBrowse(6,1,22,75,"ZCT",,,,,,)

Return

User Function BiaCont277()

	Local msAreaAtu := GetArea()
	Local msCContab := Space(20)

	YT005 := " SELECT ZCT.ZCT_CONTA CCONTAB "
	YT005 += "   FROM " + RetSqlName("ZCT") + " ZCT "
	YT005 += "  WHERE ZCT_FILIAL = '" + xFilial("ZCT") + "' "
	YT005 += "    AND ZCT_DATARQ IN (SELECT MAX(XXX.ZCT_DATARQ) "
	YT005 += "                         FROM " + RetSqlName("ZCT") + " XXX "
	YT005 += "                        WHERE XXX.ZCT_FILIAL = ZCT.ZCT_FILIAL "
	YT005 += "                          AND XXX.ZCT_MAT = ZCT.ZCT_MAT "
	YT005 += "                          AND XXX.ZCT_CLVL = ZCT.ZCT_CLVL "
	YT005 += "                          AND XXX.D_E_L_E_T_ = ' ') "
	YT005 += "    AND ZCT.ZCT_MAT = '" + SRZ->RZ_MAT + "' "
	YT005 += "    AND ZCT.ZCT_CLVL = '" + SRZ->RZ_CLVL + "' "
	YT005 += "    AND ZCT.D_E_L_E_T_ = ' ' "
	YTcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,YT005),'YT05',.T.,.T.)
	dbSelectArea("YT05")
	dbGoTop()
	msCContab := YT05->CCONTAB
	YT05->(dbCloseArea())
	Ferase(YTcIndex+GetDBExtension())
	Ferase(YTcIndex+OrdBagExt())

	RestArea( msAreaAtu )

Return ( msCContab )
