#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

User Function BIA624()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA624
Empresa   := Biancogres Cerâmica S/A
Data      := 28/03/16
Uso       := PCP
Aplicação := Cadastro de Escala para Equipes Operacionais
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

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
