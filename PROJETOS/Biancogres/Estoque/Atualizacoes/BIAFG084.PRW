#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG084
@author Gabriel Rossi Mafioletti
@since 29/04/2019
@version 1.0
@description Cadastro de Motivos de Não Separação
@type function
/*/

User Function BIAFG084()

	Local aArea     := GetArea()
	Private cCadastro := "CADASTRO DE MOTIVO DE NAO SEPARACAO"  
		
	
	private aRotina := {	{"Pesquisa"  			,"AxPesqui" ,0,1},;
							{"Visualizar"			,"AxVisual"	,0,2},;
							{"Incluir"   			,"AxInclui"	,0,3},;
							{"Alterar"   			,"AxAltera"	,0,4},;
							{"Excluir"   			,"AxDeleta"	,0,5}}
									
	DbSelectArea("ZD9")
	DbSetOrder(1)                                    
	mBrowse(6,1,22,75,"ZD9")   
	
	RestArea(aArea)

return()