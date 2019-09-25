#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH" 

// ALFONSO - FACILE 2018NOV01
// ROTINAS PARA O PROJETO CAMPOS
// VALIDA PARA CAMPO PERSONALIZADO SE É CLI PADRAO  CAMPO NOVO NÃO É OBRIGATORIO
//===============================================================================
//
// return U_VLDOFI()   

// VALIDA SE NÃO É CLIENTE PADRAO COLOCAR SE USA OFICINA OU NAO
// Rotina para colocar no PE MA030TOK (Gravação da SA1-CLIENTES)
user function VLDOFI()
	Local lRet := .F.
	//Local cMV :=SuperGetmv("MV_CLIPAD")
	//SuperGetmv("MV_CLIPAD",, "000001")
	// if (SuperGetmv("MV_CLIPAD") <> (M->A1_COD)  .AND. Empty(M->A1_YOFIC))
	if (SuperGetmv("MV_CLIPAD",, "000001") <> (M->A1_COD)  .AND. Empty(M->A1_YOFIC))
		ShowHelpDlg("Atenção", {"Obrigatório combo Oficina."}, 5, {"Favor informar."}, 5)
		return .f.
	endif

return .t.  

// 2018NOV06 - ALFONSO
// SE CLIENTE DO ORÇAMENTO OU DA VENDA ASSISTIDA É OFICINA; ALTERA A1_YOFIC=S
//
User Function CLIOFI(cA1cod,cA1loja,cL1ofi)
	//cL1ofi = L1_YOFICIN 1=sim; 2=nao

	Local aArea := SA1->(GetArea())
	Local cMsg  := ''

	DbSelectArea("SA1") 
	SA1->(DbSetOrder(1)) // A1_FILIAL + A1_COD + A1_LOJA order by pelo indice 1

	IF (SA1->(DBSeek(FWXFilial("SA1")+cA1cod+cA1loja)))
		RecLock('SA1', .F.) // Trava o registro pára Aletração coloca .F. se for ,  .T. seria uma inserção
		SA1->A1_YOFIC  := cL1ofi
		//alert("entrou CLI:" + cA1cod + "LJ: " + cA1loja + "OFI: " + cL1ofi)
		SA1->(MsUnlock()) // Libera tabela novamente
	EndIf

	RestArea(aArea)	
Return (.T.)


User Function PILOTO(cCodProd)

	/* SE OS CAMPO B0_YPILOT= S; OU ZZZ_YPILOT=S; DEVE GRABAR NAS TABELAS DE VENDAS: 
	C6_YPILOT = S
	D2_YPILOT = S
	L2_YPILOT = S
	LR_YPILOT = S
	UB_YPILOT = S
	Para indicar que estao sendo monitorados no BI
	===========================================================================
	FUNÇAO, Utilizada nos gatilhos nos campos do produtos de cada tabela acima
	===========================================================================
	REGRA
	Se segmento está ativo MV_YZZZATI = .T. buscar conteúdo do ZZZ_YPILOT para ; SEGMENTO+CODIGO DE PRODUTO, 
	se ZZZ_YPILOT=S, retornar S. Se não, retornar vazio ‘’.

	Se segmento não está ativo MV_YZZZATI = .F., buscar o conteúdo do B0_YPILOT, para FILIAL+COD DE PRODUTO, 
	se B0_YPILOT =S, , retornar S Se não, retornar vazio ‘’.

	*/ 

	Local lZZZAtivo	:= SuperGetMV("MV_YZZZATI",.F.,.F.)
	Local cSegmento	:= U_SegmEmpresa()
	Local cPilot := .F.
	Local cPilotOK :=''

    
		IF lZZZAtivo 
			DbSelectArea("ZZZ")
			DbSetOrder(1) // ZZZ_FILIAL+ZZZ_COD+ZZZ_SEGMEN)     
			cPilot := DBSeek(FWXFilial("ZZZ")+ cCodProd + cSegmento)
			cPilotOK := ZZZ->ZZZ_YPILOT
		ELSE  
			// busca na SB0 
			DbSelectArea("SB0")
			DbSetOrder(1)			
			cPilot:= DBSeek(FWXFilial("SB0")+ cCodProd)  // sem segmento
			cPilotOK := SB0->B0_YPILOT
		END IF
		If cPilotOK =='S' 		
			Return ('S')
		EndIf
	

Return ('') 

User Function Rentab(cCodProd)

	/* BUSCAR 	ZZZ_YLUCRO  OU B0_YLUCRO
	===========================================================================
	FUNÇAO, Utilizada nos gatilhos nos campos do produtos de cada tabela
	===========================================================================
	REGRA
	Se segmento está ativo MV_YZZZATI = .T. buscar conteúdo do ZZZ_YLUCRO para ; SEGMENTO+CODIGO DE PRODUTO, 
	retornar VALOR ZZZ_YLUCRO

	Se segmento não está ativo MV_YZZZATI = .F., buscar o conteúdo do B0_YLUCRO, para FILIAL+COD DE PRODUTO, 
	retornar VALOR B0_YLUCRO

	*/ 

	Local lZZZAtivo	:= SuperGetMV("MV_YZZZATI",.F.,.F.)
	Local cSegmento	:= U_SegmEmpresa()
	Local cPilot := .F.
	Local cPilotOK :=''
	local nLucro :=0

	IF lZZZAtivo 
		DbSelectArea("ZZZ")
		DbSetOrder(1) // ZZZ_FILIAL+ZZZ_COD+ZZZ_SEGMEN)     
		cPilot := DBSeek(FWXFilial("ZZZ")+ cCodProd + cSegmento)
		nLucro := ZZZ->ZZZ_YLUCRO
	ELSE  
		// busca na SB0 
		DbSelectArea("SB0")
		DbSetOrder(1)			
		cPilot:= DBSeek(FWXFilial("SB0")+ cCodProd)  // sem segmento
		nLucro := SB0->B0_YLUCRO
	END IF
	// If cPilotOK =='S' 		
	//     Return ('S')
	// EndIf

Return (nLucro) 

User Function tabYprc(nPreco,cCodProd)

	/* BUSCAR 	ZZZ_prv1,2,3  OU B0_prv1,2,3
	===========================================================================
	FUNÇAO, Utilizada nos gatilhos nos campos do produtos de cada tabela
	===========================================================================
	REGRA
	Se segmento está ativo MV_YZZZATI = .T. buscar conteúdo do ZZZ_YLUCRO para ; SEGMENTO+CODIGO DE PRODUTO, 
	retornar VALOR ZZZ_YLUCRO

	Se segmento não está ativo MV_YZZZATI = .F., buscar o conteúdo do B0_Yprv1,2,3, para FILIAL+COD DE PRODUTO, 
	retornar nro do prv
	ZZZ_PRV1, ZZZ_PRV2, ZZZ_PRV3, ZZZ_PRV4, ZZZ_PRV5, ZZZ_PRV6, ZZZ_PRV7, ZZZ_PRV8, ZZZ_PRV9
	B0_PRV1, B0_PRV2, B0_PRV3, B0_PRV4, B0_PRV5, B0_PRV6, B0_PRV7, B0_PRV8, B0_PRV9
	*/ 

	Local lZZZAtivo	:= SuperGetMV("MV_YZZZATI",.F.,.F.)
	Local cSegmento	:= U_SegmEmpresa()
	Local cTabela := .F.
	Local cColuna :=''
	//local nPreco :=0

	IF lZZZAtivo 
		DbSelectArea("ZZZ")
		DbSetOrder(1) // ZZZ_FILIAL+ZZZ_COD+ZZZ_SEGMEN)     
		cTabela := DBSeek(FWXFilial("ZZZ")+ cCodProd + cSegmento)
		//nLucro := ZZZ->ZZZ_YLUCRO
		DO CASE
			CASE nPreco == ZZZ->ZZZ_PRV1
			cColuna :='1'
			CASE nPreco == ZZZ->ZZZ_PRV2
			cColuna :='2'
			CASE nPreco == ZZZ->ZZZ_PRV3
			cColuna :='3'
			CASE nPreco == ZZZ->ZZZ_PRV4
			cColuna :='4'
			CASE nPreco == ZZZ->ZZZ_PRV5
			cColuna :='5'
			CASE nPreco == ZZZ->ZZZ_PRV6
			cColuna :='6'
			CASE nPreco == ZZZ->ZZZ_PRV7
			cColuna :='7'
			CASE nPreco == ZZZ->ZZZ_PRV8
			cColuna :='8'
			CASE nPreco == ZZZ->ZZZ_PRV9
			cColuna :='9'
			OTHERWISE
			cColuna :=''
		ENDCASE      
	ELSE  
		// busca na SB0 
		DbSelectArea("SB0")
		DbSetOrder(1)			
		cTabela:= DBSeek(FWXFilial("SB0")+ cCodProd)  // sem segmento
		// nLucro := SB0->B0_YLUCRO
		DO CASE
			CASE nPreco == SB0->B0_PRV1
			cColuna :='1'
			CASE nPreco == SB0->B0_PRV2
			cColuna :='2'
			CASE nPreco == SB0->B0_PRV3
			cColuna :='3'
			CASE nPreco == SB0->B0_PRV4
			cColuna :='4'
			CASE nPreco == SB0->B0_PRV5
			cColuna :='5'
			CASE nPreco == SB0->B0_PRV6
			cColuna :='6'
			CASE nPreco == SB0->B0_PRV7
			cColuna :='7'
			CASE nPreco == SB0->B0_PRV8
			cColuna :='8'
			CASE nPreco == SB0->B0_PRV9
			cColuna :='9'
			OTHERWISE
			cColuna :=''
		ENDCASE     

	END IF
	// If cPilotOK =='S' 		
	//     Return ('S')
	// EndIf

Return (cColuna) 

/* VALIDA SE USR LOGADO PODE ALTERAR os campos:
B0_YPILOT e ZZZ_YPILOT 
De acordo ao parametro MV_USRPIL, onde pode ter mais de um usr, separado por ";"
SuperGetmv("MV_USRPIL",, "")
*/
User Function VAL_PIL(cPil)

	Local cMsg  := ''
	Local cUsrsP := Upper(SuperGetmv("MV_USRPIL",, ""))
	Local cCodUser := RetCodUsr()  // cod do usr logado
	Local cNuser := Upper(UsrRetName(RetCodUsr())) // nome do usuario logado

	// alert("segmento " + U_SegmEmpresa())

	// IF !(Alltrim(cUsrsP) $ cCodUser)
	IF !(cCodUser $ cUsrsP) .AND. alltrim(cPil) <>''
		//alert("Usr não permitido alterar Piloto : Cod: " + cCodUser + " Nom Usr " + cNuser + " MV_USRPIL : "  + cUsrsP )
		alert("Usr não permitido alterar Piloto > " + cNuser )
		return .f.
	End If
Return (.T.)


/* 

*/
User Function YB1_CUSTD(cCodProd)
	// 2018NOV22 ALFONSO ; PROJETO: INCLU, CAMPOS
	/* BUSCAR SB1->B1_CUSTD, PARA_YCUSTO */ 
	Local aArea := SB1->(GetArea())
	local nCstd :=0

	DbSelectArea("SB1")
	DbSetOrder(1) // B1_FILIAL+B1_COD)     

	If DBSeek(FWXFilial("SB1")+ cCodProd)
		nCstd := SB1->B1_CUSTD
	endif

	RestArea(aArea)   

Return (nCstd)

User Function YB2_CM1(cCodProd)
	// 2018NOV22 ALFONSO ; PROJETO: INCLU, CAMPOS
	/* BUSCAR SB2->B2_CM1, PARA_YCMV */ 
	Local aArea := SB2->(GetArea())
	local nCmv :=0
	Local cArmz := "01"
	DbSelectArea("SB2")
	DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL)     
	if DBSeek(FWXFilial("SB2")+ cCodProd+cArmz)
		nCmv := SB2->B2_CM1
	endif

	RestArea(aArea)

Return (nCmv) 
