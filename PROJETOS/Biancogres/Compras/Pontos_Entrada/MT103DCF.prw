#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

User Function MT103DCF()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := MT103DCF
Empresa   := Biancogres Cerâmica S/A
Data      := 15/05/12
Uso       := Compras
Aplicação := Ponto de entrada que inclui um botão da aba do DANFE na nota
.           fiscal de entrada MATA103 e MATA116.
.           Originalmente usado para busca da chave na tabela de gravação
.           de XML.
.           Não é incluido nenhum novo campo com é a proposta do P.E.
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Local lInclui := PARAMIXB[1]
Local lAltera := PARAMIXB[2]
Local lVisual := PARAMIXB[3]
Local aCamposPar := PARAMIXB[4]
Local aCamposRet := {}
Local oDlgChv
Local oButton1
Local oGet1
Local cGet1 := ""

If Upper(Alltrim(cEspecie)) $ "SPED/CTE"
	Y0001 := " SELECT DS_CHAVENF
	Y0001 += "   FROM " + RetSqlName("SDS")
	Y0001 += "  WHERE DS_FILIAL = '"+xFilial("SDS")+"'
	Y0001 += "    AND DS_DOC IN('"+cNFiscal+"','"+StrZero(Val(cNFiscal),6)+"')
	Y0001 += "    AND DS_SERIE = '"+cSerie+"'
	Y0001 += "    AND DS_FORNEC = '"+cA100For+"'
	Y0001 += "    AND DS_LOJA = '"+cLoja+"'
	Y0001 += "    AND DS_EMISSA = '"+dtos(dDEmissao)+"'
	Y0001 += "    AND DS_STATUS = ' '
	Y0001 += "    AND D_E_L_E_T_ = ' '
	TcQuery Y0001 ALIAS "Y001" NEW
	dbSelectArea("Y001")
	dbGoTop()
	cGet1 := Y001->DS_CHAVENF
	Y001->(dbCloseArea())
	If !Empty(cGet1)
		DEFINE MSDIALOG oDlgChv TITLE "Chave Nfe" FROM 000, 000  TO 058, 523 COLORS 0, 16777215 PIXEL
		@ 009, 010 MSGET oGet1 VAR cGet1 SIZE 215, 010 OF oDlgChv COLORS 0, 16777215 PIXEL
		@ 009, 230 BUTTON oButton1 PROMPT "Ok" SIZE 021, 012 OF oDlgChv ACTION oDlgChv:End() PIXEL
		ACTIVATE MSDIALOG oDlgChv
	Else
		MsgALERT("Chave não localizada."+CHR(13)+CHR(13)+"Favor verificar, pois alguma informação da nota foi digitada errada ou o arquivo XML ainda não chegou!!!")
	EndIf
	
Else
	MsgSTOP("Apenas as especies SPED e CTE estão configuradas para efetuar a busca da CHAVE!!!")
EndIf

//TESTE CONEXAO INICIO
	conout(" ["+ Time() +"] Mensagem ConexãoNF-e")
	conout(" > MT103DCF:")

	If Type("cEspecie") <> "U"
		conout("    cEspecie: '" + cEspecie + "'")
	else
		conout("    cEspecie não declarada")
	EndIf

	If Empty(SF1->F1_ESPECIE)
		conout("    SF1->F1_ESPECIE = ''")
	else
		conout("    SF1->F1_ESPECIE = '" + SF1->F1_ESPECIE + "'")
	EndIf
//TESTE CONEXAO FIM
Return aCamposRet
