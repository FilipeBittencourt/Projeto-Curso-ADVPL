#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} TINCliente
@description Classe para busca e tratamento das regras da entidade CLIENTE
@author Fernando Rocha / Filipe Vieira
@since 03/12/2018
@version 1.0
/*/

#define RISCO_A "A"
#define RISCO_B "B"
#define RISCO_C "C"
#define RISCO_D "D"
#define RISCO_E "E"

Class TINEliminaResiduoPVController From LongClassName

    Data cNumPedido
	Method New() Constructor
	Method ElimiResid(cNumPedido) 

EndClass

Method New() Class TINEliminaResiduoPVController

	::cNumPedido := ""

Return  Self
 

Method ElimiResid(cNumPedido) Class TINEliminaResiduoPVController

	Local cPedido := ALLTRIM(cNumPedido)
	local cFilSC5 := xFilial("SC5") 
	local cFilSC6 := xFilial("SC6") 
	Local aArea		:= GetArea()
	Local aAreaSC5	:= SC5->(GetArea())
	Local aAreaSC6	:= SC6->(GetArea())

    if SC5->( dbSeek( cFilSC5 + cPedido ) ) 
       
        SC6->( dbGoTop() ) 
		SC6->(dbSetOrder(1))
        SC6->( dbSeek( cFilSC6 + cPedido ) ) 
        while !SC6->(EOF()) .AND. SC6->C6_FILIAL == cFilSC6 .AND. SC6->C6_NUM == cPedido
			// estornar
			MaAvalSC6("SC6",4,"SC5",Nil,Nil,Nil,Nil,Nil,Nil) 
			MaResDoFat() 
			SC6->( dbSkip() ) 
        enddo 
		SC6->(MaLiberOk({cPedido},.T.)) 
    endif 
	
	RestArea(aAreaSC6)
	RestArea(aAreaSC5)
	RestArea(aArea)
	
return 