#include "rwmake.ch"   
#include "topconn.ch"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ FA280GRV   ³ Autor ³ Ranisses A. Corona    ³ Data ³ 25/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se o valor do Titulo FT confere com o somatorio     ³±±
±±³          ³ dos Titulos de NF																						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Financeiro                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FA280GRV()
//BUSCA O VALOR DA FATURA
A0001 := " SELECT SUM(E1_VALOR) AS E1_VALOR 		"
A0001 += " FROM "+RetSqlName("SE1")+" SE1 			"
A0001 += " WHERE E1_FILIAL  = '"+xFilial("SE1")+"' "
A0001 += " AND   E1_PREFIXO	= '"+SE1->E1_PREFIXO+"'	"     
A0001 += " AND   E1_NUM			= '"+SE1->E1_NUM+"' 	"   			
A0001 += " AND   E1_CLIENTE	= '"+SE1->E1_CLIENTE+"'	"   			
A0001 += " AND   E1_LOJA		= '"+SE1->E1_LOJA+"'	"
A0001 += " AND   E1_TIPO    = 'FT' "   			
A0001 += " AND   D_E_L_E_T_ = '' "
If chkfile("A001")
	dbSelectArea("A001")
	dbCloseArea()
EndIf
TcQuery A0001 New Alias "A001"

//BUSCA O VALOR DOS TITULOS QUE GERARAM A FATURA
//A0002 := " SELECT SUM(VALOR) E5_VALOR					"
//A0002 += " FROM 										"
//A0002 += " (SELECT E5_NUMERO, AVG(E5_VALOR) VALOR		"
//A0002 += " FROM "+RetSqlName("SE5")+" SE5				"
//A0002 += " WHERE E5_FILIAL	= '"+xFilial("SE5")+"'	"
//A0002 += " AND E5_CLIFOR 		= '"+SE1->E1_CLIENTE+"'	"	   			
//A0002 += " AND E5_LOJA 			= '"+SE1->E1_LOJA+"' "   			
//A0002 += " AND E5_HISTOR 		= 'Bx.Emis.Fat."+Alltrim(SE1->E1_NUM)+"' "
//A0002 += " AND D_E_L_E_T_ 	= ''									"
//A0002 += " GROUP BY E5_NUMERO) TMP									"

A0002 := " SELECT SUM(E5_VALOR) E5_VALOR "
A0002 += " FROM "+RetSqlName("SE5")+" SE5			"
A0002 += " WHERE E5_FILIAL	= '"+xFilial("SE5")+"'	"
A0002 += " AND E5_CLIFOR 		= '"+SE1->E1_CLIENTE+"'	"	   			
A0002 += " AND E5_LOJA 			= '"+SE1->E1_LOJA+"'		"   			
A0002 += " AND E5_HISTOR 		= 'Bx.Emis.Fat."+Alltrim(SE1->E1_NUM)+"' "
A0002 += " AND D_E_L_E_T_ 	= ''										"
If chkfile("A002")
	dbSelectArea("A002")
	dbCloseArea()
EndIf
TcQuery A0002 New Alias "A002"

IF A001->E1_VALOR <> A002->E5_VALOR
	MsgBox("O valor da Fatura "+SE1->E1_NUM+" não confere com a soma dos valores dos titulos NF!","FA280GRV","STOP")  
ENDIF


If chkfile("A001")
	dbSelectArea("A001")
	dbCloseArea()
EndIf

If chkfile("A001")
	dbSelectArea("A001")
	dbCloseArea()
EndIf

Return()