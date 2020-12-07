#include "rwmake.ch"
#include "TOPCONN.CH"

User Function BIA810()

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA810	  	³ Autor ³ Ranisses A. Corona    ³ Data ³ 18/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava a Comissao do Cliente Original.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Faturamento                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Private Enter	:= CHR(13) + CHR(10)
Private cSql	:= ""
Private lRet	:= M->C5_YCLIORI

/*
DESATIVADO EM 01/01/2012, pois a comissao passou a ser calculado na empresa LM

//Busca Vendedor - Comissao do Cliente C5_YCLIORI
cSql := ""
cSql += " SELECT A1_COD, A1_VEND, A1_YVENDI, A1_YVENDB2, A1_YVENDI2, A1_YVENDB3, A1_YVENDI3,	" + Enter
cSql += "		 A1_YTRTESP, A1_COMIS, A1_YCOMISI, A1_YCOMB2, A1_YCOMI2, A1_YCOMB3, A1_YCOMI3,  	" + Enter
cSql += "		 A1_YVENBE1, A1_YCOMBE1, A1_YVENBE2, A1_YCOMBE2, A1_YVENBE3, A1_YCOMBE3	" + Enter
If M->C5_YLINHA == "1" // Para Biancogres
	cSql += " FROM	SA1010	" + Enter
Else
	cSql += " FROM	SA1050	" + Enter
EndIf
cSql += " WHERE	A1_FILIAL	= '"+xFilial("SA1")+"'	AND	" + Enter
cSql += " 		A1_COD		= '"+M->C5_YCLIORI+"'	AND	" + Enter
cSql += " 		A1_LOJA		= '"+M->C5_YLOJORI+"'	AND	" + Enter
cSql += " 		D_E_L_E_T_	= ''						" + Enter
If chkfile("_RAC1")
	DbSelectArea("_RAC1")
	DbCloseArea()
EndIf
TCQUERY cSql NEW ALIAS "_RAC1"

//Busca Vendedor - Comissao do Cliente C5_CLIENTE
cSql := ""
cSql += " SELECT A1_COD, A1_VEND, A1_YVENDI, A1_YVENDB2, A1_YVENDI2, A1_YVENDB3, A1_YVENDI3,	" + Enter
cSql += "		 A1_YTRTESP, A1_COMIS, A1_YCOMISI, A1_YCOMB2, A1_YCOMI2, A1_YCOMB3, A1_YCOMI3,	" + Enter
cSql += "		 A1_YVENBE1, A1_YCOMBE1, A1_YVENBE2, A1_YCOMBE2, A1_YVENBE3, A1_YCOMBE3	" + Enter
If M->C5_YLINHA == "1" // Para Biancogres
	cSql += " FROM	SA1010	" + Enter
Else
	cSql += " FROM	SA1050	" + Enter
EndIf
cSql += " WHERE	A1_FILIAL	= '"+xFilial("SA1")+"'	AND	" + Enter
cSql += " 		A1_COD		= '"+M->C5_CLIENTE+"'	AND	" + Enter
cSql += " 		A1_LOJA		= '"+M->C5_LOJACLI+"'	AND	" + Enter
cSql += " 		D_E_L_E_T_	= ''						" + Enter
If chkfile("_RAC2")
	DbSelectArea("_RAC2")
	DbCloseArea()
EndIf
TCQUERY cSql NEW ALIAS "_RAC2"

If _RAC1->(EOF())
	Msgalert("Cliente não encontrado!")
	lRet	:=	""
Else
	If _RAC1->A1_YTRTESP == "1"
		IF M->C5_YLINHA == "1"
			M->C5_VEND1		:= _RAC1->A1_VEND
			M->C5_VEND2		:= _RAC1->A1_YVENDB2
			M->C5_VEND3		:= _RAC1->A1_YVENDB3
			
			nComis1			  := _RAC1->A1_COMIS
			nComis2			  := _RAC1->A1_YCOMB2
			nComis3			  := _RAC1->A1_YCOMB3
		ENDIF
		
		IF M->C5_YLINHA == "2"
			M->C5_VEND1		:= _RAC1->A1_YVENDI
			M->C5_VEND2		:= _RAC1->A1_YVENDI2
			M->C5_VEND3		:= _RAC1->A1_YVENDI3
			
			nComis1			  := _RAC1->A1_YCOMISI
			nComis2			  := _RAC1->A1_YCOMI2
			nComis3			  := _RAC1->A1_YCOMI3
		ENDIF
		
		IF M->C5_YLINHA == "3"
			M->C5_VEND1		:= _RAC1->A1_YVENBE1
			M->C5_VEND2		:= _RAC1->A1_YVENBE2
			M->C5_VEND3		:= _RAC1->A1_YVENBE3
			
			nComis1			  := _RAC1->A1_YCOMBE1
			nComis2			  := _RAC1->A1_YCOMBE1
			nComis3			  := _RAC1->A1_YCOMBE1
		ENDIF

		//PARA VENDAS DO FORMATO "BA" - ACERTA O % DE COMISSAO
		If (Funname() == "MATA416" .And. nProdLM == "BA") .Or. (Funname() == "MATA410" .And. Alltrim(M->C5_YSUBTP) == "I")
			M->C5_COMIS1	:= Iif(M->C5_YLINHA == "1",Round(nComis1 + ((nComis1 * 19.695)/100),2),Round(nComis1 + (nComis1 * 0),2) )
			M->C5_COMIS2	:= Iif(M->C5_YLINHA == "1",Round(nComis2 + ((nComis2 * 19.695)/100),2),Round(nComis2 + (nComis2 * 0),2) )
			M->C5_COMIS3	:= Iif(M->C5_YLINHA == "1",Round(nComis3 + ((nComis3 * 19.695)/100),2),Round(nComis3 + (nComis3 * 0),2) )
  	Else
			M->C5_COMIS1	:= Iif(M->C5_YLINHA == "1",Round(nComis1 + ((nComis1 * 23.0769)/100),2),Round(nComis1 + (nComis1 * 0.403),2) )
			M->C5_COMIS2	:= Iif(M->C5_YLINHA == "1",Round(nComis2 + ((nComis2 * 23.0769)/100),2),Round(nComis2 + (nComis2 * 0.403),2) )
			M->C5_COMIS3	:= Iif(M->C5_YLINHA == "1",Round(nComis3 + ((nComis3 * 23.0769)/100),2),Round(nComis3 + (nComis3 * 0.403),2) )
  	EndIf

	Else
		IF M->C5_YLINHA == "1"
			M->C5_VEND1		:= _RAC2->A1_VEND
			M->C5_VEND2		:= _RAC2->A1_YVENDB2
			M->C5_VEND3		:= _RAC2->A1_YVENDB3
			
			M->C5_COMIS1  := _RAC2->A1_COMIS
			M->C5_COMIS2  := _RAC2->A1_YCOMB2
			M->C5_COMIS3  := _RAC2->A1_YCOMB3
		ENDIF
		
		IF M->C5_YLINHA == "2"
			M->C5_VEND1		:= _RAC2->A1_YVENDI
			M->C5_VEND2		:= _RAC2->A1_YVENDI2
			M->C5_VEND3		:= _RAC2->A1_YVENDI3
			
			M->C5_COMIS1  := _RAC2->A1_YCOMISI
			M->C5_COMIS2  := _RAC2->A1_YCOMI2
			M->C5_COMIS3  := _RAC2->A1_YCOMI3
		ENDIF
		
		IF M->C5_YLINHA == "3"
			M->C5_VEND1		:= _RAC2->A1_YVENBE1
			M->C5_VEND2		:= _RAC2->A1_YVENBE2
			M->C5_VEND3		:= _RAC2->A1_YVENBE3
			
			M->C5_COMIS1  := _RAC2->A1_YCOMBE1
			M->C5_COMIS2  := _RAC2->A1_YCOMBE2
			M->C5_COMIS3  := _RAC2->A1_YCOMBE3
		ENDIF
	EndIf
EndIf

If chkfile("RAC1")
	DbSelectArea("RAC1")
	DbCloseArea()
EndIf

If chkfile("RAC2")
	DbSelectArea("RAC2")
	DbCloseArea()
EndIf

*/

Return(lRet)
