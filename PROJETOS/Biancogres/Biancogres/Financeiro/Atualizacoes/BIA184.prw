#INCLUDE "PROTHEUS.CH"

/*
##############################################################################################################
# PROGRAMA...: BIA184         
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 01/11/2013                      
# DESCRICAO..: Aprovacao dos titulos a Pagar
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/
User Function BIA184()    

Local cAlias := "SE2"
Local aCores := {}
Local cFiltra := "SE2->E2_MSBLQL == '1' .AND. SE2->E2_FILIAL == '"+xFilial('SE2')+"'"

Private cCadastro := "Efetivacao de Titulos a Pagar"
Private aRotina := {}  

//+-----------------------------------------
// opções de filtro utilizando a FilBrowse
//+-----------------------------------------
Private aIndexSE2 := {}
Private bFiltraBrw:= { || FilBrowse(cAlias,@aIndexSE2,@cFiltra) }
//+-----------------------------------------

AADD(aRotina,{"Pesquisar" 	,"PesqBrw" 			,0,1})
AADD(aRotina,{"Visualizar" 	,"Fa050Visua"		,0,2})
AADD(aRotina,{"Efetivar" 	,"u_BIA184INC"		,0,3})  
AADD(aRotina,{"Excluir" 	,"u_BIA184EXC"		,0,4})
AADD(aRotina,{"Legenda" 	,"u_BIA184LEG"		,0,5}) 
//+-----------------------------------------
                                                        
aCores := {{"E2_MSBLQL =='1'" ,'BR_VERMELHO'}}

dbSelectArea(cAlias)
(cAlias)->(dbSetOrder(1))

//+-----------------------------------------
Eval(bFiltraBrw)
dbSelectArea(cAlias)
dbGoTop()
//+-----------------------------------------
mBrowse(6, 1, 22, 105, cAlias, , , , , 2, aCores)
//+-----------------------------------------
EndFilBrw(cAlias,aIndexSE2)
//+-----------------------------------------   
//RestArea(aArea)
DbCloseArea("SE2")
Return Nil  


/*
##############################################################################################################
# PROGRAMA...: BIA184INC         
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 01/11/2013                      
# DESCRICAO..: Aprovacao dos titulos a Pagar
##############################################################################################################
*/
User Function BIA184INC()

	Reclock("SE2",.F.)
	SE2->E2_MSBLQL := "2"
	SE2->(MsUnlock())
	
	MsgInfo("Titulo Efetivado!")

Return

/*
##############################################################################################################
# PROGRAMA...: BIA184EXC         
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 01/11/2013                      
# DESCRICAO..: Estorno dos titulos a Pagar, caso nao sejam aprovados
##############################################################################################################
*/
User Function BIA184EXC()

	Reclock("SE2",.F.)
	SE2->(DbDelete())
	SE2->(MsUnlock())
	
	MsgInfo("Titulo Excluido!")

Return


//**********************LEGENDA******************************
User Function BIA184LEG()

	BrwLegenda(cCadastro, "Legenda", {{"BR_VERMELHO", "Aguardando Efetivacao"}})

Return
