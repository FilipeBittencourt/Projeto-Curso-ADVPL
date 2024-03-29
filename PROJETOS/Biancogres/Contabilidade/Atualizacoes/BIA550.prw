#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

User Function BIA550()

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
Autor     := Marcos Alberto Soprani
Programa  := BIA550
Empresa   := Biancogres Cer鈓ica S/A
Data      := 22/06/15
Uso       := Cont醔il
Aplica玢o := Browser para cadastro de Percentuais de rateio UN
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

Private xTotVlr := 0
Private xLinhaL := ""
Private xTpLanc := ""
Private xDebito := ""
Private xCredit := ""
Private xClvlDB := ""
Private xClvlCR := ""
Private xCCD    := ""
Private xCCC    := ""

cCadastro := "Percentuais para Rateio UN"
aRotina   := { {"Pesquisar"       ,"AxPesqui"	                        ,0,1},;
{               "Visualizar"      ,"AxVisual"	                        ,0,2},;
{               "Incluir"         ,"AxInclui"	                        ,0,3},;
{               "Alterar"         ,"AxAltera"	                        ,0,4},;
{               "Excluir"         ,"AxDeleta"	                        ,0,5} }

dbSelectArea("Z59")
dbSetOrder(1)
dbGoTop()

Z59->(mBrowse(06,01,22,75,"Z59"))

dbSelectArea("Z59")

Return
