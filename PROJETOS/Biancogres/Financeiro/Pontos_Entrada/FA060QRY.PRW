#include "rwmake.ch" 
/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � FA060QRY   � Autor � Ranisses A. Corona    � Data � 08/08/11 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Acrescenta filtro SQL na montagem do bordero.                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � SIGAFIN                                                      潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
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
	
	// Caso os dados do bordero n鉶 sejam validos, for鏰 a query a retornar nulo
	If !oRecAnt:ValidaBor(MV_PAR04, cPort060, ParamIxb[1], ParamIxb[2])
		cSql := " 0 = 1 "
	Endif

Return(cSql)