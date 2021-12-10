#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIAFS005
Gatilho executado pelo campo C5_YSEGFAB para tratativa do % Seguro Fábrica
@author  Emerson Salvador
@since   27/07/2021
@version 1.0
@type Function
/*/
//-------------------------------------------------------------------

User Function BIAFS005()

   if M->C5_YSEGFAB == 'S'
      FWMsgRun(, {|| M->C5_YSEGFAB := BIAFS00501() }, "AGUARDE!", "Processando a rotina... BIAFS005")
   EndIf

Return(M->C5_YSEGFAB)


Static Function BIAFS00501(param_name)

   Local aArea    := GetArea()
   Local aAreaZG8 := ZG8->(GetArea())

   M->C5_PSEGFAB := 0
   ZG8->(DbSetOrder(1))
   If ZG8->(DbSeek(xFilial('ZG8')+SA1->A1_EST))
      M->C5_PSEGFAB := ZG8->ZG8_PERC
      M->C5_VLRFRET := 0
   Else
      ApMsgAlert("% Seguro Fábrica não esta cadastrado para o UF: " + SA1->A1_EST + ". Cadastre % Seg.Fábrica para este UF em 'Cadastro UF x % Seguro Fábrica' !!!","BIAFS005")
      M->C5_YSEGFAB := "N"
   Endif

   RestArea(aAreaZG8)
   RestArea(aArea)

Return(M->C5_YSEGFAB)
