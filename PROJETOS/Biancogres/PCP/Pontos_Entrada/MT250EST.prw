#include "protheus.ch"
#include "topconn.ch"
#INCLUDE "SHELL.CH"
#include "Fileio.ch"
#include "tbiconn.ch"

User Function MT250EST()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := MT250EST
Empresa   := Biancogres Cerâmica S/A
Data      := 01/11/11
Uso       := PCP / Estoque Custos
Aplicação := Chamado apos confirmação de estorno de produções. Este ponto
.            de entrada permite validar algum campo especifico do usuario
.            antes de se realizar o Estorno.
.            A princípio ele sempre retornará .T., pois sua funcionalidade
.            inicial é efetuar o estorno da baixa de estoque intercompany
.            bem como a recupeção do empenho baixado na InterCompany.
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Local gg_Ret   := .T.
Local kk_EmprG := cEmpAnt
Local lvfArea  := GetArea()

//  Implementado em 20/02/13 por Marcos Alberto Soprani para auxilio do fechamento de estoque vs movimentações retroativas que poderiam
// acontecer pelo fato de o parâmtro MV_ULMES necessitar permanecer em aberto até que o fechamento de estoque esteja concluído
If SD3->D3_EMISSAO <= GetMv("MV_YULMES")
	MsgSTOP("Impossível prosseguir, pois este movimento interfere no fechamento de custo!!! Favor verificar com a contabilidade!!!","MT250EST")
	gg_Ret := .F.
EndIf

RestArea(lvfArea)

Return( gg_Ret )
