#include "rwmake.ch"

/*/{Protheus.doc} CADOPER
@author FERNANDO ROCHA
@since 04/08/10
@version 1.0
@description AXCADASTRO Cadastro de Permiss鮡s
@type function
/*/

User Function CADOPER()

	Local aArea     := GetArea()
	Private cCadastro := "Cadastro de Permiss鮡s"  
	Private _aButtons := {}

	aAdd(_aButtons,{"BMPGROUP"	,{|| U_SVITU003("ZZ0_ACESSO") }	,"Acessos"})

	private aRotina := {	{"Pesquisa"  			,"AxPesqui" ,0,1},;
	{                        "Visualizar"			,"AxVisual"	,0,2},;
	{                        "Incluir"   			,"U_ZZ0INC"	,0,3},;
	{                        "Alterar"   			,"U_ZZ0ALT"	,0,4},;
	{                        "Excluir"   			,"AxDeleta"	,0,5}}

	DbSelectArea("ZZ0")
	DbSetOrder(1)                                    
	mBrowse(6,1,22,75,"ZZ0")   

return

//苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
//北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
//FUNCAO DE ALTERAR CUSTOMIZADA
//北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
//哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
User Function ZZ0ALT 

	DbSelectArea("ZZ0")
	AXALTERA("ZZ0", ZZ0->(RecNo()), 4,,,,,,,,_aButtons)

Return    

User Function ZZ0INC()  

	DbSelectArea("ZZ0")
	AXINCLUI("ZZ0", ZZ0->(RecNo()), 3,,,,,,,_aButtons)

Return
