#INCLUDE "TOPCONN.CH"
#include "rwmake.ch"


/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Barbara Luan Gomes Coelho
Programa  := BIABC003
Empresa   := Biancogres Cerâmica S/A
Data      := 05/02/19
Uso       := Compras
Aplicação := Retorna as informações de NF Saida e NF Entrada a partir de um processo
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
User Function BIABC003(nNumDoc,sTpDoc)
Local cSQL := ""
Local cQry := GetNextAlias()

if !Empty(nNumDoc)
	cSQL := " SELECT Z26_NUMPRC,Z26_NFISC NF_SAIDA, Z26_SERIE SERIE_SAIDA, SUBSTRING(Z26_OBS,1,9)NF_ENTRADA,SUBSTRING(Z26_OBS,10,2)SERIE_ENTRADA,"
	cSQL += "        SUBSTRING(Z25_DTINI,7,2)+'/'+SUBSTRING(Z25_DTINI,5,2) +'/'+ SUBSTRING(Z25_DTINI,1,4) DT_EMISSAO,
	cSQL += "        CASE Z25_DTLNFE WHEN '' THEN '-' ELSE SUBSTRING(Z25_DTLNFE,7,2)+'/'+SUBSTRING(Z25_DTLNFE,5,2) +'/'+ SUBSTRING(Z25_DTLNFE,1,4) END DT_ENTRADA  
	cSQL += " FROM " + RetSQLName("Z25") + " Z25 "
	cSQL += " INNER JOIN " + RetSQLName("Z26") + " Z26" 
	cSQL += " ON (Z25_FILIAL = Z26_FILIAL AND Z25_NUM = Z26_NUMPRC AND Z26.D_E_L_E_T_ = ' ') "
	cSQL += " WHERE Z26_OBS <> '' "	
	cSQL += " AND Z25.D_E_L_E_T_ = ' ' "
	cSQL += " AND Z26_ITEMNF = 'XX'"	
	cSQL += " AND Z25_FILIAL = " + ValToSQL(xFilial("Z25"))

	if sTpDoc = 'P'	

		cSQL += " AND Z25_NUM = '" + nNumDoc + "'"
	else
		if sTpDoc = 'E'	

			cSQL += " AND Z26_OBS = '" + nNumDoc + "'" 
		end if		
	end if

	TcQuery cSQL New Alias (cQry)
    
    if Empty((cQry)->NF_SAIDA) .And. Empty((cQry)->NF_ENTRADA)
    	MsgSTOP("Não há NF's associadas a este processo.", "Processo: " + (cQry)->Z26_NUMPRC)
    	Return
    end if
	@ 0,0 TO 230,280 DIALOG oEntra TITLE "Dados das NF's do processo: " + (cQry)->Z26_NUMPRC	
	
	@ 15,35 SAY "NF Saída:   " + (cQry)->NF_SAIDA + "  Série: " + (cQry)->SERIE_SAIDA
	@ 35,35 SAY "NF Entrada: " + (cQry)->NF_ENTRADA + "  Série: " + (cQry)->SERIE_ENTRADA
	@ 55,35 SAY "Dt Lançam.: " + (cQry)->DT_ENTRADA 
	
	@ 85,60 BMPBUTTON TYPE 1 ACTION Close( oEntra )

	ACTIVATE DIALOG oEntra CENTERED
	(cQry)->(dbCloseArea())
end if
Return