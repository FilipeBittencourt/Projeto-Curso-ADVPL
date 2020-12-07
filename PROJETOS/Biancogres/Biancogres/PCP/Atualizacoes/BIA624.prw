#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

User Function BIA624()

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
Autor     := Marcos Alberto Soprani
Programa  := BIA624
Empresa   := Biancogres Cer鈓ica S/A
Data      := 28/03/16
Uso       := PCP
Aplica玢o := Cadastro de Escala para Equipes Operacionais
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

dbSelectArea("Z73")
dbGoTop()

n := 1
cCadastro := " ....: Cadastro de Escala para Equipes :.... "

aRotina   := {  {"Pesquisar"   ,'AxPesqui'                             ,0, 1},;
{                "Visualizar"  ,'AxVisual'                             ,0, 2},;
{                "Incluir"     ,'AxInclui'                             ,0, 3},;
{                "Alterar"     ,'AxAltera'                             ,0, 4},;
{                "Excluir"     ,'AxDeleta'                             ,0, 5} }

mBrowse(6,1,22,75, "Z73", , , , , ,)

Return
