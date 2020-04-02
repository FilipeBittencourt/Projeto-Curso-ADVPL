#ifdef SPANISH
	#define STR0001 "Informe de Propuestas Comerciales"
	#define STR0002 "Propuestas Comerciales"
	#define STR0003 "Ente"
	#define STR0004 "Codigo"
	#define STR0005 "Descripcion"
	#define STR0006 "Propuestas"
	#define STR0007 "CLIENTE"
	#define STR0008 "PROSPECT"
	#define STR0009 "Items de la Propuesta"
	#define STR0010 "Producto"
	#define STR0011 "Accesorio"
	#define STR0012 "Cant. Items"
	#define STR0013 "Total"
	#define STR0014 "Total de la Propuesta"
	#define STR0015 "¡Atención!"
	#define STR0016 "¡Informe no compatible con DBF! "
	#define STR0017 "¡OK!"
#else
	#ifdef ENGLISH
		#define STR0001 "Commercial Proposals Report"
		#define STR0002 "Commercial Proposals"
		#define STR0003 "Entity"
		#define STR0004 "Code"
		#define STR0005 "Description"
		#define STR0006 "Proposals"
		#define STR0007 "CUSTOMER"
		#define STR0008 "PROSPECT"
		#define STR0009 "Proposal Items"
		#define STR0010 "Product"
		#define STR0011 "Accessory"
		#define STR0012 "Amt. Items"
		#define STR0013 "Total"
		#define STR0014 "Proposal  total"
		#define STR0015 "Attention!"
		#define STR0016 "Report is not compatible with DBF! "
		#define STR0017 "OK!"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Relatório de Propostas Comerciais", "Relatorio de Propostas Comerciais" )
		#define STR0002 "Propostas Comerciais"
		#define STR0003 "Entidade"
		#define STR0004 "Código"
		#define STR0005 "Descrição"
		#define STR0006 "Propostas"
		#define STR0007 "CLIENTE"
		#define STR0008 "PROSPECT"
		#define STR0009 "Itens da Proposta"
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Artigo", "Produto" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Acessório", "Acessorio" )
		#define STR0012 "Qtd. Itens"
		#define STR0013 "Total"
		#define STR0014 "Total da Proposta"
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Atenção!", "Atenção !" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Relatório não compatível com DBF. ", "Relatorio não compativel com DBF! " )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "OK", "OK!" )
	#endif
#endif
