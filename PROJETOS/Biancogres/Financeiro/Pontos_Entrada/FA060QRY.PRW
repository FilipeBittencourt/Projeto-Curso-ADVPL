#include "rwmake.ch" 
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FA060QRY   ³ Autor ³ Ranisses A. Corona    ³ Data ³ 08/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Acrescenta filtro SQL na montagem do bordero.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FA060QRY() 
Local cSql := ""
Local oRecAnt := TRecebimentoAntecipado():New()
  
	//Carrega as perguntas ja respondidas no P.E. FA60FIL
	Pergunte("FA60FI", .F.)
	 
	cSql := " E1_CLIENTE IN ( "
	cSql += " SELECT A1_COD " 
	cSql += " FROM "+ RetSqlName("SA1")
	cSql += " WHERE A1_FILIAL = "+ ValToSQL(xFilial("SA1"))
	cSql += " AND A1_YFORMA <> '3' "

	//Parametro que define se o sistema ira filtrar por Banco
	If MV_PAR05 == 1
		cSql += " AND A1_BCO1 = "+ ValToSQL(CPORT060)	
	EndIf
	
	cSql += " AND D_E_L_E_T_ = '' ) "
	
	// Caso os dados do bordero não sejam validos, força a query a retornar nulo
	If !oRecAnt:ValidaBor(MV_PAR04, cPort060, ParamIxb[1], ParamIxb[2])
		cSql := " 0 = 1 "
	Endif

Return(cSql)