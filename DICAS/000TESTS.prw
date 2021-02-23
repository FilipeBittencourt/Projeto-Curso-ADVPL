#Include 'TOTVS.CH'
#Include 'RESTFUL.CH'
#INCLUDE "PROTHEUS.CH"
#include 'shell.ch'


#define CRLF Chr(13) + Chr(10)

//U_000TESTS
USer Function 000TESTS()



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



USer Function 001TESTS()
  Local cUrl := 'http://localhost/web/ckdoc.html&Fi'
  //Local cPage := 'consprod.php?cod='+cCodWeb
  ShellExecute('open',cUrl,"","",SW_NORMAL)
RETURN








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
