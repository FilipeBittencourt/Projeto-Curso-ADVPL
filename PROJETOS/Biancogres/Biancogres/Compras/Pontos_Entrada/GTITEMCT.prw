//---------------------------------------------------------------
// Ponto de entrada na importação do CT-e para carregar em
// tela os campos customizados
// Autor..: ConexãoNF-e
// Data...: 16/08/2018
// Retorno: Array com os dados para passar via MsExecAuto
//---------------------------------------------------------------
User Function GTITEMCT()
Local aAreaAnt  := GetArea()
Local cTipo     := PARAMIXB[1] // "1" Entrada // "2" Saída
Local aCabecCTe := PARAMIXB[2]
Local aItensCTe := PARAMIXB[3]
Local aAddCampo := {}
Local cCNPJ     := ""
Local tam := LEN(aItensCTe);
	// Captura o cnpj do emitente da NF origem através da chave do XML
	Do Case
		Case cTipo == "1"
			If aScan(aItensCTe[tam],{|x| Alltrim(x[1]) == "D1_LOCAL" }) == 0
				aAdd(aAddCampo,{"D1_LOCAL", SD1->D1_LOCAL, Nil})
			else
				aItensCTe[tam][aScan(aItensCTe[tam],{|x| Alltrim(x[1]) == "D1_LOCAL" })][2] := SD1->D1_LOCAL
			endif	
		Case cTipo == "2"
			//cCNPJ := SubStr(SF2->F2_CHVNFE,7,14)
	EndCase

	

RestArea(aAreaAnt)
Return aAddCampo
