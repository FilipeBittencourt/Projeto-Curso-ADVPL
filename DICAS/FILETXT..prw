#Include 'TOTVS.CH'
#Include 'RESTFUL.CH'
#INCLUDE "PROTHEUS.CH"
#define CRLF Chr(13) + Chr(10) 

//U_FILETXT
USer Function FILETXT()    
 
 
  Local cLocal     := LOWER(SuperGetMV("ZZ_DIRDANF",.F.,"C:\temp\")) 
  FERASE(cLocal+cNomeArq+".pdf")
  Local cCodUser :=  RetCodUsr()
  Local cNomUser :=  UsrRetName(cCodUser)
  Local cUsers   :=  "filipe;pontin"// SuperGetMv("MV_YUPQSAT",.F.,"")

  If Select("SX6") <= 0	
    RPCSetEnv("99", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})	
  EndIf	

 If LOWER(cNomUser) $ LOWER(cUsers)  /* YSTAZAP */
  alert("O "+cNomUser+" est� contido em:"+cUsers+"")
 EndIf
  

Return .T.






            //int[] vet = new int[10] {2,1,8,7,6,4,5,9,-1,3};


            //for (Int32 i = 0; i < vet.Length; i++)
            //{
            //    int m = i;
            //    for (Int32 k = i; k < vet.Length; k++)
            //    {
            //        if (vet[k] < vet[m])
            //        {
            //            m = k;
            //        }
            //    }

            //    int aux = vet[m];
            //    vet[m] = vet[i];
            //    vet[i] = aux;
            //}


            //for (Int32 i = 0; i < vet.Length; i++)
            //{                 
            //    for (Int32 k = i+1; k < vet.Length; k++)
            //    {
            //        if (vet[k] < vet[i])
            //        {
            //            int aux = vet[i];
            //            vet[i] = vet[k];
            //            vet[k] = aux;
            //        }
            //    }
            //}
