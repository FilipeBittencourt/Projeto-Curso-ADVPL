#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} BIAFM021
@author Marcelo Sousa Correa
@since 19/06/19
@version 1.0
@description Funcao para preencher dados de Multiplos Vinculos 
@type function
/*/
User Function BIAFM021()
	
	//Declaração de Variáveis
	cMat := SRA->RA_MAT
	
	//Posicionamento de Tabelas 
	// RAZ - Detalhes Multiplos Vínculos
	DbSelectArea("RAZ")
	RAZ->(DbSetOrder(1))
	
	// RAW - Cabeçalho Multiplos Vinculos 
	DbSelectArea("RAW")
	RAW->(DbSetOrder(1))

	// RG1 - Lançamentos Fixos do funcionário	
	DbSelectArea("RG1")
	RG1->(DbSetOrder(1))
	RG1->(DbGoTop())
	RG1->(DbSeek(xFilial()+cMat))
	
	//While para tratar funcionários
	While !RG1->(Eof()) .AND. RG1->RG1_MAT == cMat 
	
		// Acerta lançamentos já sem funcionamento
		If !EMPTY(RG1->RG1_DFIMPG) .AND. RG1->RG1_DFIMPG < dDatabase .AND. RG1->RG1_MAT == cMat
			
			RecLock("RG1",.F.)
			
				RG1->RG1_STATUS := '2'
			
			MsUnlock()
			
		// Insere RAZ e RAW
		Elseif RG1->RG1_MAT == cMat .AND. !RAZ->(DbSeek(xFilial()+cMat+SRC->RC_PERIODO)) .AND. RG1->RG1_PD == '867'
			
			RecLock("RAZ",.T.)
			
				RAZ->RAZ_FILIAL := xFilial()
				RAZ->RAZ_MAT := cMat
				RAZ->RAZ_FOLMES := SRC->RC_PERIODO
				RAZ->RAZ_TPFOL := "2"
				RAZ->RAZ_INSCR := RG1->RG1_YINSCR
				RAZ->RAZ_TPINS := "1"
				RAZ->RAZ_VALOR := RG1->RG1_VALOR
				RAZ->RAZ_CATEG := SRA->RA_CATEFD
						
			MsUnlock()
			
			RecLock("RAW",.T.)
			
				RAW->RAW_FILIAL := xFilial() 
				RAW->RAW_MAT := cMat
				RAW->RAW_FOLMES := SRC->RC_PERIODO
				RAW->RAW_TPFOL := "2"
				RAW->RAW_PROCES := SRA->RA_PROCES
				RAW->RAW_ROTEIR := SRC->RC_ROTEIR
				RAW->RAW_SEMANA := SRC->RC_SEMANA
				RAW->RAW_TPREC  := RG1->RG1_YTPREC 
			
			MsUnlock()
		
		Endif
		
		RG1->(DbSkip())
	
	Enddo 

Return 