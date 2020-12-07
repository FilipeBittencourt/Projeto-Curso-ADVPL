#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"



/*/{Protheus.doc} BIAFG018
@author Gabriel Rossi Mafioletti
@since 21/08/2017
@version 1.0
@description Transfere produtos do tipo embalagem que são do outsourcing
do armazém 01 para o armazém 07
@type function
/*/


User Function BIAFG018(_dDataDe,_dDataAte)

	Local _cAlias	:=	GetNextAlias()
	
	Local _cDataDe	:=	DtoS(_dDataDe)
	Local _cDataAte	:=	DtoS(_dDataAte)
	Local _lTransf
	Local _cErro	:=	""
	Local cNextNum := Nil
	
	PRIVATE cCusMed  := GetMv("MV_CUSMED")
	PRIVATE aRegSD3  := {}
	
	BeginSql Alias _cAlias

		SELECT  SC2.C2_PRODUTO ,
		        SD3.D3_COD ,
		        SD3.D3_DOC ,
		        SD3.D3_LOCAL ,
		        SD3.D3_EMISSAO ,
		        SD3.D3_NUMSEQ ,
		        SD3.D3_QUANT ,
		        SD3.R_E_C_N_O_ REGSD3
		FROM    SD3010 SD3
		        INNER JOIN SC2010 SC2 ON SC2.C2_FILIAL = '01'
		                                 AND SC2.C2_NUM = SUBSTRING(SD3.D3_OP, 1, 6)
		                                 AND SC2.C2_ITEM = SUBSTRING(SD3.D3_OP, 7, 2)
		                                 AND SC2.C2_SEQUEN = SUBSTRING(SD3.D3_OP, 9, 3)
		                                 AND SC2.C2_PRODUTO IN (
		                                 SELECT XB1.B1_COD
		                                 FROM   SB1010 XB1
		                                        INNER JOIN SBZ050 SBZ ON SBZ.BZ_COD = XB1.B1_COD
		                                                              AND SBZ.%NotDel%
		                                        INNER JOIN ZZ6010 ZZ6 ON ZZ6.ZZ6_COD = XB1.B1_YFORMAT
		                                                              AND ZZ6.%NotDel%
		                                                              AND ZZ6_EMPFAB = '01'
		                                        INNER JOIN ZZ7010 ZZ7 ON ZZ7.ZZ7_COD = XB1.B1_YLINHA
		                                                              AND ZZ7.ZZ7_LINSEQ = XB1.B1_YLINSEQ
		                                                              AND ZZ7.%NotDel%
		                                                              AND SUBSTRING(ZZ7_EMP,
		                                                              1, 2) = '05'
		                                 WHERE  XB1.B1_FILIAL = '  '
		                                        AND XB1.%NotDel% )
		                                 AND SC2.%NotDel%
		        INNER JOIN SB1010 SB1 ON SB1.B1_FILIAL = '  '
		                                 AND SB1.B1_COD = SC2.C2_PRODUTO
		                                 AND SB1.B1_YCATEG IN ('O','C')		                                 
		                                 AND SB1.%NotDel%
		WHERE   SD3.D3_FILIAL = '01'
		        AND SD3.D3_EMISSAO BETWEEN %Exp:_cDataDe% AND %Exp:_cDataAte%
		        AND SD3.D3_GRUPO = '104A'
		        AND SD3.D3_TM = '999'
		        AND SD3.%NotDel%

	
	EndSql

	While (_cAlias)->(!EOF())
		cNextNum	:=	NextNumero("SD3",2,"D3_DOC",.T.)	
		_lTransf := a260Processa(;
									(_cAlias)->D3_COD,;  							//Codigo do Produto Origem 	- Obrigatorio
									(_cAlias)->D3_LOCAL,;       					//Almox Origem            			- Obrigatorio
									(_cAlias)->D3_QUANT,; 							//Quantidade 1a UM      			- Obrigatorio
									cNextNum,;							//Documento                			- Obrigatorio
									Stod((_cAlias)->D3_EMISSAO),;							//Data                     			- Obrigatorio
									ConvUM((_cAlias)->D3_COD,(_cAlias)->D3_QUANT,0,2),;	            //Quantidade 2a UM
									Nil,; 								//Sub-Lote                 			- Obrigatorio se Rastro "S"
									Nil,;	    						//Lote	                     		- Obrigatorio se usa Rastro
									Nil,;								//Validade                 			- Obrigatorio se usa Rastro
									Nil,;            					//Numero de Serie
									Nil,;								//Localizacao Origem
									(_cAlias)->D3_COD,;		     		//Codigo do Produto Destino	- Obrigatorio
									"07",;								//Almox Destino            			- Obrigatorio,
									Nil,;					        	//Localizacao Destino
									.F.,; 								//Indica se movimento e estorno
									Nil,;    							//Numero do registro original (utilizado estorno)
									Nil,;                               //Numero do registro destino (utilizado estorno)
									"BIAFG018";                         //Indicacao do programa que originou os lancamentos (se NIL, considera MATA260)
								)
		If _lTransf
		
			Reclock("SD3",.F.)
			SD3->D3_YOBS	:=	(_cAlias)->("Prod: " + Alltrim(D3_COD) + " DOC: " + Alltrim(D3_DOC) + " LOC: " + Alltrim(D3_LOCAL) + " NUMSEQ: " + Alltrim(D3_NUMSEQ))
			SD3->(MsUnlock())
			
			SD3->(DbGoTo((_cAlias)->REGSD3))
			Reclock("SD3",.F.)
			SD3->(DbDelete())
			SD3->(MsUnlock())
		Else
			_cErro += (_cAlias)->("Prod: " + Alltrim(D3_COD) + " DOC: " + Alltrim(D3_DOC) + " LOC: " + Alltrim(D3_LOCAL) + " NUMSEQ: " + Alltrim(D3_NUMSEQ)) + CRLF	
		EndIf
		(_cAlias)->(DbSkip())
	EndDo

	If Len(_cErro) > 0
	
		MsgInfo("Ocorreram Erros Durante as Trasnferências, Seguem: " + CRLF + _cErro,"BIAFG018")
	
	EndIf
	(_cAlias)->(DbCloseArea())

Return


/*/{Protheus.doc} BIAFG018_Acerto
@author Rodrigo Ribeiro Agostini
@since 06/11/2018
@version 1.0
@description Transfere produtos do tipo embalagem que são do outsourcing
do armazém 01 para o armazém 07 para determinados documentos em um determinado período
@type function
/*/
User Function YBIAFG018_Acerto(_dDataDe,_dDataAte, _sDocumentos)

	Local _cAlias	:=	GetNextAlias()
	
	Local _cDataDe	:=	DtoS(_dDataDe)
	Local _cDataAte	:=	DtoS(_dDataAte)
	Local _lTransf
	Local _cErro	:=	""
	Local cNextNum := Nil
	Local _cIN := "%" + FormatIn(_sDocumentos,",") + "%"
	
	PRIVATE cCusMed  := GetMv("MV_CUSMED")
	PRIVATE aRegSD3  := {}
	
	BeginSql Alias _cAlias

		SELECT  SC2.C2_PRODUTO ,
		        SD3.D3_COD ,
		        SD3.D3_DOC ,
		        SD3.D3_LOCAL ,
		        SD3.D3_EMISSAO ,
		        SD3.D3_NUMSEQ ,
		        SD3.D3_QUANT ,
		        SD3.R_E_C_N_O_ REGSD3
		FROM    SD3010 SD3
		        INNER JOIN SC2010 SC2 ON SC2.C2_FILIAL = '01'
		                                 AND SC2.C2_NUM = SUBSTRING(SD3.D3_OP, 1, 6)
		                                 AND SC2.C2_ITEM = SUBSTRING(SD3.D3_OP, 7, 2)
		                                 AND SC2.C2_SEQUEN = SUBSTRING(SD3.D3_OP, 9, 3)
		                                 AND SC2.C2_PRODUTO IN (
		                                 SELECT XB1.B1_COD
		                                 FROM   SB1010 XB1
		                                        INNER JOIN SBZ050 SBZ ON SBZ.BZ_COD = XB1.B1_COD
		                                                              AND SBZ.%NotDel%
		                                        INNER JOIN ZZ6010 ZZ6 ON ZZ6.ZZ6_COD = XB1.B1_YFORMAT
		                                                              AND ZZ6.%NotDel%
		                                                              AND ZZ6_EMPFAB = '01'
		                                        INNER JOIN ZZ7010 ZZ7 ON ZZ7.ZZ7_COD = XB1.B1_YLINHA
		                                                              AND ZZ7.ZZ7_LINSEQ = XB1.B1_YLINSEQ
		                                                              AND ZZ7.%NotDel%
		                                                              AND SUBSTRING(ZZ7_EMP,
		                                                              1, 2) = '05'
		                                 WHERE  XB1.B1_FILIAL = '  '
		                                        AND XB1.%NotDel% )
		                                 AND SC2.%NotDel%
		        INNER JOIN SB1010 SB1 ON SB1.B1_FILIAL = '  '
		                                 AND SB1.B1_COD = SC2.C2_PRODUTO
		                                 AND SB1.B1_YCATEG = 'O'
		                                 AND SB1.%NotDel%
		WHERE   SD3.D3_FILIAL = '01'
		        AND SD3.D3_EMISSAO BETWEEN %Exp:_cDataDe% AND %Exp:_cDataAte%
		        AND SD3.D3_GRUPO = '104A'
		        AND SD3.D3_TM = '999'
		        AND SD3.%NotDel%
		        AND SD3.D3_DOC IN %Exp:_CIN%

	
	EndSql

	
	While (_cAlias)->(!EOF())
		cNextNum	:=	NextNumero("SD3",2,"D3_DOC",.T.)	
		_lTransf := a260Processa(;
									(_cAlias)->D3_COD,;  							//Codigo do Produto Origem 	- Obrigatorio
									(_cAlias)->D3_LOCAL,;       					//Almox Origem            			- Obrigatorio
									(_cAlias)->D3_QUANT,; 							//Quantidade 1a UM      			- Obrigatorio
									cNextNum,;							//Documento                			- Obrigatorio
									Stod((_cAlias)->D3_EMISSAO),;							//Data                     			- Obrigatorio
									ConvUM((_cAlias)->D3_COD,(_cAlias)->D3_QUANT,0,2),;	            //Quantidade 2a UM
									Nil,; 								//Sub-Lote                 			- Obrigatorio se Rastro "S"
									Nil,;	    						//Lote	                     		- Obrigatorio se usa Rastro
									Nil,;								//Validade                 			- Obrigatorio se usa Rastro
									Nil,;            					//Numero de Serie
									Nil,;								//Localizacao Origem
									(_cAlias)->D3_COD,;		     		//Codigo do Produto Destino	- Obrigatorio
									"07",;								//Almox Destino            			- Obrigatorio,
									Nil,;					        	//Localizacao Destino
									.F.,; 								//Indica se movimento e estorno
									Nil,;    							//Numero do registro original (utilizado estorno)
									Nil,;                               //Numero do registro destino (utilizado estorno)
									"BIAFG018";                         //Indicacao do programa que originou os lancamentos (se NIL, considera MATA260)
								)
		If _lTransf
		
			Reclock("SD3",.F.)
			SD3->D3_YOBS	:=	(_cAlias)->("Prod: " + Alltrim(D3_COD) + " DOC: " + Alltrim(D3_DOC) + " LOC: " + Alltrim(D3_LOCAL) + " NUMSEQ: " + Alltrim(D3_NUMSEQ))
			SD3->(MsUnlock())
			
			SD3->(DbGoTo((_cAlias)->REGSD3))
			Reclock("SD3",.F.)
			SD3->(DbDelete())
			SD3->(MsUnlock())
		Else
			_cErro += (_cAlias)->("Prod: " + Alltrim(D3_COD) + " DOC: " + Alltrim(D3_DOC) + " LOC: " + Alltrim(D3_LOCAL) + " NUMSEQ: " + Alltrim(D3_NUMSEQ)) + CRLF	
		EndIf
		(_cAlias)->(DbSkip())
	EndDo

	If Len(_cErro) > 0
	
		MsgInfo("Ocorreram Erros Durante as Trasnferências, Seguem: " + CRLF + _cErro,"BIAFG018")
	
	EndIf
	(_cAlias)->(DbCloseArea())
	
	
Return

/*

PARA CHAMADA E CORRECAO DO PROBLEMA REFERENCIADO AO TICKET 9692 E 9694
REALIZADO DIA 06/11/2018

*/

User Function AcertoTransfEmb()
	
	RPCSetType(3)
	RPCSetEnv("01","01")
	
	U_YBIAFG018_Acerto(StoD('20181101'),StoD('20181105'),"ZERVOXTQ7,ZERVOXTQI,ZERVOXTQO,ZERVOXTQQ,ZERVOXTQS,ZERVOXTQU,ZERVOXTQV,ZERVOXTPD,ZERVOXTPE,ZERVOXTPF,ZERVOXTQK,ZERVOXTPH,ZERVOXTPJ,ZERVOXTQ9,ZERVOXTQB,ZERVOXTQD,ZERVOXTQF,ZERVOXTQG,ZERVOXTNY,ZERVOXTTJ,ZERVOXTTK,ZERVOXTTM,ZERVOXTTN,ZERVOXTTP,ZERVOXTTR,ZERVOXTU6,ZERVOXTU8,ZERVOXTU9")

Return