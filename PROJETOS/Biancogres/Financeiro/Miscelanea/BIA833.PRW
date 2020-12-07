#include "rwmake.ch"
#include "topconn.ch"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BIA833    º Autor ³ Ranisses A. Corona º Data ³  23/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo do Banco - CNAB A Pagar Bradesco [096 a 098]        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Financeiro                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BIA833()
	Local nBanco := ""

	If SEA->EA_MODELO $ "01_03_08"		//CREDITO EM CONTA / DOC / TED
	
		nBanco := StrZero(Val(SA2->A2_BANCO),3)
		
	ElseIf SEA->EA_MODELO == "31"			//PAGAMENTO DE TITULOS MESMO BANCO / PAGAMENTO DE TITULOS OUTROS BANCOS
	
		If !Empty(Substr(SE2->E2_CODBAR,1,3))
		
			nBanco	:=	Substr(SE2->E2_CODBAR,1,3)

		ElseIf !Empty(Substr(SE2->E2_LINDIG,1,3))
		
			nBanco	:=	Substr(SE2->E2_LINDIG,1,3)
					
		ElseIf !Empty(Substr(SE2->E2_YLINDIG,1,3))
		
			nBanco	:=	Substr(SE2->E2_YLINDIG,1,3)
			
		Else
			
			/*
		MSGBOX("ATENCAO, TITULO: "+SE2->E2_PREFIXO+"-"+SE2->E2_NUM+"-"+SE2->E2_PARCELA+CHR(13)+CHR(10)+;
		"NAO POSSUI CÓDIGO DE BARRAS OU LINHA DIGITÁVEL INFORMADOS","VERIFICAR ERRO","STOP")
			*/
			
			Help(NIL, NIL, "Codigo de barras obrigatorio", NIL,;
				"ATENCAO, TITULO: "+SE2->E2_PREFIXO+"-"+SE2->E2_NUM+"-"+SE2->E2_PARCELA+CHR(13)+CHR(10)+;
				"NAO POSSUI CÓDIGO DE BARRAS OU LINHA DIGITÁVEL INFORMADOS", 1, 0, NIL, NIL, NIL, NIL, NIL,;
				{"Verifique o modelo e tipo de pagamento, pois esperam titulos com codigo de barras"})
							
		EndIf
		
	Else
		
		//MsgBox("Modalidade de Pagamento não é valida para Operações no Banco Bradesco.","ATENÇÃO","STOP")
		
		Help(NIL, NIL, "Modalidade invalida", NIL,;
			"Modalidade de Pagamento não é valida para Operações no Banco Bradesco. O arquivo será gerado com ERRO!", 1, 0, NIL, NIL, NIL, NIL, NIL,;
			{"Verifique a modalidade " + SEA->EA_MODELO})
	
	EndIf

Return(nBanco)