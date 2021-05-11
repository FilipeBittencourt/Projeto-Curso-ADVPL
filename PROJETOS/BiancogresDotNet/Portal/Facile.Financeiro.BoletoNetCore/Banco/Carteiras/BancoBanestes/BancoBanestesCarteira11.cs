using System;
using Facile.Financeiro.BoletoNetCore.Extensions;
using static System.String;

namespace Facile.Financeiro.BoletoNetCore
{
    [CarteiraCodigo("11")]
    internal class BancoBanestesCarteira11 : ICarteira<BancoBanestes>
    {
        internal static Lazy<ICarteira<BancoBanestes>> Instance { get; } = new Lazy<ICarteira<BancoBanestes>>(() => new BancoBanestesCarteira11());

        private BancoBanestesCarteira11()
        {

        }

        public void FormataNossoNumero(Boleto boleto)
        {
            // Nosso número não pode ter mais de 11 dígitos
            
            if (IsNullOrWhiteSpace(boleto.NossoNumero) || boleto.NossoNumero == "00000000")
            {
                // Banco irá gerar Nosso Número
                boleto.NossoNumero = new String('0', 8);
                boleto.NossoNumeroDV = "00";
                boleto.NossoNumeroFormatado = "00000000-00";
            }
            else
            {
                // Nosso Número informado pela empresa
                if (boleto.NossoNumero.Trim().Length > 10)
                    throw new Exception($"Nosso Número ({boleto.NossoNumero.Trim()}) deve conter 10 dígitos.");
                
                boleto.NossoNumero = boleto.NossoNumero.Substring(0, 8).PadLeft(8, '0');
                var p1 = (boleto.NossoNumero.Trim()).CalcularDVBanestes();
                var p2 = (boleto.NossoNumero.Trim() + p1).CalcularDVBanestes();


                boleto.NossoNumeroDV = p1+p2;
                boleto.NossoNumeroFormatado = $"{boleto.NossoNumero.Trim()}-{boleto.NossoNumeroDV.Trim()}";
            }
        }

        public string FormataCodigoBarraCampoLivre(Boleto boleto)
        {
            var contaBancaria = boleto.Banco.Cedente.ContaBancaria;
            // return $"{contaBancaria.Agencia.Trim()}{boleto.Carteira.Trim()}{boleto.NossoNumero.Trim()}{contaBancaria.Conta.Trim()}{"0"}";
            var texto = $"{boleto.NossoNumero.Substring(0, 8).Trim()}{contaBancaria.Conta.Trim()}4021";
            var p1 = texto.CalcularDV1ASBACE();
            var calcP2 = (texto + p1).CheckCalcularDV2ASBACE();
            if (!calcP2.Equals(""))
            {
                p1 = calcP2;
            }
            var p2 = (texto + p1).CalcularDV2ASBACE();
            return texto+p1+p2;
        }
    }
}
