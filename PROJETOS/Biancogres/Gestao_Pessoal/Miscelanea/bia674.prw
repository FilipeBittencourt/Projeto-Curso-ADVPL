#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA673
@author Marcos Alberto Soprani
@since 27/07/2016
@version 1.0
@description Rotina responsável pela contagem dos funcionários ativos durante o cálculo da folha para controle de gravação da verba 742
@obs OS: 4122-15 - Claudia Mara
@type function
/*/

User Function BIA674()

	If Type("bpmCountFun") == "U"

		B674COUNT()

	EndIf

Return ( bpmCountFun )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B674COUNT ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 27/07/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Responsável pela contagem de funcionários                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function B674COUNT()

	Public bpmCountFun

	VP003 := " SELECT COUNT(*) CONTAD "
	VP003 += "   FROM "+RetSqlName("SRA")+" SRA "
	VP003 += "  WHERE RA_FILIAL = '"+xFilial("SRA")+"' "
	VP003 += "    AND RA_MAT BETWEEN '          ' AND '199999' "
	VP003 += "    AND RA_ADMISSA <= '"+dtos(UltimoDia(dDataBase))+"' "
	VP003 += "    AND ( RA_DEMISSA = '        ' OR RA_DEMISSA > '"+dtos(UltimoDia(dDataBase))+"' ) "
	VP003 += "    AND SRA.D_E_L_E_T_ = ' ' "
	VPcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,VP003),'VP03',.F.,.T.)
	dbSelectArea("VP03")
	dbGoTop()

	bpmCountFun := VP03->CONTAD

	If bpmCountFun > 500
		MsgINFO("O sistema irá calcular a verba 742 - SENAI")
	Else
		MsgSTOP("O sistema NÃO irá calcular a verba 742 - SENAI")
	EndIf

	VP03->(dbCloseArea())
	Ferase(VPcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(VPcIndex+OrdBagExt())          //indice gerado

Return