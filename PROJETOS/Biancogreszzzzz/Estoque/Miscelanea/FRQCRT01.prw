#include "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRQCRT01	ºAutor  ³Fernando Rocha      º Data ³ 18/10/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Transferencia para 6T na baixa de pre reequisicao.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BIANCOGRES 												  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#DEFINE TIT_MSG "SISTEMA - REQ.PRODUTO COMUM"

User Function FRQCRT01(cEmpReq,cDoc,cProduto,nQuantidade,cLocOri,cLocDest,_aCustSD3,_lReq)
	Local aArea := GetArea()
	Local aAreaD3 := GetArea("SD3")  
	Local I

	Default _lReq := .T.  

	TransfereArmazem(cDoc,cProduto,nQuantidade,cLocOri,cLocDest,_aCustSD3)

	//Campos Customizado no SD3
	SD3->(dbSetOrder(2))
	IF SD3->( dbSeek(xfilial("SD3")+PADL(cDoc,TamSX3("D3_DOC")[1])+PADL(cProduto,TamSX3("D3_COD")[1])) )   

		//Atualizando movimentos da transferencia	
		While !SD3->(Eof()) .And. SD3->(D3_FILIAL+D3_DOC+D3_COD) == (xfilial("SD3")+PADL(cDoc,TamSX3("D3_DOC")[1])+PADL(cProduto,TamSX3("D3_COD")[1]))

			If SD3->D3_CF $ "DE4_RE4"

				RecLock("SD3",.F.)

				For I := 1 To Len(_aCustSD3)
					&("SD3->"+AllTrim(_aCustSD3[I][1])) := _aCustSD3[I][2]	
				Next I

				SD3->(MsUnLock())

			EndIf

			SD3->(DbSkip())
		EndDo      

		RestArea(aAreaD3)
		RestArea(aArea)
		Return(.T.)

	ENDIF

	RestArea(aAreaD3)
	RestArea(aArea)
Return(.F.)

Static function TransfereArmazem(cDoc,cProduto,nQuantidade,cLocOri,cLocDest,_aCustSD3)

	Local _nQtdPri
	Local _nQtdSeg          

	PRIVATE cCusMed  := GetMv("MV_CUSMED")
	PRIVATE aRegSD3  := {}

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xfilial("SB1")+cProduto))

	_nQtdPri := nQuantidade
	_nQtdSeg := CONVUM(SB1->B1_COD,_nQtdPri,0,2)

	a260Processa(cProduto,;  					//Codigo do Produto Origem 	- Obrigatorio
	cLocOri,;							   		//Almox Origem            			- Obrigatorio
	_nQtdPri,; 									//Quantidade 1a UM      			- Obrigatorio
	cDoc,;										//Documento                			- Obrigatorio
	dDataBase,;									//Data                     			- Obrigatorio
	_nQtdSeg,;									//Quantidade 2a UM
	Nil,; 										//Sub-Lote                 			- Obrigatorio se Rastro "S"
	Nil,;										//Lote	                     		- Obrigatorio se usa Rastro
	Nil,;										//Validade                 			- Obrigatorio se usa Rastro
	Nil,;										//Numero de Serie
	Nil,;										//Localizacao Origem
	cProduto,;									//Codigo do Produto Destino	- Obrigatorio
	cLocDest,;									//Almox Destino            			- Obrigatorio,
	Nil,;										//Localizacao Destino
	.F.,;										//Indica se movimento e estorno
	Nil,;										//Numero do registro original (utilizado estorno)
	Nil,;                              			//Numero do registro destino (utilizado estorno)
	Nil,;                              			//Indicacao do programa que originou os lancamentos (se NIL, considera MATA260)
	Nil,;                              			//cEstFis    	- Estrutura Fisica          (APDL)
	Nil,;                                      	//cServico   	- Servico                   (APDL)
	Nil,;                                  		//cTarefa    	- Tarefa                    (APDL)
	Nil,;                                       //cAtividade 	- Atividade                 (APDL)
	Nil,;                                       //cAnomalia  	- Houve Anomalia? (S/N)     (APDL)
	Nil,;                                       //cEstDest   	- Estrututa Fisica Destino  (APDL)
	Nil,;                              			//cEndDest   	- Endereco Destino          (APDL)
	Nil,;                              			//cHrInicio  	- Hora Inicio               (APDL)
	.F.,;                              			//cAtuEst    	- Atualiza Estoque? (S/N)   (APDL)
	Nil,;                              		 	//cCarga     	- Numero da Carga           (APDL)
	Nil,;                              		 	//cUnitiza   	- Numero do Unitizador      (APDL)
	Nil,;                              		   	//cOrdTar    	- Ordem da Tarefa           (APDL)
	Nil,;                                 		//cOrdAti    	- Ordem da Atividade        (APDL)
	Nil,;                          				//cRHumano  	- Recurso Humano            (APDL)
	Nil,;                              			//cRFisico   	- Recurso Fisico            (APDL)
	Nil,;                              			//nPotencia  	- Potencia do Lote
	Nil,;                              			//cLoteDest  	- Lote Destino da Transferencia
	Nil,;                          				//dDtVldDest 	- Validade Lote Destino da Trasnferencia
	Nil,;                              			//cCAT83O    	- Cod.Cat83 Produto Origem
	Nil)                           				//cCAT83D    	- Cod.Cat83 Produto Destino

Return


