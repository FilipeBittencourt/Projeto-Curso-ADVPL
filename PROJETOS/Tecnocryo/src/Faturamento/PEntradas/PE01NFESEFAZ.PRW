#include "protheus.ch"

//=======================================================================================================================================| 
// Progama   : PE01NFESEFAZ                                                 															 |    
// Tipo      : Ponto de Entrada                                             															 | 
// Autor     : Jessé Augsuto                                                															 |
// Data      : 20/07/2016                                                   															 |
//=======================================================================================================================================|
// Descrição : Atualiza o conteúdo do parâmetro resposável pelo envio, via anexo, do Documento Fiscal no processo de Faturamento         |
//=======================================================================================================================================|
User Function PE01NFESEFAZ()

	//======================================================================================================================================|
	// Sql responsável pela consulta/atualização do conteúdo do parâmetro MV_NFEDISD  														 |
	//======================================================================================================================================|
	Local aArea     := GetArea()
	Local cWorkArea := GetNextAlias()
	Local cQuery    := ""   

	// Local aRetorno	 := {}
	Local aCfop	 := {"904","910","915","920","921","949","202","553","913"}

	//ACO INICIO: Apaga e-mail destinatário para notas de remessa
	//{aProd,cMensCli,cMensFis,aDest,aNota,aInfoItem,aDupl,aTransp,aEntrega,aRetirada,aVeiculo,aReboque,aNfVincRur,aEspVol,aNfVinc,aDetPag,aObsCont}
	Local aProd	 		:= aClone( ParamIxb[01] )
	Local cMensCli	 	:= ParamIxb[02]
	Local cMensFis	 	:= ParamIxb[03]
	Local aDest	 		:= aClone( ParamIxb[04] )
	Local aNota	 		:= aClone( ParamIxb[05] )
	Local aInfoItem 	:= aClone( ParamIxb[06] )
	Local aDupl	 		:= aClone( ParamIxb[07] )
	Local aTransp	 	:= aClone( ParamIxb[08] )
	Local aEntrega	 	:= aClone( ParamIxb[09] )
	Local aRetirada 	:= aClone( ParamIxb[10] )
	Local aVeiculo	 	:= aClone( ParamIxb[11] )
	Local aReboque	 	:= aClone( ParamIxb[12] )
	Local aNfVincRur	:= aClone( ParamIxb[13] )
	Local aEspVol	 	:= aClone( ParamIxb[14] )
	Local aNfVinc	 	:= aClone( ParamIxb[15] )
	Local aDetPag	 	:= aClone( ParamIxb[16] )
	Local aObsCont	 	:= aClone( ParamIxb[17] )
	Local x, y
	Local lRemessa	 := .F.

	FOR x := 1 TO LEN( aCfop )
		FOR y:=1 TO LEN( aProd )
			IF Right( rtrim( aProd[ y ][7] ), 3 ) ==  aCfop[x]
				lRemessa	 := .T.
			ENDIF
		NEXT
	NEXT
	
	IF lRemessa .and. Left(aDest[1],8) == "27193705" .and. ! Empty( aDest[12] )
		aDest[16] := "" //e-mail destinatário
	ENDIF
	//ACO FIM: Apaga e-mail destinatário para notas de remessa

	cQuery := " SELECT COUNT(*) QTD						 "
	cQuery += " FROM SPED000 (NOLOCK) 						 "                     
	cQuery += " WHERE ID_ENT BETWEEN '      ' AND 'ZZZZZZ'  " 
	cQuery += " AND PARAMETRO  = 'MV_NFEDISD'				 "
	cQuery += " AND CONTEUDO   != 1 						 "
	cQuery += " AND D_E_L_E_T_ != '*' 						 " 

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cWorkArea, .T., .F. )

	//============================================================================|
	// Verifica se a quantiade de registros reornados é igual é superior a zero.  |
	//                                                                            | 
	//============================================================================|
	If (cWorkArea)->QTD > 0

		cQuery := " UPDATE SPED000   							"
		cQuery += " SET CONTEUDO = 1 							"  
		cQuery += " WHERE ID_ENT BETWEEN '      ' AND 'ZZZZZZ'	"
		cQuery += " AND PARAMETRO  = 'MV_NFEDISD' 				"
		cQuery += " AND CONTEUDO   != 1 							"
		cQuery += " AND D_E_L_E_T_ != '*' 						"

		If TCSQLExec(cQuery)  == 0

			Aviso("Atenção"," Falha no processo de atualização do parâmetro MV_NFEDISD. Favor verificar.",{"Ok"})
		Endif 
	Endif 

	(cWorkArea)->(dbCloseArea()) 

	// aRetorno := aClone(PARAMIXB)

	RestArea(aArea)

Return {aProd,cMensCli,cMensFis,aDest,aNota,aInfoItem,aDupl,aTransp,aEntrega,aRetirada,aVeiculo,aReboque,aNfVincRur,aEspVol,aNfVinc,aDetPag,aObsCont}
