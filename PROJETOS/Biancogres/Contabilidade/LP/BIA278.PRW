#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

User Function BIA278()

/*��������������������������������������������������������������������������
Autor     := Marcos Alberto Soprani
Programa  := BIA278
Empresa   := Biancogres Cer�mica S/A
Data      := 19/01/12
Uso       := Contabilidade / Recursos Humanos
Aplica��o := Respons�vel pela busca dos dados contidos na tabela de Rateio
.           para contabiliza��o da Folha de Pagamento e retorno com a conta
.           cont�bil e/ou percentual de rateio dependendo do parametro que
.           � informado no lancamento padr�o.
.           Este Rateio � predefinido inicialmente para a Biancogres
.            Se for feita alguma altera��o neste programa tem que se aten-
.           tar ao programa BIA281
���������������������������������������������������������������������������*/

Local gp_RetCtd
Local gp_ParRef := ParamIXB[1]
Local gp_ParEmp := ParamIXB[2]

// Para as demais empresa do grupo, n�o efetua rateio nenhum e somente contabiliza para os LP's principais
If cEmpAnt <> "01"
	If gp_ParEmp == "0101"
		If gp_ParRef == "CTA"
			gp_RetCtd := Space(20)
		ElseIf gp_ParRef == "PER"
			gp_RetCtd := 1
		EndIf
	Else
		If gp_ParRef == "CTA"
			gp_RetCtd := Space(20)
		ElseIf gp_ParRef == "PER"
			gp_RetCtd := 0
		EndIf
	EndIf
	
Else
	// Quando for Biancogres e for Centro de Custo iniciado com "1" (administrativo) busca rateio
	If (Substr(SRZ->RZ_CC,1,1) == "1" .or. Alltrim(SRZ->RZ_CC) $ "4000/4050/4080") .and. !Alltrim(SRZ->RZ_CC) $ "1060"

		A0001 := " SELECT ISNULL((SELECT Z14_CONTA
		A0001 += " 		              FROM " + RetSqlName("Z14")
		A0001 += " 		             WHERE Z14_FILIAL = '"+xFilial("Z14")+"'
		A0001 += " 		               AND Z14_CODREF = '      '
		A0001 += " 		               AND Z14_EMPR = '"+gp_ParEmp+"'
		A0001 += " 		               AND '"+dtos(dDataBase)+"' >= Z14_DTINI
		A0001 += " 		               AND '"+dtos(dDataBase)+"' <= Z14_DTFIN
		A0001 += " 		               AND D_E_L_E_T_ = ' '), ' ') Z14_CONTA,
		A0001 += "        ISNULL((SELECT Z14_PERC
		A0001 += " 	       	        FROM " + RetSqlName("Z14")
		A0001 += " 		             WHERE Z14_FILIAL = '"+xFilial("Z14")+"'
		A0001 += " 		               AND Z14_CODREF = '      '
		A0001 += " 		               AND Z14_EMPR = '"+gp_ParEmp+"'
		A0001 += " 		               AND '"+dtos(dDataBase)+"' >= Z14_DTINI
		A0001 += " 		               AND '"+dtos(dDataBase)+"' <= Z14_DTFIN
		A0001 += " 		               AND D_E_L_E_T_ = ' '), 0) Z14_PERC

        // Retirado em 21/01/14 - passa a parti de 2014 a n�o considerar a fun��o do funcion�rio e sim o rateio geral por empresa
		//A0001 := " SELECT ISNULL((SELECT Z14_CONTA
		//A0001 += " 		              FROM " + RetSqlName("Z14")
		//A0001 += " 		             WHERE Z14_FILIAL = '"+xFilial("Z14")+"'
		//A0001 += " 		               AND Z14_CODREF = '"+SRA->RA_CODFUNC+"'
		//A0001 += " 		               AND Z14_EMPR = '"+gp_ParEmp+"'
		//A0001 += " 		               AND '"+dtos(dDataBase)+"' >= Z14_DTINI
		//A0001 += " 		               AND '"+dtos(dDataBase)+"' <= Z14_DTFIN
		//A0001 += " 		               AND D_E_L_E_T_ = ' '), ' ') Z14_CONTA,
		//A0001 += "        ISNULL((SELECT Z14_PERC
		//A0001 += " 	       	        FROM " + RetSqlName("Z14")
		//A0001 += " 		             WHERE Z14_FILIAL = '"+xFilial("Z14")+"'
		//A0001 += " 		               AND Z14_CODREF = '"+SRA->RA_CODFUNC+"'
		//A0001 += " 		               AND Z14_EMPR = '"+gp_ParEmp+"'
		//A0001 += " 		               AND '"+dtos(dDataBase)+"' >= Z14_DTINI
		//A0001 += " 		               AND '"+dtos(dDataBase)+"' <= Z14_DTFIN
		//A0001 += " 		               AND D_E_L_E_T_ = ' '), 0) Z14_PERC

        // Retirado em 19/01/12
		//A0001 := " SELECT Z14_CONTA, Z14_PERC
		//A0001 += "   FROM " + RetSqlName("Z14")
		//A0001 += "  WHERE Z14_FILIAL = '"+xFilial("Z14")+"'
		//A0001 += "    AND Z14_CODREF = '"+SRA->RA_CODFUNC+"'
		//A0001 += "    AND Z14_EMPR = '"+gp_ParEmp+"'
		//A0001 += "    AND '"+dtos(dDataBase)+"' >= Z14_DTINI
		//A0001 += "    AND '"+dtos(dDataBase)+"' <= Z14_DTFIN
		//A0001 += "    AND D_E_L_E_T_ = ' '

		TcQuery A0001 New Alias "A001"
		dbSelectArea("A001")
		dbGoTop()
		If A001->Z14_PERC > 0
			If gp_ParRef == "CTA"
				gp_RetCtd := A001->Z14_CONTA
			ElseIf gp_ParRef == "PER"
				gp_RetCtd := A001->Z14_PERC / 100
			EndIf
		Else
			If gp_ParEmp == "0101"
				If gp_ParRef == "CTA"
					gp_RetCtd := Space(20)
				ElseIf gp_ParRef == "PER"
					gp_RetCtd := 1
				EndIf
			Else
				If gp_ParRef == "CTA"
					gp_RetCtd := Space(20)
				ElseIf gp_ParRef == "PER"
					gp_RetCtd := 0
				EndIf
			EndIf
		EndIf
		A001->(dbCloseArea())
		
	Else
		// Quando n�o for Centro de Custo administrativo, somente contabiliza para LP's principais
		If gp_ParEmp == "0101"
			If gp_ParRef == "CTA"
				gp_RetCtd := Space(20)
			ElseIf gp_ParRef == "PER"
				gp_RetCtd := 1
			EndIf
		Else
			If gp_ParRef == "CTA"
				gp_RetCtd := Space(20)
			ElseIf gp_ParRef == "PER"
				gp_RetCtd := 0
			EndIf
		EndIf
		
	EndIf
	
EndIf

Return ( gp_RetCtd )