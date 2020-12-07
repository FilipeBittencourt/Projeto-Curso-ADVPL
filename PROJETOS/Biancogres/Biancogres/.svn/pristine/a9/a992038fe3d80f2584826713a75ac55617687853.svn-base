#include "rwMake.ch"
#include "Topconn.ch"
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FA330FLT   ³ Autor ³ Nilton                ³ Data ³ 25/11/04 ³±±
±±³          ³            ³ Alter ³ Ranisses A. Corona    ³ Data ³ 29/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³*Filtrar titulos na tela Compensacao CR                       ³±±
±±³          ³*Filtrar apenas Titulos de Contrato                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Financeiro                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FA330FLT()

//Exibe Pergunta
Pergunte("FA330F", .T.)  

//Apos a migracao para versao MP10, desativamos o filtro de E1_PREFIXO <> RA. O 

If MV_PAR01 == 2
	//Filtro titulos com Forma de Pagamento = CT
	dbSelectArea("SE1")
	Set filter to SE1->E1_YFORMA == "4"
//	Set filter to !SE1->E1_PREFIXO == "RA" .And. SE1->E1_YFORMA == "4"
//Else
//	Filtro titulos com Prefixo <> RA
//	dbSelectArea("SE1")
//	Set filter to !SE1->E1_PREFIXO == "RA"
EndIf

Return