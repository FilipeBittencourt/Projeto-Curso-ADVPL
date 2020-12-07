#include "rwmake.ch"
#include "topconn.ch"

User Function F02001()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
	//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
	//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
	//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local wNum

	Private cArq	:= ""
	Private cInd	:= 0
	Private cReg	:= 0

	cArq := Alias()
	cInd := IndexOrd()
	cReg := Recno()

	/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³ F02001     ³ Autor ³                       ³ Data ³   /  /   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³                                                              ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Interpretador x Base                                         ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	wAlias		:= Alias()
	wPerc  		:= M->C5_YPERC
	wCliente	:= M->C5_CLIENTE
	wLoja		:= M->C5_LOJACLI

	//Localiza Cliente
	If Alltrim(M->C5_YLINHA) $ '1_5'
		cSql := "SELECT A1_COD, A1_YDESCLI FROM SA1010 WHERE	A1_COD = '"+M->C5_CLIENTE+"' AND A1_LOJA = '"+M->C5_LOJACLI+"' AND D_E_L_E_T_ = '' "
	Else
		cSql := "SELECT A1_COD, A1_YDESCLI FROM SA1050 WHERE	A1_COD = '"+M->C5_CLIENTE+"' AND A1_LOJA = '"+M->C5_LOJACLI+"' AND D_E_L_E_T_ = '' "
	EndIf
	If chkfile("_CLI")
		dbSelectArea("_CLI")
		dbCloseArea()
	EndIf
	TCQUERY cSql ALIAS "_CLI" NEW

	For wNum := 1 to Len(aCols)
		//Atualiza Politica 
		nPosPerc				:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_YPERC'})
		aCols[wNum,nPosPerc]	:= wPerc

		//Atualiza Correcao - busca do cadastro de cliente
		nPosDesc				:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_YDESC'})
		aCols[wNum,nPosDesc]	:= _CLI->A1_YDESCLI
	Next

	DbSelectArea(cArq)
	DbSetOrder(cInd)
	DbGoTo(cReg)

	dbSelectArea(wAlias)

Return(wPerc)