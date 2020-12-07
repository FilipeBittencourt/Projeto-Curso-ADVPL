#INCLUDE "TOTVS.CH"
#Include 'PROTHEUS.CH'
#Include "tbiconn.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIAPN001
@description Analise de produtos com estoque negativo 
@author Pablo S. Nascimento
@since Junho 2020
@version 1.0
@type function
/*/

User Function BIAPN001()

	Local _sqlB2 := ""
	Local oExcel := nil
	Private qtd  := 0

	RpcSetType(3)
	RpcSetEnv("01","01")

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Produtos com diferença no estoque"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "Produto"		,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "B2_LOCAL"		,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "B2_QATU"		,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "B2_QACLASS"	,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "B2_RESERVA"	,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CalcEst"		,1,1)

	_sqlB2 := " SELECT B2_LOCAL, "
	_sqlB2 += "        B2_COD, "
	_sqlB2 += "        B2_QATU, "
	_sqlB2 += "        B2_QACLASS, "
	_sqlB2 += "        B2_RESERVA " 
	_sqlB2 += "   FROM " + RetSqlName("SB2") + " with (nolock) "
	_sqlB2 += "  WHERE 1 = 1 "
	_sqlB2 += "    AND B2_FILIAL = '" + xFilial("SB2") + "' "
	_sqlB2 += "    AND B2_COD < 'A' "
	_sqlB2 += "    AND D_E_L_E_T_ = ' ' "	
	TcQUERY _sqlB2 New ALIAS "qlB2"
	dbSelectArea("qlB2")
	qlB2->(dbGoTop())

	Conout("> ANALISE DE ESTOQUE: iniciada   Data: "+ dToC( Date()) + Space(1) + Time())

	While !Eof()

		aSaldos := CalcEst(qlB2->B2_COD, qlB2->B2_LOCAL, dDataBase + 1)
		nQuant  := aSaldos[1]
		nCusto  := aSaldos[2]

		if(nQuant != qlB2->B2_QATU)

			qtd = qtd + 1

			oExcel:AddRow(nxPlan, nxTabl, { qlB2->B2_COD,;
			qlB2->B2_LOCAL,;
			qlB2->B2_QATU,;
			qlB2->B2_QACLASS,;
			qlB2->B2_RESERVA,;
			nQuant})
		endif

		qlB2->(DbSkip())

	End

	qlB2->(dbCloseArea())

	Conout("> ANALISE DE ESTOQUE: finalizada com "+ STR(qtd) +" produtos com diferença no estoque.  Data: "+ dToC( Date()) + Space(1) + Time())

	if(qtd > 0)
		Gravar(oExcel)
	endif

	RESET ENVIRONMENT

Return

Static Function Gravar(oExcel)

	aData := {}
	GetTimeStamp( Date() , aData) 
	hora := SUBSTR( TIME(), 1, 2)              // Resulta: 10
	minuto := SUBSTR( TIME(), 4, 2)              // Resulta: 37
	nome := aData[1]+"_"+hora+"_"+minuto

	Conout("> Gerando arquivo Produtos_diferenca_estoque"+ nome +" em C:\TEMP...")

	xArqTemp := "Produtos_diferenca_estoque" + nome

	If File("\P10\Estoque\"+xArqTemp+".xml")
		If fErase("\P10\Estoque\"+xArqTemp+".xml") == -1
			Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + '\P10\Estoque\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
		EndIf
	EndIf

	oExcel:Activate()
	oExcel:GetXMLFile("\P10\Estoque\"+xArqTemp+".xml")

	Conout("> Arquivo gerado.")

Return
