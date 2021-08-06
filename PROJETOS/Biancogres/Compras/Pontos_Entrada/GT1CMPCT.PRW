#include "totvs.ch"

/*/{Protheus.doc} GT1CMPCT
@author Marcos Alberto Soprani
@since 28/06/2021
@version 1.0
@description Ponto de entrada para criar campos específicos para preenchimento do usuário
@type class
/*/

User Function GT1CMPCT()

	Local aFields := {}

	// Retirar campos adicionais do vetor até segunda ordem, por está gerando problema de preenchimento - 27/07/21.
	// Assim que for resolvido o problema do Integrador, e o Felipe (Conexão Nfe) retornar de férias e Marcos Alberto também, podemos tratar esta funcionalidade.
	// A importância deste ponto de entrada está propciar ao usuário que passe para o sistema informações específicas para cada uma das nota que compeem o Cte.
	// A não utilização, faz com que para alguns casos seja necessário usar as rotinas padrões do sistema em detrimento ao uso do Conexão NFe 

	//    aAdd(aFields,{;
	//        {"Regra"       ,"DX_YREGRA" ,"@!",TamSx3("D1_YREGRA")[1] ,0,"",,"C","ZK" ,},; // {X3_TITULO,X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_F3,X3_CONTEXT}
	//        {"D1_YREGRA"/*Campo SD1*/};
	//    })
	//    aAdd(aFields,{;
	//        {"Classe Valor","DX_CLVL"   ,"@!",TamSx3("D1_CLVL")[1]   ,0,"",,"C","CTH",},; // {X3_TITULO,X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_F3,X3_CONTEXT}
	//        {"D1_CLVL"/*Campo SD1*/};
	//    })
	//    aAdd(aFields,{;
	//        {"Contrato"    ,"DX_YCONTR" ,"@!",TamSx3("D1_YCONTR")[1] ,0,"",,"C",""   ,},; // {X3_TITULO,X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_F3,X3_CONTEXT}
	//        {"D1_YCONTR"/*Campo SD1*/};
	//    })
	//    aAdd(aFields,{;
	//        {"Subitem Proj","DX_YSUBITE","@!",TamSx3("D1_YSUBITE")[1],0,"",,"C","CTH",},; // {X3_TITULO,X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_F3,X3_CONTEXT}
	//        {"D1_YSUBITE"/*Campo SD1*/};
	//    })
	//    aAdd(aFields,{;
	//        {"Item Conta"  ,"DX_ITEMCTA","@!",TamSx3("D1_ITEMCTA")[1],0,"",,"C","CTD",},; // {X3_TITULO,X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_F3,X3_CONTEXT}
	//        {"D1_ITEMCTA"/*Campo SD1*/};
	//    })
	//    aAdd(aFields,{;
	//        {"C Contabil"  ,"DX_CONTA"  ,"@!",TamSx3("D1_CONTA")[1]  ,0,"",,"C","CT1",},; // {X3_TITULO,X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_F3,X3_CONTEXT}
	//        {"D1_CONTA"/*Campo SD1*/};
	//    })

Return aFields
