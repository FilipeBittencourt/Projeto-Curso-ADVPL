#Include "Protheus.CH"
#Include "TOPCONN.CH"

User Function BAP001()
   
    Local oObj            := Nil
    Local cEmp            := '01'
    Local cFil            := '01'
   
    Local aListEmp        := {{'01', '01'}, {'01', '02'}}
    Local nI            := 0
   
    For nI=1 To Len(aListEmp)
   
        cEmp := aListEmp[nI][1]
        cFil := aListEmp[nI][2]
       
        RPCSetEnv(cEmp, cFil)
       
            oObj    := TAutomacaoBIZAGIPedidoVenda():New(cEmp, cFil)
            oObj:Processa()
       
        RpcClearEnv()   
       
    Next nI
       
Return()
