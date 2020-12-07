#include "rwmake.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATA040   ºAutor  ³Ranisses A. Corona  º Data ³  06/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ao Cadastrar um novo Representante, este tambem sera        º±±
±±º          ³cadastrado na tabela SB1 para ser utilizado na Regra Desc.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Faturamento                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MATA040()

If (Inclui .Or. Altera) .And. Substr(M->A3_COD,1,1) == "0"
	DbSelectArea("SB1")
	DbSetOrder(1)
	If !DbSeek(xFilial("SB1")+"R"+Substr(M->A3_COD,2,5),.F.)
		RecLock("SB1",.T.)
		SB1->B1_FILIAL	:= xFilial("SB1")
		SB1->B1_COD			:= "R"+Substr(M->A3_COD,2,5)
		SB1->B1_DESC		:= "REPRESENTANTE "+M->A3_NOME
		SB1->B1_GRUPO		:= "PA"
		SB1->B1_TIPO		:= "PA"
		SB1->B1_YTIPO		:= "P"
		SB1->B1_UM			:= "M2"
		SB1->B1_SEGUM		:= "CX"
		SB1->B1_CONV		:= 1
		SB1->B1_TIPCONV		:= "D"
		SB1->B1_LOCPAD		:= "02"
		SB1->B1_POSIPI		:= "69089000"
		SB1->B1_YPECA		:= 1
		SB1->B1_YDIVPA		:= 1
		SB1->B1_YPOLIT		:= "0"
		SB1->B1_TIPODEC		:= "N"
		SB1->B1_CONTA		:= "11306001"
		SB1->B1_DATREF		:= dDataBase
		SB1->B1_UREV		:= dDataBase
		SB1->B1_CLASFIS		:= "A"
		SB1->B1_ORIGEM		:= "0"
		SB1->B1_RASTRO		:= "L"
		SB1->B1_MRP			:= "S"
		SB1->B1_CONTRAT		:= "N"
		SB1->B1_ANUENTE		:= "2"
		SB1->B1_IMPORT		:= "N"
		SB1->B1_TIPOCQ		:= "M"
		SB1->B1_OPAUTOM		:= "N"
		SB1->B1_INSS		:= "N"
		SB1->B1_SOLICIT		:= "N"
		SB1->B1_ENVOBR		:= "0"
		SB1->B1_FLAGSUG		:= "1"
		SB1->B1_MCUSTD		:= "1"
		SB1->B1_MIDIA		:= "2"
		SB1->B1_PIS			:= "2"
		SB1->B1_COFINS		:= "2"
		SB1->B1_CSLL		:= "2"
		SB1->B1_ATIVO		:= "S"
		SB1->B1_CPOTENC		:= "2"
		SB1->B1_RETOPER		:= "2"
		SB1->B1_MSBLQL		:= "2"
		SB1->B1_AGREGCU		:= "2"
		SB1->B1_USAFEFO		:= "1"
		SB1->B1_GRTRIB		:= "001"
		SB1->B1_CODBAR		:= "R"+Substr(M->A3_COD,2,5)
		SB1->B1_LOCALIZ		:= "S"
		//SB1->B1_YCNV52		:= "N"
		//SB1->B1_YMONO		:= "R"+Substr(M->A3_COD,2,5)
		SB1->B1_YTEMPPC		:= "PA"
		SB1->B1_YUSER		:= cUserName
		SB1->B1_YBLSCPC		:= "2"
		//SB1->B1_YPACOTE		:= "1"
		//SB1->B1_YPCGMR2		:= "1"
		SB1->B1_YPCGMR3		:= "1"
		
		MsUnlock()
		DbCommitAll()
	EndIf
	
EndIf

// Incluido por Marcos Alberto Soprani em atendimento a Implemantação do Provisionamento na Contabilização da Comissão - 27/12/12
If (Inclui .Or. Altera) .And. Substr(M->A3_COD,1,1) <> "A"
	dbSelectArea("CTD")
	dbSetOrder(1)
	If !dbSeek(xFilial("CTD")+"COM"+M->A3_COD)
		RecLock("CTD",.T.)
		CTD->CTD_FILIAL := xFilial("CTD")
		CTD->CTD_ITEM   := "COM"+M->A3_COD
		CTD->CTD_CLASSE := "2"
		CTD->CTD_DESC01 := M->A3_NOME
		CTD->CTD_BLOQ   := "2"
		CTD->CTD_DTEXIS := dDataBase-1
		CTD->CTD_ITSUP  := "COM"
		CTD->CTD_NORMAL := "1"
		CTD->CTD_CLOBRG := "1"
		CTD->CTD_ACCLVL := "1"
		MsUnlock()
		dbCommitAll()
	EndIf
EndIf

Return
